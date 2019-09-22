resource "aws_acm_certificate" "cert" {
  # provider = "aws.acm_provider"
  domain_name = "${var.domain_name}"
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method = "DNS"
}

resource "aws_route53_record" "cert-validation" {
  name    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${aws_route53_zone.primary.zone_id}"
  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  # provider                = "aws.acm_provider"
  certificate_arn         = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert-validation.fqdn}"]
}
