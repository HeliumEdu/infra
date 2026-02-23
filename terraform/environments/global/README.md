## The `global` Workspace

This workspace sets up services that apply across all staging and production environments, for instance monitoring.

- [DataDog](https://www.datadoghq.com/) - (optional, infrastructure monitoring)

### Initializing a Terraform Workspace

This workspace should be initialized alongside (at least) a `prod`-like workspace. See [the README for under `prod`](https://github.com/HeliumEdu/infra/tree/main/terraform/environments/prod#readme) for instructions on setting up Terraform environments.

The following Terraform Workspace variables must be defined:

  - `DD_API_KEY` (the DataDog API key, leave blank to disable)
  - `DD_APP_KEY` (the DataDog Application key with permissions for Dashboards and Monitors, leave blank if disabled)