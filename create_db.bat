@echo off
REM --- Config ---
set DB_USER=root
set DB_PASS=123456789
set DB_NAME=canteen_db
set DB_HOST=localhost
set SQL_FILE=canteen_sql.sql

echo Creating database if not exists: %DB_NAME%

REM --- Run MySQL command ---
mysql -u %DB_USER% -p%DB_PASS% -h %DB_HOST% -e "CREATE DATABASE IF NOT EXISTS %DB_NAME%;"

if %ERRORLEVEL%==0 (
    echo Database %DB_NAME% created or already exists.
) else (
    echo Failed to create database!
)

REM --- Import file SQL vào database ---
if exist %SQL_FILE% (
    echo Importing %SQL_FILE% into %DB_NAME%...
    mysql -u %DB_USER% -p%DB_PASS% -h %DB_HOST% %DB_NAME% < %SQL_FILE%
    if %ERRORLEVEL%==0 (
        echo Import successful!
    ) else (
        echo Import failed!
    )
) else (
    echo SQL file %SQL_FILE% not found!
)

pause