resource "aws_apigatewayv2_api" "lambda-nest-dev-gw" {
  name = "nest-dev-gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda-nest-dev-gw-stage" {
  api_id = aws_apigatewayv2_api.lambda-nest-dev-gw.id
  name = "nest-dev-stage"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda-nest-dev-gw-int" {
  api_id = aws_apigatewayv2_api.lambda-nest-dev-gw.id
  integration_uri = aws_lambda_function.nest-lambda.invoke_arn
  integration_type = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "lambda-nest-dev-gw-cachall" {
  api_id = aws_apigatewayv2_api.lambda-nest-dev-gw.id
  route_key = "ANY /{proxy+}"
  target = "integrations/${aws_apigatewayv2_integration.lambda-nest-dev-gw-int.id}"
}

resource "aws_lambda_permission" "lambda-nest-dev-gw-perm" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.nest-lambda.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.lambda-nest-dev-gw.execution_arn}/*/*"
}
