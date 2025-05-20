terraform {
  backend "s3" {

      bucket  = "email-app-tfstate-bucket"
      dynamodb_table = "email-app-tfstate-bucket"
      key ="global/statefile/terraform.tfstate"
      region = "us-east-1"
      encrypt =true
    
  }

  required_providers{
    aws={
        source="hashicorp/aws"
        version = "~> 5.0"

    }
  }
}

provider "aws" {
  region  = "us-east-1"
}




data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda_email"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/${aws_lambda_function.func.id}"
  retention_in_days = 14
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}


data "aws_iam_policy_document" "lambda_s3access" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = ["arn:aws:s3:::*"]
  }
}

resource "aws_iam_policy" "lambda_s3access" {
  name        = "lambda-s3access"
  path        = "/"
  description = "IAM policy for accessing s3 from a lambda"
  policy      = data.aws_iam_policy_document.lambda_s3access.json
}

resource "aws_iam_role_policy_attachment" "lambda_s3access" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_s3access.arn
}

data "aws_iam_policy_document" "lambda_sesaccess" {
  statement {
    effect = "Allow"

    actions = [
      "ses:SendEmail"
    ]

    resources = ["arn:aws:ses:us-east-1:890732368707:identity/aparnauk01@gmail.com",
    "arn:aws:ses:us-east-1:890732368707:identity/aparnauk1992@gmail.com"]
  }
}

resource "aws_iam_policy" "lambda_sesaccess" {
  name        = "lambda-sesaccess"
  path        = "/"
  description = "IAM policy for sending emails using ses from a lambda"
  policy      = data.aws_iam_policy_document.lambda_sesaccess.json
}

resource "aws_iam_role_policy_attachment" "lambda_sesaccess" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_sesaccess.arn
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.func.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket.arn
}

data "archive_file" "lambdaa" {
  type        = "zip"
  source_file = "lambda.py"
  output_path = "lambda_function_payload5.zip"
}



resource "aws_lambda_function" "func" {
  filename      = "lambda_function_payload5.zip"
  function_name = "email-lambda1"
  role          = aws_iam_role.iam_for_lambda.arn
  runtime       = "python3.13"
  handler       = "lambda.lambda_handler"
}


resource "aws_s3_bucket" "bucket" {
  bucket = "csv-s3-generator"

  tags = {
    Name        = "emailgeneratorapp"
    Environment = "Dev"
    Created-by  = "Aparna"
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.func.arn
    events              = ["s3:ObjectCreated:*"]
    
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

