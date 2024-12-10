#!/usr/bin/env python

__copyright__ = "Copyright (c) 2018 Helium Edu"
__license__ = "MIT"

import json
import os
import re
import sys
import time
from urllib import request
from urllib.request import urlopen

from git import Repo
from heliumcli import utils
from heliumcli.actions.buildrelease import BuildReleaseAction
from heliumcli.utils import get_config

BASE_DIR = os.path.normpath(os.path.join(os.path.abspath(os.path.dirname(__file__)), '..'))

VERSION = os.environ.get("VERSION")
ENVIRONMENT = os.environ.get("ENVIRONMENT")
TERRAFORM_API_TOKEN = os.environ.get("TERRAFORM_API_TOKEN")

if not VERSION or not ENVIRONMENT or not TERRAFORM_API_TOKEN:
    print("ERROR: Set all required env vars: VERSION, ENVIRONMENT, TERRAFORM_API_TOKEN.")
    sys.exit(1)

INFO_URI = "https://{}.heliumedu.com/info".format("api" if ENVIRONMENT == "prod" else f"api.{ENVIRONMENT}")

FILE_PATH = os.path.join(BASE_DIR, "terraform", "environments", ENVIRONMENT, "variables.tf")
VERSION_VARIABLE_PATTERN = """variable "helium_version" {{
  description = "The container version. Bumping this will trigger a deploy."
  default     = "{version}"
}}"""
VERSION_VARIABLE_REGEX = VERSION_VARIABLE_PATTERN.format(version="(\\d+.\\d+.\\d+)")

#####################################################################
# Bump release version and commit to prep for release deployment
#####################################################################

with open(FILE_PATH, "r") as fp:
    file_contents = fp.read()

match = re.match(VERSION_VARIABLE_REGEX, file_contents)
if match:
    result = re.sub(VERSION_VARIABLE_REGEX, VERSION_VARIABLE_PATTERN.format(version=VERSION), file_contents)

    if file_contents != result:
        with open(FILE_PATH, "w") as fp:
            fp.write(result)
else:
    print("ERROR: variables.tf does not appear to be in the expected format. Ensure the \"helium_version\" variable is "
          "defined, with a default, and is the first declaration in the file.")
    sys.exit(1)

repo = Repo(BASE_DIR)
if not repo.is_dirty():
    print("ERROR: No changes detected, nothing to commit, Terraform won't trigger the release.")
    sys.exit(1)

config = get_config()

build_release_action = BuildReleaseAction()
print("Committing changes and creating release tag ...")
print(utils.get_repo_name(BASE_DIR, config["remoteName"]))
build_release_action._commit_and_tag(BASE_DIR, VERSION, config["remoteName"], config["branchName"])

print(f"... release version {VERSION} committed.")

#####################################################################
# Fetch Terraform Workspace details
#####################################################################

req = request.Request(f"https://app.terraform.io/api/v2/organizations/HeliumEdu/workspaces/{ENVIRONMENT}",
                      headers={"Authorization": f"Bearer {TERRAFORM_API_TOKEN}",
                               "Content-Type": "application/vnd.api+json"})
workspaces_response = json.loads(urlopen(req).read())

#####################################################################
# Find planned [heliumcli] Terraform run, discard other pending
#####################################################################

heliumcli_run = None
retries = 0
retry_sleep_seconds = 10
wait_minutes = 3
while retries < ((wait_minutes * 60) / retry_sleep_seconds):
    req = request.Request(f"https://app.terraform.io/api/v2/workspaces/{workspaces_response['data']['id']}/runs",
                          headers={"Authorization": f"Bearer {TERRAFORM_API_TOKEN}",
                                   "Content-Type": "application/vnd.api+json"})
    runs_response = json.loads(urlopen(req).read())

    for run in runs_response["data"]:
        # Discard all planned or pending plans that are not what was just triggered by [heliumcli]
        if run["attributes"]["status"] in ["planned", "pending"] and not run["attributes"]["message"].startswith(
                "[heliumcli]"):
            reject_endpoint = "cancel" if run["attributes"]["actions"]["is-cancelable"] else "discard"
            req = request.Request(f"https://app.terraform.io/api/v2/runs/{run['id']}/actions/{reject_endpoint}",
                                  headers={"Authorization": f"Bearer {TERRAFORM_API_TOKEN}",
                                           "Content-Type": "application/vnd.api+json"},
                                  data=json.dumps(
                                      {"comment": "Discarding plan in favor of official release plan"}).encode())
            json.loads(urlopen(req).read())
        # Continue to wait until the [heliumcli] plan is in the correct state
        elif run["attributes"]["status"] == "planned" and run["attributes"]["message"].startswith("[heliumcli]"):
            print(f"... found planned [heliumcli] run with ID {run['id']}.")
            heliumcli_run = run
            break

    if heliumcli_run:
        break
    else:
        retries += 1
        print("Waiting for Terraform ...")
        time.sleep(retry_sleep_seconds)

if not heliumcli_run:
    print("ERROR: [heliumcli] plan was never found in Terraform.")
    sys.exit(1)

#####################################################################
# Trigger Terraform plan-and-apply for release
#####################################################################

print(f"Triggering Terraform apply on run ID {heliumcli_run['id']} in {ENVIRONMENT} ...")
req = request.Request(f"https://app.terraform.io/api/v2/runs/{heliumcli_run['id']}/actions/apply",
                      headers={"Authorization": f"Bearer {TERRAFORM_API_TOKEN}",
                               "Content-Type": "application/vnd.api+json"},
                      data=json.dumps({"data":
                          {"attributes": {
                              "message": f"[GitHub Actions] Release {VERSION}",
                              "allow-empty-apply": "true",
                              "auto-apply": "false"
                          }, "relationships": {
                              "workspace": {
                                  "data": {
                                      "id": workspaces_response["data"]["id"],
                                      "type": "workspaces"
                                  }
                              }
                          }}}).encode())
resp = urlopen(req)

#####################################################################
# Wait for the Terraform apply to be live
#####################################################################

version_is_live = False
retries = 0
retry_sleep_seconds = 20
wait_minutes = 10
while retries < ((wait_minutes * 60) / retry_sleep_seconds):
    result = json.load(urlopen(INFO_URI))
    if result["version"] == VERSION:
        version_is_live = True
        break
    else:
        retries += 1
        print(f"Waiting for {ENVIRONMENT} to report version {VERSION} ...")
        time.sleep(retry_sleep_seconds)

if version_is_live:
    print(f"... {VERSION} is now live in {ENVIRONMENT}.")
else:
    print(
        f"ERROR: {ENVIRONMENT} has not updated its version number to {VERSION} within {wait_minutes} minutes, "
        "check if deploy failed.")
    sys.exit(1)
