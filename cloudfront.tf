resource "aws_cloudfront_distribution" "wp-cdn" {
  price_class = "PriceClass_100"
  enabled     = true
  aliases = ["www.logicflux.tech", "logicflux.tech"]

  origin {
    domain_name = "logicflux.tech"
    origin_id   = "wp-cdn"
    # customer_header = {
    #
    #   name  = "X_CDN"
    #   value = "AMAZON"
    # }

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "wp-cdn"

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  viewer_certificate {
    acm_certificate_arn      = "${aws_acm_certificate.cert.arn}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }
}
