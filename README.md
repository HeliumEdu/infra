# Deploy Environment

This repository contains everything that is necessary to get a development environment setup on a local machine in
minimal time and to deploy code to other environments.

## Prerequisites

Before you can initialize the project and all dependencies, ensure you have the following prerequisites:

* HTTP access to Git server
* SSH key with access to Git server, stored locally at ~/.ssh/id_rsa
* Python (>= 2.7)
* Pip (>= 9.0)
* Git (>= 1.7)
* VirtualBox (>= 5.1)
* Vagrant (>= 1.9)
* Ansible (>= 2.2)

## Getting Started

Here is a minimal set of commands that will get a local development environment up and running:

```
git clone git@github.com:HeliumEdu/deploy.git ~/Developer/helium
cd ~/Developer/helium
make install
```

Done!

All projects should now be accessible via https://heliumedu.dev, and API documentation can now also be viewed at
https://heliumedu.dev/docs. When changes are made to deployment scripts (project's contain environmental changes, for instances
new migrations), you should use the command below to ensure the `devbox` is working with the latest environment.

```
bin/helium-cli deploy master devbox
```

The shell into the VM, execute:

```
vagrant ssh
```

To power down the VM, execute:

```
vagrant halt
```

## Offline Development

To develop using Vagrant fully offline (after the initial provision), the following should be set to `False`:

* PROJECT_DISABLE_EMAILS

For the changes to take within the box, execute:

`bin/helium-cli deploy master devbox --envvars`

## Security Note

In any non-dev environment, the `project_serve_local` and `PROJECT_SERVE_LOCAL` variables should be _removed_, and
`PLATFORM_AWS_S3_ACCESS_KEY_ID` and `PLATFORM_AWS_S3_SECRET_ACCESS_KEY` _must be set_. Doing this will cause the
platform to rely on S3 to serve up static content and media files reliably and securely. See the [AWS Setup](https://github.com/HeliumEdu/deploy/wiki/AWS-Setup) guide for instructions on how to do this.

## Documentation

Additional documentation for development, deployment, setting up environments, and more can be found on the [Deploy Wiki](https://github.com/HeliumEdu/deploy/wiki).
