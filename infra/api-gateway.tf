data "aws_iam_policy_document" "allow_demo_vpc" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "execute-api:Invoke",
    ]

    resources = [
      "execute-api:/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceVpc"
      values   = ["${aws_vpc.private_api_gateway_demo_vpc.id}"]
    }
  }
}

resource "aws_api_gateway_rest_api" "private_api_gateway_demo" {
  name = "private-api-gateway-demo"

  endpoint_configuration {
    types = ["PRIVATE"]
  }

  policy = "${data.aws_iam_policy_document.allow_demo_vpc.json}"
}

resource "aws_api_gateway_resource" "hello_lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.private_api_gateway_demo.id}"
  parent_id   = "${aws_api_gateway_rest_api.private_api_gateway_demo.root_resource_id}"
  path_part   = "hello-lambda"
}

resource "aws_api_gateway_method" "get_method_hello_lambda" {
  rest_api_id   = "${aws_api_gateway_rest_api.private_api_gateway_demo.id}"
  resource_id   = "${aws_api_gateway_resource.hello_lambda.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_method_hello_lambda_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.private_api_gateway_demo.id}"
  resource_id             = "${aws_api_gateway_resource.hello_lambda.id}"
  http_method             = "${aws_api_gateway_method.get_method_hello_lambda.http_method}"
  type                    = "AWS"
  uri                     = "${aws_lambda_function.demo_lambda.invoke_arn}"
  integration_http_method = "POST"
}

resource "aws_api_gateway_method_response" "get_method_response_hello_lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.private_api_gateway_demo.id}"
  resource_id = "${aws_api_gateway_resource.hello_lambda.id}"
  http_method = "${aws_api_gateway_integration.get_method_hello_lambda_integration.http_method}"
  status_code = "200"

  # response_models = {
  #   "application/json" = "Empty"
  # }
}

resource "aws_api_gateway_integration_response" "get_method_hello_lambda_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.private_api_gateway_demo.id}"
  resource_id = "${aws_api_gateway_resource.hello_lambda.id}"
  http_method = "${aws_api_gateway_integration.get_method_hello_lambda_integration.http_method}"
  status_code = "${aws_api_gateway_method_response.get_method_response_hello_lambda.status_code}"

  depends_on = [
    "aws_api_gateway_integration.get_method_hello_lambda_integration",
  ]
}

resource "aws_api_gateway_deployment" "private_api_gateway_demo_deployment" {
  rest_api_id = "${aws_api_gateway_rest_api.private_api_gateway_demo.id}"
  stage_name  = "demo"

  depends_on = [
    "aws_api_gateway_integration.get_method_hello_lambda_integration",
    "aws_api_gateway_integration_response.get_method_hello_lambda_integration_response",
  ]
}

# resource "aws_lambda_permission" "demo_lambda_permission" {
#   action        = "lambda:InvokeFunction"
#   function_name = "${aws_lambda_function.demo_lambda.arn}"
#   principal     = "apigateway.amazonaws.com"

#   source_arn = "${aws_api_gateway_rest_api.private_api_gateway_demo.execution_arn}/*/*/*}"

#   depends_on = [
#     "aws_api_gateway_deployment.private_api_gateway_demo_deployment",
#   ]
# }

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.demo_lambda.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:us-west-2:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.private_api_gateway_demo.id}/*/${aws_api_gateway_method.get_method_hello_lambda.http_method}${aws_api_gateway_resource.hello_lambda.path}"
}

output "url" {
  value = "${aws_api_gateway_deployment.private_api_gateway_demo_deployment.invoke_url}"
}
