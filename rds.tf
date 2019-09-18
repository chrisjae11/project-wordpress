resource "aws_db_subnet_group" "wp-subgroup" {
  name        = "rds-subnet-group"
  description = "db subnets"
  subnet_ids = ["${module.vpc.private_subnets[0]}", "${module.vpc.private_subnets[1]}"]
  tags = {
    Name = "wordpress-db"
  }
}

resource "aws_db_instance" "wp-db" {
  depends_on             = ["aws_security_group.wp-sg"]
  identifier             = "wp-db"
  allocated_storage      = "10"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  name                   = "${var.db_name}"
  username               = "${var.db_user}"
  password               = "${var.db_pass}"
  multi_az               = true
  vpc_security_group_ids = ["${aws_security_group.db-sg.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.wp-subgroup.id}"
  skip_final_snapshot = true

  tags = {
    Name = "wordpress-db"
  }
}
