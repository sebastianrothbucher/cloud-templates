module "demo" {
  source = "../../modules/demo"
  api-name = "dynamotest"
  dynamo-table = "test"
}