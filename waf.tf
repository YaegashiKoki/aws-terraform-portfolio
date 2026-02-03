# --- WAF Web ACL (セキュリティの盾本体) ---
resource "aws_wafv2_web_acl" "main" {
  name        = "portfolio-waf"
  description = "WAF for Portfolio ALB"
  scope       = "REGIONAL" # ALB用はREGIONAL, CloudFront用はCLOUDFRONT

  default_action {
    allow {} # 基本は通す（ルールに引っかかったらブロック）
  }

  # 1. AWS推奨のコモンルールセット (OWASP Top 10などをカバー)
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 10

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # 2. SQLインジェクション対策ルールセット
  rule {
    name     = "AWS-AWSManagedRulesSQLiRuleSet"
    priority = 20

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesSQLiRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "portfolio-waf"
    sampled_requests_enabled   = true
  }
}

# --- ALBとの紐付け ---
# これがないとWAFはただ置いてあるだけで機能しません
resource "aws_wafv2_web_acl_association" "main" {
  resource_arn = aws_lb.main.arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}