resource "aws_s3_object" "nest-lambda-zip" {
  bucket = "${var.lambda-s3-bucket}"
  key = "${var.lambda-s3-prefix}/nest-lambda.zip"
  source = "../../../demo/dist-lambda/nest-lambda.zip"
  etag = filemd5("../../../demo/dist-lambda/nest-lambda.zip")
}

resource "aws_iam_role" "nest-lambda-role" {
  name = "nest-lambda-role"
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

resource "aws_iam_role_policy_attachment" "nest-lambda-policy" {
  role       = aws_iam_role.nest-lambda-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "nest-lambda" {
  function_name = "nest-lambda"

  s3_bucket = aws_s3_object.nest-lambda-zip.bucket
  s3_key    = aws_s3_object.nest-lambda-zip.key

  runtime = "nodejs16.x"
  handler = "main.handler"

  source_code_hash = sha256(filebase64("../../../demo/dist-lambda/nest-lambda.zip"))

  timeout = 30

  environment {
    variables = {
      TEST_VAR = "${var.test-env-val}"
    }
  }

  role = aws_iam_role.nest-lambda-role.arn
}