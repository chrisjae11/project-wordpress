resource "aws_sns_topic" "asg-slack-notify" {
  name         = "SlackNotify-ASG"
  display_name = "Autoscaling Notifications to Slack"
}

resource "aws_autoscaling_notification" "slack-notify" {
  group_names = ["${var.asg-names}"]
  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]
  topic_arn = "${aws_sns_topic.asg-slack-notify.arn}"
}

data "archive_file" "notify-js" {
  type        = "zip"
  source_file = "./lambda/asg-notify.js"
  output_path = "./lambda/asg-notify.zip"
}

resource "aws_lambda_function" "slack-notify" {
  depends_on = ["data.archive_file.notify-js"]

  function_name = "asg-notify"
  description   = "Send notifications to Slack when Autoscaling events occur"

  runtime = "nodejs8.10"
  handler = "asg-notify.handler"

  role = "${aws_iam_role.slack-notify.arn}"

  filename         = "${data.archive_file.notify-js.output_path}"
  # source_code_hash = "${base64sha256(file(data.archive_file.notify-js.output_path))}"
  source_code_hash = filebase64sha256(data.archive_file.notify-js.output_path)

  environment {
    variables = {
      slack_channel  = "${var.channel}"
      slack_username = "${var.username}"
      slack_webhook  = "${var.webhook_id}"
    }
  }
}


resource "aws_lambda_permission" "with-sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.slack-notify.arn}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.asg-slack-notify.arn}"
}



resource "aws_sns_topic_subscription" "lambda" {
  depends_on = ["aws_lambda_permission.with-sns"]
  topic_arn  = "${aws_sns_topic.asg-slack-notify.arn}"
  protocol   = "lambda"
  endpoint   = "${aws_lambda_function.slack-notify.arn}"
}
