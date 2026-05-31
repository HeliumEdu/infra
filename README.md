<p align="center">
  <img src="https://raw.githubusercontent.com/HeliumEdu/www/main/src/assets/img/helium-logo.png" alt="Helium" width="300" />
  <br />
  <img src="https://raw.githubusercontent.com/HeliumEdu/www/main/src/assets/img/og-default.png" alt="Helium - Student Planner" width="800" />
</p>

---

[**Helium**](https://www.heliumedu.com) is a free, color-coded online student planner for classes, homework, grades, and notes.

<p align="center">
  <a href="https://apps.apple.com/us/app/helium-student-planner/id6758323154"><img src="https://raw.githubusercontent.com/HeliumEdu/www/main/src/assets/img/ios-badge.png" alt="Download on the App Store" height="50" /></a>
  &nbsp;
  <a href="https://play.google.com/store/apps/details?id=com.heliumedu.heliumapp"><img src="https://raw.githubusercontent.com/HeliumEdu/www/main/src/assets/img/play-badge.png" alt="Get it on Google Play" height="50" /></a>
</p>

<p align="center">
  <a href="https://www.patreon.com/alexdlaird/membership"><img src="https://raw.githubusercontent.com/HeliumEdu/www/main/public/img/support-patreon.svg" alt="Support on Patreon" height="30" /></a>
</p>

---

# Helium Infrastructure

![Python Versions](https://img.shields.io/badge/python-%203.12%20-blue)
[![Build](https://img.shields.io/github/actions/workflow/status/HeliumEdu/infra/build.yml)](https://github.com/HeliumEdu/infra/actions/workflows/build.yml)
![GitHub License](https://img.shields.io/github/license/heliumedu/infra)

The deployment infrastructure for Helium - Student Planner, including Terraform, Docker orchestration for local development, and the build pipeline that publishes container images to [Helium's AWS ECR](https://gallery.ecr.aws/heliumedu/).

## Prerequisites

- Docker
- Python (>= 3.12)
- Terraform (>= 1.9)

## Getting Started

This repository contains everything that is necessary for deployment and local development, including setting up a
local machine to use [Docker](https://docs.docker.com/), and the [Terraform](https://app.terraform.io/app) necessary to
provision environments.

## Development

### Initialize `dev-local` Environment in Terraform

For more information on setting up a minimal (but fully functional) `dev-local` environment, see
[the `dev-local` Terraform Workspace](https://github.com/HeliumEdu/infra/tree/main/terraform/environments/dev-local#readme).
This is not necessary to develop locally with Docker, but certain features (like emails and text messages)
will not be available without this.

### Docker Setup

Here is a minimal set of commands that will get a Docker environment setup locally.

```sh
git clone https://github.com/HeliumEdu/infra.git helium
cd helium
make
```

Done! The [`frontend`](https://github.com/HeliumEdu/frontend) and [`platform`](https://github.com/HeliumEdu/platform)
are now setup for you.

If `dev-local` was not provisioned, you'll want to set `PROJECT_DISABLE_EMAILS=True` in [`platforms'`s `.env` file](https://github.com/HeliumEdu/platform/blob/main/.env.docker.example).
Helium is now accessible at http://localhost:8080, and you should be able to register for an account. Or have a look at
[the `platform`'s README](https://github.com/HeliumEdu/platform?tab=readme-ov-file#docker-setup)
for steps to create a superuser with access to [the admin site](http://localhost:8000/admin).

In the future, this local Docker environment can quickly be brought up again simply by running:

```
make start
```

#### Image Architecture

By default, deployable Docker images will be built for `linux/arm64`. To build native images on an `x86` architecture
instead, set `PLATFORM=amd64`.

### Initialize `prod`-like Environment in Terraform

For more information on deploying a hosted, fully functional `prod`-like environment, see
[the `prod` Terraform Workspace](https://github.com/HeliumEdu/infra/tree/main/terraform/environments/prod#readme).
