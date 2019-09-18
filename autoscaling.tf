resource "aws_launch_configuration" "wp-launch" {
  name_prefix     = "wp-lc"
  image_id        = "${data.aws_ami.wp-ami.id}"
  instance_type   = "t2.micro"
  key_name        = "${aws_key_pair.mykeypair.key_name}"
  security_groups = ["${aws_security_group.wp-sg.id}"]
  user_data       = "${data.template_file.init.rendered}"

}

resource "aws_autoscaling_group" "wp-asg" {
  name                 = "woredpress-asg"
  launch_configuration = "${aws_launch_configuration.wp-launch.name}"
  min_size             = 2
  max_size             = 4
  desired_capacity     = 2
  vpc_zone_identifier  = ["${module.vpc.public_subnets[0]}", "${module.vpc.public_subnets[1]}"]
  load_balancers = ["${aws_elb.wp-elb.id}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "wp-policy-high" {
  name = "wp high cpu policy"
  scaling_adjustment = "1"
  adjustment_type = "ChangeInCapacity"
  autoscaling_group_name = "${aws_autoscaling_group.wp-asg.name}"
}

resource "aws_autoscaling-policy" "wp-policy-low" {
  name = "wp low cpu policy"
  adjustment_type = "ChangeInCapacity"

}
