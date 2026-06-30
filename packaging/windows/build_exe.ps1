param(
  [string]$Name = "AvidKiyaDevHub",
  [switch]$OneFile = $true
)
$ErrorActionPreference = "Stop"
$Root = Resolve-Path "$PSScriptRoot\..\.."
Set-Location $Root
$Py = Get-Command python -ErrorAction SilentlyContinue
if (-not $Py) { $Py = Get-Command py -ErrorAction SilentlyContinue }
if (-not $Py) { throw "Python not found. Install Python 3." }
& $Py.Source -m pip install --upgrade pip pyinstaller flask
$args = @("--name", $Name, "--noconsole", "--add-data", "web;web", "--add-data", "scripts;scripts", "--add-data", "agent;agent", "scripts/avid_desktop.py")
if ($OneFile) { $args = @("--onefile") + $args }
& $Py.Source -m PyInstaller @args
Write-Host "EXE build complete. Check dist/" -ForegroundColor Green
