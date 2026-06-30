#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/../.."
python -m pip install --upgrade pip pyinstaller flask
python -m PyInstaller --onefile --name AvidKiyaDevHub --add-data "web:web" --add-data "scripts:scripts" --add-data "agent:agent" scripts/avid_desktop.py
echo "EXE/app build complete. Check dist/"
