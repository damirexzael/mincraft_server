# This resource is the core take away of this example.
resource "aws_lambda_permission" "default" {
  statement_id  = "AllowExecutionFromAlexa"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.default.function_name
  principal     = "alexa-appkit.amazon.com"
}

resource "aws_lambda_function" "default" {
  filename         = "/tmp/lambda_minecraft.zip"
  source_code_hash = filebase64sha256("/tmp/lambda_minecraft.zip")
  function_name    = "terraform_lambda_alexa_example"
  role             = aws_iam_role.default.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.6"
  environment {
    variables = {
      INSTANCE_ID = aws_instance.instance_connect.id
    }
  }
}

resource "aws_iam_role" "default" {
  name = "terraform_lambda_alexa_example"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

####
# Alternatively you could attach the Amazon provided AWSLambdaBasicExecutionRole
# via an aws_iam_policy_attachment resource. However, the aws_iam_policy_attachment
# resource can be [destructive](https://www.terraform.io/docs/providers/aws/r/iam_policy_attachment.html)
# so it was avoided for the purporse of this example.
resource "aws_iam_role_policy" "default" {
  name = "terraform_lambda_alexa_example"
  role = aws_iam_role.default.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "ec2:*",
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
}
