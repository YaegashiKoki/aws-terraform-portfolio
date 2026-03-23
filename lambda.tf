# PythonコードをZip化
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/src"
  output_path = "${path.module}/lambda_function_payload.zip"
}

# Lambda関数
resource "aws_lambda_function" "ai_api" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "ai-helpdesk-api"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "index.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.11"
  timeout          = 30  # ★これを追加！(OpenAIのAPI待ち時間に対応)
}

# API Gateway (REST API)
resource "aws_api_gateway_rest_api" "ai_api" {
  name = "AIHelpdeskAPI"
}

resource "aws_api_gateway_resource" "ask" {
  rest_api_id = aws_api_gateway_rest_api.ai_api.id
  parent_id   = aws_api_gateway_rest_api.ai_api.root_resource_id
  path_part   = "ask"
}

resource "aws_api_gateway_method" "post" {
  rest_api_id   = aws_api_gateway_rest_api.ai_api.id
  resource_id   = aws_api_gateway_resource.ask.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.ai_api.id
  resource_id = aws_api_gateway_method.post.resource_id
  http_method = aws_api_gateway_method.post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.ai_api.invoke_arn
}

# API GatewayからLambdaを叩くための許可
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ai_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.ai_api.execution_arn}/*/*"
}

# デプロイ設定
resource "aws_api_gateway_deployment" "ai_api" {
  depends_on = [aws_api_gateway_integration.lambda]
  rest_api_id = aws_api_gateway_rest_api.ai_api.id
}

resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.ai_api.id
  rest_api_id   = aws_api_gateway_rest_api.ai_api.id
  stage_name    = "dev"
}

# 完了後にURLを表示
output "lambda_api_url" {
  value = "${aws_api_gateway_stage.dev.invoke_url}/ask"
}

# lambda.tf に追記
resource "aws_ssm_parameter" "openai_api_key" {
  name        = "/ai-helpdesk/openai-api-key"
  description = "OpenAI API Key for Lambda"
  type        = "SecureString"
  value       = "dummy_key_please_replace_in_console" # 後で手動で書き換えます

  # Terraform実行時に、AWS上の実際の値（本物のキー）をダミー値で上書きしないようにする設定
  lifecycle {
    ignore_changes = [value]
  }
}