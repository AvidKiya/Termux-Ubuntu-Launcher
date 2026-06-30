param([string]$Command="app", [string[]]$Rest)
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Py = Get-Command python -ErrorAction SilentlyContinue
if (-not $Py) { $Py = Get-Command py -ErrorAction SilentlyContinue }
if (-not $Py) { Write-Error "Python not found. Install Python 3 first."; exit 1 }
& $Py.Source "$Root\scripts\avid_pc.py" $Command @Rest
