# variables not allowed here
terraform {
  backend "s3" {
    bucket = "upgrad-terraform1"
    key    = "root/terraform.tfstate"
    region = "us-east-1"
  }
}
