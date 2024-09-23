# resource "aws_wafv2_web_acl" "public_alb_waf" {
#   name        = "${var.project}-${var.environment}-public-alb-waf"
#   scope       = "REGIONAL"
#   default_action {
#     allow {}
#   }

#   # 0. IP Whitelist
#   rule {
#     name     = "IPWhitelist"
#     priority = 0
#     action {
#       allow {}
#     }
#     statement {
#       ip_set_reference_statement {
#         arn = aws_wafv2_ip_set.whitelist.arn  # Reference to the automatically generated ARN of the IP Set
#       }
#     }
#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "IPWhitelist"
#       sampled_requests_enabled   = true
#     }
#   }

#   # 1. Country Whitelist (Turkey and Sweden)
#   rule {
#     name     = "CountryWhitelist"
#     priority = 1
#     action {
#       allow {}
#     }
#     statement {
#       geo_match_statement {
#         country_codes = ["TR", "SE"]
#       }
#     }
#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "CountryWhitelist"
#       sampled_requests_enabled   = true
#     }
#   }

#   # 2. Rate Limit
#   rule {
#     name     = "RateLimit"
#     priority = 2
#     action {
#       block {}
#     }
#     statement {
#       rate_based_statement {
#         limit              = var.rate_limit
#         aggregate_key_type = "IP"
#       }
#     }
#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "RateLimit"
#       sampled_requests_enabled   = true
#     }
#   }

#   # 3. SQL Injection Protection
#   rule {
#     name     = "SQLInjectionProtection"
#     priority = 3
#     override_action {
#       count {}
#     }
#     statement {
#       managed_rule_group_statement {
#         name        = "AWSManagedRulesSQLiRuleSet"
#         vendor_name = "AWS"
#       }
#     }
#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "SQLInjectionProtection"
#       sampled_requests_enabled   = true
#     }
#   }

#   # 4. Linux Protection
#   rule {
#     name     = "AWSManagedRulesLinuxRuleSet"
#     priority = 4
#     override_action {
#       count {}
#     }
#     statement {
#       managed_rule_group_statement {
#         name        = "AWSManagedRulesLinuxRuleSet"
#         vendor_name = "AWS"
#       }
#     }
#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "LinuxProtection"
#       sampled_requests_enabled   = true
#     }
#   }

#   # 5. Anonymous IP Protection
#   rule {
#     name     = "AnonymousIPProtection"
#     priority = 5
#     override_action {
#       count {}
#     }
#     statement {
#       managed_rule_group_statement {
#         name        = "AWSManagedRulesAnonymousIpList"
#         vendor_name = "AWS"
#       }
#     }
#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "AnonymousIPProtection"
#       sampled_requests_enabled   = true
#     }
#   }

#   # 6. Admin Protection
#   rule {
#     name     = "AdminProtection"
#     priority = 6
#     action {
#       block {}
#     }
#     statement {
#       byte_match_statement {
#         search_string = "admin"
#         field_to_match {
#           uri_path {}
#         }
#         positional_constraint = "CONTAINS"
#         text_transformation {
#           priority = 0
#           type     = "NONE"
#         }
#       }
#     }
#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "AdminProtection"
#       sampled_requests_enabled   = true
#     }
#   }

#   # 7. AWS Core Rule Set
#   rule {
#     name     = "AWSManagedRulesCommonRuleSet"
#     priority = 7
#     override_action {
#       none {}
#     }
#     statement {
#       managed_rule_group_statement {
#         name        = "AWSManagedRulesCommonRuleSet"
#         vendor_name = "AWS"
#       }
#     }
#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "CoreRuleSet"
#       sampled_requests_enabled   = true
#     }
#   }

#   visibility_config {
#     cloudwatch_metrics_enabled = true
#     metric_name                = "PublicALBWAF"
#     sampled_requests_enabled   = true
#   }
# }

# resource "aws_wafv2_web_acl_association" "public_alb_waf_association" {
#   resource_arn = module.public_alb.alb_arn
#   web_acl_arn  = aws_wafv2_web_acl.public_alb_waf.arn
# }

# resource "aws_wafv2_ip_set" "whitelist" {
#   name              = "${var.project}-${var.environment}-ip-whitelist"
#   scope             = "REGIONAL"
#   ip_address_version = "IPV4"
#   addresses         = ["13.48.94.13/32"]
#   description       = "IP Set for whitelisted IP addresses"
# }