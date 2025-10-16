resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "oac-for-${var.bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_cache_policy" "my_custom_cache_policy" {
  name        = "s3-website-cache-policy"
  comment     = "Website cache policy"
  default_ttl = 3600
  max_ttl     = 43200
  min_ttl     = 3600
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "whitelist"
      headers {
        items = ["Authorization", "Origin"]
      }
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

resource "aws_cloudfront_function" "my_cloudfront_function" {
  name    = "my-website-routing-function"
  runtime = "cloudfront-js-1.0"
  comment = "Function to handle my website routing"
  publish = true
  code    = file("${path.module}/function.js")
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.my_website.bucket_regional_domain_name
    origin_id   = "S3-${var.bucket_name}"

    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id

    origin_shield {
      enabled              = false
      origin_shield_region = var.region
    }
  }

  enabled         = true
  is_ipv6_enabled = false
  comment         = "CloudFront Distribution for ${var.bucket_name}"
  aliases         = ["blog.${var.domain_name}"]

  price_class = "PriceClass_200"
  http_version = "http3"

  viewer_certificate {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:${data.aws_caller_identity.current.account_id}:certificate/${var.acm_id}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  default_cache_behavior {
    target_origin_id       = "S3-${var.bucket_name}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id            = aws_cloudfront_cache_policy.my_custom_cache_policy.id
    origin_request_policy_id   = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" # managed cors_s3_id
    response_headers_policy_id = "5cc3b908-e619-4b99-88e5-2cf7f45965bd" # managed cors_with_preflight_id

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.my_cloudfront_function.arn
    }
  }

  custom_error_response {
    error_code            = 403
    response_page_path    = "/404.html"
    response_code         = 200
    error_caching_min_ttl = 2
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
