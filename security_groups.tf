
## Security group for myapp  instances
resource "aws_security_group" "demo" {
  name        = "${var.app_prefix}-${var.env}"
  description = "${var.app_prefix} ${var.env} - Terraform managed"
  vpc_id      = aws_vpc.demo.id
  tags = {
    Name      = "${var.app_prefix}-${var.env}"
  }

  # SSM access
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = [aws_vpc.demo.cidr_block]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
