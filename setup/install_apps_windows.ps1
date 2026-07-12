#Requires -Version 5.1
<#
Automates installation of common apps on Windows using winget,
plus Git/GitHub/GCP setup similar to install_apps.sh.

Logs all installation results to logs/ folder with timestamps.

Run in PowerShell:
  powershell -ExecutionPolicy Bypass -File .\install_apps_windows.ps1

Optional auto-confirm:
  powershell -ExecutionPolicy Bypass -File .\install_apps_windows.ps1 -AutoConfirm
#>

param(
    [switch]$AutoConfirm
)

$ErrorActionPreference = "Stop"

# Set execution policy to allow script to run
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# --- Logging Setup ---
$script:LogsDir = Join-Path (Split-Path $PSScriptRoot) "logs"
$script:InstallLog = @{}
$script:LogStartTime = Get-Date

if (-not (Test-Path $script:LogsDir)) {
    New-Item -ItemType Directory -Path $script:LogsDir -Force | Out-Null
}

function Log-InstallResult {
    param(
        [string]$Component,
        [string]$Status,  # "Success", "Skipped", "Failed", "Already Installed"
        [string]$Message = ""
    )
    
    $script:InstallLog[$Component] = @{
        Status = $Status
        Message = $Message
        Timestamp = Get-Date -Format "HH:mm:ss"
    }
    
    $fullMessage = "$Component - $Status"
    if ($Message) {
        $fullMessage += " ($Message)"
    }
    Write-Host $fullMessage
}

function Write-InstallSummary {
    $logTimestamp = $script:LogStartTime.ToString("yyyyMMdd_HHmmss")
    $logFile = Join-Path $script:LogsDir "install_summary_$logTimestamp.txt"
    
    $summary = @()
    $summary += "=== Windows Install Summary ==="
    $summary += "Start Time: $($script:LogStartTime)"
    $summary += "End Time: $(Get-Date)"
    $summary += ""
    
    $success = @()
    $skipped = @()
    $failed = @()
    
    foreach ($component in ($script:InstallLog.Keys | Sort-Object)) {
        $entry = $script:InstallLog[$component]
        $line = "[$($entry.Status)]  $component"
        if ($entry.Message) {
            $line += " - $($entry.Message)"
        }
        
        switch ($entry.Status) {
            "Success" { $success += $line }
            "Skipped" { $skipped += $line }
            default { $failed += $line }
        }
    }
    
    $summary += "SUCCESSFUL:"
    $summary += $success
    $summary += ""
    $summary += "SKIPPED:"
    $summary += $skipped
    $summary += ""
    $summary += "FAILED:"
    $summary += $failed
    $summary += ""
    $summary += "Total: $($script:InstallLog.Count) items"
    
    $summaryText = $summary -join "`n"
    
    # Write to file
    Set-Content -Path $logFile -Value $summaryText
    
    # Write to console
    Write-Host ""
    Write-Host "=========================================="
    Write-Host $summaryText
    Write-Host "=========================================="
    Write-Host "Summary saved to: $logFile"
}

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
        Log-InstallResult -Component $DisplayName -Status "Already Installed"
        return
    }

    if (-not (Confirm-Action "Install $DisplayName")) {
        Write-Host "Skipping $DisplayName installation."
        Log-InstallResult -Component $DisplayName -Status "Skipped"
        return
    }

    $commonArgs = @("--accept-source-agreements", "--accept-package-agreements")
    try {
        if ($Id) {
            winget install --id $Id -e --source winget @commonArgs
        } elseif ($FallbackName) {
            winget install --name $FallbackName --source winget @commonArgs
        } else {
            throw "No winget identifier provided for $DisplayName"
        }
        Log-InstallResult -Component $DisplayName -Status "Success"
        Write-Host "Installed: $DisplayName"
    } catch {
        if ($FallbackName) {
            Write-Host "Primary install failed for $DisplayName. Retrying by name: $FallbackName"
            try {
                winget install --name $FallbackName --source winget @commonArgs
                Log-InstallResult -Component $DisplayName -Status "Success" -Message "via fallback"
                Write-Host "Installed via fallback name: $DisplayName"
            } catch {
                Log-InstallResult -Component $DisplayName -Status "Failed" -Message $_.Exception.Message
                Write-Host "Failed to install $DisplayName"
            }
        } else {
            Log-InstallResult -Component $DisplayName -Status "Failed" -Message $_.Exception.Message
            Write-Host "Failed to install $DisplayName"
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
Inst    Log-InstallResult -Component "Git Global Config" -Status "Success"
    } else {
        Write-Host "Skipping Git global configuration."
        Log-InstallResult -Component "Git Global Config" -Status "Skipped"
    }
} else {
    Write-Host "Git not installed, skipping global configuration."
    Log-InstallResult -Component "Git Global Config" -Status "Skipped" -Message "Git not installed
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
if (    Log-InstallResult -Component "OpenSSH Server" -Status "Skipped" -Message "Admin required"
    } else {
        try {
            $cap = Get-WindowsCapability -Online | Where-Object Name -like "OpenSSH.Server*"
            if ($cap.State -ne "Installed") {
                Add-WindowsCapability -Online -Name "OpenSSH.Server~~~~0.0.1.0"
            }
            Start-Service sshd
            Set-Service -Name sshd -StartupType Automatic
            Write-Host "OpenSSH Server installed/enabled."
            Log-InstallResult -Component "OpenSSH Server" -Status "Success"
        } catch {
            Write-Host "Failed to configure OpenSSH Server: $($_.Exception.Message)"
            Log-InstallResult -Component "OpenSSH Server" -Status "Failed" -Message $_.Exception.Message
        }
    }
} else {
    Write-Host "Skipping OpenSSH Server setup."
    Log-InstallResult -Component "OpenSSH Server" -Status "Skipped
    }
} else {
    Write-Host "Skipping OpenSSH Server setup."
}

# GitHub CLI setup for SSH
Write-Header "Configuring GitHub CLI for SSH"
if (Command-Exists "gh") {
    if (Confirm-Action "Run gh auth login now (choose SSH protocol)") {
            Log-InstallResult -Component "GitHub CLI SSH Config" -Status "Success"
        } else {
            Write-Host "gh auth login failed or canceled; skipping protocol config."
            Log-InstallResult -Component "GitHub CLI SSH Config" -Status "Skipped" -Message "Auth login failed"
        }
    } else {
        Write-Host "Skipping gh auth login."
        Log-InstallResult -Component "GitHub CLI SSH Config" -Status "Skipped"
    }
} else {
    Write-Host "gh not installed, skipping GitHub CLI setup."
    Log-InstallResult -Component "GitHub CLI SSH Config" -Status "Skipped" -Message "gh not installed
        Write-Host "Skipping gh auth login."
    }
} else {
    Write-Host "gh not installed, skipping GitHub CLI setup."
}

# Clone reference repo
Write-Header "Cloning Reference Repository"
$referenceRepo = "https://github.com/btruss13/reference"
    Log-InstallResult -Component "Reference Repo Clone" -Status "Skipped" -Message "Already exists"
} else {
    if (Confirm-Action "Clone reference repository ($referenceRepo) to $referenceDir") {
        Push-Location $HOME
        try {
            git clone $referenceRepo
            Log-InstallResult -Component "Reference Repo Clone" -Status "Success"
        } catch {
            Write-Host "Failed to clone reference repository: $($_.Exception.Message)"
            Log-InstallResult -Component "Reference Repo Clone" -Status "Failed" -Message $_.Exception.Message
        } finally {
            Pop-Location
        }
    } else {
        Write-Host "Skipping reference repository clone."
        Log-InstallResult -Component "Reference Repo Clone" -Status "Skipped"
    }
}

Write-Header "Done"
Write-InstallSummary
}

Write-Header "Done"
Write-Host "Windows install/setup script completed."