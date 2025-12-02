variable "environment" {
  description = "The environment"
  type        = string
}

variable "route53_heliumedu_com_zone_id" {
  description = "The Route 53 Zone ID"
  type        = string
}

variable "route53_heliumedu_com_zone_name" {
  description = "The Route 53 zone name"
  type        = string
}

variable "dkim_public_key" {
  description = "The DKIM public key"
  type        = string
  default     = "v=DKIM1;k=rsa;p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAynNkRISLXgQy5Y1/NFhlRFS5pUQgiJdc/SE8sP3CLzsQ1u56XmCr3Jpt6wHs8cKxSqXxF1/Vqpf0cOHIWWGKMOqMhFJTPb+10r1xz/nzYhhHwoySLMsPvNUEIF4SV3wmXmbxfQJhgKzYj1zPNdzTY4IjdAxVfNB5/vn73zzOGI6MJfUFuE1Fo4U5Iq30ZKnxNfmz/Tdey81NxIQWNf07yCGMDsHIboa7tpMfNlmiw4HFRceX4Bdin0dzMzSIEQ5OQ/eWBIew12SgsAcDW3FSy2SNiGLLF8P8N30UCYCrofnC4dCd6K0MubyDBokQfuIJ7bYkVSeKVevO8yIO2AET3wIDAQAB"
}
