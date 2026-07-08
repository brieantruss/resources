# GCP and Git Environment Switching (One-Command Workflow)

Date: 2026-07-08

## Purpose
Use one command to switch all local context between environments (account, project, ADC quota project, and git identity).

## Current One-Word Commands
These commands are defined in ~/.bashrc:

- use-arvig
- use-modulo

After opening a new terminal (or running source ~/.bashrc), run one of these and your environment is switched.

## What Each Command Switches
Each switch command sets:

1. gcloud active account
2. gcloud active project
3. ADC quota project
4. global git name/email

## Verify After Switching
Run these checks any time:

gcloud config get-value account
gcloud config get-value project
git config --global user.email
bq --project_id=arvig-report-data query --use_legacy_sql=false 'SELECT 1 AS ok'

For Modulo verification, change project_id to my-data-479716.

## Current Function Definitions (for ~/.bashrc)

_switch_env() {
  local account="$1"
  local project="$2"
  local git_email="$3"

  gcloud config set account "$account" --quiet >/dev/null || return 1
  gcloud config set project "$project" --quiet >/dev/null || return 1

  # This may fail if ADC is not initialized yet; keep going and print next step.
  if ! gcloud auth application-default set-quota-project "$project" --quiet >/dev/null 2>&1; then
    echo "ADC quota project not set yet. Run: gcloud auth application-default login"
  fi

  git config --global user.name "Briean Truss"
  git config --global user.email "$git_email"

  echo "Switched:"
  echo "  account=$(gcloud config get-value account 2>/dev/null)"
  echo "  project=$(gcloud config get-value project 2>/dev/null)"
  echo "  git_email=$(git config --global user.email 2>/dev/null)"
}

use-arvig() {
  _switch_env "briean.truss.ra@arvig.com" "arvig-report-data" "briean.truss.ra@arvig.com"
}

use-modulo() {
  _switch_env "btruss@moduloinsights.com" "my-data-479716" "btruss@moduloinsights.com"
}

## Add More One-Word Commands Later
Copy this pattern into ~/.bashrc and customize values:

use-ENVNAME() {
  _switch_env "ACCOUNT_EMAIL" "GCP_PROJECT_ID" "GIT_EMAIL"
}

Example:

use-sandbox() {
  _switch_env "you@company.com" "my-sandbox-project" "you@company.com"
}

Then apply changes:

source ~/.bashrc

## First-Time Auth Notes
If switching fails due to auth, run:

gcloud auth login ACCOUNT_EMAIL --update-adc
gcloud auth application-default login

Then run your one-word switch command again.

## Important Separation
- git config controls commit author identity only.
- gcloud account/project controls CLI context.
- ADC controls API-client context.

All three can differ unless switched together.
