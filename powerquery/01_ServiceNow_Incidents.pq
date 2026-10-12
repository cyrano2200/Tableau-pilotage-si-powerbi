// ============================================================
// Power Query (M) — ServiceNow Incidents → Fact partiel
// Equans IT Hubs — Helpdesk / N2 / N3
// ------------------------------------------------------------
// Dans Power BI Desktop :
//   Obtenir des données > Plus > En ligne services > ServiceNow
//   ou : Obtenir des données > Requête vide > Éditeur avancé (coller)
// Prérequis : URL instance + compte service (lecture incident)
// ============================================================

let
    // --- PARAMETRES A PERSONNALISER ---
    ServiceNowUrl = "https://VOTRE_INSTANCE.service-now.com",
    // Option A (connecteur natif) : remplacer cette source par
    // ServiceNow.Tables(ServiceNowUrl){[Name="incident"]}[Data]

    // Option B (OData / API) — exemple générique :
    Source = OData.Feed(
        ServiceNowUrl & "/api/now/table/incident",
        null,
        [Implementation = "2.0"]
    ),

    // Si connecteur natif utilisé, partir de la table incident :
    // Source = ServiceNow.Tables(ServiceNowUrl),
    // Incident = Source{[Name="incident"]}[Data],

    Typed = Table.TransformColumnTypes(
        Source,
        {
            {"number", type text},
            {"sys_created_on", type datetime},
            {"resolved_at", type datetime},
            {"closed_at", type datetime},
            {"priority", type text},
            {"state", type text},
            {"category", type text},
            {"assignment_group", type text},
            {"reopen_count", Int64.Type}
        }
    ),

    // Mapping priorité ServiceNow -> P1..P4 (adapter aux valeurs Equans)
    AddPriority = Table.AddColumn(
        Typed,
        "Priority",
        each
            if Text.Contains(Text.From([priority] ?? ""), "1") then "P1"
            else if Text.Contains(Text.From([priority] ?? ""), "2") then "P2"
            else if Text.Contains(Text.From([priority] ?? ""), "3") then "P3"
            else "P4",
        type text
    ),

    // Mapping groupe d'assignation -> niveau (à calibrer avec Equans)
    AddLevel = Table.AddColumn(
        AddPriority,
        "CurrentLevel",
        each
            let g = Text.Lower(Text.From([assignment_group] ?? ""))
            in
                if Text.Contains(g, "helpdesk") or Text.Contains(g, "service desk") or Text.Contains(g, "n1") then "Helpdesk"
                else if Text.Contains(g, "n2") or Text.Contains(g, "applicatif") or Text.Contains(g, "crm") then "N2"
                else if Text.Contains(g, "n3") or Text.Contains(g, "vendor") or Text.Contains(g, "editeur") then "N3"
                else "Helpdesk",
        type text
    ),

    AddSource = Table.AddColumn(AddLevel, "SourceSystem", each "ServiceNow", type text),

    SelectCols = Table.SelectColumns(
        AddSource,
        {
            "number", "sys_created_on", "resolved_at", "closed_at",
            "Priority", "category", "state", "CurrentLevel",
            "reopen_count", "SourceSystem", "assignment_group"
        }
    ),

    Rename = Table.RenameColumns(
        SelectCols,
        {
            {"number", "TicketID"},
            {"sys_created_on", "CreatedDate"},
            {"resolved_at", "ResolvedDate"},
            {"closed_at", "ClosedDate"},
            {"category", "Category"},
            {"state", "Status"},
            {"CurrentLevel", "ResolvedLevel"},
            {"reopen_count", "ReopenCount"}
        }
    )
in
    Rename


// NOTES EQUANS
// 1) Préférer un compte technique lecture seule + ACL limitées.
// 2) Pour EscalatedToN2 / EscalatedToN3 : joindre la table
//    sys_audit / metric_instance / reassignment history, ou un
//    champ custom u_max_tier / u_escalated_n2 renseigné par workflow.
// 3) SLA : joindre task_sla (has_breached, stage, sla).
// 4) CSAT : joindre asmt_assessment_instance / survey.
