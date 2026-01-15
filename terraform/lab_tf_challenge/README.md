# Lab URL
https://www.skills.google/paths/77/course_templates/648/labs/613022

# How To Run

```sh
gcloud auth application-default revoke # Clean ADC creds for Terraform
gcloud auth application-default login # for Terraform or ADC Auth
gcloud config set project playground-s-xxxx
export GOOGLE_PROJECT=$(gcloud config get project)
# Change the region according the LAB in variables.tf
./deploy-infra.sh lab_tf_challenge plan

# for gcloud
gcloud auth revoke --all  # Clean SDK creds
gcloud auth login # for gcloud commands or SDK Auth
gcloud config set compute/region xxxx
gcloud config set compute/zone xxxx-x
```

# Test
```sh
while true; do curl -m1 $IPADDRESS; done
```