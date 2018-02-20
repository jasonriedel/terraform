output "internal_ip" {
  value = "${google_compute_instance.tuxlabs.network_interface.0.network_ip}"
}

output "external_ip" {
  value = "${google_compute_instance.tuxlabs.network_interface.0.access_config.0.assigned_nat_ip}"
}

output "instance_id" {
  value = "${google_compute_instance.tuxlabs.instance_id}"
}