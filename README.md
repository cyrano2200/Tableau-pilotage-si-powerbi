# Tableau de Pilotage SI

## Vues du dashboard

- **KPI** — escalades, SLA, volumes filtrés
- **Org** — organigramme Directeur → Responsables → Team Leaders → Agents
- **Team** — tickets par équipe, team leader et agent
- **Live** — suivi temps réel des appels (entrants, attente, répondus, perdus…)

Départements : **SAP**, **Poste de travail**, **Packaging**, **Salesforce**, **Helpdesk**, **Niveau 2**, **Niveau 3**, **Éditeurs**. Les filtres changent toutes les vues.

**Helpdesk N1 · Support N2 · Expertise N3**  
Dashboard de pilotage SI (escalades, SLA, funnel) — données kit démo ServiceNow + Salesforce.

## Démo en ligne (GitHub Pages)

**https://cyrano2200.github.io/Tableau-pilotage-si-powerbi/**

## Ouvrir dans Codespaces

**https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=cyrano2200/Tableau-pilotage-si-powerbi**

Ou depuis le dépôt : bouton **Code** → **Codespaces** → **Create codespace on main**.

## Contenu
| Fichier | Description |
|---------|-------------|
| `index.html` | Tableau de pilotage SI (dashboard interactif) |
| `data/` | Excel + CSV pour Power BI Desktop |
| `dax/Mesures_DAX.txt` | Mesures DAX |
| `powerquery/` | Scripts ServiceNow + Salesforce |
| `docs/` | Maquettes + guide |
| `START_HERE_FR.md` | Mode d'emploi |
| `Equans_Pilotage_SI_PowerBI/` | Projet Power BI Desktop (.pbip) |

## Power BI Desktop
1. Ouvrir Power BI Desktop  
2. Importer `data/Equans_PowerBI_Pilotage_SI_Modele_Demo.xlsx` (ou ouvrir le `.pbip`)  
3. Coller les mesures `dax/Mesures_DAX.txt`  
4. Reproduire la maquette `docs/dashboard_powerbi_style_helpdesk.png`

## Auteur
BAHJI Mohammed — Master PSI — MIAGE Casa / FEDE
