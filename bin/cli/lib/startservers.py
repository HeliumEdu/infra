import subprocess

import os

from . import utils

__author__ = 'Alex Laird'
__copyright__ = 'Copyright 2018, Helium Edu'
__version__ = '1.0.4'

child_processes = []


class StartServersAction:
    def __init__(self):
        self.name = "start-servers"
        self.help = "Launch servers to run Helium locally"

    def setup(self, subparsers):
        parser = subparsers.add_parser(self.name, help=self.help)
        parser.set_defaults(action=self)

    def run(self, args):
        root_dir = utils.get_root_dir()

        subprocess.call(["make", "install", "-C", os.path.join(root_dir, "projects", "platform")])
        subprocess.call(["make", "install", "-C", os.path.join(root_dir, "projects", "frontend")])
        subprocess.Popen(os.path.join(root_dir, "projects", "platform", ".venv", "bin", "python") + " " +
                         os.path.join(root_dir, "projects", "platform", "manage.py") + " runserver",
                         shell=True)
        subprocess.Popen("npm run start --prefix " + os.path.join(root_dir, "projects", "frontend"),
                         shell=True).wait()
