terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}