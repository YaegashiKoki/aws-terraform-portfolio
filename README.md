# AWS Fargate & IaC Portfolio

TerraformとGitHub Actionsを使用した、セキュアでモダンなAWSコンテナ構築のポートフォリオです。

## 🏗 アーキテクチャ構成
- **Compute:** Amazon ECS (Fargate)
- **Network:** VPC (Public/Private Subnets), ALB
- **IaC:** Terraform
- **CI/CD:** GitHub Actions (Terraform Apply & App Deploy)
- **Security:** Security Group Chaining, Least Privilege IAM Roles
- **Language:** Python (Flask)

## 🚀 デプロイフロー
1. GitHubへコードをPush
2. GitHub Actionsが起動
3. Dockerイメージのビルド & ECRへPush
4. Terraformによるインフラ変更の適用
5. ECSタスク定義の更新とデプロイ

## 🛠 工夫した点
- **完全なIaC化:** ネットワークからアプリ基盤まで全てTerraformで管理。
- **セキュリティ:** セキュリティグループのチェーン設定により、ALB経由以外のアクセスを遮断。
- **自動化:** インフラとアプリのデプロイをワンストップで自動化。