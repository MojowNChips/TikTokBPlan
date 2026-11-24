@echo off
REM ==========================================================================
REM  One-time cleanup of the TikTok project folder (2026-11-24)
REM  Moves obsolete files into _to_delete\ , then asks before deleting them.
REM  Double-click it, or run from the project folder.
REM ==========================================================================
setlocal
cd /d "%~dp0"
if not exist docker-compose.yml (echo Run this from the project folder. & pause & exit /b 1)
if not exist _to_delete mkdir _to_delete
if not exist _to_delete\TikTokAPI_review mkdir _to_delete\TikTokAPI_review
if not exist _to_delete\scripts mkdir _to_delete\scripts
if not exist _to_delete\workflows mkdir _to_delete\workflows

echo.
echo [1/4] Retired / duplicate shell scripts (replaced by diagnose.sh)
for %%F in (apply-mime-fix.sh fix-caddy-mime.sh fix-mime-complete.sh fix-caddy.sh diagnose-droplet.sh diagnose-full.sh diagnose-mime.sh) do if exist "%%F" move /y "%%F" _to_delete\ >nul && echo    moved %%F

echo [2/4] Old docs (merged into GUIDE.md and 30_DAY_PLAN.md)
for %%F in (DEPLOYMENT_GUIDE.md QUICKSTART_CHECKLIST.md GOOGLE_SHEETS_TEMPLATE.md TIKTOK_30DAY_PLAN.md) do if exist "%%F" move /y "%%F" _to_delete\ >nul && echo    moved %%F
for %%F in (APP_DESCRIPTION.md DATA_USAGE.md LOGO_SPECS.md PRIVACY_POLICY.md TERMS_OF_SERVICE.md TIKTOK_SUBMISSION_CHECKLIST.md) do if exist "TikTokAPI_review\%%F" move /y "TikTokAPI_review\%%F" _to_delete\TikTokAPI_review\ >nul && echo    moved TikTokAPI_review\%%F

echo [3/4] VPS SSH plugin (unrelated, broken)
for %%F in (manifest.json architecture-plugin-terminal-vps.md) do if exist "%%F" move /y "%%F" _to_delete\ >nul && echo    moved %%F
for %%D in (src dsh-bundle test-plan) do if exist "%%D" move /y "%%D" _to_delete\ >nul && echo    moved %%D\

echo [4/4] Dead code / caches
if exist scripts\process_clip_wrapper.py move /y scripts\process_clip_wrapper.py _to_delete\scripts\ >nul && echo    moved scripts\process_clip_wrapper.py
if exist scripts\__pycache__ move /y scripts\__pycache__ _to_delete\scripts\ >nul && echo    moved scripts\__pycache__\
if exist workflows\_original_v0 move /y workflows\_original_v0 _to_delete\workflows\ >nul && echo    moved workflows\_original_v0\

echo.
echo Everything is in _to_delete\ . Nothing used by the pipeline was touched.
set /p ANS=Delete _to_delete\ permanently now? (y/n) 
if /i "%ANS%"=="y" (rmdir /s /q _to_delete & echo Deleted.) else (echo Kept. Delete the folder yourself when happy.)

echo.
echo To publish the cleanup to GitHub (then git pull on the droplet):
echo    git add -A ^&^& git commit -m "Cleanup: merged docs, removed dead code" ^&^& git push
echo.
pause
