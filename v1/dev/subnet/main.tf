provider "aws" {
  region = var.region  
}

module "subnet" {
  source = "../modules/subnet"
  env ="Dev"  
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id  
  igw_id = data.terraform_remote_state.vpc.outputs.igw_id
}