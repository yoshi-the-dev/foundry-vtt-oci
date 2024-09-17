<h1 align="center">Foundry VTT OCI</h1> 

<div align="center">
  <img src="https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform badge"/>
  <img src="https://img.shields.io/badge/Oracle-F80000?style=for-the-badge&logo=Oracle&logoColor=white" alt="Oracle badge"/>
</div>

<br>
 
This Terraform setup expects to provide an easy way to automatically deploy a functional, free Oracle Cloud hosted instance following the [suggested specifications](https://foundryvtt.wiki/en/setup/hosting/always-free-oracle) for installing Foundry VTT on cloud.

### Credits [![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
Based on https://github.com/MrDionysus/foundry-vtt-oci-terraform implementation.

Updated the values, improved the documentation for less-familiar users and added some other things like a volume backup system, the possibility of an automatic setup, and some other interesting configurable variables.

## Prerequisites
 - A valid license for [Foundry VTT](https://foundryvtt.com).
 - A new [Oracle OCI account](https://cloud.oracle.com).
 - A local installation of Terraform. Installation details can be found on the [official page](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).

## Usage
Before starting, you need to clone this repo to your system.
```bash
git clone https://github.com/yoshichulo/foundry-vtt-oci.git
```

### Preparing the SSH keys
You need to create Create an SSH key to use to access your instance. This key pair will be used later to allow you to SSH into your new server so that you can set up the Foundry VTT software. Store it wherever you store your SSH keys (typically `%USERPROFILE%/.ssh` on `Windows` or `~./ssh` on `Linux`).
```bash
ssh-keygen -t rsa -N "" -b 2048 -C <your-ssh-key-name> -f <your-ssh-key-name>
```

That will generate a private key (`your-ssh-key-name`) and a public key (`your-ssh-key-name.pub`) that, as mentioned before, will be used by you later on when you want to access the server.

Now you need to generate an aditional pair of keys for being able to communicate with the OCI API and being able to provide all the resources to your infrastructure. For that, you need to follow the following steps:

1. Create the `.oci` directory, where you'll save your keys.
```bash
mkdir <your-home-directory>/.oci
```
*Note: (if you're using WSL, as on the official documentation mentions, it's recommend to create it on the Linux environment directly instead of a `/mnt/` one, so you don't need to tweak the permissions with `chmod` later on).*

2. Generate a 2048-bit private key in a PEM format:
```bash
# Using ssh-keygen
ssh-keygen -t rsa -b 2048 -m PEM -f <your-home-directory>/.oci/<your-rsa-key-name>.pem

# Or using OpenSSL
openssl genrsa -out <your-home-directory>/.oci/<your-rsa-key-name>.pem 2048 && \
openssl rsa -pubout -in <your-home-directory>/.oci/<your-rsa-key-name>.pem -out $HOME/.oci<your-rsa-key-name>_public.pem
```

3. Change permissions, so only you can read and write to the private key file (important step. If not, your system will complain later on about the permissions not being strict enough).
```bash
chmod 600 <your-home-directory>/.oci/<your-rsa-key-name>.pem
```

Now, you'll need to add this public key to your user account. For that:
- In the OCI Console's top navigation bar, click the Profile menu, and then go to User settings.
- Click **API Keys**.
- Click **Add API Key**.
- Select **Paste Public Keys**.
- Paste value from previous step, including the lines with `BEGIN PUBLIC KEY` and `END PUBLIC KEY`.
- Click **Add**.

**Save those values for now**, since they'll be used later and can't be seen again. You'll need to add again your API key if you lose this information.
More information on the [official documentation page](https://docs.oracle.com/en-us/iaas/developer-tutorials/tutorials/tf-provider/01-summary.htm).

### Preparing your .tfvars file

#### Required changes
- `tenancy_ocid`: your OCI tenancy OCID (values generated when added the API key).
- `user_ocid`: your OCI user OCID (values generated when added the API key).
- `fingerprint`: your OCI fingerprint (values generated when added the API key).
- `rsa_private_key_path`: path to your RSA private key (`<your-home-directory>/.oci/<your-rsa-key-name>.pem`).
- `region_identifier`: your tenant region ID (you can check either when added the API key or on [your regions page](https://cloud.oracle.com/regions)). 
- `ssh_public_key_path`: path to SSH public key that you will use to connect to your instance (the one we generated at the beginning).
- `alert_rule_recipients`: email address to be notified if budget is exceeded

#### Optional changes
These are changes that you can customize based on your needs. The ones that are already present allow you to create up to two instances, using 50% of the allowed free resources on each one. I'm running some games with around 5 players and +100 active modules at the same time without any issues.

- `compute_shape`: shape of an instance. Default one is `VM.Standard.A1.Flex`.
- `instance_source_details_boot_volume_size_in_gbs`: boot volume size in GBs. Default one is `80`.
- `memory_in_gbs`: total amount of memory in GBs. Default one is `12`.
- `ocpus`: total amount of OCPUs available. Default one is `2`.
- `image_id`: image that will be installed on the instance. Default one is `Ubuntu 20.04`. You can check others on [the official page](https://docs.oracle.com/en-us/iaas/images/). Be sure that it's supported for your compute shape.
- `budget_amount`: maximum budget for the account in $. With the default configuration, it should be always free. Default is `1`.
- `ingress_ports`: list of ports to allow through the security group. Default ones are `[22, 80, 443, 30000]`.

#### Planning and running
Once you have everything prepared, you'll only need to run the following commands:
```bash
# Initialize your Terraform project and download the OCI provider
terraform init 

# Start the provisioning
terraform apply -var-file=oci-vars.tfvars
```

*Note: you'll need to answer "yes" once you execute the `apply` command to execute the changes.*

## F.A.Q

#### I receive an "out of capacity" error when trying to apply the changes

It's normal. Depending on your region, getting Free Tier resources can be hard. However, the instance is the only thing that may rise some errors. Everything else should be already created.

You can run the included `keeptrying.sh` (`Linux`) script or `keeptrying.ps1` (`Windows`), which will try to create the compute resource every 60 seconds and will continue until it finds the word `Apply` in the results, which will happen once your instance gets created.

Be patient, since it can take from a few minutes to some hours.

#### How do I connect to my instance?

For connecting via SSH you'll need your instance IP. You can find it on [your instances](https://cloud.oracle.com/compute/instances) page. Also, the user may vary if you use a different image than `Ubuntu`.

```bash
ssh -i /path/to/your/private/key ubuntu@<instance_ip>

# For example
ssh -i ~/.ssh/foundry-ssh ubuntu@1.2.3.4
```

## Contact
If you have questions you can reach out to me at **yoshi.png** on Discord.

If you think there's something that can be improved, feel free to open a PR or add an issue to discuss it 🙂.
