terraform {
  backend "s3" {
    bucket  = ""
    key     = "my-blog/terraform.tfstate"
    region  = ""
    profile = ""
  }
}