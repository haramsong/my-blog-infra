provider "aws" {
  region  = "ap-northeast-2"
  profile = var.profile
  assume_role {
    role_arn = "arn:aws:iam::${var.aws_account_id}:role/${var.role_name}"
  }
}