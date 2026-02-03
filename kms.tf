# --- KMS Key (カスタマー管理キー) ---
resource "aws_kms_key" "app" {
  description             = "KMS key for Portfolio App"
  deletion_window_in_days = 7 # 削除しても7日間は復元可能（最小値）
  enable_key_rotation     = true # 毎年鍵を自動交換する設定（SCS重要ポイント）
}

# --- Alias (人間が読みやすい名前) ---
resource "aws_kms_alias" "app" {
  name          = "alias/portfolio-key"
  target_key_id = aws_kms_key.app.key_id
}