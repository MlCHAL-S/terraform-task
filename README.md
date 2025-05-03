# Terraform GCP Load Balanced Apache Deployment

## Requirements

1. Everything should be inside Terraform configuration files, manual changes are not allowed.  
2. Try to use terraform modules to segregate resources by its types (compute, network).  
3. Create a temporary VM with metadata script installing HTTP server (Apache) with a simple website inside.  
4. Create an image from a temporary VM.  
5. Terraform should create a scale set of 3 instances (use predefined image as source image for VMs), including external load balancer with health checks, everything should be done via terraform tf/tfstate files.  
6. Every host should display server number/hostname to ensure that load balancer is working.  
7. Users should be able to connect to the website in High Availability mode via external load balancer IP.  
8. Add firewall for accessing external load balancer from limited IP addresses range and only for certain ports.  
9. Use Public Cloud storage service as backend for Terraform state.  

## How to Run

10. Create a GCS bucket for the Terraform backend.

11. Update `terraform.tfvars` with your values:
    - `project`
    - `region`
    - `zone`
    - `bucket`

12. Initialize Terraform:

```bash
terraform init
```

```bash
terraform apply
```