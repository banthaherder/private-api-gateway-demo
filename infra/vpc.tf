data "aws_availability_zones" "available" {}

resource "aws_vpc" "private_api_gateway_demo_vpc" {
  cidr_block           = "172.25.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "PrivateAPIGatewayDemo"
  }
}

resource "aws_subnet" "private_subnet_az1" {
  vpc_id            = "${aws_vpc.private_api_gateway_demo_vpc.id}"
  cidr_block        = "172.25.0.0/20"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"

  tags = {
    Name = "PrivateSubnetAZ1"
  }

  depends_on = ["aws_vpc.private_api_gateway_demo_vpc"]
}

resource "aws_subnet" "private_subnet_az2" {
  vpc_id            = "${aws_vpc.private_api_gateway_demo_vpc.id}"
  cidr_block        = "172.25.16.0/20"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"

  tags = {
    Name = "PrivateSubnetAZ2"
  }

  depends_on = ["aws_vpc.private_api_gateway_demo_vpc"]
}

resource "aws_subnet" "private_subnet_az3" {
  vpc_id            = "${aws_vpc.private_api_gateway_demo_vpc.id}"
  cidr_block        = "172.25.32.0/20"
  availability_zone = "${data.aws_availability_zones.available.names[2]}"

  tags = {
    Name = "PrivateSubnetAZ3"
  }

  depends_on = ["aws_vpc.private_api_gateway_demo_vpc"]
}

resource "aws_vpc_endpoint" "api_gateway" {
  vpc_id            = "${aws_vpc.private_api_gateway_demo_vpc.id}"
  service_name      = "com.amazonaws.us-west-2.execute-api"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    "${aws_security_group.allow_https.id}",
  ]

  private_dns_enabled = true

  subnet_ids = [
    "${aws_subnet.private_subnet_az1.id}",
    "${aws_subnet.private_subnet_az2.id}",
    "${aws_subnet.private_subnet_az3.id}",
  ]

  depends_on = [
    "aws_security_group.allow_https",
    "aws_subnet.private_subnet_az1",
    "aws_subnet.private_subnet_az2",
    "aws_subnet.private_subnet_az3",
  ]
}
