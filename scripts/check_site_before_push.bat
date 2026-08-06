@echo off
setlocal

echo ============================================================
echo Checking YAML files...
echo ============================================================
ruby scripts\check_site_data.rb
if errorlevel 1 (
  echo.
  echo Validation failed. Nothing should be pushed yet.
  pause
  exit /b 1
)

echo.
echo ============================================================
echo Building the complete Jekyll website...
echo ============================================================
call bundle exec jekyll build --strict_front_matter
if errorlevel 1 (
  echo.
  echo Jekyll build failed. Nothing should be pushed yet.
  pause
  exit /b 1
)

echo.
echo ============================================================
echo SUCCESS: YAML validation and Jekyll build both passed.
echo You may now commit and push the files.
echo ============================================================
pause
exit /b 0
