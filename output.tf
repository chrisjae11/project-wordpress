output "rds-host" {
  value = "${aws_db_instance.wp-db.address}"
}


output "efs-id" {
  value = "${aws_efs_file_system.wp-efs.id}"
}

output "elb-dns" {
  value = "${aws_elb.wp-elb.dns_name}"
}
