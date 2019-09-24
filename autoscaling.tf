resource "aws_launch_configuration" "wp-launch" {
  name_prefix     = "wp-lc"
  image_id        = "${data.aws_ami.wp-ami.id}"
  instance_type   = "t2.micro"
  key_name        = "${aws_key_pair.mykeypair.key_name}"
  security_groups = ["${aws_security_group.wp-sg.id}"]
  enable_monitoring = true

  user_data       = "${data.template_file.init.rendered}"

}

resource "aws_autoscaling_group" "wp-asg" {
  name                 = "wordpress-asg"
  launch_configuration = "${aws_launch_configuration.wp-launch.name}"
  min_size             = 2
  max_size             = 4
  desired_capacity     = 2
  vpc_zone_identifier  = ["${module.vpc.public_subnets[0]}", "${module.vpc.public_subnets[1]}"]
  load_balancers       = ["${aws_elb.wp-elb.id}"]

  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "wp-policy-high" {
  name                   = "wp high cpu policy"
  scaling_adjustment     = "1"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.wp-asg.name}"
}

resource "aws_autoscaling_policy" "wp-policy-low" {
  name                   = "wp low cpu policy"
  scaling_adjustment     = "-1"
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.wp-asg.name}"
}

resource "aws_cloudwatch_metric_alarm" "high-cpu" {
  alarm_name          = "wp-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.wp-asg.name}"
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.wp-policy-high.arn}"]

}


resource "aws_cloudwatch_metric_alarm" "low-cpu" {
  alarm_name          = "wordpress-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "25"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.wp-asg.name}"
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.wp-policy-low.arn}"]

}
