locals {
  environment = var.environment
  project_id  = var.project_id
  region      = var.region
  
  # Common tags - intentionally missing security-related tags
  common_tags = {
    Environment = local.environment
    Project     = "dummy-vulnerable"
  }
}