@echo off
setlocal

echo ============================================================
echo 1. Validating YAML, front matter, and page routes
echo ============================================================
ruby scripts\check_site.rb
if errorlevel 1 (
  echo.
  echo Validation failed. Fix the errors before pushing.
  pause
  exit /b 1
)

echo.
echo ============================================================
echo 2. Building the complete Jekyll website
echo ============================================================
call bundle exec jekyll build --strict_front_matter
if errorlevel 1 (
  echo.
  echo Jekyll build failed. Fix the errors before pushing.
  pause
  exit /b 1
)

echo.
echo ============================================================
echo SUCCESS: the repository is safe to commit and push.
echo ============================================================
pause
exit /b 0
