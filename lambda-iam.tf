resource "aws_iam_role" "slack-notify" {
  name = "slack-notify"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

data "aws_iam_policy_document" "slack-notify" {
  statement {
    sid    = "CloudwatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:GetLogEvents",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_role_policy" "slack-notify" {
  name   = "SlackNotifications"
  role   = "${aws_iam_role.slack-notify.id}"
  policy = "${data.aws_iam_policy_document.slack-notify.json}"
}
