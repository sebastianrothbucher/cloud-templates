variable "test-env-val" {
  type = string
}
variable "lambda-s3-bucket" {
  type = string
}
variable "lambda-s3-prefix" {
  type = string
}
variable "cognito-pool-name" { # "" is no pool = no authorizer (API IS OPEN THEN!)
  type = string
  default = ""
}
variable "cors-host" { # "" is no cors
  type = string
  default = ""
}