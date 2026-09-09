@echo off
setlocal enabledelayedexpansion

title Active Directory Lab - GitHub Push

set "PATH=C:\Users\ilkin\AppData\Local\Programs\Git\cmd;C:\Users\ilkin\AppData\Local\Programs\Git\gcm;%PATH%"

echo ================================================================
echo  Active Directory Red Team Lab - Automatic GitHub Push
echo ================================================================
echo.
echo Repository: https://github.com/ferecovilkin/active-directory-red-team-lab.git
echo.

git remote remove origin 2>nul
git remote add origin https://github.com/ferecovilkin/active-directory-red-team-lab.git
git branch -M main

echo Checking files and staging changes...
git add .
git commit -m "feat: Active Directory Red Team Lab architecture, detections, and hardening" 2>nul

echo.
echo Pushing changes to GitHub...
echo (If a browser window opens, click 'Sign in' / 'Authorize')
echo.

git push -u origin main

echo.
if %errorlevel% equ 0 (
    echo ================================================================
    echo  [SUCCESS] Project successfully pushed to GitHub!
    echo ================================================================
) else (
    echo ================================================================
    echo  [NOTICE] Authentication may be required.
    echo ================================================================
)

echo.
pause
