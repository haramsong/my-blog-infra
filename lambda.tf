data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "view_count" {
  function_name    = "view-count"
  role             = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.lambda_role_name}"
  handler          = "index.handler"
  runtime          = "nodejs22.x"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.view_count.name
      API_SECRET = var.api_secret
    }
  }

  timeout = 3
}