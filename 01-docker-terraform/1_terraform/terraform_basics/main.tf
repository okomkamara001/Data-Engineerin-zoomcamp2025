terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.16.0"
    }
  }
}

provider "google" {
  # configurations
  credentials = "./keys/my-creds.json"
  project     = "charged-scholar-446408-g1"
  region      = "us-east1"
}


resource "google_storage_bucket" "demo-bucket" {
  name          = "de-zoomcamp-terraform-bucket"
  location      = "US"
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}

resource "google_bigquery_dataset" "demo-dataset" {
  dataset_id = "zoomcamp_dataset"

}