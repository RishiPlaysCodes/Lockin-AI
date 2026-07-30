# ============================================================
# Focus Guardian AI - Launcher for Windows (PowerShell)
# ============================================================
# Usage:
#   .\run.ps1           Full setup + run server
#   .\run.ps1 setup     Only setup
#   .\run.ps1 serve     Only run server
#   .\run.ps1 test      Run tests
#   .\run.ps1 seed      Seed demo data
#
# If you get an execution policy error, run this once:
#   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
# ============================================================

# Move to the script's directory
Set-Location -Path $PSScriptRoot

# Find Python
$python = $null
foreach ($candidate in @("python", "py")) {
    if (Get-Command $candidate -ErrorAction SilentlyContinue) {
        $python = $candidate
        break
    }
}

if (-not $python) {
    Write-Host "[ERROR] Python is not installed or not in PATH." -ForegroundColor Red
    Write-Host "Download it from https://www.python.org/downloads/"
    Write-Host 'IMPORTANT: Check "Add Python to PATH" during installation.'
    exit 1
}

& $python --version
& $python run.py @args
