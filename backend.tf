terraform {
  backend "s3" {
    bucket = "abhay-terraform-state-mumbai"
    key    = "dev/terraform.tfstate"
    region = "ap-south-1"
  }
}
