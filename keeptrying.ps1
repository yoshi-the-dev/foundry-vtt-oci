while ($true) {
  $output = terraform apply -auto-approve -var-file=oci-vars.tfvars
  if ($output -match "Apply") {
      break
  }
  Start-Sleep -Seconds 60
}