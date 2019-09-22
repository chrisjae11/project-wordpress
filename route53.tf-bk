resource "aws_route53_zone" "primary" {
  name              = "logicflux.tech"
  delegation_set_id = "${var.delegation_set}"
  force_destroy     = true

}

resource "aws_route53_record" "www-wp" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "www.logicflux.tech"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_elb.wp-elb.dns_name}"]
}

resource "aws_route53_record" "apex" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "logicflux.tech"
  type    = "A"

  alias {
    name                   = "${aws_elb.wp-elb.dns_name}"
    zone_id                = "${aws_elb.wp-elb.zone_id}"
    evaluate_target_health = false
  }
}
