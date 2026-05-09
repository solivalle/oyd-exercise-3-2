resource "aws_iam_role" "lambda" {
  name = "${var.name}-${var.environment}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "this" {
  function_name    = "${var.name}-${var.environment}"
  filename         = "${path.module}/../../../app/function.zip"
  source_code_hash = filebase64sha256("${path.module}/../../../app/function.zip")
  handler          = "index.handler"
  runtime          = "nodejs22.x"
  architectures    = [var.architecture]
  memory_size      = var.memory_size
  role             = aws_iam_role.lambda.arn

  environment {
    variables = {
      COMPUTE_TYPE = "lambda"
    }
  }
}

resource "aws_apigatewayv2_api" "this" {
  name          = "${var.name}-${var.environment}"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "this" {
  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.this.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "rates" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "GET /rates"
  target    = "integrations/${aws_apigatewayv2_integration.this.id}"
}

resource "aws_apigatewayv2_route" "convert" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "POST /convert"
  target    = "integrations/${aws_apigatewayv2_integration.this.id}"
}

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}