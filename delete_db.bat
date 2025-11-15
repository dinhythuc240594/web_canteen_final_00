@echo off
REM --- Config ---
set DB_USER=root
set DB_PASS=123456789
set DB_NAME=canteen_db
set DB_HOST=localhost

echo Deleting database: %DB_NAME%

REM --- Run MySQL command ---
mysql -u %DB_USER% -p%DB_PASS% -h %DB_HOST% -e "DROP DATABASE IF EXISTS %DB_NAME%;"

if %ERRORLEVEL%==0 (
    echo Database %DB_NAME% deleted (if it existed).
) else (
    echo Failed to delete database!
)

pause
