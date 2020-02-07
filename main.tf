provider "aws" {
  alias = "acm"
}

data "aws_iam_policy_document" "site_bucket_access" {
  statement {
    actions = [
      "s3:GetObject"
    ]

    resources = [
      "arn:aws:s3:::${var.project}-${var.environment}-site-bucket-${random_string.bucket_suffix.result}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:UserAgent"
      values   = [random_string.secret.result]
    }
  }
}

resource "random_string" "secret" {
  length  = 32
  special = false
  upper   = false
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket" "site_bucket" {
  bucket = "${var.project}-${var.environment}-site-bucket-${random_string.bucket_suffix.result}"
  policy = "${data.aws_iam_policy_document.site_bucket_access.json}"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_cloudfront_distribution" "site_distribution" {
  origin {
    domain_name = aws_s3_bucket.site_bucket.website_endpoint
    origin_id   = "${var.project}-${var.environment}-site-origin-${random_string.bucket_suffix.result}"
    custom_origin_config {
      https_port             = 443
      http_port              = 80
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.1", "TLSv1.2"]
    }
    custom_header {
      name  = "User-Agent"
      value = random_string.secret.result
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for static site (${var.project}-${var.environment})"

  aliases = [var.domain]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.project}-${var.environment}-site-origin-${random_string.bucket_suffix.result}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate.site_certificate.arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.1_2016"
  }
  depends_on = [aws_acm_certificate_validation.site_certificate_validation]
}

resource "aws_acm_certificate" "site_certificate" {
  provider          = aws.acm
  domain_name       = var.domain
  validation_method = "DNS"

  tags = {
    Name        = "Certificate for static site ${var.project}-${var.environment}"
    Environment = var.environment
    Project     = var.project
  }

}

resource "aws_route53_record" "site_certificate_challenge" {
  provider = aws.acm
  zone_id  = var.hosted_zone_id
  ttl      = 500
  name     = aws_acm_certificate.site_certificate.domain_validation_options[0].resource_record_name
  type     = aws_acm_certificate.site_certificate.domain_validation_options[0].resource_record_type
  records  = [aws_acm_certificate.site_certificate.domain_validation_options[0].resource_record_value]
}



resource "aws_route53_record" "site_domain_alias" {
  provider = aws.acm
  zone_id  = var.hosted_zone_id
  name     = var.domain
  type     = "A"
  alias {
    name                   = aws_cloudfront_distribution.site_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.site_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate_validation" "site_certificate_validation" {
  provider                = aws.acm
  certificate_arn         = aws_acm_certificate.site_certificate.arn
  validation_record_fqdns = [aws_route53_record.site_certificate_challenge.fqdn]
}
