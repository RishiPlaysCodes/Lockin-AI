@echo off
REM ============================================================
REM Focus Guardian AI - Launcher for Windows (CMD)
REM ============================================================
REM Usage:
REM   run.bat           Full setup + run server
REM   run.bat setup     Only setup
REM   run.bat serve     Only run server
REM   run.bat test      Run tests
REM   run.bat seed      Seed demo data
REM
REM You can also just double-click this file in File Explorer.
REM ============================================================

cd /d "%~dp0"

REM Find Python
where python >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    set PYTHON=python
) else (
    where py >nul 2>nul
    if %ERRORLEVEL% EQU 0 (
        set PYTHON=py
    ) else (
        echo [ERROR] Python is not installed or not in PATH.
        echo Download it from https://www.python.org/downloads/
        echo IMPORTANT: Check "Add Python to PATH" during installation.
        pause
        exit /b 1
    )
)

%PYTHON% --version
%PYTHON% run.py %*

REM Keep the window open if double-clicked
if "%~1"=="" pause
