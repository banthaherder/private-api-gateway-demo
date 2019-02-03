variable "lambda_src_path" {
  type        = "string"
  description = "The path to src zip"
  default     = "../.tmp/zips/demoFunction.zip"
}

variable "lambda_name" {
  type        = "string"
  description = "The name for the demo lambda"
  default     = "demoFunction"
}

resource "aws_iam_role" "demo_lambda_role" {
  name = "svc_lambda_role"

  assume_role_policy = <<EOF
{   
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
            "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow"
        }
    ]
}  
EOF
}

resource "aws_iam_policy" "lambda_execution_role_policy" {
  name = "AWSLambdaBasicExecutionRoleFor${title(var.lambda_name)}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:us-west-2:${data.aws_caller_identity.current.account_id}:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:us-west-2:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.lambda_name}:*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_execution_role_policy_attach" {
  role       = "${aws_iam_role.demo_lambda_role.name}"
  policy_arn = "${aws_iam_policy.lambda_execution_role_policy.arn}"
}

resource "aws_lambda_function" "demo_lambda" {
  filename         = "${var.lambda_src_path}"
  function_name    = "${var.lambda_name}"
  handler          = "main"
  role             = "${aws_iam_role.demo_lambda_role.arn}"
  source_code_hash = "${base64sha256(file("${var.lambda_src_path}"))}"
  runtime          = "go1.x"
  timeout          = 10
}
