# -----------------------------------------------------------------------------
# data lookups
# -----------------------------------------------------------------------------
data "aws_availability_zones" "available" {}

data "aws_ami" "target_ami" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.20190618-x86_64-ebs"]
  }
}

# -----------------------------------------------------------------------------
# items not likely to change much
# -----------------------------------------------------------------------------

variable "tags" {
  type = map
  default = {
    "Owner"   = "minecraft"
    "Project" = "instance-connect"
    "Client"  = "internal"
  }
}

# 172.33.0.0 - 172.33.255.255
variable "vpc_cidr" {
  default = "10.0.0.0/24"
}

# /* variables to inject via terraform.tfvars */
variable "elastic_ip_allocation_id" {}
# variable "aws_account_id" { }
# variable "aws_profile" {}
# variable "test_user" {}

# -----------------------------------------------------------------------------
# items that may change
# -----------------------------------------------------------------------------
variable "ssh_list" {
  type = list
  default = [ "0.0.0.0/0" , "::/0"]
}
