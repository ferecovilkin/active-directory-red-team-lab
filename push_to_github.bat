@echo off
setlocal enabledelayedexpansion

echo =======================================================
echo Active Directory Lab - GitHub Push Script
echo =======================================================
echo.

where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Git is not installed or not in your PATH.
    echo Please install Git from https://git-scm.com/download/win
    echo After installing, restart this script.
    echo.
    pause
    exit /b 1
)

set /p REPO_URL="Enter your GitHub Repository Remote URL (e.g., https://github.com/username/active-directory-lab.git): "

if "%REPO_URL%"=="" (
    echo [ERROR] Repository URL cannot be empty!
    pause
    exit /b 1
)

echo.
echo Initializing Git repository...
git init
git branch -M main

echo Adding files to git staging...
git add .

echo Creating initial commit...
git commit -m "feat: initial release of Active Directory Lab architecture, detections, and hardening"

echo Setting up remote origin...
git remote remove origin 2>nul
git remote add origin %REPO_URL%

echo Pushing to GitHub...
git push -u origin main

if %errorlevel% equ 0 (
    echo.
    echo [SUCCESS] Successfully pushed to GitHub!
) else (
    echo.
    echo [NOTICE] Push failed or requires authentication. Please ensure you are logged in to GitHub.
)

pause
