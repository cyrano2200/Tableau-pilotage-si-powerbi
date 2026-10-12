# Equans Power BI — Produit Final
## Pilotage SI : Helpdesk N1 · Support N2 · Expertise N3

### Option A — Voir le dashboard tout de suite (sans Power BI)
1. Double-cliquez sur **`Equans_SI_Dashboard_FINAL.html`**
2. Il s’ouvre dans votre navigateur (Chrome / Edge)
3. Vous voyez le tableau de pilotage (escalades, SLA, funnel, matrice KPI…)

### Option B — Produit Power BI Desktop (recommandé pour le mémoire / Equans)
1. Installez **Power BI Desktop** (gratuit) : https://powerbi.microsoft.com/desktop/
2. Ouvrez Power BI Desktop
3. **Obtenir des données → Excel** → choisissez :
   `data/Equans_PowerBI_Pilotage_SI_Modele_Demo.xlsx`
4. Cochez et chargez :
   - `Fact_Tickets_Unified`
   - `Dim_Priority`, `Dim_Level`, `Dim_Source`, `Dim_Application`, `Dim_Calendar`
5. **Vue Modèle** : créez les relations (voir `docs/` + feuille `Modele_Relations` dans l’Excel)
6. **Nouvelle mesure** : copiez-collez les mesures depuis `dax/Mesures_DAX.txt`
7. Reproduisez les pages à partir de la maquette :
   `docs/dashboard_powerbi_style_helpdesk.png`
8. Fichier → **Enregistrer sous** → `Equans_Pilotage_SI_Helpdesk_N2_N3.pbix`

### Option C — Connexion live ServiceNow + Salesforce
1. Utilisez les scripts `powerquery/*.pq`
2. Remplacez la source Excel par les connecteurs ServiceNow / Salesforce
3. Gardez les **mêmes noms de colonnes** pour ne pas casser les mesures DAX

### Contenu du dossier
| Élément | Description |
|---------|-------------|
| `Equans_SI_Dashboard_FINAL.html` | Dashboard interactif final (démo) |
| `data/` | Excel + CSV (400 tickets) |
| `dax/Mesures_DAX.txt` | Mesures Power BI |
| `powerquery/` | Scripts SN + SF |
| `docs/` | Guide Word + maquettes PNG |
| `BUILD_POWERBI_STEPS.md` | Pas-à-pas détaillé visuels |

### KPIs pivots
- Escalade Helpdesk → N2 (cible ≤ 30 %)
- Escalade N2 → N3 (cible ≤ 20 %)
- SLA global, CSAT, funnel N1/N2/N3

Mémoire Master PSI — BAHJI Mohammed — Equans IT Hubs
