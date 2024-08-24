#!/bin/bash

while ! terraform apply -auto-approve --var-file=oci-vars.tfvars | grep Apply
do
  sleep 60
done
