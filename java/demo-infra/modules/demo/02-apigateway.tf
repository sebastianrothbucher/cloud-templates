resource "aws_api_gateway_rest_api" "lambda-java-dev-gw" {
  name = "java-${var.test-env-framework}-dev-gw"
}

resource "aws_api_gateway_resource" "lambda-java-dev-gw-res" {
  rest_api_id = aws_api_gateway_rest_api.lambda-java-dev-gw.id
  parent_id =  aws_api_gateway_rest_api.lambda-java-dev-gw.root_resource_id
  path_part = "{proxy+}"
}

resource "aws_api_gateway_method" "lambda-java-dev-gw-mth" {
  rest_api_id = aws_api_gateway_rest_api.lambda-java-dev-gw.id
  resource_id = aws_api_gateway_resource.lambda-java-dev-gw-res.id
  http_method = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda-java-dev-gw-lambda" {
  rest_api_id = aws_api_gateway_rest_api.lambda-java-dev-gw.id
  resource_id = aws_api_gateway_method.lambda-java-dev-gw-mth.resource_id
  http_method = aws_api_gateway_method.lambda-java-dev-gw-mth.http_method

  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.java-lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "lambda-java-dev-gw-deploy" {
  depends_on = [
    aws_api_gateway_integration.lambda-java-dev-gw-lambda
  ]

  rest_api_id = aws_api_gateway_rest_api.lambda-java-dev-gw.id
  stage_name = "java-${var.test-env-framework}-dev-stage"
}

resource "aws_lambda_permission" "lambda-java-dev-gw-perm" {
  statement_id = "AllowAPIGatewayInvoke"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.java-lambda.function_name
  principal = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.lambda-java-dev-gw.execution_arn}/*/*"
}
