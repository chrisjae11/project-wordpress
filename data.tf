data "aws_availability_zones" "available" {}

data "aws_ami" "wp-ami" {
  most_recent = true
  owners = ["self"]

  filter {
    name = "tag:Name"
    values = ["wordpress"]
  }
}


data "template_file" "init" {
  template = "${file("scripts/init.sh")}"
   vars = {
    efs_dns = "${aws_efs_mount_target.wp-tg01.dns_name}"
    dbhost = "${aws_db_instance.wp-db.address}"
    db_pass = "${var.db_pass}"
    db_user = "${var.db_user}"
    db_name = "${var.db_name}"
  }
}
