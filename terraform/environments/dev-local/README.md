## Initializing a new Environment

The following services are necessary to deploy the minimalist `dev-local` environment:

- [AWS](https://aws.amazon.com/) - emails
- [Twilio](https://www.twilio.com/en-us) - text messages

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
  - `TWILIO_ACCOUNT_SID` (optional, if Twilio module is removed)
  - `TWILIO_AUTH_TOKEN` (optional, if Twilio module is removed)
  - `helium_twiml_handler_url` (optional, if Twilio module is removed)
  - `ci_twiml_handler_url` (optional, if Twilio module is removed)

Once all of the above is configured, you can trigger Terraform to provision the new environment by executing:

```
terraform apply
```

### Route 53 Subdomains

For non-`prod` environments, note that once provisioned, Terraform will create a separate Route 53 Hosted Zoned for
the environment, subdomains of their parent zones. For example, there will be a `heliumedu.dev` zone, and a
`dev-local.heliumedu.dev` zone. In order to complete the mapping, take note of the name servers in the subdomain
zone (`dev-loca.heliumedu.dev`, then go to the parent zone (`heliumedu.dev`), create a new NS record named `dev-local`,
and for its value put all the name servers noted for the subdomain's zone.