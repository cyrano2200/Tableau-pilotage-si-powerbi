# Equans Power BI Kit — helpers
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$html = Join-Path $Root "Equans_SI_Dashboard_FINAL.html"
$xlsx = Join-Path $Root "data\Equans_PowerBI_Pilotage_SI_Modele_Demo.xlsx"
Write-Host "Equans IT Hubs — Kit Power BI Final" -ForegroundColor Cyan
Write-Host "1) Opening HTML dashboard..." -ForegroundColor Green
Start-Process $html
Write-Host "2) Excel model path:" $xlsx
if (Test-Path $xlsx) { Write-Host "   OK - import this file in Power BI Desktop" -ForegroundColor Green }
Write-Host "Done. Read START_HERE_FR.md for full Power BI steps."
