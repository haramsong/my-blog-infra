variable "profile" {
  default = null
}

variable "bucket_name" {
  sensitive = true
}

variable "acm_id" {
  sensitive = true
}

variable "region" {}

variable "domain_name" {}

variable "aws_account_id" {
  sensitive = true
}

variable "role_name" {
  sensitive = true
}

variable "lambda_role_name" {
  sensitive = true
}

variable "api_endpoint" {
  sensitive = true
}