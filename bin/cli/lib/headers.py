import datetime
import os
import shutil

import git

from . import utils

__author__ = 'Alex Laird'
__copyright__ = 'Copyright 2018, Helium Edu'
__version__ = '1.0.4'


class HeadersAction:
    def __init__(self):
        self.name = "headers"
        self.help = "Update projects' header information"

        self.__project_name = utils.get_project_name()
        self.__current_year = str(datetime.date.today().year)
        self.__current_version = None

    def setup(self, subparsers):
        parser = subparsers.add_parser(self.name, help=self.help)
        parser.set_defaults(action=self)

    def run(self, args):
        root_dir = utils.get_root_dir()

        projects_dir = os.path.join(root_dir, "projects")

        settings_file = open(os.path.join(projects_dir, "platform", "conf", "configs", "common.py"))
        for line in settings_file:
            if line.startswith("__version__ = "):
                self.__current_version = line.strip().split("__version__ = '")[1].rstrip("'")

        if not self.__current_version:
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

                if os.path.exists(file_path) and not os.path.isdir(file_path) and \
                                os.path.splitext(file_path)[1] in [".py", ".js", ".jsx", ".css", ".scss"]:
                    count = self.__process_file(count, file_path)

            print("-------------------------------")
            print("Updated " + str(count) + " version and copyright header(s).")
            print("")

        self.__process_file(0, os.path.join(projects_dir, "frontend", "package.json"))

    def __process_file(self, count, file_path):
        change = open(file_path, "r")
        new_file = open(file_path + ".tmp", "w")

        updated = False
        for line in change:
            if file_path.endswith(".py"):
                line, count, updated = self.__process_python_line(count, updated, file_path, line)
            elif file_path.endswith(".js") or file_path.endswith(".jsx") or \
                    file_path.endswith(".css") or file_path.endswith(".scss"):
                line, count, updated = self.__process_js_or_css_line(count, updated, file_path, line)
            elif os.path.basename(file_path) == "package.json":
                line, count, updated = self.__process_package_json(count, updated, file_path, line)

            new_file.write(line)

        change.close()
        new_file.close()

        if updated:
            shutil.copy(file_path + ".tmp", file_path)
        os.remove(file_path + ".tmp")

        return count

    def __process_python_line(self, count, updated, file_path, line):
        if utils.should_updated(line, "__version__ = '{}'".format(self.__current_version), "__version__ ="):
            print("Updating " + file_path)

            line = "__version__ = '{}'\n".format(self.__current_version)
            count += 1
            updated = True
        elif utils.should_updated(line,
                                  "__copyright__ = 'Copyright {}, {}'".format(self.__current_year, self.__project_name),
                                  "__copyright__ = ", "{}'".format(self.__project_name)):
            print("Updating " + file_path)

            line = "__copyright__ = 'Copyright {}, {}'\n".format(self.__current_year, self.__project_name)
            count += 1
            updated = True

        return line, count, updated

    def __process_js_or_css_line(self, count, updated, file_path, line):
        if utils.should_updated(line, "* @version " + self.__current_version, "* @version"):
            print("Updating " + file_path)

            line = " * @version {}\n".format(self.__current_version)
            count += 1
            updated = True
        elif utils.should_updated(line, "* Copyright (c) {} {}.".format(self.__current_year, self.__project_name),
                                  "* Copyright (c)", "{}.".format(self.__project_name)):
            print("Updating " + file_path)

            line = " * Copyright (c) {} {}.\n".format(self.__current_year, self.__project_name)
            count += 1
            updated = True

        return line, count, updated

    def __process_package_json(self, count, updated, file_path, line):
        if utils.should_updated(line, "\"version\": \"{}\",".format(self.__current_version), "\"version\": \""):
            print("Updating version in " + file_path)

            line = "  \"version\": \"{}\",\n".format(self.__current_version)
            count += 1
            updated = True

        return line, count, updated
