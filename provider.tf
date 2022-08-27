provider "google" {
  project     = var.project_id
  region      = var.resource_region
  credentials = file("./credentials/crediantials.json")
}