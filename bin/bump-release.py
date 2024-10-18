#!/usr/bin/env python

__copyright__ = "Copyright (c) 2018 Helium Edu"
__license__ = "MIT"

import os
import re
import sys

from git import Repo
from heliumcli import utils
from heliumcli.actions.buildrelease import BuildReleaseAction
from heliumcli.utils import get_config

BASE_DIR = os.path.normpath(os.path.join(os.path.abspath(os.path.dirname(__file__)), '..'))

VERSION = os.environ.get("VERSION")

if not VERSION:
    print("VERSION env var must be set")
    sys.exit(1)

FILE_PATH = os.path.join(BASE_DIR, "terraform", "environments", "prod", "variables.tf")
VERSION_VARIABLE_PATTERN = """variable "helium_version" {{
  description = "The container version. Bumping this will trigger a deploy."
  default     = "{version}"
}}"""
VERSION_VARIABLE_REGEX = VERSION_VARIABLE_PATTERN.format(version="(\\d+.\\d+.\\d+)")

with open(FILE_PATH, "r") as fp:
    file_contents = fp.read()

updated = False

match = re.match(VERSION_VARIABLE_REGEX, file_contents)
if match:
    result = re.sub(VERSION_VARIABLE_REGEX, VERSION_VARIABLE_PATTERN.format(version=VERSION), file_contents)

    if file_contents != result:
        with open(FILE_PATH, "w") as fp:
            fp.write(result)

        updated = True
else:
    print("variables.tf does not appear to be in the expected format. Ensure the \"helium_version\" variable is "
          "defined, with a default, and is the first declaration in the file.")
    sys.exit(1)

repo = Repo(BASE_DIR)
if repo.is_dirty():
    config = get_config()

    build_release_action = BuildReleaseAction()
    print(utils.get_repo_name(BASE_DIR, config["remoteName"]))
    build_release_action._commit_and_tag(BASE_DIR, VERSION, config["remoteName"], config["branchName"])
else:
    print("No changes detected, nothing to commit")
