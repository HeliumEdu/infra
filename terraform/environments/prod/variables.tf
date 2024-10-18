variable "helium_version" {
  description = "The container version. Bumping this will trigger a deploy."
  default     = "1.7.16"
}

variable "environment" {
  description = "The environment"
  default     = "prod"
}

variable "environment_prefix" {
  description = "Prefix used for env in hostnames (empty string when `prod`)"
  default     = ""
}

variable "aws_region" {
  description = "The AWS region"
  default     = "us-east-1"
}

variable "region_azs" {
  description = "Map of AZ suffixes and their index"
  default = {
    az1 = {
      suffix = "a"
      index  = "0"
    }
    az2 = {
      suffix = "b"
      index  = "1"
    }
    az3 = {
      suffix = "c"
      index  = "2"
    }
  }
}

variable "default_arch" {
  description = "The target arch of container builds"
  default     = "X86_64"
}

variable "frontend_host_count" {
  description = "The number of frontend hosts desired in the cluster"
  default     = 2
}

variable "platform_host_count" {
  description = "The number of platform hosts desired in the cluster"
  default     = 3
}

variable "db_multi_az" {
  description = "True if DB should be multi-AZ"
  default     = false
}

variable "num_cache_nodes" {
  description = "The number of cache nodes"
  default     = 1
}

variable "helium_area_code" {
  description = "The area code for the Helium phone number"
  default     = ""
}

variable "ci_area_code" {
  description = "The area code for the CI phone number"
  default     = ""
}

### Variables defined below this point must have their defaults defined in the Terraform Workspace

variable "AWS_ACCESS_KEY_ID" {
  description = "The AWS access key ID"
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "The AWS secret access key"
}

variable "TWILIO_ACCOUNT_SID" {
  description = "The Twilio account SID"
}

variable "TWILIO_AUTH_TOKEN" {
  description = "The Twilio auth token"
}

variable "HELIUM_TWIML_HANDLER_URL" {
  description = "The URL for the Helium TwiML Bin"
}

variable "CI_TWIML_HANDLER_URL" {
  description = "The URL for the CI TwiML Bin"
}

variable "DD_API_KEY" {
  description = "The DataDog API key"
}

variable "DD_APP_KEY" {
  description = "The DataDog app key"
}

variable "ROLLBAR_API_KEY" {
  description = "The Rollbar API key"
}