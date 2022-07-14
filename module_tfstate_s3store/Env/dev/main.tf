#Configure the AWS Provider
provider "aws" {
  region  = "us-east-1"
  profile = "akashk"
}
terraform {
  backend "s3" {
    bucket = "practicebuckettf"
    key    = "practicebuckettf/terraform.tf.state"
    region = "us-east-1"
  }
}

module "Instance" {
  source             = "../../Module/Instance"
  vpc_cidr_block     = "20.0.0.0/16"
  public_cidr_block  = "20.0.1.0/24"
  private_cidr_block = "20.0.2.0/24"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  vpc-tf             = "practice -vpc"


}
