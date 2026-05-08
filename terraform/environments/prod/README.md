## Initializing a new Environment

The following services are setup in a `prod`-like environment:

- [AWS](https://aws.amazon.com/) - hosting infrastructure, attachments, and emails
- [DataDog](https://www.datadoghq.com/) - (optional, infrastructure monitoring)
- [Sentry](https://rollbar.com/) - (optional, real-time error logging and tracking)

### Initializing a Terraform Workspace

To initialize a Terraform Workspace for the first time, execute:

```
terraform init
```

Once the Workspace is initialized in Terraform, its settings can be configured in [the Terraform UI](https://app.terraform.io/app). Change the Terraform Working Directory to the relative path in this repo (ex. for `prod`, it needs to be `/terraform/environments/prod`).

The following Terraform Workspace variables must be defined:

  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `DD_API_KEY` (the DataDog API key, leave blank to disable)
  - `SENTRY_DSN` (the Platform Sentry DSN, leave blank to disable)

Once all of the above is configured, you can trigger Terraform to provision the new environment by executing:

```
terraform apply
```
