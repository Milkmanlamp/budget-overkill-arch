#S3
data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    sid     = "DenyExceptVPCEndpoint"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "StringNotEquals"
      variable = "aws:sourceVpce"
      values   = [aws_vpc_endpoint.gateways["s3"].id]
    }
    condition {
      test     = "ArnNotEquals"
      variable = "aws:PrincipalArn"
      values = [
        data.aws_caller_identity.current.arn,
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "restrict_to_vpc_endpoint" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}

data "aws_iam_policy_document" "s3_endpoint_policy" {
  statement {
    sid    = "AllowSpecificBucket"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]
    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*"
    ]
  }
}
## DynamoDB
resource "aws_dynamodb_resource_policy" "qoute_table_policy" {
  resource_arn = aws_dynamodb_table.qoutes_table.arn
  policy       = data.aws_iam_policy_document.dynamodb_table_policy.json
}
data "aws_iam_policy_document" "dynamodb_endpoint_policy" {
  statement {
    sid    = "AllowSpecificTable"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:DescribeTable",
      "dynamodb:DescribeStream",
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:ListStreams",
    ]
    resources = [
      aws_dynamodb_table.qoutes_table.arn,
      "${aws_dynamodb_table.qoutes_table.arn}/stream/*",
    ]
  }
}

data "aws_iam_policy_document" "dynamodb_table_policy" {
  statement {
    sid    = "DenyExceptVPCEndpoint"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions   = ["dynamodb:*"]
    resources = [aws_dynamodb_table.qoutes_table.arn]
    condition {
      test     = "StringNotEquals"
      variable = "aws:sourceVpce"
      values   = [aws_vpc_endpoint.gateways["dynamodb"].id]
    }
    condition {
      test     = "ArnNotEquals"
      variable = "aws:PrincipalArn"
      values = [
        data.aws_caller_identity.current.arn,
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      ]
    }
  }
}
## ECS
data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_execution" {
  name               = "${var.project_name}-ecs-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_iam_role" "ecs_task" {
  name               = "${var.project_name}-ecs-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

data "aws_iam_policy_document" "ecs_task_permissions" {
  statement {
    sid    = "AllowDynamoDB"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query",
      "dynamodb:Scan",
    ]
    resources = [aws_dynamodb_table.qoutes_table.arn]
  }
  statement {
    sid    = "AllowS3"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
    ]
  }
}

resource "aws_iam_role_policy" "ecs_task" {
  name   = "${var.project_name}-ecs-task-policy"
  role   = aws_iam_role.ecs_task.id
  policy = data.aws_iam_policy_document.ecs_task_permissions.json
}
