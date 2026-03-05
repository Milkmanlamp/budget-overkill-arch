variable "region" {
  default = "ap-southeast-2"
}
variable "project_name" {
  default = "Big-Hugh"
}
variable "cider_block" {
  default = "10.0.0.0/16"
}
data "aws_availability_zones" "available" {
  state = "available"
}
