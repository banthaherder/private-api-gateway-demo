provider "aws" {
  version = "~> 1.57"
  region  = "us-west-2"
  profile = "tf"
}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}
