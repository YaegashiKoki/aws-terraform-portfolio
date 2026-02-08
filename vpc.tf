# --- VPC ---
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "portfolio-vpc" }
}

# --- Internet Gateway (パブリックサブネット用) ---
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "portfolio-igw" }
}

# --- Public Subnets (ALB & NAT Gateway配置用) ---
resource "aws_subnet" "public_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"
  tags              = { Name = "portfolio-public-1a" }
}

resource "aws_subnet" "public_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1c"
  tags              = { Name = "portfolio-public-1c" }
}

# --- Private Subnets (ECS & RDS配置用) ---
resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "ap-northeast-1a"
  tags              = { Name = "portfolio-private-1a" }
}

resource "aws_subnet" "private_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "ap-northeast-1c"
  tags              = { Name = "portfolio-private-1c" }
}

# =========================================================
# ★ NAT Gateway 設定
# ECSがDockerイメージをプルしたり、外へ通信する際に必要になります
# =========================================================


# NAT Gateway用の固定IP (EIP)
resource "aws_eip" "nat_1a" {
  domain = "vpc"
  tags   = { Name = "portfolio-nat-eip-1a" }
}

# NAT Gateway 本体 (パブリックサブネットに配置)
resource "aws_nat_gateway" "nat_1a" {
  allocation_id = aws_eip.nat_1a.id
  subnet_id     = aws_subnet.public_1a.id

  tags = { Name = "portfolio-nat-1a" }

  # IGWが先にできていないとエラーになるため依存関係を指定
  depends_on = [aws_internet_gateway.igw]
}


# --- Route Table (Public) ---
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "portfolio-public-rt" }
}

# Route Table Association (Public)
resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.public.id
}

# --- Route Table (Private) ---
resource "aws_route_table" "private_1a" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1a.id
  }
  

  tags = { Name = "portfolio-private-rt-1a" }
}

resource "aws_route_table" "private_1c" {
  vpc_id = aws_vpc.main.id

  # 本番構成では冗長化のためAZ-cにもNATを置くのが一般的ですが、
  # ポートフォリオ用(節約)なら、cの通信もaのNAT経由にする「クロスAZ」構成もアリです。
  # 一旦ここではルート定義なし(閉域)としておきます。

  tags = { Name = "portfolio-private-rt-1c" }
}

# Route Table Association (Private)
resource "aws_route_table_association" "private_1a" {
  subnet_id      = aws_subnet.private_1a.id
  route_table_id = aws_route_table.private_1a.id
}

resource "aws_route_table_association" "private_1c" {
  subnet_id      = aws_subnet.private_1c.id
  route_table_id = aws_route_table.private_1c.id
}