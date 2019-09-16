provider "aws" {
  region              = var.regions[var.network]
  allowed_account_ids = [var.aws_account_id]

  assume_role {
    role_arn = "arn:aws:iam::${var.aws_account_id}:role/admin"
  }
}
