output "instance_public_ip" {
  description = "Public IP of the Foundry instance"
  value       = oci_core_instance.foundry_instance.public_ip
}