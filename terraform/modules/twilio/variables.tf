variable "environment" {
  description = "The environment"
  type        = string
}

variable "helium_area_code" {
  description = "The area code for the Helium phone number"
  type        = string
}

variable "ci_area_code" {
  description = "The area code for the CI phone number"
  type        = string
}

variable "helium_twiml_handler_url" {
  description = "The URL for the TwiML Bin"
  type        = string
}

variable "ci_twiml_handler_url" {
  description = "The URL for the TwiML Bin"
  type        = string
}