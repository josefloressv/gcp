# Google Cloud CLI

```bash
# Authenticate
gcloud init

# Cloud Storage tool
gsutil

# List Instances (Compute Engine)
gcloud compute instances list --project my-project --zone us-central1-a

gcloud auth list

gcloud config list project

gcloud services enable run.googleapis.com

gcloud config set compute/region us-west1
LOCATION="us-west1"

gcloud container images list
gcloud auth configure-docker

gcloud container images list

cloud config set compute/region NAME
gcloud config set account `ACCOUNT`
gcloud config set compute/region europe-west4
gcloud config set compute/zone europe-west4-b

gcloud config get project
```