resource "google_compute_instance" "docker" {
  name         = "docker-gitlab"
  machine_type = "n1-standard-1"
  zone         = var.zone
  tags         = ["docker-gitlab"]

  boot_disk {
    initialize_params { image = var.docker_disk_image }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }

  metadata = {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

    connection {
      type        = "ssh"
      host        = google_compute_address.app_ip.address
      user        = "appuser"
      agent       = false
      private_key = file(var.private_key_path)
    }

  //  provisioner "remote-exec" {
  //    inline = ["echo export DATABASE_URL=\"${var.mongo_ip}\" >> ~/.profile"]
  //  }

  //  provisioner "file" {
  //    source      = "${path.module}/files/puma.service"
  //    destination = "/tmp/puma.service"
  //  }

  //  provisioner "remote-exec" {
  //    script = "${path.module}/files/deploy.sh"
  //  }
}

resource "google_compute_address" "docker_ip" {
  name = "reddit-docker-ip"
}

resource "google_compute_firewall" "firewall_puma" {
  name    = "allow-puma-default"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "firewall_docker" {
  name    = "allow-docker-default"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["2376"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "firewall_http_https" {
  name    = "allow-http-https-default"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  source_ranges = ["0.0.0.0/0"]
}

