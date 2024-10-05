<p align="center"><img src="https://www.heliumedu.com/assets/img/logo_full_blue.png" /></p>

![Python Versions](https://img.shields.io/badge/python-%203.10%20|%203.11%20-blue)
[![Build](https://img.shields.io/github/actions/workflow/status/HeliumEdu/deploy/build.yml)](https://github.com/HeliumEdu/deploy/actions/workflows/build.yml)
![GitHub License](https://img.shields.io/github/license/heliumedu/deploy)

# Deploy Environment

This repository contains everything that is necessary to get a development environment setup on a local machine in
minimal time and to deploy code to other environments using [Docker](https://docs.docker.com/).

## Prerequisites

- Docker

## Development
### Docker Setup

Here is a minimal set of commands that will get a Docker environment setup locally.

```sh
git clone https://github.com/HeliumEdu/deploy.git ~/Developer/helium
cd ~/Developer/helium
make
```

Done! Now that your environment has been initialized, to quickly bring up Docker in the future, simply run `make start`.

## Deployment

When a tag is pushed to this repository, a release is cut, and container images published to
[AWS ECR](https://aws.amazon.com/ecr/). To deploy this new release, bump the Image URI in [the Terraform for each AWS ECS Task Definition](https://github.com/HeliumEdu/deploy/blob/main/terraform/modules/ecs/main.tf).
Pushing this change trigger the fleet to roll to this release when the Terraform is applied.