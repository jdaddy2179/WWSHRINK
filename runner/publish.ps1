# Build a self-contained, single-file wwsmoke.exe (no .NET install needed to run
# it). Requires the .NET 8 SDK on THIS machine to build.
#   Windows:  ./publish.ps1
#   Other RID: ./publish.ps1 -Rid linux-x64   (or osx-x64, osx-arm64)
param([string]$Rid = "win-x64")

$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
dotnet publish "$dir/WWSmokeRunner.csproj" -c Release -r $Rid -o "$dir/publish"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$exe = if ($Rid -like "win-*") { "wwsmoke.exe" } else { "wwsmoke" }
Write-Host "`nDone. Ship these two files together:" -ForegroundColor Green
Write-Host "  $dir/publish/$exe"
Write-Host "  $dir/publish/appsettings.json"
