#Requires -Version 5.1
<#
Verifies a Windows machine is ready for the Arvig Dataform workflow.

Run:
  powershell -ExecutionPolicy Bypass -File .\verify_windows_setup.ps1

Optional: check Dataform repo directly
  powershell -ExecutionPolicy Bypass -File .\verify_windows_setup.ps1 -RepoPath "$HOME\dev\arvig_dataform"
#>

param(
    [string]$RepoPath = "$HOME\dev\arvig_dataform"
)

$ErrorActionPreference = "Continue"
$failures = New-Object System.Collections.Generic.List[string]

function Write-Header {
    param([string]$Title)
    Write-Host ""
    Write-Host "--- $Title ---"
    Write-Host ""
}

function Check-Command {
    param(
        [string]$Command,
        [string]$Display,
        [string]$VersionCommand
    )

    Write-Host "Checking $Display..."
    if (Get-Command $Command -ErrorAction SilentlyContinue) {
        if ($VersionCommand) {
            try {
                $v = Invoke-Expression $VersionCommand 2>$null | Select-Object -First 1
                if ($v) { Write-Host "  OK: $v" } else { Write-Host "  OK" }
            } catch {
                Write-Host "  OK"
            }
        } else {
            Write-Host "  OK"
        }
    } else {
        Write-Host "  MISSING: $Display"
        $failures.Add($Display)
    }
}

function Check-Path {
    param(
        [string]$PathToCheck,
        [string]$Label
    )

    Write-Host "Checking $Label..."
    if (Test-Path $PathToCheck) {
        Write-Host "  OK: $PathToCheck"
    } else {
        Write-Host "  MISSING: $PathToCheck"
        $failures.Add($Label)
    }
}

Write-Header "Core CLI Tools"
Check-Command -Command "git" -Display "Git" -VersionCommand "git --version"
Check-Command -Command "gh" -Display "GitHub CLI" -VersionCommand "gh --version"
Check-Command -Command "gcloud" -Display "Google Cloud SDK" -VersionCommand "gcloud --version"
Check-Command -Command "bq" -Display "BigQuery CLI" -VersionCommand "bq version"
Check-Command -Command "node" -Display "Node.js" -VersionCommand "node --version"
Check-Command -Command "python" -Display "Python" -VersionCommand "python --version"
Check-Command -Command "code" -Display "VS Code CLI" -VersionCommand "code --version"

Write-Header "Authentication Status"
Write-Host "Checking gh auth..."
try {
    $ghStatus = gh auth status 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  OK"
        $ghStatus | Select-Object -First 6 | ForEach-Object { Write-Host "  $_" }
    } else {
        Write-Host "  NOT AUTHENTICATED"
        $failures.Add("GitHub auth")
    }
} catch {
    Write-Host "  ERROR checking gh auth"
    $failures.Add("GitHub auth")
}

Write-Host "Checking gcloud auth/account/project..."
try {
    $acct = gcloud config get-value account 2>$null
    $proj = gcloud config get-value project 2>$null

    if ($acct -and $acct -ne "(unset)") {
        Write-Host "  account: $acct"
    } else {
        Write-Host "  account: NOT SET"
        $failures.Add("gcloud account")
    }

    if ($proj -and $proj -ne "(unset)") {
        Write-Host "  project: $proj"
    } else {
        Write-Host "  project: NOT SET"
        $failures.Add("gcloud project")
    }
} catch {
    Write-Host "  ERROR checking gcloud config"
    $failures.Add("gcloud config")
}

Write-Header "Arvig Dataform Repo Checks"
Check-Path -PathToCheck $RepoPath -Label "Repo path"

if (Test-Path $RepoPath) {
    $dfCmd = Join-Path $RepoPath "dataform.cmd"
    $venvPy = Join-Path $RepoPath ".venv\Scripts\python.exe"
    $creds = Join-Path $RepoPath ".df-credentials.json"
    $vscodeSettings = Join-Path $RepoPath ".vscode\settings.json"
    $vscodeMcp = Join-Path $RepoPath ".vscode\mcp.json"

    Check-Path -PathToCheck $dfCmd -Label "dataform.cmd"
    Check-Path -PathToCheck $venvPy -Label "Python venv (.venv)"
    Check-Path -PathToCheck $creds -Label ".df-credentials.json"
    Check-Path -PathToCheck $vscodeSettings -Label "VS Code settings"
    Check-Path -PathToCheck $vscodeMcp -Label "VS Code MCP config"

    if (Test-Path $dfCmd) {
        Write-Host "Checking Dataform CLI wrapper..."
        Push-Location $RepoPath
        try {
            & .\dataform.cmd --help | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  OK: dataform.cmd responds"
            } else {
                Write-Host "  FAIL: dataform.cmd returned non-zero"
                $failures.Add("dataform.cmd runtime")
            }
        } catch {
            Write-Host "  FAIL: dataform.cmd execution error"
            $failures.Add("dataform.cmd runtime")
        } finally {
            Pop-Location
        }
    }
}

Write-Header "Summary"
if ($failures.Count -eq 0) {
    Write-Host "PASS: Machine appears ready for Arvig Dataform workflow."
    exit 0
} else {
    Write-Host "Needs attention. Missing/failed checks:"
    $failures | Sort-Object -Unique | ForEach-Object { Write-Host "  - $_" }
    Write-Host ""
    Write-Host "Typical fixes:"
    Write-Host "  - Run install script: .\install_apps_windows.ps1"
    Write-Host "  - Auth: gcloud auth login --update-adc; gcloud auth application-default login; gh auth login"
    Write-Host "  - Repo setup: node .\.tools\scripts\setup.js"
    exit 1
}
