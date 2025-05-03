resource "google_compute_instance" "temp" {
  name         = "temp-vm-for-image"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install apache2 -y
    systemctl enable apache2
    systemctl start apache2
    touch /var/tmp/startup-finished
  EOT
}


resource "null_resource" "stop_vm" {
  provisioner "local-exec" {
    command = <<EOT
        until gcloud compute ssh temp-vm-for-image --zone=${var.zone} --command="test -f /var/tmp/startup-finished"; do
            echo "Waiting for startup script to finish..."
            sleep 5
        done
        gcloud compute instances stop temp-vm-for-image --zone=${var.zone}
    EOT
  }

  depends_on = [google_compute_instance.temp]
}

# 2. Create image from stopped VM
resource "google_compute_image" "custom_image" {
  name        = "apache2-test-image"
  source_disk = google_compute_instance.temp.boot_disk[0].source

  depends_on = [null_resource.stop_vm]
}

# 3. Create instance template from image
resource "google_compute_instance_template" "apache_template" {
  name         = "apache-template"
  machine_type = var.machine_type
  tags         = ["apache-server"]


  disk {
    auto_delete  = true
    boot         = true
    source_image = google_compute_image.custom_image.self_link
  }

  network_interface {
    network = "default"
    access_config {

    }
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    echo "<h1>Hello from $(hostname) VM</h1>" | tee /var/www/html/index.html
  EOT

}

# 4. Create MIG
resource "google_compute_region_instance_group_manager" "apache_mig" {
  name   = "apache-mig"
  region = var.region

  base_instance_name = "apache"
  version {
    instance_template = google_compute_instance_template.apache_template.self_link_unique
  }
  target_size = 3
}

# 5. Create health check
resource "google_compute_health_check" "apache" {
  name = "apache-health-check"

  http_health_check {
    port         = 80
    request_path = "/"
  }
}

# 6. LB
resource "google_compute_backend_service" "apache_backend" {
  name          = "apache-backend"
  protocol      = "HTTP"
  health_checks = [google_compute_health_check.apache.id]

  backend {
    group = google_compute_region_instance_group_manager.apache_mig.instance_group
  }
}

resource "google_compute_url_map" "apache_url_map" {
  name            = "apache-url-map"
  default_service = google_compute_backend_service.apache_backend.self_link
}

resource "google_compute_target_http_proxy" "apache_proxy" {
  name    = "apache-proxy"
  url_map = google_compute_url_map.apache_url_map.self_link
}

resource "google_compute_global_forwarding_rule" "apache_forwarding_rule" {
  name       = "apache-forwarding-rule"
  port_range = "80"
  target     = google_compute_target_http_proxy.apache_proxy.id
}
