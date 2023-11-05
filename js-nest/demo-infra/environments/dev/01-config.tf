provider "aws" {
  region = "eu-central-1"
}
terraform {
  backend "s3" {
    bucket = "sro-test-lambda"
    key = "terra-state/dev/nest-lambda/nest-lambda.tfstate"
    region = "eu-central-1"
  }
}

