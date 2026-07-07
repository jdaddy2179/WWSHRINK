@echo off
REM Build a self-contained, single-file wwsmoke.exe (no .NET install needed to
REM run it). Requires the .NET 8 SDK on THIS machine to build.
dotnet publish "%~dp0WWSmokeRunner.csproj" -c Release -r win-x64 -o "%~dp0publish"
if errorlevel 1 goto :eof
echo.
echo Done. Ship these two files together:
echo   %~dp0publish\wwsmoke.exe
echo   %~dp0publish\appsettings.json
