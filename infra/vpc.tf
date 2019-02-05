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

resource "aws_subnet" "public_subnet_az2" {
  vpc_id                  = "${aws_vpc.private_api_gateway_demo_vpc.id}"
  cidr_block              = "172.25.16.0/20"
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnetAZ2"
  }

  depends_on = ["aws_vpc.private_api_gateway_demo_vpc"]
}

resource "aws_internet_gateway" "demo_vpc_igw" {
  vpc_id = "${aws_vpc.private_api_gateway_demo_vpc.id}"

  tags = {
    Name = "DemoIGW"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.private_api_gateway_demo_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.demo_vpc_igw.id}"
  }

  tags = {
    Name = "DemoRouteTableForPublicSubnet"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = "${aws_subnet.public_subnet_az2.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"

  depends_on = [
    "aws_subnet.public_subnet_az2",
  ]
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
  ]

  depends_on = [
    "aws_security_group.allow_https",
    "aws_subnet.private_subnet_az1",
  ]
}
