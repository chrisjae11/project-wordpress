module "notify_slack" {
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "~> 2.0"

  sns_topic_name = "slack-topic"

  slack_webhook_url = "https://hooks.slack.com/services/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"
  slack_channel     = "aws"
  slack_username    = "chris"
}
