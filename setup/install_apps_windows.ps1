#Requires -Version 5.1
<#
Automates installation of common apps on Windows using winget,
plus Git/GitHub/GCP setup similar to install_apps.sh.

Run in PowerShell:
  powershell -ExecutionPolicy Bypass -File .\install_apps_windows.ps1

Optional auto-confirm:
  powershell -ExecutionPolicy Bypass -File .\install_apps_windows.ps1 -AutoConfirm
#>

param(
    [switch]$AutoConfirm
)

$ErrorActionPreference = "Stop"

function Write-Header {
    param([string]$Title)
    Write-Host ""
    Write-Host "--- $Title ---"
    Write-Host ""
}

function Command-Exists {
    param([string]$Name)
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Confirm-Action {
    param([string]$Prompt)

    if ($AutoConfirm) {
        Write-Host "Auto-confirming: $Prompt"
        return $true
    }

    $choice = Read-Host "$Prompt (y/N)?"
    return ($choice -match '^[Yy]$')
}

function Install-WingetPackage {
    param(
        [string]$Id,
        [string]$DisplayName,
        [string]$CheckCommand,
        [string]$FallbackName
    )

    Write-Header "Installing $DisplayName"

    if ($CheckCommand -and (Command-Exists $CheckCommand)) {
        Write-Host "$DisplayName appears to be already installed."
        return
    }

    if (-not (Confirm-Action "Install $DisplayName")) {
        Write-Host "Skipping $DisplayName installation."
        return
    }

    $commonArgs = @("--accept-source-agreements", "--accept-package-agreements")

    try {
        if ($Id) {
            winget install --id $Id -e @commonArgs
        } elseif ($FallbackName) {
            winget install --name $FallbackName @commonArgs
        } else {
            throw "No winget identifier provided for $DisplayName"
        }
        Write-Host "Installed: $DisplayName"
    } catch {
        if ($FallbackName) {
            Write-Host "Primary install failed for $DisplayName. Retrying by name: $FallbackName"
            winget install --name $FallbackName @commonArgs
            Write-Host "Installed via fallback name: $DisplayName"
        } else {
            throw
        }
    }
}

function Ensure-Winget {
    if (-not (Command-Exists "winget")) {
        throw "winget is required but not found. Install App Installer from Microsoft Store, then rerun."
    }
}

function Ensure-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

Write-Host "Starting Windows Program Installation Script..."
Write-Host "This may prompt for elevation and/or app installer confirmations."

Ensure-Winget

Write-Header "Refreshing Winget Sources"
try {
    winget source update
} catch {
    Write-Host "Winget source update failed; continuing."
}

# Core tooling + apps (closest Windows equivalents)
Install-WingetPackage -Id "Python.Python.3.12" -DisplayName "Python 3.12" -CheckCommand "python" -FallbackName "Python 3.12"
Install-WingetPackage -Id "Microsoft.VisualStudioCode" -DisplayName "Visual Studio Code" -CheckCommand "code" -FallbackName "Visual Studio Code"
Install-WingetPackage -Id "DbVis.DBVisualizer" -DisplayName "DBVisualizer" -CheckCommand "dbviscmd" -FallbackName "DBVisualizer"
Install-WingetPackage -Id "Zoom.Zoom" -DisplayName "Zoom" -CheckCommand "zoom" -FallbackName "Zoom"
Install-WingetPackage -Id "Google.Chrome" -DisplayName "Google Chrome" -CheckCommand "chrome" -FallbackName "Google Chrome"
Install-WingetPackage -Id "Git.Git" -DisplayName "Git" -CheckCommand "git" -FallbackName "Git"
Install-WingetPackage -Id "GitHub.cli" -DisplayName "GitHub CLI (gh)" -CheckCommand "gh" -FallbackName "GitHub CLI"
Install-WingetPackage -Id "Google.CloudSDK" -DisplayName "Google Cloud SDK (gcloud)" -CheckCommand "gcloud" -FallbackName "Google Cloud CLI"
Install-WingetPackage -Id "Bitwarden.Bitwarden" -DisplayName "Bitwarden" -CheckCommand "bitwarden" -FallbackName "Bitwarden"
Install-WingetPackage -Id "SlackTechnologies.Slack" -DisplayName "Slack" -CheckCommand "slack" -FallbackName "Slack"
Install-WingetPackage -Id "ShareX.ShareX" -DisplayName "ShareX (Flameshot equivalent)" -CheckCommand "sharex" -FallbackName "ShareX"
Install-WingetPackage -Id "Appest.TickTick" -DisplayName "TickTick" -CheckCommand "ticktick" -FallbackName "TickTick"

# Git global configuration
Write-Header "Git Global Configuration"
if (Command-Exists "git") {
    if (Confirm-Action "Set global Git user email (btruss@moduloinsights.com) and name (Briean Truss)") {
        git config --global user.email "btruss@moduloinsights.com"
        git config --global user.name "Briean Truss"
        Write-Host "Git global config updated."
    } else {
        Write-Host "Skipping Git global configuration."
    }
} else {
    Write-Host "Git not installed, skipping global configuration."
}

# OpenSSH Server
Write-Header "Configuring OpenSSH Server"
if (Confirm-Action "Install and enable OpenSSH Server") {
    if (-not (Ensure-Admin)) {
        Write-Host "OpenSSH Server installation needs an elevated PowerShell (Run as Administrator). Skipping."
    } else {
        try {
            $cap = Get-WindowsCapability -Online | Where-Object Name -like "OpenSSH.Server*"
            if ($cap.State -ne "Installed") {
                Add-WindowsCapability -Online -Name "OpenSSH.Server~~~~0.0.1.0"
            }
            Start-Service sshd
            Set-Service -Name sshd -StartupType Automatic
            Write-Host "OpenSSH Server installed/enabled."
        } catch {
            Write-Host "Failed to configure OpenSSH Server: $($_.Exception.Message)"
        }
    }
} else {
    Write-Host "Skipping OpenSSH Server setup."
}

# GitHub CLI setup for SSH
Write-Header "Configuring GitHub CLI for SSH"
if (Command-Exists "gh") {
    if (Confirm-Action "Run gh auth login now (choose SSH protocol)") {
        gh auth login
        if ($LASTEXITCODE -eq 0) {
            gh config set -h github.com git_protocol ssh
            Write-Host "Configured gh git protocol to SSH."
        } else {
            Write-Host "gh auth login failed or canceled; skipping protocol config."
        }
    } else {
        Write-Host "Skipping gh auth login."
    }
} else {
    Write-Host "gh not installed, skipping GitHub CLI setup."
}

# Clone reference repo
Write-Header "Cloning Reference Repository"
$referenceRepo = "https://github.com/btruss13/reference"
$referenceDir = Join-Path $HOME "reference"

if (Test-Path $referenceDir) {
    Write-Host "Reference repository already exists at $referenceDir"
} else {
    if (Confirm-Action "Clone reference repository ($referenceRepo) to $referenceDir") {
        Push-Location $HOME
        try {
            git clone $referenceRepo
        } catch {
            Write-Host "Failed to clone reference repository: $($_.Exception.Message)"
        } finally {
            Pop-Location
        }
    } else {
        Write-Host "Skipping reference repository clone."
    }
}

Write-Header "Done"
Write-Host "Windows install/setup script completed."