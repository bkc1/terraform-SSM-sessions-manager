


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

resource "aws_iam_role_policy_attachment" "managedssm" {
  role       = "${aws_iam_role.demo.name}"
  policy_arn = "${data.aws_iam_policy.managedssm.arn}"
#  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"

}

# Needed specific for Sessions Mgr logging via S3/CW. Added S3 readonly (List/Get) on * for demo purposes.
data "template_file" "iam-ssm" {
  template = "${file("${path.root}/templates/ssm_policy.tpl")}"
  vars = {
    region      = "${var.aws_region}"
    bucket = "${aws_s3_bucket.log.bucket}"
  }
}

resource "aws_iam_policy" "iam-ssm" {
  name   = "${var.app_prefix}-${var.env}-${var.aws_region}-SessionsMgr-perms"
  policy = "${data.template_file.iam-ssm.rendered}"
}

resource "aws_iam_role_policy_attachment" "demo" {
  role       = "${aws_iam_role.demo.name}"
  policy_arn = "${aws_iam_policy.iam-ssm.arn}"
}



# test/demo instance
resource "aws_instance" "demo1" {
  tags                    = {
    Name                  = "${var.app_prefix}-${var.env}-test1"
  }
  instance_type           = "t2.micro"
  ami                     = "${data.aws_ami.amznlinux2.id}"
  key_name                = "${aws_key_pair.auth.id}"
  vpc_security_group_ids  = ["${aws_security_group.demo.id}"]
  iam_instance_profile    = "${aws_iam_instance_profile.demo.name}"
  subnet_id               = "${aws_subnet.demo1.id}"
  root_block_device {
    delete_on_termination = true
    volume_type           = "standard"
  }
}
