# gcp
GCP PlayGround

Authentica with Service Account key
```bash
# 1) Save the key to a file (lock it down)
mkdir -p ~/.gcp
chmod 700 ~/.gcp
code ~/.gcp/sa-key.json
# paste the key
# 2) Authenticate gcloud as the service account
gcloud auth activate-service-account --key-file="~/.gcp/sa-key.json"
# 3) Set the project (important)
gcloud config set project playground-s-11-529b1435
# 4) Test
gcloud auth list
```

If you’re running an app locally (ADC)
Some client libraries expect Application Default Credentials, not just gcloud auth.
```bash
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.gcp/sa-key.json"
```

What you can do with a Service Account key

Typical uses:
	•	Run gcloud / gsutil / bq locally as a non-human identity
	•	CI/CD automation (GitHub Actions, Jenkins, etc.)
	•	Local testing for apps that use Google APIs via ADC (Application Default Credentials)

What it doesn’t magically do:
	•	It won’t grant access beyond the service account’s IAM roles.
	•	It’s not ideal for day-to-day human use (keys are risky vs user auth or impersonation).