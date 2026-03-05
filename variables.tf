variable "region" {
  default = "ap-southeast-2"
}
variable "project_name" {
  default = "big-hugh"
}
variable "cider_block" {
  default = "10.0.0.0/16"
}
data "aws_availability_zones" "available" {
  state = "available"
}
data "aws_caller_identity" "current" {}

locals {
  gateway_endpoints = {
    "s3" = {
      policy = data.aws_iam_policy_document.s3_endpoint_policy.json
    }
    "dynamodb" = {
      policy = data.aws_iam_policy_document.dynamodb_endpoint_policy.json
    }
  }
}
