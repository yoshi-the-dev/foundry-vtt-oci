resource "oci_core_volume_backup_policy" "foundry_volume_backup_policy" {
  compartment_id = oci_core_instance.foundry_instance.compartment_id
  display_name   = "foundry_volume_backup_policy"

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