output "helium_phone_number" {
  value = twilio_api_accounts_incoming_phone_numbers.helium_phone_number.phone_number
}

output "ci_phone_number" {
  value = twilio_api_accounts_incoming_phone_numbers.ci_phone_number.phone_number
}