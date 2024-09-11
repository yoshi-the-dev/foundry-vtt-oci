resource "oci_core_instance" "foundry_instance" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.tenancy_ocid
  display_name        = "foundry_instance"
  shape               = var.compute_shape

  shape_config {
    ocpus         = var.ocpus
    memory_in_gbs = var.memory_in_gbs
  }

  create_vnic_details {
    subnet_id                 = oci_core_subnet.public_subnet.id
    display_name              = "primaryvnic"
    assign_public_ip          = true
    assign_private_dns_record = false
  }

  source_details {
    source_type             = "image"
    source_id               = var.image_id
    boot_volume_size_in_gbs = var.instance_source_details_boot_volume_size_in_gbs
  }

  metadata = {
    ssh_authorized_keys = file("${var.ssh_public_key_path}")
  }
}

resource "oci_core_volume_backup_policy" "foundry_volume_backup_policy" {
  compartment_id = oci_core_instance.foundry_instance.compartment_id
  display_name = "foundry_volume_backup_policy"

  schedules {
    backup_type       = "INCREMENTAL"
    period            = "ONE_WEEK"
    retention_seconds = 3024000

    day_of_week = "MONDAY"
    time_zone   = "REGIONAL_DATA_CENTER_TIME"
  }
}

# Retrieve boot volume attachment for the instance
data "oci_core_boot_volume_attachments" "foundry_boot_volume_attachments" {
  compartment_id      = var.tenancy_ocid
  availability_domain = oci_core_instance.foundry_instance.availability_domain
  instance_id         = oci_core_instance.foundry_instance.id
}

# Retrieve the boot volume
data "oci_core_boot_volume" "foundry_boot_volume" {
  boot_volume_id = data.oci_core_boot_volume_attachments.foundry_boot_volume_attachments.boot_volume_attachments[0].boot_volume_id
}

resource "oci_core_volume_backup_policy_assignment" "foundry_volume_backup_policy_assignment" {
  #Required
  asset_id  = data.oci_core_boot_volume.foundry_boot_volume.id
  policy_id = oci_core_volume_backup_policy.foundry_volume_backup_policy.id
}