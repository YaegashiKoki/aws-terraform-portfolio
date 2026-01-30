terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # ★ S3 Backend 設定
  backend "s3" {
    bucket         = "tfstate-portfolio-634220481756"
    key            = "portfolio/terraform.tfstate"    # ファイル名
    region         = "ap-northeast-1"
    dynamodb_table = "tfstate-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = "ap-northeast-1"
}