resource "aws_codebuild_project" "deploy" {
  name                   = "${local.application_name}-Deploy"
  service_role           = aws_iam_role.codebuild.arn
  environment {
    type                        = "LINUX_CONTAINER"
    image                       = local.build_image
    compute_type                = "BUILD_GENERAL1_SMALL"
    privileged_mode             = false
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = local.account_id
    }
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = "us-east-1"
    }
  }

  build_batch_config {
    service_role = aws_iam_role.batch.arn
  }


  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/../../buildspecs/buildspec_deploy.yml")
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.deploy.name
      status     = "ENABLED"
    }
  }
}


################################################################################
# Cloudwatch Log Group
################################################################################

resource "aws_cloudwatch_log_group" "deploy" {
  name = "/aws/codebuild/${local.application_name}-deploy"

  retention_in_days = 30
}


