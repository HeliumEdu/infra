## Initializing a new Environment

The following services are necessary to deploy the minimalist `dev-local` environment:

- [AWS](https://aws.amazon.com/) - hosting infrastructure
- [Twilio](https://www.twilio.com/en-us) - in-app text reminders

### Twilio Setup

See [the Twilio Setup section](https://github.com/HeliumEdu/deploy/tree/main/terraform/environments/prod#twilio-setup) of the `prod` environment, as the setup is the same (as the TwiML Bins can safely be reused in all environments).

### Initializing a Terraform Workspace

To initialize a Terraform Workspace for the first time, execute:

```
terraform init
```

Once the Workspace is initialized in Terraform, its settings can be configured in [the Terraform UI](https://app.terraform.io/app). Change the Terraform Working Directory to the relative path in this repo (ex. for `dev-local`, it needs to be `/terraform/environments/dev-local`).

The following Terraform Workspace variables must be defined:

  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `TWILIO_ACCOUNT_SID`
  - `TWILIO_AUTH_TOKEN`
  - `helium_twiml_handler_url`
  - `ci_twiml_handler_url`

Once all of the above is configured, you can trigger Terraform to provision the new environment by executing:

```
terraform apply
```
