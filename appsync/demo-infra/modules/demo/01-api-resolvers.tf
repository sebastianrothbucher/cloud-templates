data aws_dynamodb_table "dynamo-table" {
  name = var.dynamo-table
}

resource "aws_iam_role" "appsync-data-access-role" {
  name = "appsync-data-access-role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "appsync.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "appsync-data-access-policy" {
  name = "appsync-data-access-policy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "dynamodb:DeleteItem",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:UpdateItem"
        ],
        "Resource": [
          "${data.aws_dynamodb_table.dynamo-table.arn}",
          "${data.aws_dynamodb_table.dynamo-table.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "appsync-data-access-policy-attach" {
  role = aws_iam_role.appsync-data-access-role.name
  policy_arn = aws_iam_policy.appsync-data-access-policy.arn
}

resource "aws_appsync_graphql_api" "appsync-api" {
  name = "dynamo-${var.dynamo-table}"
  authentication_type = "API_KEY"
  schema = file("../../../demo/schema/schema.graphqls")
}

resource "aws_appsync_datasource" "appsync-dynamo-ds" {
  api_id = aws_appsync_graphql_api.appsync-api.id
  name = "dynamo_${var.dynamo-table}"
  type = "AMAZON_DYNAMODB"
  service_role_arn = aws_iam_role.appsync-data-access-role.arn
  dynamodb_config {
    table_name = data.aws_dynamodb_table.dynamo-table.name
  }
}

resource "aws_appsync_resolver" "appsync-resolver-items" {
  api_id = aws_appsync_graphql_api.appsync-api.id
  type = "Query"
  field = "items"
  kind = "UNIT"
  data_source = aws_appsync_datasource.appsync-dynamo-ds.name
  code = file("../../../demo/resolvers/items-resolver.js")
  runtime {
    name = "APPSYNC_JS"
    runtime_version = "1.0.0"
  }
}

resource "aws_appsync_resolver" "appsync-resolver-putItem" {
  api_id = aws_appsync_graphql_api.appsync-api.id
  type = "Mutation"
  field = "putItem"
  kind = "UNIT"
  data_source = aws_appsync_datasource.appsync-dynamo-ds.name
  code = file("../../../demo/resolvers/putItem-resolver.js")
  runtime {
    name = "APPSYNC_JS"
    runtime_version = "1.0.0"
  }
}
