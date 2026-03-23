# --- ECS Task Execution Role ---
# ECSエージェントがECRからイメージを引いたり、ログを出したりする権限
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "portfolio-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Lambda用の実行ロール
resource "aws_iam_role" "lambda_exec" {
  name = "lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# ログ出力用のポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# iam.tf に追記
resource "aws_iam_policy" "lambda_ssm_policy" {
  name        = "lambda-ssm-policy"
  description = "Allow Lambda to read SSM parameters"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement =[
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter"
        ]
        # 本当はアカウントID等を指定しますが、今回は簡略化のためResourceを絞り込みます
        Resource = "arn:aws:ssm:*:*:parameter/ai-helpdesk/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_ssm_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_ssm_policy.arn
}