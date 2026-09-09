@echo off
setlocal enabledelayedexpansion

title Active Directory Lab - GitHub Push

set "PATH=C:\Users\ilkin\AppData\Local\Programs\Git\cmd;C:\Users\ilkin\AppData\Local\Programs\Git\gcm;%PATH%"

echo ================================================================
echo  Active Directory Red Team Lab - Automatic GitHub Push
echo ================================================================
echo.
echo Repozitoriya: https://github.com/ferecovilkin/active-directory-red-team-lab.git
echo.

git remote remove origin 2>nul
git remote add origin https://github.com/ferecovilkin/active-directory-red-team-lab.git
git branch -M main

echo Fayllar yoxlanilir...
git add .
git commit -m "feat: Active Directory Red Team Lab architecture, detections, and hardening" 2>nul

echo.
echo GitHub-a push edilir...
echo (Eger brauzer penceresi acilsa, 'Sign in' / 'Authorize' duymesine klikleyin)
echo.

git push -u origin main

echo.
if %errorlevel% equ 0 (
    echo ================================================================
    echo  [UGURLU] Layihe ugurla GitHub-a push edildi!
    echo ================================================================
) else (
    echo ================================================================
    echo  [MELUMAT] Autentifikasiya teleb oluna biler.
    echo ================================================================
)

echo.
pause
