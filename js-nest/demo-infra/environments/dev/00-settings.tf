locals {
  dev-cognito-pool-name = "testpool" # "" is no pool = no authorizer (API IS OPEN THEN!)
  dev-cors-host = "http://localhost:8080" # "" is no cors
}