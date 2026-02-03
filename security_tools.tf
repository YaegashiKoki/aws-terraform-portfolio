# --- GuardDuty (脅威検知) ---
# ※最初の30日間は無料です
resource "aws_guardduty_detector" "main" {
  enable = true
}

# --- IAM Access Analyzer (外部公開チェック) ---
# ※これは完全無料です
resource "aws_accessanalyzer_analyzer" "main" {
  analyzer_name = "portfolio-analyzer"
  type          = "ACCOUNT"
}