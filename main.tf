provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

module "network" {
  source = "./modules/network"
  project = var.project
  region = var.region
}

module "compute" {
  source = "./modules/compute"
  project = var.project
  region = var.region
  zone = var.zone
  image = var.image
  machine_type = var.machine_type
}