# Guide de mise en place — Tableau de pilotage SI

Ce document explique **quelles applications utiliser**, **comment les relier**, et **comment mettre en production** le pilotage (tickets, organigramme, équipes, appels temps réel, **double écoute**, **chat coach**).

**Démo en ligne :** https://cyrano2200.github.io/Tableau-pilotage-si-powerbi/  
**Dépôt :** https://github.com/cyrano2200/Tableau-pilotage-si-powerbi

---

## 1. Vue d’ensemble (ce que tu pilotes)

| Vue (barre gauche) | Objectif | Source de données cible |
|--------------------|----------|-------------------------|
| **KPI** | Volume, SLA, escalades N1→N2 / N2→N3, charge par équipe | ServiceNow + Salesforce |
| **Org** | Organigramme cliquable : Directeur → Responsables → Team Leaders → Agents | RH / Entra ID / Excel référentiel |
| **Team** | Tickets traités par département, équipe, TL, agent | Tickets + référentiel org |
| **Live** | Appels (entrants, attente, répondus, perdus, ASA) + **double écoute** + **chat coach** | Téléphonie / CTI + Teams (chat) |
| **BO** | Backoffice : tickets traités **par département** et **par agent** (clos / en cours / attente, SLA, CSAT) | Fact_Tickets + Dim_Org |
| **Plan** | Planning par équipe : shifts, congés, formations, couverture journalière | Planning RH / Teams Shifts / Excel |

### Départements & équipes du modèle

| Département | Équipes (exemples démo) |
|-------------|-------------------------|
| **SAP** | SAP Finance, SAP Logistique |
| **Poste de travail** | Support End-User, Images & Déploiement |
| **Packaging** | Packages Standard, Packages Métiers |
| **Salesforce** | CRM & Sales Cloud, Intégrations & Flows |
| **Helpdesk** | Helpdesk L1 Matin, Helpdesk L1 Après-midi |
| **Niveau 2** | Support Applicatif N2, Support Infra N2 |
| **Niveau 3** | Architecture & Expertise, Performance & Données |
| **Éditeurs** | Éditeur SAP, Éditeur Salesforce, Éditeur Microsoft |

Hiérarchie : **Directeur SI** → **Responsable département** → **Team Leader** → **Agents**.

Les filtres (département, équipe, TL, agent, mois, source, niveau) mettent à jour **toutes** les vues.

---

## 2. Applications à utiliser (stack recommandée)

### Socle (obligatoire)

| Besoin | Application | Pourquoi |
|--------|-------------|---------|
| Tickets ITSM | **ServiceNow** | Incidents, SLA, groupes d’affectation, escalades |
| Tickets métier / CRM | **Salesforce** (Cases / Service Cloud) | Cases CRM, lien Salesforce–SAP |
| Pilotage & reporting | **Power BI Desktop + Power BI Service** | Tableaux de bord, RLS, partage Direction |
| Référentiel org / agents | **Microsoft Entra ID** + Excel/SharePoint RH | Organigramme, équipes, managers |
| Stockage fichiers | **SharePoint** ou **OneDrive** | Dimensions (équipes, calendrier, mapping) |

### Appels temps réel + double écoute

| Option | Application | Idéal si… |
|--------|-------------|-----------|
| **A — Entreprise** | **Genesys Cloud**, **Nice CXone**, **Amazon Connect** | Contact center (files, ASA, abandon, monitoring) |
| **B — Microsoft 365** | **Teams Phone** + **Call Queues** | Helpdesk déjà sur Teams |
| **C — PME / lab** | **3CX** ou **FreePBX** (CDR + API) | Budget limité |
| **D — Via ITSM** | **ServiceNow CTI / OpenFrame** + softphone | Les appels créent déjà des incidents |

### Chat coach (messages Agent / Team Leader)

| Option | Application | Comment |
|--------|-------------|---------|
| **Recommandée** | **Microsoft Teams** | Power Automate → chat 1:1 ou Adaptive Card |
| Alternative | Softphone / CTI (Genesys / 3CX messaging) | API « whisper » / message agent |
| Alternative | **ServiceNow** Work notes / Mentions | Notification dans l’incident |

La démo HTML **simule** live, double écoute et chat (mémoire / présentation). En production, branchez CTI + Teams / Power Automate.

### Compléments utiles

| Besoin | Application |
|--------|-------------|
| Orchestration | **Power Automate** ou **Azure Data Factory** |
| Entrepôt (optionnel) | **Azure SQL** / **Fabric Lakehouse** |
| Sécurité | **Entra ID** + Row-Level Security Power BI |
| Docs / SOP | **SharePoint** / Confluence |

---

## 3. Architecture cible (comment tout se relie)

```
ServiceNow ──┐
Salesforce ──┼──> Power Query / Dataflows ──> Fact_Tickets_Unified ──┐
Entra ID/RH ─┘         (+ Dim_Org)                                    │
                                                                      ├──> Power BI
Téléphonie/CTI ──> API / Events ──> Fact_Calls ──────────────────────┤     KPI · Org · Team · Live
   (+ Monitor Listen/Whisper/Barge → Fact_Monitor)                    │
                                                                      │
Microsoft Teams <── Power Automate <── Chat coach (Agent / TL) ───────┘
                         └──> Fact_CoachChat
```

**Jointures clés :**
- Tickets : `AgentEmail` / `AssignmentGroup` → `Dim_Org`
- Appels : `AgentEmail` → `Dim_Org` (+ `CallId` lié au ticket si CTI)
- Chat / double écoute : `PersonId` ou email Entra ID de l’agent / TL

---

## 4. Mettre en place les tickets (ServiceNow + Salesforce)

### 4.1 ServiceNow

1. Compte intégration (lecture) : `incident`, `sys_user`, `sys_user_group`, `task_sla`.
2. Power BI : connecteur ServiceNow / OData / Web (selon licence).
3. Script : `powerquery/01_ServiceNow_Incidents.pq`.
4. Mapper : TicketID, Team, Agent, Priority, Application, EscN2/EscN3, SLA, dates.

### 4.2 Salesforce

1. Connected App + OAuth.
2. Objets : `Case`, `User`, Queues.
3. Script : `powerquery/02_Salesforce_Cases.pq`.

### 4.3 Unification

1. `powerquery/03_Fact_Tickets_Unified.pq` (union SNOW + SF).
2. Colonnes : `Department`, `Level` (Helpdesk / N2 / N3 / Éditeur), `EscN2`, `EscN3`.
3. Mesures : `dax/Mesures_DAX.txt`.
4. Démo locale : `data/Fact_Tickets_Unified.csv` ou Excel dans `data/`.

### Règles d’escalade

| Transition | Règle typique |
|------------|---------------|
| Helpdesk → N2 | Réaffectation vers groupe N2 |
| N2 → N3 | Passage expertise / problème majeur |
| N3 → Éditeurs | Ticket éditeur (SAP / SF / Microsoft) lié au parent |

---

## 5. Mettre en place l’organigramme

### 5.1 Table `Dim_Org`

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

### 5.2 Liaison aux tickets

- ServiceNow : `assigned_to.email` → `Dim_Org.Email`
- Salesforce : `Owner.Email` → `Dim_Org.Email`
- Power BI : relation + visuel organigramme (AppSource) ou drill-through

### 5.3 Filtre par département

- Slicers synchronisés sur toutes les pages
- RLS optionnelle (un TL ne voit que son équipe)
- Dans la démo HTML : clic sur un nœud Org = filtre global

---

## 6. Suivi des appels temps réel (vue Live)

### 6.1 KPIs wallboard

| KPI | Définition |
|-----|------------|
| Entrants | Appels offerts |
| En attente | Dans la file |
| En cours | En conversation |
| Répondus | Décrochés / traités |
| Perdus | Abandonnés avant réponse |
| ASA | Temps d’attente moyen (secondes) |
| État agent | Disponible / En appel / Wrap-up / Pause / Ringing |
| Temps par état | Chronomètre de l’état courant + cumuls Dispo / Appel / Wrap-up / Pause (session) |

### 6.2 Branchement téléphonie

- **Genesys / Nice / Amazon Connect** → API analytics / Event Hub / Push dataset Power BI  
- **Teams Phone** → Call Queues + Graph / Call Analytics  
- **3CX** → CDR/API → Azure SQL / SharePoint → Power BI  
- **ServiceNow CTI** → `u_call_log` + lien incident  

### 6.3 Modèle `Fact_Calls`

`CallId`, `StartTime`, `Department`, `Team`, `AgentEmail`, `Direction`, `State`, `WaitSeconds`, `TalkSeconds`, `Reason`, `Queue`.

---

## 7. Double écoute (écoute / whisper / barge)

Fonctionnalité de **coaching téléphonique** pour le Team Leader / Responsable / PM depuis le tableau.

### 7.1 Dans la démo (onglet Live)

1. Aller sur **Live**.
2. Sur une carte agent **En appel**, cliquer **Double écoute**.
3. Choisir le mode dans la bannière verte :
   - **Silence** — écoute seule (l’agent et l’appelant ne vous entendent pas)
   - **Whisper** — vous parlez **uniquement à l’agent** (coach)
   - **Barge** — vous entrez en **conférence** (agent + appelant vous entendent)
4. **Terminer** pour couper ; coupure auto si l’appel se termine.

### 7.2 En production — quelles apps / APIs

| Mode | Genesys / Nice / Connect | 3CX | Teams Phone |
|------|--------------------------|-----|-------------|
| Silence (Listen) | API Monitor / Silent monitor | Listen feature supervisor | Supervision policy (si dispo) |
| Whisper | Whisper / Coach API | Whisper | Limited / via outils partenaires |
| Barge | Barge-in API | Barge | Limited / partenaires |

**Contrôles à prévoir :**
- Droits Entra ID / rôle « Superviseur » uniquement  
- Journal d’audit (qui a écouté qui, quand, combien de temps)  
- Bannière visible côté superviseur (comme dans la démo)  
- Interdiction d’écouter hors de son département (RLS / droits file)

### 7.3 Table d’audit `Fact_Monitor` (recommandée)

`MonitorId`, `SupervisorEmail`, `AgentEmail`, `CallId`, `Mode` (silent/whisper/barge), `StartTime`, `EndTime`, `Department`.

---

## 8. Chat coach (message Agent ou Team Leader)

Permet d’envoyer une consigne depuis le tableau **sans quitter le pilotage**.

### 8.1 Dans la démo (onglet Live)

1. Panneau **Chat coach → Agent / Team Leader**.
2. Choisir le type (Agent ou Team Leader), la personne, la priorité.
3. Saisir le message (ou utiliser un modèle : encouragement / escalade).
4. **Envoyer le chat** → historique local dans le tableau.
5. Raccourci : bouton **Chat** sur une carte agent.

Le filtre département limite la liste des destinataires.

### 8.2 En production — mise en place Microsoft Teams

1. Créer un flux **Power Automate** :
   - Déclencheur : bouton Power BI / Power Apps / HTTP depuis le portail  
   - Actions : **Post message in a chat or channel** (chat 1:1 avec l’UPN agent/TL)
2. Payload minimal : `toEmail`, `priority`, `message`, `from`, `department`, `team`.
3. Option : Adaptive Card avec boutons « Accusé réception » / « Besoin d’aide N2 ».
4. Logger les envois dans `Fact_CoachChat` (SharePoint list ou Azure SQL) pour le suivi PM.

### 8.3 Alternative ServiceNow

- Work note @mention sur l’incident ouvert de l’agent  
- ou notification `sysevent` / mobile push ServiceNow

### 8.4 Modèle `Fact_CoachChat`

`ChatId`, `Timestamp`, `FromEmail`, `ToEmail`, `ToRole` (Agent/TL), `Priority`, `Message`, `Department`, `Team`, `Channel` (Teams/SNOW).

---

## 9. Déployer Power BI (pas à pas)

1. Installer **Power BI Desktop**.
2. Ouvrir `Equans_Pilotage_SI_PowerBI/` ou importer `data/*`.
3. Coller `dax/Mesures_DAX.txt`.
4. Créer les pages :
   - Pilotage KPI  
   - Organigramme  
   - Performance équipes & agents  
   - **Live appels** (wallboard)  
   - Optionnel : page Coach (double écoute + chat — souvent via Power App embarquée)
5. Publier le workspace Direction SI.
6. Refresh : tickets 15–60 min ; appels streaming ou 1–5 min.
7. RLS par rôle (Agent / TL / Responsable / Directeur).

Maquettes : `docs/dashboard_powerbi_style_helpdesk.png`, `docs/architecture_powerbi_salesforce_servicenow.png`.

---

## 10. Démo HTML vs production

| | `index.html` (GitHub Pages) | Production |
|--|-----------------------------|------------|
| Usage | Démo mémoire / formation | Pilotage ops |
| Données | Jeu fictif (~400 tickets) | ServiceNow + Salesforce |
| Org | Figée dans le JS | `Dim_Org` RH / Entra ID |
| Appels | Simulation JS (3 s) | API téléphonie |
| Double écoute | Simulation UI (modes Silence/Whisper/Barge) | API monitoring CTI |
| Chat coach | Historique local navigateur | Teams / Power Automate |
| Partage | Lien Pages | Workspace Entra ID sécurisé |

---

## 11. Checklist de mise en production (ordre PM)

1. [ ] Valider les **8 départements** et groupes SNOW / queues Salesforce  
2. [ ] Publier **Dim_Org** (Directeur → Agents)  
3. [ ] Brancher **ServiceNow** + **Salesforce** → `Fact_Tickets_Unified`  
4. [ ] Mesures DAX escalades / SLA  
5. [ ] Choisir stack **téléphonie** → `Fact_Calls`  
6. [ ] Activer **double écoute** superviseur (droits + audit `Fact_Monitor`)  
7. [ ] Brancher **chat coach** (Teams + Power Automate + `Fact_CoachChat`)  
8. [ ] Publier Power BI + slicers département synchronisés  
9. [ ] RLS (TL / Responsable / Directeur)  
10. [ ] Rituels : daily Helpdesk+N2, hebdo ops, mensuel N2/N3/Éditeurs  
11. [ ] Former les TL à : escalades, file d’appels, double écoute, chat coach  

---

## 12. Mapping départements → applications

| Département | Applications / files typiques |
|-------------|-------------------------------|
| SAP | SAP FI/MM/SD, Interface CRM-SAP, Quickdevis |
| Poste de travail | Office 365, AD, VPN, postes, imprimantes |
| Packaging | SCCM, Intune, packages standard / métiers |
| Salesforce | Sales Cloud, Service Cloud, Flows |
| Helpdesk | File N1 / Call Queue principale |
| Niveau 2 | Support applicatif & infra |
| Niveau 3 | Expertise / architecture / perf |
| Éditeurs | Tickets SAP / Salesforce / Microsoft |

---

## 13. Ownership (exemple)

| Domaine | Owner |
|---------|-------|
| Modèle Power BI | Resp. Pilotage SI |
| Connecteurs SNOW / SF | Admin ITSM / Admin Salesforce |
| Organigramme | RH + Resp. SI |
| Téléphonie / files / double écoute | Resp. Helpdesk + Telecom |
| Chat coach (Teams) | Resp. Collaboration / M365 |
| Escalades N2/N3/Éditeurs | Responsables N2 / N3 |

---

## 14. Fichiers utiles dans ce dépôt

| Chemin | Rôle |
|--------|------|
| `index.html` | Démo interactive (KPI · Org · Team · Live + écoute + chat) |
| `docs/GUIDE_MISE_EN_PLACE.md` | **Ce guide** |
| `powerquery/*.pq` | Extraction SNOW / SF / union |
| `dax/Mesures_DAX.txt` | KPIs escalade & SLA |
| `data/` | CSV / Excel démo |
| `Equans_Pilotage_SI_PowerBI/` | Projet Power BI |
| `START_HERE_FR.md` | Démarrage rapide |
| `BUILD_POWERBI_STEPS.md` | Build .pbip |
| `README.md` | Présentation du dépôt |

---

## 15. Parcours conseillé (démo)

1. Ouvrir https://cyrano2200.github.io/Tableau-pilotage-si-powerbi/  
2. Filtrer un département (ex. **Helpdesk** ou **Salesforce**)  
3. Vue **Org** — cliquer un Team Leader → tickets filtrés  
4. Vue **Team** — comparer charge / SLA par agent  
5. Vue **Live** — observer la file, lancer une **double écoute**, envoyer un **chat** à un agent ou TL  

---

*Master PSI — BAHJI Mohammed — Tableau de pilotage SI*  
*Dernière mise à jour : double écoute (Silence / Whisper / Barge) + chat coach Agent / Team Leader*

---

## 16. Backoffice (visibilité tickets)

Onglet **BO** du dashboard :

| Bloc | Contenu |
|------|---------|
| KPIs | Volume filtré, Clos, En cours, En attente, Agents actifs, SLA |
| Par département | Cartes + graphique — clic pour zoomer sur un département |
| Par agent | Traités, Clos, En cours, Attente, SLA, CSAT, Esc N2/N3 |
| Détail | Liste des tickets du périmètre (max. 100 en démo) |

Utilisation PM : contrôler la charge backoffice, comparer les départements, identifier les agents en surcharge ou sous SLA, puis drill-down vers un agent (filtre global).

En production Power BI : page « Backoffice » avec matrices `Department × Status` et `Agent × Status`, mêmes mesures DAX.

---

## 17. Planning par équipe (onglet Plan)

Onglet **Plan** : planning hebdomadaire de **tous les collaborateurs** (Directeur, Responsables, Team Leaders, Agents), groupé par département / équipe.

### Règle de pauses (obligatoire sur vacation travaillée)

| Pause | Durée | Exemple Standard (09:00–18:00) |
|-------|-------|-------------------------------|
| Pausette matin | **15 min** | 10:30–10:45 |
| Pause déjeuner | **1 h** | 12:30–13:30 |
| Pausette soir / après-midi | **15 min** | 16:00–16:15 |

Autres vacations démo : Matin (08–16), Après-midi (12–20), Soir (14–22), Formation — chacune avec les 3 pauses affichées dans la cellule du planning.

### Contenu de la vue

- KPIs : effectif, équipes, couverture Lun–Ven, congés, formations
- Grille semaine (Lun→Dim) par personne, avec détail des pauses
- Tableau absences / formations
- Graphique de couverture journalière
- Tableau récapitulatif des horaires de pause par vacation

### Filtres

Les filtres PM (département, équipe, TL, agent) réduisent le planning affiché.

### Production — applications recommandées

| Besoin | Application |
|--------|-------------|
| Planning agents | **Microsoft Teams Shifts** ou Workforce Management (Genesys / Nice) |
| Export RH | Excel / SharePoint → Power BI (`Fact_Planning`) |
| Pointage pauses | Softphone / CTI ou badgeuse (optionnel) |

Modèle `Fact_Planning` : `PersonId`, `Date`, `Shift`, `Start`, `End`, `BreakAM_15`, `Lunch_60`, `BreakPM_15`, `Status` (Work/Off/Leave/Training).

