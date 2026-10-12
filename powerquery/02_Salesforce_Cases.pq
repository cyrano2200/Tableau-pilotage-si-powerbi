// ============================================================
// Power Query (M) — Salesforce Cases → Fact partiel
// Equans IT Hubs — Helpdesk / N2 / N3
// ------------------------------------------------------------
// Power BI Desktop :
//   Obtenir des données > Plus > Services en ligne > Salesforce Objects
//   Environnement Production / Custom, objet Case (+ champs custom)
// ============================================================

let
    // Connecteur natif Salesforce (UI) :
    // Source = Salesforce.Data("https://login.salesforce.com/", [ApiVersion=48]),
    // CaseTable = Source{[Name="Case"]}[Data],

    // Placeholder générique (remplacé automatiquement par le connecteur UI) :
    Source = Salesforce.Data("https://login.salesforce.com/", [ApiVersion = 58]),
    CaseTable = Source{[Name = "Case"]}[Data],

    // Garder les colonnes utiles (adapter noms API Equans)
    Keep = Table.SelectColumns(
        CaseTable,
        {
            "CaseNumber", "CreatedDate", "ClosedDate", "Priority",
            "Status", "Type", "Reason", "Origin", "IsClosed",
            "IsEscalated", "OwnerId", "AccountId"
            // Ajouter si existants :
            // "Product__c", "Support_Tier__c", "First_Response_Time__c",
            // "Time_to_Resolution__c", "CSAT__c", "Business_Unit__c"
        },
        MissingField.Ignore
    ),

    Typed = Table.TransformColumnTypes(
        Keep,
        {
            {"CaseNumber", type text},
            {"CreatedDate", type datetime},
            {"ClosedDate", type datetime},
            {"Priority", type text},
            {"Status", type text},
            {"IsEscalated", type logical}
        }
    ),

    AddSource = Table.AddColumn(Typed, "SourceSystem", each "Salesforce Case", type text),

    // Normalisation priorité Salesforce -> P1..P4
    AddPriority = Table.AddColumn(
        AddSource,
        "PriorityNorm",
        each
            let p = Text.Lower(Text.From([Priority] ?? ""))
            in
                if p = "critical" or p = "highest" or p = "1" then "P1"
                else if p = "high" or p = "2" then "P2"
                else if p = "medium" or p = "3" then "P3"
                else "P4",
        type text
    ),

    // Niveau : via queue / custom Support_Tier__c si dispo, sinon heuristique IsEscalated
    AddLevel = Table.AddColumn(
        AddPriority,
        "ResolvedLevel",
        each
            if [IsEscalated] = true then "N2" else "Helpdesk",
        type text
    ),

    Rename = Table.RenameColumns(
        AddLevel,
        {
            {"CaseNumber", "TicketID"},
            {"PriorityNorm", "Priority"},
            {"Type", "Category"}
        }
    )
in
    Rename


// NOTES EQUANS
// 1) Auth : compte OAuth dédié Power BI (pas compte personnel).
// 2) Pour N2/N3 fiables : créer Support_Tier__c (Helpdesk/N2/N3)
//    mis à jour par Omni-Channel / assignment rules / Flow.
// 3) Joindre User / Group pour identifier queues Helpdesk vs N2.
// 4) Entitlements + Milestones = source SLA Salesforce.
// 5) Si le volume Case est faible vs ServiceNow, Salesforce peut
//    servir surtout au CRM métier + cases applicatifs CRM.
