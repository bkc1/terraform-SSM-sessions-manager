
# S3 resources

resource "random_id" "hash" {
  byte_length = 4
}

# S3 bucket gets removed upon terraform destroy
resource "aws_s3_bucket" "log" {
  bucket        = "ssm-sessions-mgr-logs-${random_id.hash.hex}"
  force_destroy = true
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.s3key.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_kms_key" "s3key" {
  description             = "${var.app_prefix}-${var.env}-s3-key-terraform managed"
  deletion_window_in_days = 7
  tags = {
    Name = "${var.app_prefix}-${var.env}"
  }
}

resource "aws_kms_alias" "s3key" {
  name          = "alias/${var.app_prefix}-${var.env}-s3"
  target_key_id = "${aws_kms_key.s3key.key_id}"
}
