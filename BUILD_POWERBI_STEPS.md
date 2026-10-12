# Pas-à-pas Power BI Desktop — Reproduire le tableau de pilotage

## Page 1 — Executive (comme la maquette)
### Cartes (Card visuals)
- `Tickets`
- `SLA Resolution %` (format %)
- `Escalade Helpdesk vers N2 %`
- `Escalade N2 vers N3 %`

### Jauges (Gauge)
- Esc N1→N2 : Value = mesure, Target = 0.30, Max = 1
- Esc N2→N3 : Value = mesure, Target = 0.20, Max = 1

### Funnel
- Champs : ResolvedLevel (ou Level) + Tickets
- Ordre : Helpdesk → N2 → N3

### Matrice / Tableau
- Lignes : Dim_Level[LevelName]
- Valeurs : SLA Resolution %, Tickets, CSAT Moyen

## Page 2 — Helpdesk
- SLA Premiere Reponse %
- Taux Resolution Helpdesk %
- Volume par Category / Application
- Filtre SourceSystem

## Page 3 — Escalades
- Graphique en entonnoir
- Courbe mensuelle Escalade Helpdesk vers N2 %
- Courbe Escalade N2 vers N3 %
- Statut Escalade (Vert/Orange/Rouge)

## Thème couleurs
- Helpdesk / Vert : #2E9B5A
- N2 / Orange : #E89A2C
- N3 / Rouge : #D94A4A
- Header bleu : #2F6FED

## Relations
Fact_Tickets_Unified[Priority] → Dim_Priority[Priority]
Fact_Tickets_Unified[ResolvedLevel] → Dim_Level[LevelKey]
Fact_Tickets_Unified[SourceSystem] → Dim_Source[SourceKey]
Fact_Tickets_Unified[Application] → Dim_Application[Application]
Fact_Tickets_Unified[CreatedDate] (date only) → Dim_Calendar[Date]
