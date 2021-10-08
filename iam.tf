resource "aws_iam_instance_profile" "demo" {
  name = "${var.app_prefix}-${var.env}-${var.aws_region}-ec2-profile"
  role = aws_iam_role.demo.name
}

# IAM role for EC2 instance
resource "aws_iam_role" "demo" {
  name               = "${var.app_prefix}-${var.env}-${var.aws_region}-EC2-role"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

#Managed SSM policy, needed to be managed by SSM
data "aws_iam_policy" "managedssm" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "managedssm-attach" {
  role       = aws_iam_role.demo.name
  policy_arn = data.aws_iam_policy.managedssm.arn
}

# EC2 instance policy must of IAM perms to write logs to CW and S3 if this option is selected
data "template_file" "policy-tpl" {
  template = file("${path.root}/templates/instance_policy.tpl")
  vars = {
    region   = var.aws_region
    bucket   = aws_s3_bucket.log.bucket
    key_arn = aws_kms_key.cwkey.arn
  }
}

resource "aws_iam_policy" "instance-policy" {
  name   = "${var.app_prefix}-${var.env}-${var.aws_region}-SessionsMgr-perms"
  policy = data.template_file.policy-tpl.rendered
}

# Attach instance policy to IAM role, allowing API actions to CW and S3 for logging
resource "aws_iam_role_policy_attachment" "instance-policy-attach" {
  role       = aws_iam_role.demo.name
  policy_arn = aws_iam_policy.instance-policy.arn
}

# Test IAM user with restricted SSH perms
resource "aws_iam_user" "restricted" {
  name = "RestrictedUser"
}

resource "aws_iam_access_key" "demo" {
  user = aws_iam_user.restricted.name
}

data "template_file" "startSSH-tpl" {
  template = file("${path.root}/templates/startssh_policy.tpl")
  vars = {
    account_id = data.aws_caller_identity.current.account_id
    key_arn = aws_kms_key.cwkey.arn
  }
}

resource "aws_iam_policy" "iam-startssh" {
  name   = "${var.app_prefix}-${var.env}-${var.aws_region}-ssmstartssh"
  policy = data.template_file.startSSH-tpl.rendered
}

resource "aws_iam_user_policy_attachment" "startssh-attach" {
  user       = aws_iam_user.restricted.name
  policy_arn = aws_iam_policy.iam-startssh.arn
}
