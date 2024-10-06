###########################################################################
# Before provisioning, create two TwiML Bins via the Twilio Console.
#
# Friendly Name: Helium Auto Response
# <?xml version="1.0" encoding="UTF-8"?>
# <Response>
#   <Message><Body>This number is only for sending notifications and is not monitored.</Body></Message>
# </Response>
#
# Friendly Name: CI Empty Ack
# <?xml version="1.0" encoding="UTF-8"?>
# <Response></Response>
#
# Get the URL from these TwiML Bins and store them in the Terraform variables `helium_twiml_handler_url`
# and `ci_twiml_handler_url`.
###########################################################################

resource "twilio_api_accounts_incoming_phone_numbers" "helium_phone_number" {
  friendly_name = "Helium Edu (${var.environment})"
  sms_url       = var.helium_twiml_handler_url
  voice_url     = ""
}

output "helium_phone_number" {
  value = twilio_api_accounts_incoming_phone_numbers.helium_phone_number.phone_number
}

resource "twilio_api_accounts_incoming_phone_numbers" "ci_phone_number" {
  friendly_name = "CI Test Number (${var.environment})"
  sms_url       = var.ci_twiml_handler_url
  voice_url     = ""
}

output "ci_phone_number" {
  value = twilio_api_accounts_incoming_phone_numbers.ci_phone_number.phone_number
}
