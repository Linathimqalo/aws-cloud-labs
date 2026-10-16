# -----------------------------------------------------------------------------
# External Access Analyzer
# Finds resources (S3, IAM roles, KMS keys, etc.) that grant access to
# entities outside your AWS account or organization.
# -----------------------------------------------------------------------------

resource "aws_accessanalyzer_analyzer" "external" {
  analyzer_name = "${var.project_name}-external"
  type          = "ACCOUNT"

  tags = {
    Name = "${var.project_name}-external"
  }
}

# -----------------------------------------------------------------------------
# Unused Access Analyzer
# Finds IAM roles and permissions that have not been used within a
# defined period. Helps with least-privilege cleanup.
# -----------------------------------------------------------------------------

resource "aws_accessanalyzer_analyzer" "unused" {
  analyzer_name = "${var.project_name}-unused"
  type          = "ACCOUNT_UNUSED_ACCESS"

  configuration {
    unused_access {
      unused_access_age = var.unused_access_age
    }
  }

  tags = {
    Name = "${var.project_name}-unused"
  }
}