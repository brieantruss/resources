# Windows Profile Switching (PowerShell)

Date: 2026-07-11

## Goal
Provide the same style commands on Windows that you used on Linux:
- use-arvig
- use-modulo
- use-personal
- use-list
- use-status
- use-default
- use-clear
- use-profile <name>

## 1) Open Your PowerShell Profile

```powershell
if (!(Test-Path $PROFILE)) {
  New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}
notepad $PROFILE
```

Paste everything below into your profile file.

## 2) Profile Function Block

```powershell
$global:EnvProfiles = @{
  arvig = @{
    gcloudAccount = 'briean.truss.ra@arvig.com'
    gcpProject    = 'arvig-report-data'
    gitName       = 'Briean Truss'
    gitEmail      = 'briean.truss.ra@arvig.com'
    ghUser        = 'brieantruss'
  }
  modulo = @{
    gcloudAccount = 'btruss@moduloinsights.com'
    gcpProject    = 'my-data-479716'
    gitName       = 'Briean Truss'
    gitEmail      = 'btruss@moduloinsights.com'
    ghUser        = 'btruss13'
  }
  personal = @{
    gcloudAccount = 'briean.j.truss@gmail.com'
    gcpProject    = ''
    gitName       = 'Briean Truss'
    gitEmail      = 'briean.j.truss@gmail.com'
    ghUser        = 'btruss13'
  }
}

function Get-CurrentProfileName {
  $acct = (gcloud config get-value account 2>$null)
  $proj = (gcloud config get-value project 2>$null)
  $mail = (git config --global user.email 2>$null)

  foreach ($k in $global:EnvProfiles.Keys) {
    $p = $global:EnvProfiles[$k]
    if ($p.gcloudAccount -eq $acct -and $p.gcpProject -eq $proj -and $p.gitEmail -eq $mail) {
      return $k
    }
  }
  return '(custom/unknown)'
}

function use-profile {
  param([Parameter(Mandatory=$true)][string]$Name)

  if (-not $global:EnvProfiles.ContainsKey($Name)) {
    Write-Host "Unknown profile: $Name"
    use-list
    return
  }

  $p = $global:EnvProfiles[$Name]

  if ($p.gcloudAccount) { gcloud config set account $p.gcloudAccount | Out-Null }

  if ($p.gcpProject) {
    gcloud config set project $p.gcpProject | Out-Null
    gcloud auth application-default set-quota-project $p.gcpProject | Out-Null
  } else {
    gcloud config unset project | Out-Null
  }

  if ($p.gitName)  { git config --global user.name  "$($p.gitName)" }
  if ($p.gitEmail) { git config --global user.email "$($p.gitEmail)" }

  if ($p.ghUser) {
    gh auth switch -u $p.ghUser 2>$null | Out-Null
  }

  Write-Host "Switched to profile: $Name"
  use-status
}

function use-list {
  Write-Host 'Available profiles:'
  $global:EnvProfiles.Keys | Sort-Object | ForEach-Object { "- $_" }
}

function use-status {
  Write-Host "Active profile: $(Get-CurrentProfileName)"
  Write-Host "gcloud account: $(gcloud config get-value account 2>$null)"
  Write-Host "gcloud project: $(gcloud config get-value project 2>$null)"
  Write-Host "git name: $(git config --global user.name 2>$null)"
  Write-Host "git email: $(git config --global user.email 2>$null)"
  Write-Host 'gh auth:'
  gh auth status 2>$null | Select-Object -First 6
}

function use-default {
  $defaultProfile = if ($env:ENV_SWITCH_DEFAULT_PROFILE) { $env:ENV_SWITCH_DEFAULT_PROFILE } else { 'personal' }
  use-profile $defaultProfile
}

function use-clear {
  gcloud config unset account | Out-Null
  gcloud config unset project | Out-Null
  git config --global --unset user.name 2>$null
  git config --global --unset user.email 2>$null
  Write-Host 'Cleared local gcloud account/project and global git name/email.'
  Write-Host 'This does not revoke ADC or fully logout gh sessions.'
}

function use-arvig   { use-profile 'arvig' }
function use-modulo  { use-profile 'modulo' }
function use-personal { use-profile 'personal' }
```

## 3) Reload Profile and Verify

```powershell
. $PROFILE
use-list
use-arvig
use-status
```

## 4) Add a New Client Profile
Add another entry under $global:EnvProfiles in your profile file.

Template:

```powershell
clientname = @{
  gcloudAccount = 'you@client.com'
  gcpProject    = 'client-project-id'
  gitName       = 'Briean Truss'
  gitEmail      = 'you@client.com'
  ghUser        = 'client-github-user'
}
```

Then reload:

```powershell
. $PROFILE
use-profile clientname
```

## 5) Default Profile (Optional)
If you want a default profile each terminal session:

```powershell
[System.Environment]::SetEnvironmentVariable('ENV_SWITCH_DEFAULT_PROFILE', 'arvig', 'User')
```

Open a new terminal, then run:

```powershell
use-default
```

## 6) Hard Reset (Optional)

```powershell
gcloud auth application-default revoke
gh auth logout
```

Use this only when you intentionally want to remove saved auth state.
