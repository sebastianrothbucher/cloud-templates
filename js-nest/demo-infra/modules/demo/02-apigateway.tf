resource "aws_api_gateway_rest_api" "lambda-nest-dev-gw" {
  name = "nest-dev-gw"
}

resource "aws_api_gateway_resource" "lambda-nest-dev-gw-res" {
  rest_api_id = aws_api_gateway_rest_api.lambda-nest-dev-gw.id
  parent_id =  aws_api_gateway_rest_api.lambda-nest-dev-gw.root_resource_id
  path_part = "{proxy+}"
}

data "aws_cognito_user_pools" "lambda-nest-dev-gw-cognito-pools" {
  for_each = var.cognito-pool-name != "" ? toset(["1"]) : toset([])
  name = var.cognito-pool-name
}

resource "aws_api_gateway_authorizer" "lambda-nest-dev-gw-cognito-authrizers" {
  for_each = var.cognito-pool-name != "" ? toset(["1"]) : toset([])
  rest_api_id = aws_api_gateway_rest_api.lambda-nest-dev-gw.id
  name = "nest-dev-authorizer"
  type = "COGNITO_USER_POOLS"
  provider_arns = data.aws_cognito_user_pools.lambda-nest-dev-gw-cognito-pools["1"].arns
}

resource "aws_api_gateway_method" "lambda-nest-dev-gw-mth" {
  for_each = toset(["GET", "HEAD", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"]) # cannot use ANY b/c no auth for OPTIONS
  rest_api_id = aws_api_gateway_rest_api.lambda-nest-dev-gw.id
  resource_id = aws_api_gateway_resource.lambda-nest-dev-gw-res.id
  http_method = each.key
  authorization = var.cognito-pool-name != "" && each.key != "OPTIONS" ? "COGNITO_USER_POOLS" : "NONE"
  authorizer_id = var.cognito-pool-name != "" && each.key != "OPTIONS" ? aws_api_gateway_authorizer.lambda-nest-dev-gw-cognito-authrizers["1"].id : null  # null = no authorizer
  authorization_scopes = var.cognito-pool-name != "" && each.key != "OPTIONS" ? ["openid"] : null
}

resource "aws_api_gateway_integration" "lambda-nest-dev-gw-lambda" {
  for_each = aws_api_gateway_method.lambda-nest-dev-gw-mth
  rest_api_id = aws_api_gateway_rest_api.lambda-nest-dev-gw.id
  resource_id = each.value.resource_id
  http_method = each.value.http_method

  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.nest-lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "lambda-nest-dev-gw-deploy" {
  depends_on = [
    aws_api_gateway_integration.lambda-nest-dev-gw-lambda
  ]

  rest_api_id = aws_api_gateway_rest_api.lambda-nest-dev-gw.id
  stage_name = "nest-dev-stage"
}

resource "aws_lambda_permission" "lambda-nest-dev-gw-perm" {
  statement_id = "AllowAPIGatewayInvoke"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.nest-lambda.function_name
  principal = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.lambda-nest-dev-gw.execution_arn}/*/*"
}
