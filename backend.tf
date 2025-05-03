terraform {
    required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.8.0"
    }
  }

  backend "gcs" {
    bucket  = "terraform-bucket-playground-s-11-d69c6de9"
    prefix  = "terraform/state"
  }
}
