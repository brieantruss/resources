# Windows VS Code Fresh Setup Runbook

Date: 2026-07-11

## Goal
Prepare a brand-new Windows machine so it can run the same workflow you use now:
- Git + GitHub
- GCP + BigQuery CLI
- VS Code + Copilot
- Arvig/Dataform repo workflow
- Profile switching commands (Arvig/Modulo/Personal)

## 1) Install Core Tools (PowerShell as Administrator)
Run this block in Windows PowerShell:

```powershell
winget install --id Microsoft.VisualStudioCode -e
winget install --id Git.Git -e
winget install --id GitHub.cli -e
winget install --id Google.CloudSDK -e
winget install --id OpenJS.NodeJS.LTS -e
winget install --id Python.Python.3.12 -e
winget install --id BurntSushi.ripgrep.MSVC -e
```

Optional but useful:

```powershell
winget install --id Microsoft.WindowsTerminal -e
winget install --id JanDeDobbeleer.OhMyPosh -e
```

## 2) Sign In and Basic Tool Bootstrap
Open a new PowerShell window (not admin needed) and run:

```powershell
git --version
gh --version
gcloud --version
node --version
python --version
code --version
```

Sign in to GitHub CLI:

```powershell
gh auth login
```

Sign in to GCP (browser flow):

```powershell
gcloud auth login --update-adc
gcloud auth application-default login
```

## 3) Clone Repositories
Example (adjust paths if you want):

```powershell
New-Item -ItemType Directory -Force -Path "$HOME\dev" | Out-Null
Set-Location "$HOME\dev"

gh repo clone brieantruss/resources
gh repo clone arvig-modulo/arvig_dataform
```

## 4) VS Code Extensions
Install these at minimum:

```powershell
code --install-extension GitHub.copilot
code --install-extension GitHub.copilot-chat
code --install-extension ashishalex.dataform-lsp-vscode
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension GoogleCloudTools.cloudcode
```

## 5) Open the Working Repo in VS Code

```powershell
code "$HOME\dev\arvig_dataform"
```

## 6) Dataform Repo Quick Checks
In a terminal inside arvig_dataform:

```powershell
Set-Location "$HOME\dev\arvig_dataform"

git status
```

Run the repo setup script used by this project (this configures Dataform CLI, Python env, VS Code settings, and MCP config):

```powershell
node .\.tools\scripts\setup.js
```

After setup completes, create the Dataform credentials file in repo root:

```powershell
Set-Location "$HOME\dev\arvig_dataform"
'{"projectId":"arvig-report-data","location":"US"}' | Out-File -Encoding ascii .df-credentials.json
```

Use the Windows wrapper already in repo:
- dataform.cmd

Example:

```powershell
.\dataform.cmd --help
```

Verify end-to-end repo readiness:

```powershell
Set-Location "$HOME\dev\arvig_dataform"

# Dataform
.\dataform.cmd compile
.\dataform.cmd run --dry-run

# Python environment created by setup.js
.\.venv\Scripts\python.exe --version
.\.venv\Scripts\python.exe .\.tools\scripts\analysis.py

# BigQuery CLI
bq --project_id=arvig-report-data query --use_legacy_sql=false "SELECT 1 AS ok"
```

If dataform command is not found globally, use .\dataform.cmd from repo root.

If .venv creation fails during setup.js, reinstall Python from python.org and ensure python is on PATH, then rerun setup.js.

If GCP auth expires later, rerun:

```powershell
gcloud auth login --update-adc
gcloud auth application-default login
```

## 7) Add Profile Switching Commands
Use this companion doc:
- windows_profile_switching_powershell.md

After adding profile functions, restart terminal and run:

```powershell
use-list
use-arvig
use-status
```

## 8) One-Command Environment Capture for Copilot (When You Log In From New Machine)
Run this command and paste output into chat so setup can be finalized quickly:

```powershell
$report = [ordered]@{
  host_name = $env:COMPUTERNAME
  user = $env:USERNAME
  os = (Get-CimInstance Win32_OperatingSystem).Caption
  pwsh = $PSVersionTable.PSVersion.ToString()
  git = (git --version) 2>$null
  gh = (gh --version | Select-Object -First 1) 2>$null
  gcloud = (gcloud --version | Select-Object -First 1) 2>$null
  node = (node --version) 2>$null
  python = (python --version) 2>&1
  code = (code --version | Select-Object -First 1) 2>$null
  gh_auth = (gh auth status 2>&1 | Select-Object -First 6)
  gcloud_account = (gcloud config get-value account 2>$null)
  gcloud_project = (gcloud config get-value project 2>$null)
  profile_path = $PROFILE
  profile_exists = (Test-Path $PROFILE)
}
$report | ConvertTo-Json -Depth 4
```

## 9) Notes
- Keep repos private where appropriate.
- Do not store real tokens in markdown docs.
- For any future machine, repeat sections 1, 2, 3, 7, 8.
