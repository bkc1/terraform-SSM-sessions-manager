
resource "aws_cloudwatch_log_group" "sessionsmgr" {
  name              = "ssm-sessions-mgr"
  retention_in_days = 14
  kms_key_id        = aws_kms_key.cwkey.arn
  tags = {
    Environment = var.env
  }
}

