@echo off
set ROOT=%~dp0
python "%ROOT%scripts\avid_pc.py" %*
if errorlevel 9009 py "%ROOT%scripts\avid_pc.py" %*
