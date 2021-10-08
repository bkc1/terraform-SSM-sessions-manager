
# test/demo spot instance
resource "aws_spot_instance_request" "demo1" {
  wait_for_fulfillment    = true
  instance_type           = "t2.micro"
  ami                     = data.aws_ami.amznlinux2.id
  key_name                = aws_key_pair.auth.id
  vpc_security_group_ids  = [aws_security_group.demo.id]
  iam_instance_profile    = aws_iam_instance_profile.demo.name
  subnet_id               = aws_subnet.demo1.id
  root_block_device {
    delete_on_termination = true
    volume_type           = "standard"
  }
  provisioner "local-exec" {
    command = "aws ec2 create-tags --resources ${self.spot_instance_id} --tags Key=Name,Value=demo1 --region ${var.aws_region}"
  }
  tags                    = {
    Name                  = "${var.app_prefix}-${var.env}-demo1"
  }
}
