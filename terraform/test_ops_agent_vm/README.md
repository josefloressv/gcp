# Lab URL
N/A

# How To Run

```sh
gcloud auth application-default revoke # Clean ADC creds for Terraform
gcloud auth application-default login # for Terraform or ADC Auth
gcloud config set project playground-s-xxxx
export GOOGLE_PROJECT=$(gcloud config get project)
# Change the region according the LAB in variables.tf
./deploy-infra.sh test_ops_agent_vm plan

# for gcloud
gcloud auth revoke --all  # Clean SDK creds
gcloud auth login # for gcloud commands or SDK Auth
gcloud config set compute/region xxxx
gcloud config set compute/zone xxxx-x
```

# Test
```sh
# SSH to the EC2 Instance
gcloud compute ssh --zone "us-central1-a" "vm-ops-agent-1" --project "playground-s-11-529b1435"

# Install
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install

# Verify
sudo systemctl status google-cloud-ops-agent --no-pager
sudo systemctl is-enabled google-cloud-ops-agent

# Check logs
sudo journalctl -u google-cloud-ops-agent -n 200 --no-pager
```