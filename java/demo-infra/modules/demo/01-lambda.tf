locals {
  jar-version = replace(file("../../../demo-${var.test-env-framework}/target/classes/META-INF/version.properties"), "version=", "")
}

resource "aws_s3_object" "java-lambda-zip" {
  bucket = "${var.lambda-s3-bucket}"
  key = "${var.lambda-s3-prefix}/demo-${var.test-env-framework}-${local.jar-version}.jar"
  source = "../../../demo-${var.test-env-framework}/target/demo-${var.test-env-framework}-${local.jar-version}.jar"
  etag = filemd5("../../../demo-${var.test-env-framework}/target/demo-${var.test-env-framework}-${local.jar-version}.jar")
}

resource "aws_iam_role" "java-lambda-role" {
  name = "java-${var.test-env-framework}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "java-lambda-policy" {
  role       = aws_iam_role.java-lambda-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "java-lambda" {
  function_name = "java-${var.test-env-framework}-lambda"

  s3_bucket = aws_s3_object.java-lambda-zip.bucket
  s3_key    = aws_s3_object.java-lambda-zip.key

  runtime = "java17"
  handler = "sebastianrothbucher.LambdaHandler::handleRequest"

  source_code_hash = filebase64sha256("../../../demo-${var.test-env-framework}/target/demo-${var.test-env-framework}-${local.jar-version}.jar")

  timeout = 30

  environment {
    variables = {
      TEST_VAR = "${var.test-env-val}"
    }
  }

  # (only needed for snapstart)
  publish = true
  #TODO snap_start {
  #  apply_on = "PublishedVersions"
  #}

  role = aws_iam_role.java-lambda-role.arn
}

resource "null_resource" "java-lambda-snapstart-cleanup" {
  triggers = {
    new_version = aws_lambda_function.java-lambda.version
  }

  provisioner "local-exec" {
    command = "aws lambda delete-function --function-name ${aws_lambda_function.java-lambda.function_name}:${tonumber(aws_lambda_function.java-lambda.version)-1}"
  }
}