variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}
variable zone {
  description = "Zone for instance"
  default     = "europe-west1-b"
}
variable docker_disk_image {
  description = "Disk image for docker"
  default     = "docker-reddit-base-1574717679"
}

variable instances {
  description = "Docker instance quantity"
  default     = 1
}

variable private_key_path {
  description = "Path to the private key used for ssh access"
}


