#####################################################################
# Google Cloud Platform
#####################################################################
provider "google" {
    credentials = "${file("gcp-credentials.json")}"
    project = "${var.project}"
    region = "${var.region}"
}

#####################################################################
# Disks
#####################################################################
resource "google_compute_disk" "tuxlabs" {
  name = "tuxlabs"
  image = "ubuntu-os-cloud/ubuntu-1710"
  type = "pd-standard"
  zone = "${var.zone}"
  size = 10
}

#####################################################################
# VM Instances
#####################################################################
resource "google_compute_instance" "tuxlabs" {
    name = "tuxlabs"
    machine_type = "g1-small"
    zone = "${google_compute_disk.tuxlabs.zone}"

    labels = { environment = "dev"}

    boot_disk {
        source = "${google_compute_disk.tuxlabs.name}"
        auto_delete = true
    }

    network_interface {
        network = "default"
        access_config {
            # ephemeral external ip address
        }
    }

    metadata {
    }

    scheduling {
        preemptible = false
        on_host_maintenance = "MIGRATE"
        automatic_restart = true
    }

    provisioner "remote-exec" {
        inline = [
            "echo 'hello from $HOSTNAME' > ~/terraform_complete"
        ]
        connection {
            type = "ssh"
            user = "tuxninja",
            private_key = "${file("~/.ssh/id_rsa")}"
        }
    }

}

#####################################################################
# Firewall Rules
#####################################################################
resource "google_compute_firewall" "allow-ssh" {
    name = "allow-ssh-home"
    network = "default"

    allow {
        protocol = "tcp"
        ports = ["22"]
    }

    source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow-http" {
    name = "allow-http"
    network = "default"

    allow {
        protocol = "tcp"
        ports = ["80"]
    }

    source_ranges = ["0.0.0.0/0"]
    target_tags = ["http"]
}