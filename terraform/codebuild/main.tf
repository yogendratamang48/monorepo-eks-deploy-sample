locals {
  application_name = "simple-ping"
  ecr_names = [
    "simple-ping",
    "simple-pong"
  ]
  repository_name = "simple-mono-repo"
  repository_url   = "730335205732.dkr.ecr.us-east-1.amazonaws.com/simple-ping"
  build_image      = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
}

resource "aws_codebuild_project" "this" {
  name                   = local.application_name
  service_role           = aws_iam_role.codebuild.arn
  concurrent_build_limit = 1

  environment {
    type                        = "LINUX_CONTAINER"
    image                       = local.build_image
    compute_type                = "BUILD_GENERAL1_SMALL"
    # image_pull_credentials_type = "SERVICE_ROLE"
    privileged_mode             = false
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = "730335205732"
    }
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = "us-east-1"
    }
  }



  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/buildspec.yaml")
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.this.name
      status     = "ENABLED"
    }
  }
}


################################################################################
# Cloudwatch Log Group
################################################################################

resource "aws_cloudwatch_log_group" "this" {
  name = "/aws/codebuild/${local.application_name}"

  retention_in_days = 30
}


################################################################################
# IAM Role for CodeBuild
################################################################################

resource "aws_iam_role" "codebuild" {
  name = "${local.application_name}-codebuild"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild" {
  role       = aws_iam_role.codebuild.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}