module "public_vpc" {
  source = "./modules/vpc"
}

module "myec2" {
  source = "./modules/ec2"
  public_subnet_id = module.public_vpc.public_subnet_id
  vpc_id = module.public_vpc.vpc_id
  //Below gets the VPC OD output from the VPC module and passes it to
  //The instance module to create the VPC on the correct group

}

#
# module "sec_groups" {
#   source = "./modules/SecurityGroups"
#   vpc_id = module.public_vpc.vpc_id
# }
