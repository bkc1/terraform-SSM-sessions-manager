resource "aws_kms_key" "cwkey" {
  description             = "${var.app_prefix}-${var.env}-cwlogs-key-terraform managed"
  deletion_window_in_days = 7
  tags = {
    Name = "${var.app_prefix}-${var.env}"
  }
  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Id" : "key-default-1",
  "Statement" : [
    {
      "Sid" : "EnableIAMUserPermissions",
      "Effect" : "Allow",
      "Principal" : {
        "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Action" : "kms:*",
      "Resource" : "*"
    },
    {
      "Effect": "Allow",
      "Principal": {
          "Service": "logs.${var.aws_region}.amazonaws.com"
      },
      "Action": [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Principal": {
          "Service": "ssm.amazonaws.com"
      },
      "Action": [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_kms_alias" "cwkey" {
  name          = "alias/${var.app_prefix}-${var.env}-cwlogs"
  target_key_id = aws_kms_key.cwkey.key_id
}
