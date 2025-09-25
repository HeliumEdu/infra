<p align="center"><img src="https://www.heliumedu.com/assets/img/logo_full_blue.png" /></p>

![Python Versions](https://img.shields.io/badge/python-%203.12%20-blue)
[![Build](https://img.shields.io/github/actions/workflow/status/HeliumEdu/deploy/build.yml)](https://github.com/HeliumEdu/deploy/actions/workflows/build.yml)
![GitHub License](https://img.shields.io/github/license/heliumedu/deploy)

# Helium Infrastructure

The deployment infastructure for [Helium Edu](https://www.heliumedu.com/).

Released container images are published to [Helium's AWS ECR](https://gallery.ecr.aws/heliumedu/).

## Prerequisites

- Docker
- Python (>= 3.12)
- Terraform (>= 1.9)
- See [Deployment](#deployment) for others

## Getting Started

This repository contains everything that is necessary for deployment and local development, including setting up a
local machine to use [Docker](https://docs.docker.com/), and the [Terraform](https://app.terraform.io/app) necessary to
provision environments.

## Development

### Initialize `dev-local` Environment in Terraform

For more information on setting up a minimal (but fully functional) `dev-local` environment, see
[the `dev-local` Terraform Workspace](https://github.com/HeliumEdu/deploy/tree/main/terraform/environments/dev-local#readme).
This is not necessary to develop locally with Docker, but certain features (like emails and text messages)
will not be available without this.

### Docker Setup

Here is a minimal set of commands that will get a Docker environment setup locally.

```sh
git clone https://github.com/HeliumEdu/deploy.git helium
cd helium
make
```

Done! The [`frontend`](https://github.com/HeliumEdu/frontend), [`platform`](https://github.com/HeliumEdu/platform), and
[`cluster-tests`](https://github.com/HeliumEdu/cluster-tests) are now setup for you.

If `dev-local` was not provisioned, you'll want to set `PROJECT_DISABLE_EMAILS=True` and `PROJECT_DISABLE_TEXTS=True`
in [`platforms'`s `.env` file](https://github.com/HeliumEdu/platform/blob/main/.env.docker.example) (and restart Docker
with `make restart`). Helium is now accessible at http://localhost:3000, and you should be able to register for an
account. Or have a look at [the `platform`'s README](https://github.com/HeliumEdu/platform?tab=readme-ov-file#docker-setup)
for steps to create a superuser with access to [the admin site](http://localhost:8000/admin).

In the future, this local Docker environment can quickly be brought up again simply by running:

```
make start
```

#### Image Architecture

By default, deployable Docker images will be built for `linux/arm64`. To build native images on an `x86` architecture
instead, set `PLATFORM=amd64`.

## Deployment

Use [the Release action](https://github.com/HeliumEdu/deploy/actions/workflows/release.yml) to cut a release and publish container images to
[AWS ECR](https://aws.amazon.com/ecr/). If a [Terraform Workspace](https://developer.hashicorp.com/terraform/cli/workspaces) has been provisioned
and [hooks to this repo are setup](https://developer.hashicorp.com/terraform/cloud-docs/vcs), then bumping the
[Image URI version variable in Terraform](https://github.com/HeliumEdu/deploy/blob/main/terraform/environments/prod/variables.tf#L1) will trigger a new deployment to this version when the Terraform applies.

### Initialize `prod`-like Environment in Terraform

For more information on deploying a hosted, fully functional `prod`-like environment, see
[the `prod` Terraform Workspace](https://github.com/HeliumEdu/deploy/tree/main/terraform/environments/prod#readme).
