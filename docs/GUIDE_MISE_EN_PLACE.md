# Guide de mise en place — Tableau de pilotage SI

Ce document explique **quelles applications utiliser**, **comment les relier**, et **comment mettre en production** le pilotage (tickets, organigramme, équipes, appels temps réel).

Démo en ligne : https://cyrano2200.github.io/Tableau-pilotage-si-powerbi/

---

## 1. Vue d’ensemble (ce que tu pilotes)

| Vue | Objectif | Source de données cible |
|-----|----------|-------------------------|
| **KPI** | Volume, SLA, escalades N1→N2 / N2→N3 | ServiceNow + Salesforce |
| **Org** | Directeur → Responsables → Team Leaders → Agents | RH / Azure AD / Excel référentiel |
| **Team** | Tickets par département, équipe, TL, agent | Tickets + référentiel org |
| **Live** | Appels entrants, attente, répondus, perdus, ASA | Téléphonie / Contact Center / CTI |

Départements couverts dans le modèle : **SAP**, **Poste de travail**, **Packaging**, **Salesforce**, **Helpdesk**, **Niveau 2**, **Niveau 3**, **Éditeurs**.

---

## 2. Applications à utiliser (stack recommandée)

### Socle (obligatoire)

| Besoin | Application | Pourquoi |
|--------|-------------|---------|
| Tickets ITSM | **ServiceNow** | Incidents, SLA, groupes d’affectation, escalades |
| Tickets métier / CRM | **Salesforce** (Cases + éventuellement Service Cloud) | Cases Salesforce, lien CRM–SAP |
| Pilotage & reporting | **Power BI Desktop + Power BI Service** | Tableaux de bord, RLS, partage Direction |
| Référentiel org / agents | **Microsoft Entra ID (Azure AD)** + fichier RH (Excel/SharePoint) | Organigramme, équipes, managers |
| Stockage fichiers / Excel | **SharePoint** ou **OneDrive** | Fichiers dimensions (équipes, calendrier) |

### Appels temps réel (choisir 1 stack téléphonie)

| Option | Application | Idéal si… |
|--------|-------------|-----------|
| **A — Recommandée entreprise** | **Genesys Cloud**, **Nice CXone**, ou **Amazon Connect** | Vrai contact center (files, ASA, abandon) |
| **B — Microsoft 365** | **Teams Phone** + **Call Queue** + Power BI connec. / Graph | Helpdesk déjà sur Teams |
| **C — PME / lab** | **3CX** ou **FreePBX** (CDR + API) | Budget limité, besoin rapide |
| **D — Via ITSM** | **ServiceNow CTI / OpenFrame** + softphone | Les appels créent déjà des incidents SNOW |

Le dashboard HTML du dépôt **simule** le live (démo mémoire). En production, remplacez cette simulation par un flux téléphonie → Power BI (DirectQuery / push dataset) ou Stream Analytics.

### Compléments utiles

| Besoin | Application |
|--------|-------------|
| Orchestration données | **Power Automate** ou **Azure Data Factory** |
| Entrepôt (optionnel) | **Azure SQL** / **Fabric Lakehouse** |
| Auth & sécurisation | **Entra ID** + Row-Level Security Power BI |
| Docs / SOP | **SharePoint** / Confluence |

---

## 3. Architecture cible (comment tout se relie)

```
┌─────────────────┐   ┌──────────────────┐   ┌────────────────────┐
│  ServiceNow     │   │  Salesforce      │   │  Téléphonie / CTI  │
│  Incidents      │   │  Cases           │   │  Appels / files    │
└────────┬────────┘   └────────┬─────────┘   └─────────┬──────────┘
         │                     │                       │
         ▼                     ▼                       ▼
┌────────────────────────────────────┐      ┌─────────────────────┐
│     Power Query / Dataflow         │      │ API / Event Hub /   │
│     Fact_Tickets_Unified           │      │ Push dataset appels │
└─────────────────┬──────────────────┘      └──────────┬──────────┘
                  │                                    │
                  ▼                                    ▼
┌──────────────────────────────────────────────────────────────────┐
│                         Power BI                                 │
│  Dim_Org (Directeur/Resp/TL/Agent)  ×  Fact_Tickets  ×  Fact_Calls│
│  Vues : KPI · Organigramme · Équipes · Live appels               │
└──────────────────────────────────────────────────────────────────┘
```

Clé de jointure principale côté tickets : **`AgentId` / `AssignmentGroup` / email agent`**.  
Clé côté org : **email Entra ID** = propriétaire du ticket / agent CTI.

---

## 4. Mettre en place les tickets (ServiceNow + Salesforce)

### 4.1 ServiceNow

1. Créer un compte intégration (lecture) avec accès tables :
   - `incident`
   - `sys_user`, `sys_user_group`
   - `task_sla` (si SLA détaillés)
2. Dans Power BI : **Obtenir des données → Web / OData / connecteur ServiceNow** (selon licence).
3. Utiliser le script fourni : `powerquery/01_ServiceNow_Incidents.pq`.
4. Mapper au minimum :
   - `number` → TicketID  
   - `assignment_group` → Team  
   - `assigned_to` → Agent  
   - `priority`, `state`, `u_application` / CI  
   - `escalation` / historique pour EscN2 / EscN3  
   - dates ouverture / résolution → SLA

### 4.2 Salesforce

1. Connected App + OAuth (User ou Integration User).
2. Objets : `Case`, `User`, `Group` / Queues.
3. Script : `powerquery/02_Salesforce_Cases.pq`.
4. Mapper `CaseNumber`, `Owner`, `Priority`, `Status`, `Origin`, champs custom Application / BU.

### 4.3 Unification

1. Exécuter `powerquery/03_Fact_Tickets_Unified.pq` (union SNOW + SF).
2. Ajouter colonnes calculées :
   - `Department` (via table de mapping Groupe → Département)
   - `Level` (Helpdesk / N2 / N3 / Éditeur)
   - `EscN2`, `EscN3` (règles d’escalade)
3. Coller les mesures : `dax/Mesures_DAX.txt`.
4. Jeu démo local : `data/Fact_Tickets_Unified.csv` ou `data/Equans_PowerBI_Pilotage_SI_Modele_Demo.xlsx`.

### Règles d’escalade (à figer avec le tutor)

| Transition | Règle métier typique |
|------------|---------------------|
| Helpdesk → N2 | Réaffectation hors groupe L1 ou `assignment_group` ∈ N2 |
| N2 → N3 | Passage groupe Expertise / problème majeur |
| N3 → Éditeurs | Ouverture ticket éditeur (SAP / SF / Microsoft) + lien parent |

---

## 5. Mettre en place l’organigramme

### 5.1 Contenu du référentiel

Créer une table `Dim_Org` (SharePoint Excel ou Azure SQL) :

| Colonne | Exemple |
|---------|---------|
| PersonId | AG-N2-1 |
| Nom | Mohamed BAHJI |
| Role | Agent / Team Leader / Responsable / Directeur |
| Department | Niveau 2 |
| Team | Support Applicatif N2 |
| ManagerId | TL-N2-1 |
| Email | m.bahji@entreprise.com |
| Active | Oui |

Hiérarchie attendue :

1. **Directeur SI**
2. **Responsable** de chaque département
3. **Team Leader** par équipe
4. **Agents**

### 5.2 Comment le lier aux tickets

- Dans ServiceNow : `assigned_to.email` → `Dim_Org.Email`
- Dans Salesforce : `Owner.Email` → `Dim_Org.Email`
- Dans Power BI : relation `Fact_Tickets[AgentEmail] → Dim_Org[Email]`
- Visual organigramme : visuel **Hierarchy** / **Organization chart** (AppSource) ou pages drill-through par département

### 5.3 Filtrer la vue par département

- Slicer `Department` sur toutes les pages
- Sync des slicers (Power BI : « Synchroniser les segments »)
- Optionnel : **RLS** pour qu’un TL ne voie que son équipe

Le HTML démo fait déjà ce filtre côté client (vues Org / Team / KPI / Live).

---

## 6. Mettre en place le suivi des appels (temps réel)

### 6.1 Indicateurs à brancher (PM wallboard)

| KPI | Définition |
|-----|------------|
| Entrants | Appels offerts sur la file |
| En attente | Dans la queue (non décrochés) |
| En cours | En conversation |
| Répondus | Décrochés / traités |
| Perdus / abandonnés | Raccrochés avant réponse |
| ASA | Average Speed of Answer (secondes) |
| État agent | Disponible / En appel / Wrap-up / Pause |

### 6.2 Branchement selon la stack

**Option A — Contact Center (Genesys / Nice / Amazon Connect)**  
1. Activer l’export **temps réel** (API Analytics / Data Firehose / Kinesis).  
2. Land dans Azure Event Hub ou un **Push dataset** Power BI.  
3. Page Power BI « Live » en **rafraîchissement automatique** (1–5 min, ou streaming).

**Option B — Teams Phone**  
1. Configurer **Call Queues** + **Auto attendants** (Helpdesk).  
2. Extraire CDR / Call Analytics (admin Teams) via Graph / export.  
3. Joindre `userPrincipalName` → `Dim_Org.Email`.

**Option C — 3CX**  
1. Activer API / CDR.  
2. Power Automate ou script → Azure SQL / Excel SharePoint.  
3. Power BI DirectQuery ou refresh fréquent.

**Option D — ServiceNow CTI**  
1. Softphone crée / met à jour l’incident à l’appel.  
2. Table d’événements CTI ou custom `u_call_log`.  
3. Même modèle `Fact_Calls` joint aux tickets (`TicketID` / `CallId`).

### 6.3 Modèle `Fact_Calls` (colonnes mini)

`CallId`, `StartTime`, `Department`, `Team`, `AgentEmail`, `Direction` (Entrant/Sortant), `State` (Répondu/En attente/Perdu), `WaitSeconds`, `TalkSeconds`, `Reason`, `Queue`.

---

## 7. Déployer Power BI (pas à pas)

1. Installer **Power BI Desktop**.
2. Ouvrir le projet `Equans_Pilotage_SI_PowerBI/` **ou** importer `data/*.csv` / Excel démo.
3. Coller les mesures `dax/Mesures_DAX.txt`.
4. Créer 4 pages :
   - Pilotage KPI  
   - Organigramme / effectifs  
   - Performance équipes & agents  
   - Live appels  
5. Publier vers **Power BI Service** (workspace Direction SI).
6. Planifier le refresh (tickets : 15–60 min ; appels : streaming ou 1–5 min).
7. Partager aux responsables de département (avec RLS si besoin).

Maquettes : `docs/dashboard_powerbi_style_helpdesk.png`, `docs/architecture_powerbi_salesforce_servicenow.png`.

---

## 8. Démo HTML (ce dépôt) vs production

| | `index.html` (GitHub Pages) | Production Power BI |
|--|-----------------------------|---------------------|
| Usage | Démo mémoire / présentation | Pilotage opérationnel |
| Données | Jeu fictif embarqué | ServiceNow + Salesforce + CTI |
| Org | Figée dans le JS | `Dim_Org` RH / Entra ID |
| Appels | Simulation JS (3 s) | API téléphonie / push dataset |
| Partage | Lien Pages public | Workspace sécurisé Entra ID |

Ouvrir la démo : ouvrir `index.html` ou le lien Pages du README.

---

## 9. Checklist de mise en production (ordre PM)

1. [ ] Valider les **8 départements** et les groupes ServiceNow / queues Salesforce  
2. [ ] Publier le référentiel **Dim_Org** (Directeur → Agents)  
3. [ ] Brancher **ServiceNow** (lecture incidents + SLA)  
4. [ ] Brancher **Salesforce Cases**  
5. [ ] Unifier dans **Fact_Tickets_Unified** + mesures DAX  
6. [ ] Choisir la stack **téléphonie** et créer **Fact_Calls**  
7. [ ] Publier Power BI + slicers département synchronisés  
8. [ ] Activer RLS (TL / Responsable / Directeur)  
9. [ ] Rituels : daily Helpdesk+N2, hebdo ops, mensuel N2/N3/Éditeurs  
10. [ ] Former les team leaders à lire escalades + file d’appels  

---

## 10. Mapping départements → applications

| Département | Applications / files typiques |
|-------------|-------------------------------|
| SAP | SAP FI/MM/SD, Interface CRM-SAP, Quickdevis |
| Poste de travail | Office 365, AD, VPN, postes, imprimantes |
| Packaging | SCCM, Intune, packages standard / métiers |
| Salesforce | Sales Cloud, Service Cloud, Flows |
| Helpdesk | File N1 / Call Queue principale |
| Niveau 2 | Groupes support applicatif & infra |
| Niveau 3 | Expertise / architecture / perf |
| Éditeurs | Tickets SAP / Salesforce / Microsoft (éditeur) |

---

## 11. Contacts & ownership (exemple)

| Domaine | Owner |
|---------|-------|
| Modèle données Power BI | Resp. Pilotage SI |
| Connecteurs SNOW / SF | Admin ITSM / Admin Salesforce |
| Organigramme | RH + Resp. SI |
| Téléphonie / files | Resp. Helpdesk + Telecom |
| Escalades N2/N3/Éditeurs | Responsables N2 / N3 |

---

## 12. Fichiers utiles dans ce dépôt

| Chemin | Rôle |
|--------|------|
| `index.html` | Démo interactive (4 vues) |
| `powerquery/*.pq` | Extraction SNOW / SF / union |
| `dax/Mesures_DAX.txt` | KPIs escalade & SLA |
| `data/` | CSV / Excel démo |
| `Equans_Pilotage_SI_PowerBI/` | Projet Power BI |
| `START_HERE_FR.md` | Démarrage rapide |
| `BUILD_POWERBI_STEPS.md` | Étapes build .pbip |
| `docs/GUIDE_MISE_EN_PLACE.md` | **Ce guide** |

---

*Master PSI — BAHJI Mohammed — Tableau de pilotage SI*
