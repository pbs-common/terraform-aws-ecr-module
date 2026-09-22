locals {
  allow_lambda_access_statement = {
    "Sid" : "LambdaECRImageRetrievalPolicy",
    "Effect" : "Allow",
    "Principal" : {
      "Service" : "lambda.amazonaws.com"
    },
    "Action" : [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer"
    ]
  }
  ecr_statements = concat(
    var.allow_lambda_access ? [local.allow_lambda_access_statement] : [],
    [for statement in var.extra_policy_statements : jsondecode(statement)],
  )

  # A repository policy with no statements is malformed, so an empty statement list means no policy
  # at all rather than an empty one.
  create_ecr_policy = var.create_ecr_policy && length(local.ecr_statements) > 0
}

resource "aws_ecr_repository_policy" "policy" {
  count = local.create_ecr_policy ? 1 : 0

  repository = aws_ecr_repository.repo.name

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : local.ecr_statements,
    }
  )
}
