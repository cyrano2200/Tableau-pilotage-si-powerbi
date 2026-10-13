# Ouvrir le tableau de pilotage SI dans Power BI Desktop

## Méthode recommandée (1 clic)
1. Installez **Power BI Desktop** (déjà fait chez vous).
2. Double-cliquez sur le fichier :
   **`Equans_Pilotage_SI.pbip`**
3. Power BI demande parfois de **mettre à jour / actualiser** les données :
   - Paramètre `DataFolder` = chemin du dossier `data\` de ce projet  
     Exemple : `C:\Users\lenovo\Desktop\kit power bi equans\Tableau_Pilotage_SI_PowerBI\data\`
   - Puis **Accueil → Actualiser**
4. Vous obtenez la page **Pilotage SI - Executive** avec :
   - Volume, SLA, escalades Helpdesk→N2 / N2→N3
   - CSAT, SLA par niveau
   - Volumes par niveau et par application

5. Fichier → **Enregistrer sous** → `Equans_Pilotage_SI_Helpdesk_N2_N3.pbix`

## Si le .pbip ne s’ouvre pas
Utilisez le script `Build-From-Excel.ps1` (importe l’Excel démo et rappelle les mesures).

## Sources live ensuite
Remplacez les CSV par les connecteurs ServiceNow / Salesforce (`powerquery/` du kit).
