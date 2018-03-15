import os

import yaml
from configparser import ConfigParser

__author__ = 'Alex Laird'
__copyright__ = 'Copyright 2018, Helium Edu'
__version__ = '1.0.4'

VERSION = __version__


def get_title():
    return """\
    __         ___                            ___
   / /_  ___  / (_)_  ______ ___        _____/ (_)
  / __ \/ _ \/ / / / / / __ `__ \______/ ___/ / /
 / / / /  __/ / / /_/ / / / / / /_____/ /__/ / /
/_/ /_/\___/_/_/\__,_/_/ /_/ /_/      \___/_/_/
                                              v{}
""".format(VERSION)


def get_root_dir():
    return os.path.abspath(os.path.join(os.path.dirname(os.path.realpath(__file__)), "..", "..", ".."))


def parse_hosts_file(env):
    config = ConfigParser()
    config.read('ansible/hosts')

    hosts = []
    for section in config.sections():
        if section.startswith(env):
            for item, section_vars in config.items(section):
                host = item.split(' ')[0]
                section_vars = '{}={}'.format(item.split(' ')[1], section_vars)

                user = 'ubuntu'
                for var in section_vars.split(' '):
                    split = var.split('=')
                    if split[0] == 'ansible_user':
                        user = split[1]
                hosts.append([user, host])

    return hosts


def should_updated(line, verification, start_needle, end_needle=""):
    needs_update = False

    if line.strip().startswith(start_needle) and line.strip().endswith(end_needle):
        if line.strip() != verification:
            needs_update = True

    return needs_update


def get_project_name():
    with open(os.path.join(get_root_dir(), "ansible", "group_vars", "all.yml"), 'r') as stream:
        data = yaml.load(stream)
        return data["project_developer"]


def get_projects():
    return [
        "platform",
        "frontend",
    ]
