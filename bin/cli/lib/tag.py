import os

import git

from . import utils

__author__ = 'Alex Laird'
__copyright__ = 'Copyright 2018, Helium Edu'
__version__ = '1.0.4'


class TagAction:
    def __init__(self):
        self.name = "tag"
        self.help = "Tag a new version for all projects"

    def setup(self, subparsers):
        parser = subparsers.add_parser(self.name, help=self.help)
        parser.add_argument("version", help="The version number to be tagged")
        parser.set_defaults(action=self)

    def run(self, args):
        tag = args.version.lstrip("v")

        root_dir = utils.get_root_dir()

        projects_dir = os.path.join(root_dir, "projects")

        repo = git.Repo(root_dir)

        print(os.path.basename(root_dir))
        if tag not in repo.tags:
            print(repo.create_tag(tag, m=""))
        else:
            print("Already tagged.")
        repo.remotes["origin"].push(tags=True)
        print("")

        for project in utils.get_projects():
            print(project)

            repo = git.Repo(os.path.join(projects_dir, project))

            if tag not in repo.tags:
                print(repo.create_tag(tag, m=""))
            else:
                print("Already tagged.")
            repo.remotes["origin"].push(tags=True)
            print("")
