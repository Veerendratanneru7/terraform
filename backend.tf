terraform {
  backend "s3" {
    bucket         = "smartvault-terraform-state"
    key            = "mfa/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
