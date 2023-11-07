variable "test-env-framework" {
  type = string
  validation {
    condition = contains(["springboot", "micronaut"], var.test-env-framework)
    error_message = "either springboot or micronaut"
  }
}
variable "test-env-val" {
  type = string
}
variable "lambda-s3-bucket" {
  type = string
}
variable "lambda-s3-prefix" {
  type = string
}
variable "snap-start" {
  type = bool
  default = true
}