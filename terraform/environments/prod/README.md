## Initializing a new Environment

The following services are necessary to deploy Helium:

- [AWS](https://aws.amazon.com/) - hosting infrastructure and emails
- [Twilio](https://www.twilio.com/en-us) - text messages
- [DataDog](https://www.datadoghq.com/) - infrastructure monitoring
- [Rollbar](https://rollbar.com/) - real-time error logging and tracking

### Twilio Setup

Not all Twilio operations can be provisioned with Terraform. Manually create two TwiML Bins via [the Twilio Console](https://www.twilio.com/console):

**Helium Auto Response**
```xml
<?xml version="1.0" encoding="UTF-8"?>
  <Response>
    <Message><Body>This number is only for sending notifications and is not monitored.</Body></Message>
  </Response>
```

**CI Empty Ack**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<Response></Response>
```

Note the URLs for these TwiML Bins, they need to be stored in the Terraform Workspace next.

Additionally, after the Terraform has been applied and the Twilio numbers exist, the `Helium Edu` number won't be able to send outbound text messages until they've gone through the A2P 10DLC registration process, which also must be done [in the Twilio Console](https://console.twilio.com/us1/develop/sms/regulatory-compliance/a2p-10dlc-overview).

### Initializing a Terraform Workspace

To initialize a Terraform Workspace for the first time, execute:

```
terraform init
```

Once the Workspace is initialized in Terraform, its settings can be configured in [the Terraform UI](https://app.terraform.io/app). Change the Terraform Working Directory to the relative path in this repo (ex. for `prod`, it needs to be `/terraform/environments/prod`).

The following Terraform Workspace variables must be defined:

  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `TWILIO_ACCOUNT_SID` (optional, if Twilio module is removed)
  - `TWILIO_AUTH_TOKEN` (optional, if Twilio module is removed)
  - `DD_API_KEY` (the DataDog API key, leave blank to disable)
  - `DD_APP_KEY` (the DataDog App key, leave blank to disable)
  - `ROLLBAR_API_KEY` (leave blank to disable)
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