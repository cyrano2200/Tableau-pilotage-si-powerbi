# Tableau de pilotage SI

Dashboard de pilotage SI : **KPI**, **organigramme**, **équipes**, **appels temps réel** — départements SAP, Poste de travail, Packaging, Salesforce, Helpdesk, Niveau 2, Niveau 3, Éditeurs.

## Démo en ligne (GitHub Pages)

**https://cyrano2200.github.io/Tableau-pilotage-si-powerbi/**

## Comment tout mettre en place

**Guide complet (applications, liaisons tickets / org / appels) :**

### 📘 [docs/GUIDE_MISE_EN_PLACE.md](docs/GUIDE_MISE_EN_PLACE.md)

Ce guide explique :
- **quelles applications utiliser** (ServiceNow, Salesforce, Power BI, Entra ID, téléphonie, Teams…)
- **comment lier les tickets** ServiceNow + Salesforce
- **comment brancher l’organigramme** (Directeur → Responsables → Team Leaders → Agents)
- **comment connecter les appels** (entrants, attente, répondus, perdus, ASA)
- **double écoute** (Silence / Whisper / Barge) et **chat coach** vers Agent / Team Leader
- **checklist PM** de mise en production

### Stack recommandée (résumé)

| Besoin | Application |
|--------|-------------|
| Tickets ITSM | **ServiceNow** |
| Cases CRM | **Salesforce** |
| Reporting | **Power BI** (Desktop + Service) |
| Organigramme | **Entra ID** + Excel/SharePoint RH |
| Appels live | **Genesys / Teams Phone / 3CX** ou CTI ServiceNow |
| Double écoute | API monitoring CTI (Listen / Whisper / Barge) |
| Chat coach | **Microsoft Teams** via Power Automate |
| Automatisation | **Power Automate** / Azure Data Factory |

## Vues du dashboard

- **KPI** — escalades, SLA, volumes filtrés
- **Org** — organigramme Directeur → Responsables → Team Leaders → Agents
- **Team** — tickets par équipe, team leader et agent
- **Live** — appels temps réel + **double écoute** + **chat coach** (Agent / Team Leader)
- **BO** — backoffice : tickets traités par département et par agent
- **Plan** — planning par équipe (shifts, congés, formations, couverture)

Les filtres (département, équipe, TL, agent) changent **toutes** les vues.

## Ouvrir dans Codespaces

**https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=cyrano2200/Tableau-pilotage-si-powerbi**

Ou : bouton **Code** → **Codespaces** → **Create codespace on main**.

## Contenu du dépôt

| Fichier | Description |
|---------|-------------|
| `index.html` | Tableau de pilotage SI (démo interactive) |
| `docs/GUIDE_MISE_EN_PLACE.md` | **Mise en place & applications** |
| `data/` | Excel + CSV pour Power BI Desktop |
| `dax/Mesures_DAX.txt` | Mesures DAX |
| `powerquery/` | Scripts ServiceNow + Salesforce |
| `docs/` | Maquettes + guides |
| `START_HERE_FR.md` | Démarrage rapide |
| `BUILD_POWERBI_STEPS.md` | Build projet Power BI |
| `Equans_Pilotage_SI_PowerBI/` | Projet Power BI Desktop (.pbip) |

## Power BI Desktop (rapide)

1. Ouvrir Power BI Desktop  
2. Importer `data/Equans_PowerBI_Pilotage_SI_Modele_Demo.xlsx` (ou ouvrir le `.pbip`)  
3. Coller les mesures `dax/Mesures_DAX.txt`  
4. Suivre `docs/GUIDE_MISE_EN_PLACE.md` pour brancher les vraies sources  

## Auteur

BAHJI Mohammed — Master PSI — MIAGE Casa / FEDE
