## The `global` Workspace

This workspace sets up resources that have no environment counterpart - either shared across all environments (monitoring, notifications) or singular in nature (the marketing site).

- [DataDog](https://www.datadoghq.com/) - infrastructure monitoring (optional)
- HCP Terraform run-failure notifications across `prod`, `dev`, and `dev-local`
- Marketing site (`landing.heliumedu.com`) - S3, CloudFront, ACM, Route 53. Source: [HeliumEdu/www](https://github.com/HeliumEdu/www)

### Initializing a Terraform Workspace

This workspace should be initialized alongside (at least) a `prod`-like workspace. See [the README under `prod`](https://github.com/HeliumEdu/infra/tree/main/terraform/environments/prod#readme) for instructions on setting up Terraform environments.

The following Terraform Workspace variables must be defined:

  - `AWS_ACCOUNT_ID`
  - `DD_API_KEY` (the DataDog API key, leave blank to disable)
  - `DD_APP_KEY` (the DataDog Application key with permissions for Dashboards and Monitors, leave blank if disabled)
  - `TERRAFORM_API_TOKEN` (team-level, needs permissions to approve runs)
