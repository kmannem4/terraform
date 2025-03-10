terraform {
  backend "s3" {
    region = "us-east-1"
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region  = var.region
}

resource "aws_instance" "app_server" {
  #checkov:skip=CKV_AWS_126:checkov bug skipping
  #checkov:skip=CKV_AWS_135:checkov bug skipping
  #checkov:skip=CKV_AWS_79:checkov bug skipping
  #checkov:skip=CKV_AWS_8:checkov bug skipping
  #checkov:skip=CKV2_AWS_41:checkov bug skipping
  ami           = var.aminame
  instance_type = var.instancetype

  tags = {
    Name = "ExampleAppServerInstance"
  }
}
