# Lab URL
https://www.skills.google/paths/77/course_templates/648/labs/613022

# How To Run

```sh
gcloud auth application-default revoke
gcloud auth application-default login
gcloud config set account xxx@xxx.com
gcloud config set project playground-s-xxxx
export GOOGLE_PROJECT=$(gcloud config get project)
# Change the region according the LAB in variables.tf
./deploy-infra.sh lab_nlb plan

```

# Notes
NAME  ZONE            MACHINE_TYPE  PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP    STATUS
www1  europe-west4-b  e2-small                   10.164.0.2   35.204.61.208  RUNNING

NAME  ZONE            MACHINE_TYPE  PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP  STATUS
www2  europe-west4-b  e2-small                   10.164.0.3   34.90.1.92   RUNNING

NAME  ZONE            MACHINE_TYPE  PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP   STATUS
www3  europe-west4-b  e2-small                   10.164.0.4   34.7.186.229  RUNNING

```sh
while true; do curl -m1 $IPADDRESS; done
```