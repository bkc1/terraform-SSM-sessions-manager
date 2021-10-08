# Fetch AZs in the current region
data "aws_availability_zones" "available" {
  state = "available"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "demo" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.app_prefix}-${var.env}"
  }
}

# Sets search domain in DHCP options
resource "aws_vpc_dhcp_options" "demo" {
  domain_name         = var.domain_name
  domain_name_servers = ["AmazonProvidedDNS"]
  tags = {
    Name              = aws_vpc.demo.tags.Name
  }
}

# Applies DHCP options to VPC
resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = aws_vpc.demo.id
  dhcp_options_id = aws_vpc_dhcp_options.demo.id
  depends_on      = [aws_vpc_dhcp_options.demo]
}

# Create a subnet to launch our instances into, defining the AZ
resource "aws_subnet" "demo1" {
  availability_zone       = data.aws_availability_zones.available.names[0]
  vpc_id                  = aws_vpc.demo.id
  cidr_block              = var.subnet1
  map_public_ip_on_launch = false
  tags = {
    Name = "${aws_vpc.demo.tags.Name}-priv-subnet-1"
  }
}

# Endpoints
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.demo.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  tags = {
    Name        = "${var.app_prefix}-s3-EP"
    Environment = var.env
  }
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  route_table_id  = aws_vpc.demo.main_route_table_id
}

# With the instance having no outbound internet access, many private endpoints need to be setup to reach AWS services 
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.demo.id
  service_name        = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.demo1.id]
  security_group_ids  = [aws_security_group.demo.id]
  private_dns_enabled = true
  tags = {
    Name        = "${var.app_prefix}-ssm-EP"
    Environment = var.env
  }
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id              = aws_vpc.demo.id
  service_name        = "com.amazonaws.${var.aws_region}.ec2"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.demo1.id]
  security_group_ids  = [aws_security_group.demo.id]
  private_dns_enabled = true
  tags = {
    Name        = "${var.app_prefix}-ec2-EP"
    Environment = var.env
  }
}

resource "aws_vpc_endpoint" "ec2-msgs" {
  vpc_id              = aws_vpc.demo.id
  service_name        = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.demo1.id]
  security_group_ids  = [aws_security_group.demo.id]
  private_dns_enabled = true
  tags = {
    Name        = "${var.app_prefix}-ec2-msgs-EP"
    Environment = var.env
  }
}

resource "aws_vpc_endpoint" "ssm-msgs" {
  vpc_id              = aws_vpc.demo.id
  service_name        = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.demo1.id]
  security_group_ids  = [aws_security_group.demo.id]
  private_dns_enabled = true
  tags = {
    Name        = "${var.app_prefix}-ssm-msgs-EP"
    Environment = var.env
  }
}

resource "aws_vpc_endpoint" "kms" {
  vpc_id              = aws_vpc.demo.id
  service_name        = "com.amazonaws.${var.aws_region}.kms"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.demo1.id]
  security_group_ids  = [aws_security_group.demo.id]
  private_dns_enabled = true
  tags = {
    Name        = "${var.app_prefix}-kms-EP"
    Environment = var.env
  }
}

resource "aws_vpc_endpoint" "cwlogs" {
  vpc_id              = aws_vpc.demo.id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.demo1.id]
  security_group_ids  = [aws_security_group.demo.id]
  private_dns_enabled = true
  tags = {
    Name        = "${var.app_prefix}-cloudwatchlogs-EP"
    Environment = var.env
  }
}
