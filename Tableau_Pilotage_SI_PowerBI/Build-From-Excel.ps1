#Requires -Version 5.1
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Pbip = Join-Path $Root "Tableau_Pilotage_SI.pbip"
$Xlsx = Join-Path $Root "data\Tableau_PowerBI_Pilotage_SI_Modele_Demo.xlsx"
$Data = Join-Path $Root "data\"
if (-not (Test-Path $Pbip)) { Write-Error "PBIP introuvable: $Pbip"; exit 1 }

Write-Host "=== Tableau Pilotage SI — Power BI ===" -ForegroundColor Cyan
Write-Host "DataFolder à utiliser dans Power BI :" -ForegroundColor Yellow
Write-Host "  $Data"
Write-Host "Excel de secours :" $Xlsx
Write-Host "Ouverture du projet PBIP..." -ForegroundColor Green

# Prefer pbip
Start-Process $Pbip
Start-Sleep -Seconds 2
Write-Host @"

Dans Power BI Desktop :
1) Si demandé, définir le paramètre DataFolder = $Data
2) Accueil > Actualiser
3) Vérifier les cartes Escalade Helpdesk→N2 / N2→N3 / SLA
4) Fichier > Enregistrer sous > Tableau_Pilotage_SI_Helpdesk_N2_N3.pbix

"@ -ForegroundColor White
