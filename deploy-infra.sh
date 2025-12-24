#! /usr/bin/env bash
set -o nounset -o pipefail -o errexit;

# Source the .env file
cd terraform/
. .env

# Validate arguments: $1 folder, $2 action
if [ -z "$1" ]; then
  echo "Error: Folder argument is missing. Use ./deploy-infra.sh core dev plan"
  exit 1
elif [ -z "$2" ]; then
  echo "Error: Terraform Action argument is missing. Use ./deploy-infra.sh core dev plan"
  exit 1
elif [ ! -d "$1" ]; then
  echo "Error: $1 folder doesn't exists!"
  exit 1
elif ! [[ "$2" =~ ^($VALID_ACTIONS)$ ]]; then
  echo "Error: Invalid Terraform action \"$2\" . Must be $VALID_ACTIONS."
  exit 1
fi

# Define Dynamic environment variables
INFRA_DIR=$1
TFACTION=$2

# Validate Infra folder exists
if [ ! -d "$INFRA_DIR" ]; then
  echo "Error: $INFRA_DIR folder doesn't exists!"
  exit 1
fi

cd "$INFRA_DIR"

# ----------------------------------------------------------------
# Install Terraform using tfenv
# ----------------------------------------------------------------
# Check if current Terraform version matches required version
set +o pipefail  # Temporarily disable pipefail
TF_VERSION_OUTPUT=$(terraform version | head -n 1)
set -o pipefail  # Re-enable pipefail
CURRENT_TF_VERSION=$(echo "$TF_VERSION_OUTPUT" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
echo "Current Terraform version: $CURRENT_TF_VERSION"
if [ "$CURRENT_TF_VERSION" != "$TF_VERSION" ]; then
  # Install Terraform using tfenv
  echo "Installing Terraform $TF_VERSION..."
  tfenv use "$TF_VERSION"
fi

# ----------------------------------------------------------------
# Terraform commands
# ----------------------------------------------------------------

# Format
echo "Terraform format..."
terraform fmt

# Initialize
echo "Initializing Terraform..."
terraform init \
  -upgrade \
  -input=false

# Validate
echo "Terraform validate..."
terraform validate

# Imports goes here
# -------------------------------------------------------------------------
# terraform state rm [tfstat elemental]
# terraform import -var-file="$VAR_FILE" [tfstat elemental] [gcloud arn/id]

# Plan
if [[ "_${TFACTION}" =~ ^_(plan|apply)$ ]]; then
  echo "Running Terraform plan..."
  terraform plan \
    -input=false 
fi

# Apply
if [ "_${TFACTION}" == "_apply" ]; then
  echo "Running Terraform apply..."
  terraform apply \
    -auto-approve=true
fi

# Destroy
if [ "_${TFACTION}" == "_destroy" ]; then
  echo "Running Terraform destroy..."
  terraform destroy \
    -input=false
fi
