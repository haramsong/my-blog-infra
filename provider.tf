terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "ap-northeast-2"
  profile = var.profile
  assume_role {
    role_arn = "arn:aws:iam::${var.aws_account_id}:role/${var.role_name}"
  }
}