# GCP and Git Environment Switching (One-Command Workflow)

Date: 2026-07-08

## Purpose
Use one command to switch all local context between environments (account, project, ADC quota project, and git identity).

## Current One-Word Commands
These commands are defined in ~/.bashrc:

- use-arvig
- use-modulo
- use-personal
- use-default
- use-clear
- use-status
- use-add-client

Also available:

- use-profile <name>
- use-list

After opening a new terminal (or running source ~/.bashrc), run one of these and your environment is switched.

## What Each Command Switches
Each switch command sets:

1. gcloud active account
2. gcloud active project
3. ADC quota project
4. global git name/email
5. attempts gh account switch if a GitHub username is configured for that profile

## Quick Command Guide

- use-arvig: switch to Arvig profile
- use-modulo: switch to Modulo profile
- use-personal: switch to personal profile
- use-profile <name>: switch to any named profile
- use-list: list available profile names
- use-status: print active profile + current gcloud/git/gh context
- use-default: switch to ENV_SWITCH_DEFAULT_PROFILE (or personal if unset)
- use-clear: clear gcloud account/project and global git name/email
- use-add-client: add a new profile and shorthand command permanently

## Verify After Switching
Run these checks any time:

gcloud config get-value account
gcloud config get-value project
git config --global user.email
bq --project_id=arvig-report-data query --use_legacy_sql=false 'SELECT 1 AS ok'

For Modulo verification, change project_id to my-data-479716.

## Current Function Definitions (for ~/.bashrc)

This setup now uses named profiles.

Key profile commands:

- use-list
- use-profile <name>
- use-arvig
- use-modulo
- use-personal
- use-default
- use-clear
- use-status
- use-add-client

## Add a New Client Profile (Recommended)

Command format:

use-add-client <profile_name> <gcp_account_email> <gcp_project_id_or_dash> <git_email> [git_name] [gh_username]

Notes:

- profile_name should be simple (letters/numbers/dash/underscore)
- pass - for gcp_project_id_or_dash if you do not want a default project
- this appends to ~/.bashrc so it persists across sessions
- this also creates shorthand command use-<profile_name>

Example:

use-add-client acme you@acme.com acme-prod you@acme.com "Briean Truss" acmegithub

Then:

source ~/.bashrc
use-acme
use-status

## Add More Profiles Later
Add another _env_profile_add line in ~/.bashrc:

_env_profile_add "clientname" "gcp_account@company.com" "gcp-project-id" "git@email.com" "Your Name" "github_username"

Then apply changes:

source ~/.bashrc

## Set Your Default Profile

Put this in ~/.bashrc if you want a specific default:

export ENV_SWITCH_DEFAULT_PROFILE=arvig

Then run:

source ~/.bashrc
use-default

## First-Time Auth Notes
If switching fails due to auth, run:

gcloud auth login ACCOUNT_EMAIL --update-adc
gcloud auth application-default login

Then run your one-word switch command again.

## Important Separation
- git config controls commit author identity only.
- gcloud account/project controls CLI context.
- ADC controls API-client context.

- gh auth context is separate; profiles attempt gh auth switch when gh username is configured.

All three can differ unless switched together.

## Clear vs Default

- use-default: switches to ENV_SWITCH_DEFAULT_PROFILE (defaults to personal)
- use-clear: unsets gcloud account/project and global git name/email

use-clear intentionally does not revoke saved ADC credentials or log out gh sessions.

Optional hard reset commands:

gcloud auth application-default revoke
gh auth logout
