resource "twilio_api_accounts_incoming_phone_numbers" "helium_phone_number" {
  friendly_name = "Helium Edu (${var.environment})"
  sms_url       = var.helium_twiml_handler_url
  voice_url     = ""
  area_code     = var.helium_area_code
}

resource "twilio_api_accounts_incoming_phone_numbers" "ci_phone_number" {
  friendly_name = "CI Test Number (${var.environment})"
  sms_url       = var.ci_twiml_handler_url
  voice_url     = ""
  area_code     = var.ci_area_code
}
