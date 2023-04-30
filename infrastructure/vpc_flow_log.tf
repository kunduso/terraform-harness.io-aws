#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log
resource "aws_flow_log" "app1" {
  iam_role_arn    = aws_iam_role.vpc_flowlog_role.arn
  log_destination = aws_cloudwatch_log_group.cw_loggroup.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.this.id
}
data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_log_group" "cw_loggroup" {
  name = "vpc-flowlog"
  retention_in_days = 14
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "vpc_flowlog_role" {
  name               = "vpc_flowlog_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "vpc_flowlog_policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["arn:aws:logs:us-east-2:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.cw_loggroup.name}:*"]
  }
}

resource "aws_iam_role_policy" "vpc_flowlog_role" {
  name   = "vpc_flowlog_role"
  role   = aws_iam_role.vpc_flowlog_role.id
  policy = data.aws_iam_policy_document.vpc_flowlog_policy.json
}
