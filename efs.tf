resource "aws_efs_file_system" "wp-efs" {
  creation_token = "wp-efs"

  tags = {
    Name = "wordpress"
  }
}

resource "aws_efs_mount_target" "wp-tg01" {
  file_system_id  = "${aws_efs_file_system.wp-efs.id}"
  subnet_id       = "${module.vpc.public_subnets[0]}"
  security_groups = ["${aws_security_group.efs-sg.id}"]
}

resource "aws_efs_mount_target" "wp-tg02" {
  file_system_id  = "${aws_efs_file_system.wp-efs.id}"
  subnet_id       = "${module.vpc.public_subnets[1]}"
  security_groups = ["${aws_security_group.efs-sg.id}"]
}
