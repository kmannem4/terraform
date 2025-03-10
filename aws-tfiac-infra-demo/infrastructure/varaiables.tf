variable "aminame" {
  description = "AMI Name"
  default     = "ami-01c647eace872fc02"
  type        = string
}

variable "instancetype" {
  description = "Instance Type"
  default     = "t2.micro"
  type        = string
}

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
  type        = string
}

