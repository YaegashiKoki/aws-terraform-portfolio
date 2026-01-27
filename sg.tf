# 1. ALB用 SG (インターネットからHTTP許可)
resource "aws_security_group" "alb" {
  name        = "portfolio-alb-sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "portfolio-alb-sg" }
}

# 2. ECS(アプリ)用 SG (ALBからのみ許可)
resource "aws_security_group" "ecs" {
  name        = "portfolio-ecs-sg"
  description = "Allow traffic from ALB only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id] # ★ここがチェーン設定
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "portfolio-ecs-sg" }
}

# 3. DB用 SG (ECSからのみ許可)
resource "aws_security_group" "db" {
  name        = "portfolio-db-sg"
  description = "Allow traffic from ECS only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL/Aurora from ECS"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id] # ★ここもチェーン設定
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "portfolio-db-sg" }
}