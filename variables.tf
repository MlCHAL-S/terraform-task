variable "project" {
  type = string
  description = "GCP project ID"
}

variable "region" {
  type = string
  description = "GCP region"
}

variable "zone" {
  type = string
  description = "GCP zone"
}

variable "image" {
  type = string
  description = "Base image for VM instances"
}

variable "machine_type" {
  type = string
  description = "Machine type for instances"
}
