# ----------------------------------
# 1. CloudWatch Log Group
# ----------------------------------
resource "aws_cloudwatch_log_group" "app_log_group" {
  name              = "/aws/ec2/${var.stage}-app-logs"
  retention_in_days = 7
}

# ----------------------------------
# 2. SNS Topic and Email Subscription
# ----------------------------------
resource "aws_sns_topic" "log_alert_topic" {
  name = "log-alert-topic"
}

resource "aws_sns_topic_subscription" "log_alert_email_subscription" {
  topic_arn = aws_sns_topic.log_alert_topic.arn
  protocol  = "email"
  endpoint  = var.alert_email  
}

# ----------------------------------
# 3. Log Metric Filter for ERROR
# ----------------------------------
resource "aws_cloudwatch_log_metric_filter" "error_filter" {
  name           = "app-log-error-filter"
  log_group_name = aws_cloudwatch_log_group.app_log_group.name
  pattern        = "Error"

  metric_transformation {
    name      = "AppLogErrorCount"
    namespace = "AppLogMetrics"
    value     = "1"
  }
}

# ----------------------------------
# 4. Log Metric Filter for Exception
# ----------------------------------
resource "aws_cloudwatch_log_metric_filter" "exception_filter" {
  name           = "app-log-exception-filter"
  log_group_name = aws_cloudwatch_log_group.app_log_group.name
  pattern        = "Exception"

  metric_transformation {
    name      = "AppLogExceptionCount"
    namespace = "AppLogMetrics"
    value     = "1"
  }
}

# ----------------------------------
# 5. CloudWatch Alarm for ERROR
# ----------------------------------
resource "aws_cloudwatch_metric_alarm" "error_alarm" {
  alarm_name          = "${var.stage}-app-log-error-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  period              = 60
  threshold           = 1
  statistic           = "Sum"
  metric_name         = aws_cloudwatch_log_metric_filter.error_filter.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.error_filter.metric_transformation[0].namespace
  alarm_description   = "Triggered when ERROR appears in application logs"
  alarm_actions       = [aws_sns_topic.log_alert_topic.arn]
}

# ----------------------------------
# 6. CloudWatch Alarm for Exception
# ----------------------------------
resource "aws_cloudwatch_metric_alarm" "exception_alarm" {
  alarm_name          = "${var.stage}-app-log-exception-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  period              = 60
  threshold           = 1
  statistic           = "Sum"
  metric_name         = aws_cloudwatch_log_metric_filter.exception_filter.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.exception_filter.metric_transformation[0].namespace
  alarm_description   = "Triggered when Exception is logged in application logs"
  alarm_actions       = [aws_sns_topic.log_alert_topic.arn]
}
