resource "aws_cloudwatch_log_group" "eventbridge-test-log" {
  name = "/aws/events/test"
}

# thx, https://github.com/terraform-aws-modules/terraform-aws-eventbridge

module "eventbridge" {
  source = "terraform-aws-modules/eventbridge/aws"
  version = "3.0.0"

  bus_name = "kafka"

  targets = {
    test = [
      {
        name = "send-to-test-log-group"
        arn = aws_cloudwatch_log_group.eventbridge-test-log.arn
      }
    ]
  }

  rules = {
    test = {
      name = "kafka-test-rule"
      event_pattern = jsonencode({
        "detail": {
          "value": {
            "type": ["test"]
          }
        }
      })
    }
  }

}

# can use https://github.com/awslabs/eventbridge-kafka-connector (i.e. a Kafka-connect sink) to pump to eventbridge

data "aws_iam_role" "kafka-node-role" {
  name = "kafka-node" # separately managed in this ex
}

resource "aws_iam_policy" "kafka-node-policy" {
  name = "kafka-node-policy"
  policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "",
          "Effect": "Allow",
          "Action": "events:PutEvents",
          "Resource": "${module.eventbridge.eventbridge_bus_arn}"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "kafka-node-policy-attach" {
  policy_arn = aws_iam_policy.kafka-node-policy.arn
  role = data.aws_iam_role.kafka-node-role.name
}