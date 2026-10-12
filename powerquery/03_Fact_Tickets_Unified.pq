// ============================================================
// Power Query (M) — Union ServiceNow + Salesforce
// Produit Fact_Tickets_Unified pour le modèle sémantique
// ============================================================

let
    // Remplacer par les requêtes réelles du fichier .pbix
    SN = ServiceNow_Incidents,       // requête 01
    SF = Salesforce_Cases,           // requête 02

    // Harmoniser colonnes minimales avant append
    SN_H = Table.SelectColumns(
        Table.AddColumn(
            Table.AddColumn(
                Table.AddColumn(SN, "Application", each "ServiceNow App", type text),
                "EscalatedToN2", each if [ResolvedLevel] = "N2" or [ResolvedLevel] = "N3" then 1 else 0, Int64.Type
            ),
            "EscalatedToN3", each if [ResolvedLevel] = "N3" then 1 else 0, Int64.Type
        ),
        {"TicketID","SourceSystem","CreatedDate","ClosedDate","Priority","Category","Status","ResolvedLevel","EscalatedToN2","EscalatedToN3","Application"},
        MissingField.Ignore
    ),

    SF_H = Table.SelectColumns(
        Table.AddColumn(
            Table.AddColumn(
                Table.AddColumn(SF, "Application", each "Salesforce CRM", type text),
                "EscalatedToN2", each if [ResolvedLevel] <> "Helpdesk" then 1 else 0, Int64.Type
            ),
            "EscalatedToN3", each if [ResolvedLevel] = "N3" then 1 else 0, Int64.Type
        ),
        {"TicketID","SourceSystem","CreatedDate","ClosedDate","Priority","Category","Status","ResolvedLevel","EscalatedToN2","EscalatedToN3","Application"},
        MissingField.Ignore
    ),

    Appended = Table.Combine({SN_H, SF_H}),

    AddHelpdesk = Table.AddColumn(Appended, "HelpdeskTouched", each 1, Int64.Type),

    // Durées (heures) si absentes des sources
    AddHours = Table.AddColumn(
        AddHelpdesk,
        "ResolutionHours",
        each
            if [ClosedDate] = null or [CreatedDate] = null then null
            else Duration.TotalHours([ClosedDate] - [CreatedDate]),
        type number
    ),

    AddDate = Table.AddColumn(
        AddHours,
        "CreatedDateOnly",
        each Date.From([CreatedDate]),
        type date
    )
in
    AddDate


// BONNES PRATIQUES
// - Désactiver "Charger" sur SN et SF ; ne charger que Fact_Tickets_Unified + Dims
// - Incremental refresh sur CreatedDate (Premium/PPU/Fabric recommandé)
// - Gateways si sources on-prem / private link
// - En prod Equans : préférer un Dataflow qui matérialise Fact_Tickets_Unified
