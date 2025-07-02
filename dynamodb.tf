resource "aws_dynamodb_table" "view_count" {
  name         = "${var.api_endpoint}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "slug"

  attribute {
    name = "slug"
    type = "S"
  }
}