resource "aws_security_group" "allow_https" {
  name        = "allow_internal_traffic"
  description = "Allow all internal traffic from within VPC"
  vpc_id      = "${aws_vpc.private_api_gateway_demo_vpc.id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.private_api_gateway_demo_vpc.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
