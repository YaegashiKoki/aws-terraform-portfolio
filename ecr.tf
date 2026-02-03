# --- ECR (Dockerイメージの保管場所) ---
resource "aws_ecr_repository" "app" {
  name                 = "portfolio-app"
  image_tag_mutability = "MUTABLE"
  force_delete         = true # ポートフォリオ用なので、中身があっても強制削除できるようにする

  # セキュリティ対策: プッシュ時に脆弱性スキャンをONにする
  image_scanning_configuration {
    scan_on_push = true
  }

    # ★ここを追加！ (KMSによる暗号化)
  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_alias.app.arn
  }

  tags = { Name = "portfolio-app-repo" }
}