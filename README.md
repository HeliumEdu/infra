# Deploy Environment

This repository contains everything that is necessary to get a development environment setup on a local machine in
minimal time and to deploy code to other environments.

## Prerequisites

* A permissioned SSH key at ~/.ssh/id_rsa
* Python (>= 3.5)
* Pip (>= 9.0)
* VirtualBox (>= 5.1)
* Vagrant (>= 2.0)

## Getting Started

### Vagrant Development
Here is a minimal set of commands that will get a Vagrant, which most closely emulates a prod-like environment,
development environment up and running:

```
git clone git@github.com:HeliumEdu/deploy.git ~/Developer/helium
cd ~/Developer/helium
make install
```

Done! For convenience, [helium-cli](https://github.com/HeliumEdu/heliumcli#readme), which is compatible with this
project and provides a useful set of tools for maintaining, building, and deploying the code, has also been installed.

All projects should now be accessible via https://heliumedu.test. The `platform` project, which powers the backend and
API endpoints as well as the /admin area, lives at https://api.heliumedu.test. When changes are made to deployment
scripts (project's contain environmental changes, for instances new migrations), you should use the command below to
ensure the `devbox` is working with the latest environment.

```
helium-cli deploy-build master devbox
```

The shell into the VM, execute:

```
vagrant ssh
```

To power down the VM, execute:

```
vagrant halt
```

To see how the Vagrant environment is provisioned and configured, including how environment variables are set within
the box, have a look in the `ansible` folder, especially `ansible/group_vars/devbox.yml`. Note that when values in
`group_vars` are changed, the Vagrant box would need to be reprovisioned with the following:

`helium-cli deploy-build master devbox --envvars`

Python projects are run from within their virtualenvs. To run the `python manage.py createsuperuser` command then,
for example, in `/srv/helium/platform`, you need to first activate the virtualenv for the platform. You can do this by
execute like `source $PLATFORM_VENV/bin/activate`.

### Local Development
Each project also comes with its own development server for rapid development and testing. Using these development
servers can be a simple way to get started with minimal effort. All you need is to have the `ENVIRONMENT` environment
variable set to "dev", then execute:

```
helium-cli start-servers
```

This single command will launch any necessary services for each project to run in the current environment. See the
"Local Development" section of READMEs for more details on what that means to each project.

## Offline Development

To develop fully offline (after the initial provision), the following should be set to `False`:

* PROJECT_DISABLE_EMAILS

If using Vagrant, this would be in the `ansible/group_vars/devbox.yml` file (and `--envvars` would need to be
reprovisioned). If developing locally, this would need to be set in the `.env` file.

## Security Note

In any non-dev environment, the `project_serve_local` and `PROJECT_SERVE_LOCAL` variables should be _removed_, and
`PLATFORM_AWS_S3_ACCESS_KEY_ID` and `PLATFORM_AWS_S3_SECRET_ACCESS_KEY` _must be set_. Doing this will cause the
platform to rely on S3 to serve up static content and media files reliably and securely. See the [AWS Setup](
https://github.com/HeliumEdu/deploy/wiki/External-Services#using-s3)
guide for instructions on how to do this.

## Documentation

Auto-generated API documentation is accessible via any environment at /docs. Additional documentation for development,
deployment, setting up environments, and more can be found on the [Deploy Wiki](https://github.com/HeliumEdu/deploy/wiki).
