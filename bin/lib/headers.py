import datetime
import os
import shutil

import git

from . import utils

__author__ = 'Alex Laird'
__copyright__ = 'Copyright 2018, Helium Edu'
__version__ = '1.0.0'


class UpdateHeadersAction:
    def __init__(self):
        self.name = "headers"
        self.help = "Update projects' header information"

    def setup(self, subparsers):
        parser = subparsers.add_parser(self.name, help=self.help)
        parser.set_defaults(action=self)

    def run(self, args):
        root_dir = utils.get_root_dir()

        project_name = utils.get_project_name()

        projects_dir = os.path.join(root_dir, "projects")

        current_version = None
        settings_file = open(os.path.join(projects_dir, "platform", "conf", "configs/common.py"))
        for line in settings_file:
            if line.startswith("__version__ = "):
                current_version = line.strip().split("__version__ = '")[1].rstrip("'")
        current_year = str(datetime.date.today().year)

        if not current_version:
            print("An error exists in platform/conf/common.py, as no PROJECT_VERSION was found.")

            return

        for project in utils.get_projects():
            project_dir = os.path.join(projects_dir, project)

            repo = git.cmd.Git(project_dir)
            repo.fetch(tags=True, prune=True)
            repo = git.Repo(project_dir)

            versions_list = repo.tags
            versions_list.sort(key=lambda v: list(map(int, v.tag.tag.lstrip("v").split("."))))

            if len(versions_list) == 0:
                print("No tags have been created yet.")

                return

            latest_tag = versions_list[-1]
            changes = latest_tag.commit.diff(None)

            print("Checking the " + str(len(changes)) + ' file(s) in "' +
                  project + '" that have been modified since ' + latest_tag.tag.tag + " was tagged ...")
            print("-------------------------------")

            count = 0
            for change in changes:
                file_path = os.path.join(project_dir, change.b_rawpath.decode("utf-8"))

                if os.path.exists(file_path) and not os.path.isdir(file_path):
                    change = open(file_path, "r")
                    new_file = open(file_path + ".tmp", "w")

                    updated = False
                    for line in change:
                        if utils.update(line, "__version__ = '" + current_version + "'", "__version__ = "):
                            print("Updating " + file_path)

                            line = "__version__ = '" + current_version + "'\n"

                            updated = True
                            count += 1
                        elif utils.update(line, "* @version " + current_version, "* @version "):
                            print("Updating " + file_path)

                            line = " * @version " + current_version + "\n"

                            updated = True
                            count += 1

                        if utils.update(line, "__copyright__ = 'Copyright " + current_year + ", {}'".format(
                                project_name),
                                        "__copyright__ = ", "{}.".format(project_name)):
                            print("Updating " + file_path)

                            line = "__copyright__ = 'Copyright " + current_year + ", {}'\n".format(project_name)

                            updated = True
                            count += 1
                        elif utils.update(line, "* Copyright (c) " + current_year + " {}.".format(project_name),
                                          "* Copyright (c) ",
                                          "{}.".format(project_name)):
                            print("Updating " + file_path)

                            line = " * Copyright (c) " + current_year + " {}.\n".format(project_name)

                            updated = True
                            count += 1

                        new_file.write(line)

                    change.close()
                    new_file.close()

                    if updated:
                        shutil.copy(file_path + ".tmp", file_path)
                    os.remove(file_path + ".tmp")

            print("-------------------------------")
            print("Updated " + str(count) + " version number(s).")
            print("")
