module "demo" {
    source = "../../modules/demo"
    test-env-framework = "springboot"
    test-env-val = "schmu-dev"
    lambda-s3-bucket = "sro-test-lambda"
    lambda-s3-prefix = "artifacts/springboot-lambda"
}