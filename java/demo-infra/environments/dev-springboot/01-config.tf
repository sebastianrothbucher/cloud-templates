provider "aws" {
  region = "eu-central-1"
}
terraform {
  backend "s3" {
    bucket = "sro-test-lambda"
    key = "terra-state/dev/springboot-lambda/springboot-lambda.tfstate"
    region = "eu-central-1"
  }
}

