variable "instance_type" {
  default = "t2.micro"
}

data "aws_ami" "ami" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

variable "public_subnet_id" {
  default = ""
}

//Need to Initialize Variables that will be passed down
//From parents!
variable "vpc_id" {
  default = ""
}
