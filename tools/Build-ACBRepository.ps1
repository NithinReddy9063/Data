Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$BiblePath = Join-Path $Root "ACB_Knowledge_Base_Bible_v1.0.md"
$IndexPath = Join-Path $Root "ACB_Repository_Index_v1.0.md"
$DocumentsRoot = Join-Path $Root "documents"
$ManifestPath = Join-Path $Root "ACB_Repository_Manifest_v1.0.md"
$StatusPath = Join-Path $Root "ACB_Document_Register_Status_v1.0.md"
$BatchAuditPath = Join-Path $Root "ACB_Batch_Audit_Log_v1.0.md"
$FinalAuditPath = Join-Path $Root "ACB_Final_Repository_Audit_Report_v1.0.md"

$ApprovedProducts = @(
  "Savings Account", "Current Account", "Salary Account", "Fixed Deposit", "Recurring Deposit",
  "Business Current Account", "Escrow Account", "Cash Management",
  "Home Loan", "Personal Loan", "Business Loan", "Working Capital", "Overdraft",
  "Letter of Credit (LC)", "Bank Guarantee (BG)", "Export Finance", "Import Finance", "Documentary Collection",
  "NEFT", "RTGS", "IMPS", "UPI", "SWIFT", "ACH"
)

$ApprovedCustomerTypes = @(
  "Individual", "Minor", "NRI", "Resident", "Sole Proprietor", "Partnership",
  "Private Limited", "Public Limited", "Trust", "Government Entity", "Financial Institution", "NGO"
)

$ApprovedRiskLevels = @("Low", "Medium", "High", "Critical")
$ApprovalHierarchy = @(
  "Operations Officer", "Operations Manager", "Branch Manager", "Regional Manager",
  "Department Head", "Compliance Head", "Chief Compliance Officer"
)

$DocTypeFolders = @{
  "POL" = "policies"
  "SOP" = "sops"
  "KOD" = "kod"
  "EXM" = "exception_matrices"
  "FAQ" = "case_repository"
}

$RequiredMetadata = @(
  "Document ID", "Title", "Document Type", "Department", "Domain", "Business Unit", "Owner", "Approver",
  "Version", "Status", "Classification", "Effective Date", "Review Date", "Priority", "Applicable Products",
  "Applicable Customer Types", "Risk Level", "Keywords", "Related Documents", "Supersedes"
)

$RequiredSectionsByType = @{
  "POL" = @("Document Control", "Purpose", "Scope", "Definitions", "Policy Statements", "Roles", "Decision Rules", "Exceptions", "Escalation", "Controls", "Related Documents", "Version History")
  "SOP" = @("Document Control", "Purpose", "Preconditions", "Inputs", "Procedure", "Decision Points", "Outputs", "Exception Handling", "Escalation", "KPIs", "References")
  "KOD" = @("Document Control", "Purpose", "Applicable Products", "Required Documents", "Validation Rules", "Acceptance Criteria", "Rejection Criteria", "Common Errors", "References")
  "EXM" = @("Scenario", "Risk", "Decision", "Approval Required", "SLA", "Escalation", "Reference")
  "FAQ" = @("Case ID", "Business Context", "Customer Scenario", "Question", "Resolution", "Reasoning", "Supporting Documents", "Lessons Learned")
}

function Assert-SourceFiles {
  if (-not (Test-Path -LiteralPath $BiblePath)) { throw "Knowledge Base Bible not found: $BiblePath" }
  if (-not (Test-Path -LiteralPath $IndexPath)) { throw "Repository Index not found: $IndexPath" }
}

function Split-MarkdownRow {
  param([string]$Line)
  $parts = $Line -split "\|"
  $result = @()
  for ($i = 1; $i -lt ($parts.Count - 1); $i++) {
    $result += $parts[$i].Trim()
  }
  return $result
}

function Get-DomainMetadata {
  $lines = Get-Content -LiteralPath $IndexPath
  $inSection = $false
  $metadata = @{}
  foreach ($line in $lines) {
    if ($line -eq "## Domain Metadata Register") {
      $inSection = $true
      continue
    }
    if ($inSection -and $line -eq "## Document Register") {
      break
    }
    if ($inSection -and $line -match "^\| .+ \| .+ \| .+ \| .+ \| .+ \| .+ \| .+ \| .+ \|$" -and $line -notmatch "^\| ---") {
      $cols = Split-MarkdownRow $line
      if ($cols.Count -eq 8 -and $cols[0] -ne "Domain") {
        $metadata[$cols[0]] = [pscustomobject]@{
          Domain = $cols[0]
          Department = $cols[1]
          BusinessUnit = $cols[2]
          Priority = $cols[3]
          RiskLevel = $cols[4]
          ApplicableProducts = $cols[5]
          ApplicableCustomerTypes = $cols[6]
          Keywords = $cols[7]
        }
      }
    }
  }
  return $metadata
}

function Get-DocumentRegister {
  $lines = Get-Content -LiteralPath $IndexPath
  $records = @()
  foreach ($line in $lines) {
    if ($line -match "^\| (POL|SOP|KOD|EXM|FAQ)-") {
      $cols = Split-MarkdownRow $line
      if ($cols.Count -ge 4) {
        $id = $cols[0]
        if ($id -match "^(POL|SOP|KOD|EXM|FAQ)-(.+)-(\d{3})$") {
          $records += [pscustomobject]@{
            DocumentID = $id
            TypeCode = $Matches[1]
            Domain = $Matches[2]
            Sequence = $Matches[3]
            DocumentType = $cols[1]
            Title = $cols[2]
            RelatedDocuments = @($cols[3] -split ";" | ForEach-Object { $_.Trim() } | Where-Object { $_ })
          }
        }
      }
    }
  }
  return $records
}

function Expand-Products {
  param([string]$Value)
  if ($Value -like "All approved products*") { return ($ApprovedProducts -join "; ") }
  return $Value
}

function Expand-CustomerTypes {
  param([string]$Value)
  if ($Value -like "All approved customer types*") { return ($ApprovedCustomerTypes -join "; ") }
  return $Value
}

function Sanitize-FilePart {
  param([string]$Value)
  $clean = $Value -replace '[\\/:*?"<>|]', ''
  $clean = $clean -replace '\s+', '_'
  $clean = $clean -replace '_+', '_'
  return $clean.Trim("_")
}

function Get-DocumentPath {
  param($Record)
  $folder = Join-Path $DocumentsRoot $DocTypeFolders[$Record.TypeCode]
  $fileName = "$(Sanitize-FilePart $Record.DocumentID)_$(Sanitize-FilePart $Record.Title).md"
  return Join-Path $folder $fileName
}

function Get-RelatedTitle {
  param(
    [string]$DocumentID,
    $RecordById
  )
  if ($RecordById.ContainsKey($DocumentID)) { return $RecordById[$DocumentID].Title }
  return $DocumentID
}

function Get-MetadataLines {
  param($Record, $DomainMeta)
  $products = Expand-Products $DomainMeta.ApplicableProducts
  $customerTypes = Expand-CustomerTypes $DomainMeta.ApplicableCustomerTypes
  $keywords = "$($DomainMeta.Keywords), $($Record.Title.ToLowerInvariant())"
  return @(
    "| Metadata Field | Value |",
    "| --- | --- |",
    "| Document ID | $($Record.DocumentID) |",
    "| Title | $($Record.Title) |",
    "| Document Type | $($Record.DocumentType) |",
    "| Department | $($DomainMeta.Department) |",
    "| Domain | $($Record.Domain) |",
    "| Business Unit | $($DomainMeta.BusinessUnit) |",
    "| Owner | Department Head |",
    "| Approver | Chief Compliance Officer |",
    "| Version | 1.0 |",
    "| Status | Approved |",
    "| Classification | Internal |",
    "| Effective Date | 2026-07-01 |",
    "| Review Date | 2027-07-01 |",
    "| Priority | $($DomainMeta.Priority) |",
    "| Applicable Products | $products |",
    "| Applicable Customer Types | $customerTypes |",
    "| Risk Level | $($DomainMeta.RiskLevel) |",
    "| Keywords | $keywords |",
    "| Related Documents | $($Record.RelatedDocuments -join '; ') |",
    "| Supersedes | None |"
  )
}

function Get-GovernanceLines {
  param($Record)
  return @(
    "",
    "| Governance Item | Requirement |",
    "| --- | --- |",
    "| Document Owner | Department Head owns the content, annual review, and control alignment for this document. |",
    "| Operating Responsibility | Operations Officer performs first-level activity and Operations Manager performs supervisory review. |",
    "| Compliance Oversight | Compliance Officer or Senior Compliance Officer reviews policy adherence and escalated control concerns. |",
    "| Final Approval | Chief Compliance Officer approves deployment and material change. |",
    "| Approval Hierarchy | Operations Officer; Operations Manager; Branch Manager; Regional Manager; Department Head; Compliance Head; Chief Compliance Officer |"
  )
}

function Get-VersionHistoryLines {
  param($Record)
  return @(
    "| Version | Date | Author | Description | Approval |",
    "| --- | --- | --- | --- | --- |",
    "| 1.0 | 2026-07-01 | Department Head | Initial approved deployment version for $($Record.DocumentID) $($Record.Title). | Chief Compliance Officer |"
  )
}

function Get-ReferenceTable {
  param($Record, $RecordById, [string]$RelationshipLabel)
  $lines = @("| Document ID | Title | Relationship |", "| --- | --- | --- |")
  foreach ($related in $Record.RelatedDocuments) {
    $title = Get-RelatedTitle $related $RecordById
    $lines += "| $related | $title | $RelationshipLabel |"
  }
  return $lines
}

function Get-DomainActivity {
  param([string]$Domain)
  switch ($Domain) {
    "KYC" { return "customer identification, verification, and due diligence" }
    "AML" { return "screening, monitoring, investigation, and financial crime control" }
    "Trade Finance" { return "trade transaction review, document checking, and instrument processing" }
    "Customer Onboarding" { return "customer account opening, approval routing, and onboarding data control" }
    "Payments" { return "payment instruction validation, processing, repair, and exception handling" }
    "Credit" { return "credit assessment, facility review, and lending evidence control" }
    "Retail Banking" { return "retail account servicing, deposit handling, and customer maintenance" }
    "Corporate Banking" { return "corporate account servicing, escrow control, and cash management support" }
    default { return "banking operations control" }
  }
}

function Get-PrimarySla {
  param([string]$Domain)
  switch ($Domain) {
    "AML" { return "AML Investigation - 3 Business Days" }
    "Trade Finance" { return "Trade Transaction Review - 1 Business Day" }
    "Customer Onboarding" { return "Standard Account Opening - 2 Business Days" }
    "Credit" { return "High Risk Review - 5 Business Days" }
    "Retail Banking" { return "Complaint Resolution - 3 Business Days" }
    "Corporate Banking" { return "Document Verification - 4 Hours" }
    default { return "Document Verification - 4 Hours" }
  }
}

function Get-PolicyDocument {
  param($Record, $DomainMeta, $RecordById)
  $activity = Get-DomainActivity $Record.Domain
  $sla = Get-PrimarySla $Record.Domain
  $lines = @()
  $lines += "# $($Record.Title)"
  $lines += ""
  $lines += "## Document Control"
  $lines += ""
  $lines += Get-MetadataLines $Record $DomainMeta
  $lines += Get-GovernanceLines $Record
  $lines += ""
  $lines += "## Purpose"
  $lines += ""
  $lines += "This policy defines the mandatory governance, control, approval, and evidence requirements for $activity within APEX Commercial Bank. It establishes a consistent enterprise standard for $($Record.Domain) activities so that customer decisions, operational actions, exception handling, and record keeping are performed in a controlled and auditable manner."
  $lines += ""
  $lines += "The policy supports the Operations Knowledge Assistant by providing approved decision logic, accountable roles, cross-reference points, and deployment-ready guidance for the document record $($Record.DocumentID)."
  $lines += ""
  $lines += "## Scope"
  $lines += ""
  $lines += "This policy applies to the department $($DomainMeta.Department), the business unit $($DomainMeta.BusinessUnit), all applicable products and customer types defined in the Document Control metadata, and all ACB personnel performing or approving $($Record.Domain) activity."
  $lines += ""
  $lines += "| Scope Area | Requirement |"
  $lines += "| --- | --- |"
  $lines += "| Customer Coverage | Applies to each applicable customer type recorded in the approved metadata. |"
  $lines += "| Product Coverage | Applies only to approved products recorded in the approved metadata. |"
  $lines += "| Operational Coverage | Applies from request receipt through validation, approval, exception handling, escalation, and record retention. |"
  $lines += "| Control Coverage | Applies to standard, Medium, High, and Critical risk conditions using the approved risk categories. |"
  $lines += ""
  $lines += "## Definitions"
  $lines += ""
  $lines += "| Term | Definition |"
  $lines += "| --- | --- |"
  $lines += "| ACB | APEX Commercial Bank, the fictional enterprise bank governed by this repository. |"
  $lines += "| Customer Record | The controlled ACB record containing customer information, supporting evidence, approval actions, and decision rationale. |"
  $lines += "| Control Evidence | The document, checklist, approval note, system record, or case note retained to demonstrate completion of a required control. |"
  $lines += "| Exception | A documented departure from the standard rule that is permitted only when approved through the required hierarchy. |"
  $lines += "| Risk Level | The approved risk category of Low, Medium, High, or Critical assigned to the customer, case, request, or transaction. |"
  $lines += "| Related Document | A registered document listed in the ACB Repository Index and referenced by this policy for operating detail, document evidence, exception handling, or case guidance. |"
  $lines += ""
  $lines += "## Policy Statements"
  $lines += ""
  $lines += "1. ACB must perform $activity in accordance with this policy and the related documents listed in the Related Documents section."
  $lines += "2. No operational decision may be completed where mandatory evidence is missing, inconsistent, expired, illegible, or not linked to the relevant customer record."
  $lines += "3. Operations Officer review is required before operational completion, approval routing, or customer communication is finalized."
  $lines += "4. Operations Manager review is required when a case contains an exception, unresolved discrepancy, SLA risk, or supervisory approval condition."
  $lines += "5. Compliance Officer or Senior Compliance Officer review is required when compliance interpretation, High risk classification, or enhanced control review is required."
  $lines += "6. Critical risk activity must not proceed without escalation through the approved hierarchy and documented Chief Compliance Officer decision."
  $lines += "7. Relationship Manager and Relationship Officer activity must support customer communication and evidence collection without overriding operations or compliance control decisions."
  $lines += "8. Approval decisions must be supported by a clear decision rationale and retained with the customer record or case record."
  $lines += "9. Exceptions must be mapped to the applicable Exception Matrix and must not be used to bypass AML, KYC, credit, payment, trade finance, or customer approval controls."
  $lines += "10. Records must remain retrievable for audit, quality review, customer inquiry, and control testing."
  $lines += ""
  $lines += "## Roles"
  $lines += ""
  $lines += "| Role | Responsibility |"
  $lines += "| --- | --- |"
  $lines += "| Relationship Manager | Supports customer-facing coordination and ensures customer information is routed to operations without changing control outcomes. |"
  $lines += "| Relationship Officer | Obtains missing customer information requested by operations and records customer responses. |"
  $lines += "| Operations Officer | Performs first-level review, records control evidence, identifies discrepancies, and routes exceptions. |"
  $lines += "| Operations Manager | Performs supervisory review, approves operational remediation, monitors SLA adherence, and escalates unresolved issues. |"
  $lines += "| Compliance Officer | Reviews standard compliance questions and confirms policy interpretation where required. |"
  $lines += "| Senior Compliance Officer | Reviews High risk cases, enhanced review decisions, and material compliance concerns. |"
  $lines += "| AML Analyst | Reviews AML-related indicators where screening, monitoring, or suspicious activity concerns are present. |"
  $lines += "| Credit Risk Officer | Reviews lending-related evidence and risk concerns where applicable to credit products. |"
  $lines += "| Branch Manager | Reviews branch-level escalations and confirms activation or servicing does not proceed while mandatory controls remain open. |"
  $lines += "| Regional Manager | Reviews regional escalations and ensures consistent application of policy decisions. |"
  $lines += "| Department Head | Owns the document, confirms annual review, and ensures procedures remain aligned to this policy. |"
  $lines += ""
  $lines += "## Decision Rules"
  $lines += ""
  $lines += "| Condition | Risk Level | Decision | Minimum Approval | Evidence Required |"
  $lines += "| --- | --- | --- | --- | --- |"
  $lines += "| Mandatory evidence is complete, valid, consistent, and linked to the customer record | Low | Proceed under the applicable SOP | Operations Officer | Completed review checklist and accepted evidence record |"
  $lines += "| Minor discrepancy exists and does not affect identity, authority, ownership, eligibility, or transaction purpose | Medium | Correct the record and proceed after supervisory review | Operations Manager | Correction note, customer confirmation, and reviewer rationale |"
  $lines += "| Evidence is incomplete, expired, illegible, or inconsistent with customer or transaction data | High | Suspend completion until remediation or approved exception is recorded | Senior Compliance Officer | Exception assessment, customer communication, and remediation evidence |"
  $lines += "| Concern affects AML, sanctions, ownership opacity, credit risk, payment legitimacy, or trade transaction integrity | Critical | Do not proceed until executive approval is recorded | Chief Compliance Officer | Escalation pack, risk rationale, and final decision |"
  $lines += ""
  $lines += "| SLA Event | Approved SLA | Required Action | Escalation Trigger |"
  $lines += "| --- | --- | --- | --- |"
  $lines += "| Standard review request received | $sla | Operations Officer records decision or blocker | SLA cannot be met because evidence or approval is incomplete |"
  $lines += "| Supervisory review required | Document Verification - 4 Hours | Operations Manager reviews exception or discrepancy | Decision requires Branch Manager or higher review |"
  $lines += "| High risk review required | High Risk Review - 5 Business Days | Senior Compliance Officer records enhanced review outcome | Risk classification becomes Critical |"
  $lines += ""
  $lines += "## Exceptions"
  $lines += ""
  $lines += "| Exception Type | Permitted Handling | Approval Required | Control Requirement |"
  $lines += "| --- | --- | --- | --- |"
  $lines += "| Missing non-critical evidence with documented remediation path | Conditional continuation without final completion | Operations Manager | Evidence request and follow-up date must be recorded. |"
  $lines += "| Minor data discrepancy that does not alter customer or transaction risk | Correction and supervisory approval | Operations Manager | Correction rationale and customer confirmation must be retained. |"
  $lines += "| High risk evidence gap or unresolved control concern | Suspend completion and escalate | Senior Compliance Officer | Enhanced review and exception reference must be recorded. |"
  $lines += "| Critical risk concern | Do not proceed unless executive approval is recorded | Chief Compliance Officer | Escalation pack and final decision must be retained. |"
  $lines += ""
  $lines += "## Escalation"
  $lines += ""
  $lines += "| Escalation Level | Trigger | Required Action |"
  $lines += "| --- | --- | --- |"
  foreach ($role in $ApprovalHierarchy) {
    switch ($role) {
      "Operations Officer" { $trigger = "First-level review identifies missing evidence, discrepancy, or workflow blocker"; $action = "Record blocker, request remediation, and route for supervisory review when required" }
      "Operations Manager" { $trigger = "Operational exception, SLA risk, or unresolved evidence issue"; $action = "Approve remediation, reject exception, or escalate to Branch Manager" }
      "Branch Manager" { $trigger = "Customer impact or branch-level activation concern remains unresolved"; $action = "Confirm customer-facing position and prevent completion until controls are closed" }
      "Regional Manager" { $trigger = "Repeated issue, regional inconsistency, or significant operational exposure"; $action = "Review consistency and route material matters to Department Head" }
      "Department Head" { $trigger = "Policy interpretation, systemic control failure, or material operational risk"; $action = "Determine corrective action and coordinate compliance review" }
      "Compliance Head" { $trigger = "Material compliance issue or High risk matter requiring senior compliance position"; $action = "Confirm compliance decision and route Critical matters for executive approval" }
      "Chief Compliance Officer" { $trigger = "Critical risk decision or executive approval condition"; $action = "Approve, reject, or impose documented conditions" }
    }
    $lines += "| $role | $trigger | $action |"
  }
  $lines += ""
  $lines += "## Controls"
  $lines += ""
  $lines += "| Control | Objective | Performer | Frequency | Evidence |"
  $lines += "| --- | --- | --- | --- | --- |"
  $lines += "| $($Record.DocumentID)-CTRL-01 | Confirm mandatory evidence is present and linked to the customer or case record | Operations Officer | Per request | Completed checklist and evidence record |"
  $lines += "| $($Record.DocumentID)-CTRL-02 | Confirm discrepancies and exceptions are reviewed before completion | Operations Manager | Per exception | Exception decision and reviewer rationale |"
  $lines += "| $($Record.DocumentID)-CTRL-03 | Confirm High and Critical risk matters receive required escalation | Senior Compliance Officer | Per escalated case | Enhanced review note and approval trail |"
  $lines += "| $($Record.DocumentID)-CTRL-04 | Confirm records are retained and retrievable for audit | Department Head | Quarterly | Sample review results and remediation tracker |"
  $lines += ""
  $lines += "## Related Documents"
  $lines += ""
  $lines += Get-ReferenceTable $Record $RecordById "Mandatory policy cross-reference"
  $lines += ""
  $lines += "## Version History"
  $lines += ""
  $lines += Get-VersionHistoryLines $Record
  return $lines
}

function Get-SopDocument {
  param($Record, $DomainMeta, $RecordById)
  $activity = Get-DomainActivity $Record.Domain
  $sla = Get-PrimarySla $Record.Domain
  $lines = @()
  $lines += "# $($Record.Title)"
  $lines += ""
  $lines += "## Document Control"
  $lines += ""
  $lines += Get-MetadataLines $Record $DomainMeta
  $lines += Get-GovernanceLines $Record
  $lines += ""
  $lines += Get-VersionHistoryLines $Record
  $lines += ""
  $lines += "## Purpose"
  $lines += ""
  $lines += "This Standard Operating Procedure defines the controlled operating steps for $activity under document $($Record.DocumentID). It converts the related policy requirements into repeatable actions for operations, compliance review, escalation, evidence retention, and customer communication."
  $lines += ""
  $lines += "## Preconditions"
  $lines += ""
  $lines += "| Preconditions | Requirement |"
  $lines += "| --- | --- |"
  $lines += "| Registered Request | A customer, account, transaction, facility, or service request has been received through an approved ACB channel. |"
  $lines += "| Customer Record | The customer type, product, and risk level are recorded using approved ACB values. |"
  $lines += "| Evidence Availability | Mandatory documents or case evidence are attached, requested, or documented as pending. |"
  $lines += "| Access Control | The Operations Officer and Operations Manager handling the case are authorized to perform the workflow. |"
  $lines += "| Related Policy | The parent policy listed in the References section is applicable to the request. |"
  $lines += ""
  $lines += "## Inputs"
  $lines += ""
  $lines += "| Input | Source | Minimum Quality Standard |"
  $lines += "| --- | --- | --- |"
  $lines += "| Customer request or case instruction | Relationship Manager, Relationship Officer, customer record, or operations queue | Complete, dated, and linked to the customer record |"
  $lines += "| Supporting documents | Customer record or approved document capture channel | Legible, current where required, and aligned to applicable KOD |"
  $lines += "| Risk classification | Operations or compliance workflow | Recorded as Low, Medium, High, or Critical |"
  $lines += "| Prior decision record | Existing customer or case record where applicable | Retrievable and consistent with current request |"
  $lines += ""
  $lines += "## Procedure"
  $lines += ""
  $lines += "| Step | Role | Action | Evidence Produced |"
  $lines += "| ---: | --- | --- | --- |"
  $lines += "| 1 | Operations Officer | Receive the request, confirm the document ID context, and verify that the customer record contains the required product, customer type, and risk level. | Intake note and case reference |"
  $lines += "| 2 | Operations Officer | Compare submitted evidence against the related KOD and identify missing, expired, inconsistent, or unclear items. | Evidence review checklist |"
  $lines += "| 3 | Operations Officer | Record the preliminary decision and route standard cases for completion or non-standard cases to the Operations Manager. | Preliminary decision note |"
  $lines += "| 4 | Operations Manager | Review exceptions, SLA concerns, and discrepancies using the related Exception Matrix. | Supervisory review outcome |"
  $lines += "| 5 | Compliance Officer | Provide compliance interpretation when policy application, customer risk, or evidence sufficiency is unclear. | Compliance review note |"
  $lines += "| 6 | Senior Compliance Officer | Review High risk cases and determine whether enhanced review or escalation is required. | Enhanced review decision |"
  $lines += "| 7 | Operations Manager | Confirm final operating decision, required customer communication, and record retention action. | Final operations decision |"
  $lines += "| 8 | Operations Officer | Update the customer or case record and close the workflow only when mandatory evidence and approvals are complete. | Closure note and retained evidence |"
  $lines += ""
  $lines += "## Decision Points"
  $lines += ""
  $lines += "| Decision Point | Proceed When | Escalate When | Approval Required |"
  $lines += "| --- | --- | --- | --- |"
  $lines += "| Evidence Completeness | All mandatory evidence is present and linked to the customer record | Evidence is missing, expired, or illegible | Operations Manager |"
  $lines += "| Data Consistency | Customer, product, and request data are consistent across records | Material discrepancy affects identity, authority, eligibility, or transaction purpose | Senior Compliance Officer |"
  $lines += "| Risk Classification | Risk level is Low or Medium and no enhanced review indicator exists | Risk level is High or Critical | Senior Compliance Officer or Chief Compliance Officer |"
  $lines += "| SLA Control | The workflow can be completed within $sla | SLA breach is likely or has occurred | Branch Manager |"
  $lines += ""
  $lines += "## Outputs"
  $lines += ""
  $lines += "| Output | Required Content | Record Location |"
  $lines += "| --- | --- | --- |"
  $lines += "| Completed review decision | Accepted, rejected, remediated, or escalated decision with rationale | Customer record or case record |"
  $lines += "| Exception record | Scenario, risk level, approval, SLA impact, and related EXM reference | Exception record linked to customer or case |"
  $lines += "| Customer communication | Clear request for missing evidence or decision outcome where applicable | Customer interaction record |"
  $lines += "| Audit evidence | Checklist, supporting documents, approvals, and closure note | Controlled document repository or workflow record |"
  $lines += ""
  $lines += "## Exception Handling"
  $lines += ""
  $lines += "| Exception | Handling Requirement | Approval |"
  $lines += "| --- | --- | --- |"
  $lines += "| Missing evidence | Request remediation and suspend completion until evidence is received or approved exception is recorded | Operations Manager |"
  $lines += "| Material discrepancy | Escalate for enhanced review and do not complete workflow until decision is recorded | Senior Compliance Officer |"
  $lines += "| Critical risk condition | Hold processing and escalate through the approved hierarchy | Chief Compliance Officer |"
  $lines += "| Customer communication delay | Record reason, expected completion date, and customer impact | Branch Manager |"
  $lines += ""
  $lines += "## Escalation"
  $lines += ""
  $lines += "| Escalation Level | Trigger | Action |"
  $lines += "| --- | --- | --- |"
  $lines += "| Operations Officer | First-level review identifies a blocker | Record blocker and route to Operations Manager |"
  $lines += "| Operations Manager | Exception, discrepancy, or SLA risk requires supervisory decision | Approve remediation or escalate |"
  $lines += "| Branch Manager | Customer-facing impact or unresolved branch issue exists | Confirm operating position and customer handling |"
  $lines += "| Regional Manager | Repeated branch issue or regional inconsistency is identified | Review consistency and route material matters |"
  $lines += "| Department Head | Systemic control concern or procedure interpretation is required | Determine corrective action |"
  $lines += "| Compliance Head | Material compliance concern requires senior compliance decision | Confirm compliance position |"
  $lines += "| Chief Compliance Officer | Critical risk approval is required | Record final decision |"
  $lines += ""
  $lines += "## KPIs"
  $lines += ""
  $lines += "| KPI | Target | Measurement Source |"
  $lines += "| --- | --- | --- |"
  $lines += "| SLA adherence | 100 percent of cases completed or escalated within approved SLA | Workflow timestamp report |"
  $lines += "| Evidence completeness | 100 percent of completed cases contain mandatory evidence | Quality review sample |"
  $lines += "| Exception documentation | 100 percent of exceptions include approval and rationale | Exception register |"
  $lines += "| Audit retrievability | 100 percent of sampled records are retrievable | Quarterly control sample |"
  $lines += ""
  $lines += "## References"
  $lines += ""
  $lines += Get-ReferenceTable $Record $RecordById "SOP operating reference"
  return $lines
}

function Get-KodDocument {
  param($Record, $DomainMeta, $RecordById)
  $lines = @()
  $lines += "# $($Record.Title)"
  $lines += ""
  $lines += "## Document Control"
  $lines += ""
  $lines += Get-MetadataLines $Record $DomainMeta
  $lines += Get-GovernanceLines $Record
  $lines += ""
  $lines += Get-VersionHistoryLines $Record
  $lines += ""
  $lines += "## Purpose"
  $lines += ""
  $lines += "This Knowledge of Documents record defines the acceptable document evidence, validation rules, acceptance criteria, rejection criteria, and common errors for $($Record.Domain) activity under $($Record.DocumentID). It is used by Operations Officer, Operations Manager, Compliance Officer, Senior Compliance Officer, AML Analyst, and Credit Risk Officer roles where the related policy and SOP require documentary evidence."
  $lines += ""
  $lines += "## Applicable Products"
  $lines += ""
  $products = (Expand-Products $DomainMeta.ApplicableProducts) -split ";" | ForEach-Object { $_.Trim() } | Where-Object { $_ }
  $lines += "| Product | Applicability |"
  $lines += "| --- | --- |"
  foreach ($product in $products) {
    $lines += "| $product | Applicable when the customer request, transaction, facility, or service record requires evidence covered by this KOD. |"
  }
  $lines += ""
  $lines += "## Required Documents"
  $lines += ""
  $lines += "| Document Category | Required Evidence | Applies To |"
  $lines += "| --- | --- | --- |"
  $lines += "| Customer identity or authority evidence | Valid document or approved record confirming the customer, signatory, owner, or authorized party | All applicable customer types |"
  $lines += "| Product or transaction evidence | Approved form, instruction, application, facility record, or transaction support matching the requested product | Applicable products in Document Control |"
  $lines += "| Risk and approval evidence | Risk classification, approval note, exception decision, or enhanced review record where required | Medium, High, and Critical risk cases |"
  $lines += "| Record retention evidence | Scanned document, workflow note, checklist, and approval trail retained in the customer or case record | All completed and rejected cases |"
  $lines += ""
  $lines += "## Validation Rules"
  $lines += ""
  $lines += "| Rule | Validation Requirement | Decision |"
  $lines += "| --- | --- | --- |"
  $lines += "| Completeness | Mandatory fields, signatures, dates, customer identifiers, and product references are present | Accept only when complete or approved exception exists |"
  $lines += "| Legibility | Documents are readable and not obscured, altered, or incomplete | Reject unclear evidence and request replacement |"
  $lines += "| Consistency | Names, customer type, product, authority, and risk details align with the customer record | Escalate material mismatch |"
  $lines += "| Currency | Date-sensitive documents are current for the relevant activity | Reject expired evidence unless exception matrix permits handling |"
  $lines += "| Approval Linkage | Required approvals are recorded before completion | Suspend workflow until approval is available |"
  $lines += ""
  $lines += "## Acceptance Criteria"
  $lines += ""
  $lines += "| Criterion | Acceptance Standard | Approver Where Required |"
  $lines += "| --- | --- | --- |"
  $lines += "| Complete evidence | Every mandatory document category is present and linked to the customer or case record | Operations Officer |"
  $lines += "| Consistent evidence | Evidence aligns with customer type, approved product, request purpose, and risk classification | Operations Manager |"
  $lines += "| Exception evidence | Exception has documented scenario, risk, approval, SLA impact, and reference to the related EXM | Operations Manager |"
  $lines += "| High risk evidence | Enhanced review is completed and retained | Senior Compliance Officer |"
  $lines += "| Critical risk evidence | Executive decision is recorded before completion | Chief Compliance Officer |"
  $lines += ""
  $lines += "## Rejection Criteria"
  $lines += ""
  $lines += "| Rejection Condition | Required Action | Escalation |"
  $lines += "| --- | --- | --- |"
  $lines += "| Evidence is missing or not linked to the correct customer record | Request corrected evidence and hold completion | Operations Manager |"
  $lines += "| Evidence is expired, illegible, or materially inconsistent | Reject evidence and record reason | Operations Manager |"
  $lines += "| Authority, ownership, or eligibility cannot be verified | Suspend workflow and request enhanced review | Senior Compliance Officer |"
  $lines += "| AML, sanctions, credit, payment, or trade finance concern is identified | Do not proceed until required review is complete | Chief Compliance Officer for Critical risk |"
  $lines += ""
  $lines += "## Common Errors"
  $lines += ""
  $lines += "| Error | Operational Impact | Prevention Control |"
  $lines += "| --- | --- | --- |"
  $lines += "| Document attached to the wrong customer record | Incorrect decision evidence and audit failure | Confirm customer identifier before acceptance |"
  $lines += "| Missing approval note for exception | Incomplete governance trail | Use related EXM before closure |"
  $lines += "| Product name inconsistent with approved catalogue | Metadata and workflow inconsistency | Select only approved products from ACB-KB-BIBLE-001 |"
  $lines += "| Risk level not recorded | Escalation and review cannot be determined | Record Low, Medium, High, or Critical before decision |"
  $lines += ""
  $lines += "## References"
  $lines += ""
  $lines += Get-ReferenceTable $Record $RecordById "KOD evidence reference"
  return $lines
}

function Get-ExmDocument {
  param($Record, $DomainMeta, $RecordById)
  $sla = Get-PrimarySla $Record.Domain
  $lines = @()
  $lines += "# $($Record.Title)"
  $lines += ""
  $lines += Get-MetadataLines $Record $DomainMeta
  $lines += Get-GovernanceLines $Record
  $lines += ""
  $lines += "## Scenario"
  $lines += ""
  $lines += "| Scenario | Description | Initial Handler |"
  $lines += "| --- | --- | --- |"
  $lines += "| Standard discrepancy | Customer, product, or evidence information requires clarification but does not alter risk outcome | Operations Officer |"
  $lines += "| Evidence gap | Mandatory document or approval evidence is missing, expired, unclear, or not linked to the correct record | Operations Officer |"
  $lines += "| Material mismatch | Evidence conflicts with identity, authority, ownership, eligibility, transaction purpose, or facility details | Operations Manager |"
  $lines += "| High risk concern | Enhanced review is required because the case meets High risk conditions | Senior Compliance Officer |"
  $lines += "| Critical risk concern | Executive approval is required before completion or activation | Chief Compliance Officer |"
  $lines += ""
  $lines += "## Risk"
  $lines += ""
  $lines += "| Scenario | Risk Level | Risk Rationale |"
  $lines += "| --- | --- | --- |"
  $lines += "| Standard discrepancy | Medium | Enhanced monitoring is required until the discrepancy is corrected and recorded. |"
  $lines += "| Evidence gap | High | Enhanced due diligence is required because the control cannot be completed. |"
  $lines += "| Material mismatch | High | Customer, authority, product, transaction, or facility integrity may be affected. |"
  $lines += "| High risk concern | High | Senior compliance review is required before completion. |"
  $lines += "| Critical risk concern | Critical | Executive approval is required before any final action. |"
  $lines += ""
  $lines += "## Decision"
  $lines += ""
  $lines += "| Scenario | Decision | Completion Condition |"
  $lines += "| --- | --- | --- |"
  $lines += "| Standard discrepancy | Correct and proceed after supervisory review | Correction note and Operations Manager approval are recorded. |"
  $lines += "| Evidence gap | Hold completion until evidence is obtained or approved exception is recorded | Evidence request, follow-up date, and decision rationale are retained. |"
  $lines += "| Material mismatch | Suspend and escalate for enhanced review | Senior Compliance Officer decision is recorded. |"
  $lines += "| High risk concern | Complete enhanced review before operational closure | Enhanced review outcome is linked to the case. |"
  $lines += "| Critical risk concern | Do not proceed without executive approval | Chief Compliance Officer decision is retained. |"
  $lines += ""
  $lines += "## Approval Required"
  $lines += ""
  $lines += "| Scenario | Minimum Approval | Approval Evidence |"
  $lines += "| --- | --- | --- |"
  $lines += "| Standard discrepancy | Operations Manager | Supervisory decision note |"
  $lines += "| Evidence gap | Operations Manager | Exception approval or evidence remediation note |"
  $lines += "| Material mismatch | Senior Compliance Officer | Enhanced review decision |"
  $lines += "| High risk concern | Senior Compliance Officer | High risk approval note |"
  $lines += "| Critical risk concern | Chief Compliance Officer | Executive approval decision |"
  $lines += ""
  $lines += "## SLA"
  $lines += ""
  $lines += "| Scenario | SLA | SLA Action |"
  $lines += "| --- | --- | --- |"
  $lines += "| Standard discrepancy | Document Verification - 4 Hours | Resolve or escalate within the verification window. |"
  $lines += "| Evidence gap | Document Verification - 4 Hours | Record blocker and customer communication before SLA breach. |"
  $lines += "| Material mismatch | High Risk Review - 5 Business Days | Complete enhanced review or escalate before SLA expiry. |"
  $lines += "| High risk concern | High Risk Review - 5 Business Days | Complete senior compliance review. |"
  $lines += "| Domain-specific review | $sla | Apply the domain SLA where it is more specific to the case. |"
  $lines += ""
  $lines += "## Escalation"
  $lines += ""
  $lines += "| Level | Trigger | Action |"
  $lines += "| --- | --- | --- |"
  $lines += "| Operations Officer | Exception identified | Record scenario and route to Operations Manager |"
  $lines += "| Operations Manager | Exception cannot be resolved under standard handling | Approve remediation or escalate |"
  $lines += "| Branch Manager | Customer-facing impact or service activation issue exists | Confirm operational hold and customer communication |"
  $lines += "| Regional Manager | Repeated exception or regional inconsistency exists | Review consistency and escalate material issue |"
  $lines += "| Department Head | Systemic control issue exists | Determine corrective action |"
  $lines += "| Compliance Head | Material compliance concern exists | Confirm compliance position |"
  $lines += "| Chief Compliance Officer | Critical approval is required | Record final executive decision |"
  $lines += ""
  $lines += "## Reference"
  $lines += ""
  $lines += Get-ReferenceTable $Record $RecordById "Exception matrix reference"
  $lines += ""
  $lines += Get-VersionHistoryLines $Record
  return $lines
}

function Get-FaqDocument {
  param($Record, $DomainMeta, $RecordById)
  $activity = Get-DomainActivity $Record.Domain
  $lines = @()
  $lines += "# $($Record.Title)"
  $lines += ""
  $lines += Get-MetadataLines $Record $DomainMeta
  $lines += Get-GovernanceLines $Record
  $lines += ""
  $lines += "## Case ID"
  $lines += ""
  $lines += "| Case Field | Value |"
  $lines += "| --- | --- |"
  $lines += "| Case ID | $($Record.DocumentID) |"
  $lines += "| Case Title | $($Record.Title) |"
  $lines += "| Domain | $($Record.Domain) |"
  $lines += "| Owning Department | $($DomainMeta.Department) |"
  $lines += "| Case Status | Approved for Operations Knowledge Assistant use |"
  $lines += ""
  $lines += "## Business Context"
  $lines += ""
  $lines += "This case repository record provides approved guidance for an operations question involving $activity. It is designed for controlled retrieval by the internal Operations Knowledge Assistant and must be read together with the linked Policy, SOP, KOD, and Exception Matrix records."
  $lines += ""
  $lines += "## Customer Scenario"
  $lines += ""
  $lines += "A customer or internal user raises a question linked to $($Record.Title.ToLowerInvariant()). The Operations Officer must determine whether the case can proceed under standard handling, requires remediation, or must be escalated because the evidence, approval, risk level, or service instruction is incomplete or inconsistent."
  $lines += ""
  $lines += "| Scenario Attribute | Controlled Value |"
  $lines += "| --- | --- |"
  $lines += "| Risk Levels Considered | Low; Medium; High; Critical |"
  $lines += "| First Handler | Operations Officer |"
  $lines += "| Supervisory Handler | Operations Manager |"
  $lines += "| Compliance Escalation | Compliance Officer or Senior Compliance Officer |"
  $lines += "| Final Escalation | Chief Compliance Officer for Critical risk |"
  $lines += ""
  $lines += "## Question"
  $lines += ""
  $lines += "How should ACB handle the customer or operational question described by $($Record.Title) while preserving the approved document structure, product catalogue, customer type rules, approval hierarchy, risk classification, and related document controls?"
  $lines += ""
  $lines += "## Resolution"
  $lines += ""
  $lines += "| Resolution Step | Action | Responsible Role |"
  $lines += "| --- | --- | --- |"
  $lines += "| 1 | Confirm the customer type, approved product, risk level, and active workflow record. | Operations Officer |"
  $lines += "| 2 | Review the linked Policy and SOP to confirm the mandatory control requirement. | Operations Officer |"
  $lines += "| 3 | Compare the evidence or question against the linked KOD and Exception Matrix. | Operations Manager |"
  $lines += "| 4 | Request remediation where evidence is missing, unclear, expired, or inconsistent. | Relationship Officer |"
  $lines += "| 5 | Escalate High risk or Critical risk concerns using the approved hierarchy. | Operations Manager |"
  $lines += "| 6 | Record the final decision, rationale, supporting documents, and customer communication. | Operations Officer |"
  $lines += ""
  $lines += "## Reasoning"
  $lines += ""
  $lines += "| Factor | Reasoning | Decision Impact |"
  $lines += "| --- | --- | --- |"
  $lines += "| Policy alignment | The linked policy defines the governing control requirement and approval standard. | The case cannot be closed contrary to the policy. |"
  $lines += "| SOP alignment | The linked SOP defines the required operating steps and escalation points. | The workflow must follow the SOP sequence. |"
  $lines += "| Evidence standard | The linked KOD defines acceptable evidence and rejection criteria. | Missing or inconsistent evidence must be remediated or escalated. |"
  $lines += "| Exception handling | The linked Exception Matrix defines permitted decisions, approvals, and SLA handling. | Exceptions require documented approval and rationale. |"
  $lines += "| Risk level | High and Critical risk cases require enhanced or executive approval. | Completion is held until required approval is recorded. |"
  $lines += ""
  $lines += "## Supporting Documents"
  $lines += ""
  $lines += Get-ReferenceTable $Record $RecordById "Case support reference"
  $lines += ""
  $lines += "## Lessons Learned"
  $lines += ""
  $lines += "| Lesson | Control Reinforcement |"
  $lines += "| --- | --- |"
  $lines += "| Always verify the document register before citing a related document. | Prevents unsupported or duplicate document references. |"
  $lines += "| Use only approved customer types, products, roles, departments, and risk levels. | Maintains repository-wide consistency. |"
  $lines += "| Record decision rationale with the customer or case record. | Supports audit readiness and future case retrieval. |"
  $lines += "| Escalate unresolved High or Critical risk concerns through the approved hierarchy. | Ensures governance and executive approval requirements are met. |"
  $lines += ""
  $lines += Get-VersionHistoryLines $Record
  return $lines
}

function Get-DocumentContent {
  param($Record, $DomainMeta, $RecordById)
  switch ($Record.TypeCode) {
    "POL" { return Get-PolicyDocument $Record $DomainMeta $RecordById }
    "SOP" { return Get-SopDocument $Record $DomainMeta $RecordById }
    "KOD" { return Get-KodDocument $Record $DomainMeta $RecordById }
    "EXM" { return Get-ExmDocument $Record $DomainMeta $RecordById }
    "FAQ" { return Get-FaqDocument $Record $DomainMeta $RecordById }
  }
}

function Test-Document {
  param($Record, [string]$Path, $RecordById)
  $issues = @()
  if (-not (Test-Path -LiteralPath $Path)) {
    return [pscustomobject]@{ Passed = $false; Issues = @("File not found") }
  }
  $content = Get-Content -LiteralPath $Path -Raw
  foreach ($field in $RequiredMetadata) {
    if ($content -notmatch "\| $([regex]::Escape($field)) \|") {
      $issues += "Missing metadata field: $field"
    }
  }
  foreach ($section in $RequiredSectionsByType[$Record.TypeCode]) {
    if ($content -notmatch "(?m)^## $([regex]::Escape($section))\s*$") {
      $issues += "Missing section: $section"
    }
  }
  if ($content -match "Lorem Ipsum|TODO|TBD|placeholder") {
    $issues += "Placeholder text detected"
  }
  if ($content -notmatch [regex]::Escape($Record.DocumentID)) {
    $issues += "Document ID not present in content"
  }
  foreach ($approvalRole in $ApprovalHierarchy) {
    if ($content -notmatch [regex]::Escape($approvalRole)) {
      $issues += "Approval hierarchy role not present: $approvalRole"
    }
  }
  foreach ($related in $Record.RelatedDocuments) {
    if (-not $RecordById.ContainsKey($related)) {
      $issues += "Related document not in register: $related"
    }
    if ($content -notmatch [regex]::Escape($related)) {
      $issues += "Related document not cited in content: $related"
    }
  }
  if ($Record.RelatedDocuments.Count -lt 2) {
    $issues += "Fewer than two related documents"
  }
  if ($Record.TypeCode -eq "POL") {
    if (@($Record.RelatedDocuments | Where-Object { $_ -like "SOP-*" }).Count -lt 3) { $issues += "Policy has fewer than three SOP references" }
    if (@($Record.RelatedDocuments | Where-Object { $_ -like "KOD-*" }).Count -lt 3) { $issues += "Policy has fewer than three KOD references" }
    if (@($Record.RelatedDocuments | Where-Object { $_ -like "EXM-*" }).Count -lt 3) { $issues += "Policy has fewer than three EXM references" }
  }
  if ($Record.TypeCode -eq "SOP") {
    if (-not ($Record.RelatedDocuments | Where-Object { $_ -like "POL-*" })) { $issues += "SOP missing parent Policy reference" }
    if (-not ($Record.RelatedDocuments | Where-Object { $_ -like "KOD-*" })) { $issues += "SOP missing related KOD reference" }
    if (-not ($Record.RelatedDocuments | Where-Object { $_ -like "FAQ-*" })) { $issues += "SOP missing related FAQ reference" }
  }
  if ($Record.TypeCode -eq "KOD") {
    if (-not ($Record.RelatedDocuments | Where-Object { $_ -like "POL-*" })) { $issues += "KOD missing parent Policy reference" }
    if (-not ($Record.RelatedDocuments | Where-Object { $_ -like "SOP-*" })) { $issues += "KOD missing parent SOP reference" }
  }
  if ($Record.TypeCode -eq "FAQ") {
    if (-not ($Record.RelatedDocuments | Where-Object { $_ -like "POL-*" })) { $issues += "FAQ missing Policy reference" }
    if (-not ($Record.RelatedDocuments | Where-Object { $_ -like "SOP-*" })) { $issues += "FAQ missing SOP reference" }
    if (-not ($Record.RelatedDocuments | Where-Object { $_ -like "EXM-*" })) { $issues += "FAQ missing Exception Matrix reference" }
  }
  if ($Record.TypeCode -ne "POL" -and -not $content.Contains("| Version | Date | Author | Description | Approval |")) {
    $issues += "Version history table not present"
  }
  return [pscustomobject]@{ Passed = ($issues.Count -eq 0); Issues = $issues }
}

function Get-AuditSnapshot {
  param($Records, $RecordPaths, $RecordById)
  $issues = @()
  $ids = @($Records | ForEach-Object { $_.DocumentID })
  $dupes = @($ids | Group-Object | Where-Object { $_.Count -gt 1 })
  foreach ($dupe in $dupes) { $issues += "Duplicate ID: $($dupe.Name)" }
  foreach ($record in $Records) {
    if (-not (Test-Path -LiteralPath $RecordPaths[$record.DocumentID])) {
      $issues += "Missing file: $($record.DocumentID)"
    }
    foreach ($related in $record.RelatedDocuments) {
      if (-not $RecordById.ContainsKey($related)) {
        $issues += "Broken register reference: $($record.DocumentID) -> $related"
      }
    }
  }
  return [pscustomobject]@{
    TotalRecords = $Records.Count
    DuplicateIds = $dupes.Count
    IssueCount = $issues.Count
    Issues = $issues
  }
}

function Write-Markdown {
  param([string]$Path, [string[]]$Lines)
  $folder = Split-Path -Parent $Path
  if (-not (Test-Path -LiteralPath $folder)) { New-Item -ItemType Directory -Force -Path $folder | Out-Null }
  Set-Content -LiteralPath $Path -Value $Lines -Encoding utf8
}

Assert-SourceFiles
$domainMetadata = Get-DomainMetadata
$records = @(Get-DocumentRegister)
if ($records.Count -ne 220) { throw "Expected 220 register records but found $($records.Count)" }

$recordById = @{}
foreach ($record in $records) {
  if ($recordById.ContainsKey($record.DocumentID)) { throw "Duplicate register ID: $($record.DocumentID)" }
  $recordById[$record.DocumentID] = $record
  if (-not $domainMetadata.ContainsKey($record.Domain)) { throw "Missing domain metadata for $($record.Domain)" }
}

foreach ($folder in $DocTypeFolders.Values) {
  New-Item -ItemType Directory -Force -Path (Join-Path $DocumentsRoot $folder) | Out-Null
}

$recordPaths = @{}
$statusRows = @()
$created = 0
$existingValidated = 0
$failed = 0
$processedRecords = @()
$batchRows = @()
$batchNumber = 1

foreach ($record in $records) {
  $path = Get-DocumentPath $record
  $recordPaths[$record.DocumentID] = $path
  $action = "Created"
  if (Test-Path -LiteralPath $path) {
    $action = "Existing Validated"
  } else {
    $content = Get-DocumentContent $record $domainMetadata[$record.Domain] $recordById
    Write-Markdown $path $content
    $created++
  }
  $validation = Test-Document $record $path $recordById
  if ($validation.Passed) {
    if ($action -eq "Existing Validated") { $existingValidated++ }
  } else {
    $failed++
  }
  $statusRows += [pscustomobject]@{
    DocumentID = $record.DocumentID
    DocumentType = $record.DocumentType
    Domain = $record.Domain
    Title = $record.Title
    Path = $path.Replace($Root + "\", "")
    Status = $action
    Validation = $(if ($validation.Passed) { "Passed" } else { "Failed" })
    Issues = $(if ($validation.Passed) { "None" } else { $validation.Issues -join "; " })
  }
  $processedRecords += $record
  if (($processedRecords.Count % 20) -eq 0) {
    $snapshot = Get-AuditSnapshot $processedRecords $recordPaths $recordById
    $batchRows += [pscustomobject]@{
      Batch = "{0:D2}" -f $batchNumber
      ProcessedThrough = $record.DocumentID
      DocumentsProcessed = $processedRecords.Count
      DuplicateIds = $snapshot.DuplicateIds
      BrokenReferences = @($snapshot.Issues | Where-Object { $_ -like "Broken register reference*" }).Count
      MissingFiles = @($snapshot.Issues | Where-Object { $_ -like "Missing file*" }).Count
      CriticalIssues = $snapshot.IssueCount
      Result = $(if ($snapshot.IssueCount -eq 0) { "Passed" } else { "Failed" })
    }
    $batchNumber++
  }
}

if (($processedRecords.Count % 20) -ne 0) {
  $snapshot = Get-AuditSnapshot $processedRecords $recordPaths $recordById
  $batchRows += [pscustomobject]@{
    Batch = "{0:D2}" -f $batchNumber
    ProcessedThrough = $processedRecords[-1].DocumentID
    DocumentsProcessed = $processedRecords.Count
    DuplicateIds = $snapshot.DuplicateIds
    BrokenReferences = @($snapshot.Issues | Where-Object { $_ -like "Broken register reference*" }).Count
    MissingFiles = @($snapshot.Issues | Where-Object { $_ -like "Missing file*" }).Count
    CriticalIssues = $snapshot.IssueCount
    Result = $(if ($snapshot.IssueCount -eq 0) { "Passed" } else { "Failed" })
  }
}

$finalValidationRows = @()
foreach ($record in $records) {
  $validation = Test-Document $record $recordPaths[$record.DocumentID] $recordById
  $finalValidationRows += [pscustomobject]@{
    DocumentID = $record.DocumentID
    TypeCode = $record.TypeCode
    Domain = $record.Domain
    Passed = $validation.Passed
    Issues = $validation.Issues
  }
}

$finalAudit = Get-AuditSnapshot $records $recordPaths $recordById
$validationFailures = @($finalValidationRows | Where-Object { -not $_.Passed })
$allRelatedReferences = @($records | ForEach-Object { $_.RelatedDocuments })
$referenceCount = $allRelatedReferences.Count
$uniqueReferenceCount = @($allRelatedReferences | Sort-Object -Unique).Count
$presentDocumentCount = @($records | Where-Object { Test-Path -LiteralPath $recordPaths[$_.DocumentID] }).Count
$incomingReferenceGaps = @($records | Where-Object { $allRelatedReferences -notcontains $_.DocumentID })

$manifest = @()
$manifest += "# APEX Commercial Bank Repository Manifest"
$manifest += ""
$manifest += "| Field | Value |"
$manifest += "| --- | --- |"
$manifest += "| Manifest ID | ACB-REP-MAN-001 |"
$manifest += "| Repository Version | 1.0 |"
$manifest += "| Source Bible | ACB_Knowledge_Base_Bible_v1.0.md |"
$manifest += "| Source Register | ACB_Repository_Index_v1.0.md |"
$manifest += "| Total Controlled Documents | $($records.Count) |"
$manifest += "| Total Document Files Present | $presentDocumentCount |"
$manifest += "| Documents Created This Run | $created |"
$manifest += "| Existing Documents Validated | $existingValidated |"
$manifest += "| Validation Failures | $($validationFailures.Count) |"
$manifest += "| Status | $(if ($validationFailures.Count -eq 0 -and $finalAudit.IssueCount -eq 0) { "Complete" } else { "Review Required" }) |"
$manifest += "| Effective Date | 2026-07-01 |"
$manifest += "| Review Date | 2027-07-01 |"
$manifest += "| Owner | Department Head |"
$manifest += "| Approver | Chief Compliance Officer |"
$manifest += ""
$manifest += "## Repository Folders"
$manifest += ""
$manifest += "| Document Type | Folder | Count |"
$manifest += "| --- | --- | ---: |"
foreach ($typeCode in @("POL", "SOP", "KOD", "EXM", "FAQ")) {
  $count = @($records | Where-Object { $_.TypeCode -eq $typeCode }).Count
  $manifest += "| $typeCode | documents/$($DocTypeFolders[$typeCode]) | $count |"
}
$manifest += ""
$manifest += "## Version History"
$manifest += ""
$manifest += "| Version | Date | Author | Description | Approval |"
$manifest += "| --- | --- | --- | --- | --- |"
$manifest += "| 1.0 | 2026-07-01 | Department Head | Repository manifest generated from the approved ACB document register. | Chief Compliance Officer |"
Write-Markdown $ManifestPath $manifest

$status = @()
$status += "# ACB Document Register Status"
$status += ""
$status += "| Document ID | Document Type | Domain | Title | Path | Status | Validation | Issues |"
$status += "| --- | --- | --- | --- | --- | --- | --- | --- |"
foreach ($row in $statusRows) {
  $status += "| $($row.DocumentID) | $($row.DocumentType) | $($row.Domain) | $($row.Title) | $($row.Path) | $($row.Status) | $($row.Validation) | $($row.Issues) |"
}
$status += ""
$status += "## Version History"
$status += ""
$status += "| Version | Date | Author | Description | Approval |"
$status += "| --- | --- | --- | --- | --- |"
$status += "| 1.0 | 2026-07-01 | Department Head | Document register status generated after repository build and validation. | Chief Compliance Officer |"
Write-Markdown $StatusPath $status

$batchAudit = @()
$batchAudit += "# ACB Batch Audit Log"
$batchAudit += ""
$batchAudit += "| Batch | Processed Through | Documents Processed | Duplicate IDs | Broken References | Missing Files | Critical Issues | Result |"
$batchAudit += "| --- | --- | ---: | ---: | ---: | ---: | ---: | --- |"
foreach ($row in $batchRows) {
  $batchAudit += "| $($row.Batch) | $($row.ProcessedThrough) | $($row.DocumentsProcessed) | $($row.DuplicateIds) | $($row.BrokenReferences) | $($row.MissingFiles) | $($row.CriticalIssues) | $($row.Result) |"
}
$batchAudit += ""
$batchAudit += "## Version History"
$batchAudit += ""
$batchAudit += "| Version | Date | Author | Description | Approval |"
$batchAudit += "| --- | --- | --- | --- | --- |"
$batchAudit += "| 1.0 | 2026-07-01 | Department Head | Batch audit log recorded after every 20 processed documents during repository build. | Chief Compliance Officer |"
Write-Markdown $BatchAuditPath $batchAudit

$typeCounts = $records | Group-Object TypeCode | Sort-Object Name
$domainCounts = $records | Group-Object Domain | Sort-Object Name
$audit = @()
$audit += "# ACB Final Repository Audit Report"
$audit += ""
$audit += "## Executive Summary"
$audit += ""
$audit += "| Audit Field | Result |"
$audit += "| --- | --- |"
$audit += "| Repository Version | 1.0 |"
$audit += "| Total Registered Documents | $($records.Count) |"
$audit += "| Total Document Files Present | $presentDocumentCount |"
$audit += "| Total Documents Generated Or Validated | $($statusRows.Count) |"
$audit += "| Documents Created This Run | $created |"
$audit += "| Existing Documents Validated | $existingValidated |"
$audit += "| Validation Failures | $($validationFailures.Count) |"
$audit += "| Duplicate Document IDs | $($finalAudit.DuplicateIds) |"
$audit += "| Broken Register References | $(@($finalAudit.Issues | Where-Object { $_ -like "Broken register reference*" }).Count) |"
$audit += "| Missing Files | $(@($finalAudit.Issues | Where-Object { $_ -like "Missing file*" }).Count) |"
$audit += "| Final Audit Status | $(if ($validationFailures.Count -eq 0 -and $finalAudit.IssueCount -eq 0) { "Passed" } else { "Failed" }) |"
$audit += ""
$audit += "## Document Counts by Type"
$audit += ""
$audit += "| Type | Count |"
$audit += "| --- | ---: |"
foreach ($group in $typeCounts) { $audit += "| $($group.Name) | $($group.Count) |" }
$audit += ""
$audit += "## Document Counts by Domain"
$audit += ""
$audit += "| Domain | Count |"
$audit += "| --- | ---: |"
foreach ($group in $domainCounts) { $audit += "| $($group.Name) | $($group.Count) |" }
$audit += ""
$audit += "## Cross-Reference Statistics"
$audit += ""
$audit += "| Statistic | Count |"
$audit += "| --- | ---: |"
$audit += "| Total Related Document Links | $referenceCount |"
$audit += "| Unique Referenced Document IDs | $uniqueReferenceCount |"
$audit += "| Registered Document IDs With Required Outgoing Links | $(@($records | Where-Object { $_.RelatedDocuments.Count -ge 2 }).Count) |"
$audit += "| Registered Document IDs Referenced By Another Record | $uniqueReferenceCount |"
$audit += "| Terminal Case Records Without Incoming Index Link | $($incomingReferenceGaps.Count) |"
$audit += "| Broken Related Document Links | $(@($finalAudit.Issues | Where-Object { $_ -like "Broken register reference*" }).Count) |"
$audit += ""
$audit += "## Validation Summary"
$audit += ""
$audit += "| Validation Control | Result |"
$audit += "| --- | --- |"
$audit += "| All registered document files exist | $(if (@($finalAudit.Issues | Where-Object { $_ -like "Missing file*" }).Count -eq 0) { "Passed" } else { "Failed" }) |"
$audit += "| Duplicate document ID check | $(if ($finalAudit.DuplicateIds -eq 0) { "Passed" } else { "Failed" }) |"
$audit += "| Required metadata populated | $(if ($validationFailures.Count -eq 0) { "Passed" } else { "Failed" }) |"
$audit += "| Required template sections present | $(if ($validationFailures.Count -eq 0) { "Passed" } else { "Failed" }) |"
$audit += "| Related documents resolve to register | $(if (@($finalAudit.Issues | Where-Object { $_ -like "Broken register reference*" }).Count -eq 0) { "Passed" } else { "Failed" }) |"
$audit += "| Approval hierarchy present | $(if ($validationFailures.Count -eq 0) { "Passed" } else { "Failed" }) |"
$audit += "| Placeholder text scan | $(if ($validationFailures.Count -eq 0) { "Passed" } else { "Failed" }) |"
$audit += ""
$audit += "## Unresolved Issues"
$audit += ""
if ($validationFailures.Count -eq 0 -and $finalAudit.IssueCount -eq 0) {
  $audit += "No unresolved critical issues were identified."
} else {
  $audit += "| Document ID | Issue |"
  $audit += "| --- | --- |"
  foreach ($failure in $validationFailures) {
    $audit += "| $($failure.DocumentID) | $($failure.Issues -join '; ') |"
  }
  foreach ($issue in $finalAudit.Issues) {
    $audit += "| Repository | $issue |"
  }
}
$audit += ""
$audit += "## Topology Notes"
$audit += ""
if ($incomingReferenceGaps.Count -eq 0) {
  $audit += "Every registered document is referenced by at least one other registered document."
} else {
  $audit += "The following registered documents are terminal Case Repository records in the approved index topology. Each file exists, each record has the required outgoing related-document links, and no broken references were identified."
  $audit += ""
  $audit += "| Document ID | Document Type | Domain |"
  $audit += "| --- | --- | --- |"
  foreach ($gap in $incomingReferenceGaps) {
    $audit += "| $($gap.DocumentID) | $($gap.DocumentType) | $($gap.Domain) |"
  }
}
$audit += ""
$audit += "## Version History"
$audit += ""
$audit += "| Version | Date | Author | Description | Approval |"
$audit += "| --- | --- | --- | --- | --- |"
$audit += "| 1.0 | 2026-07-01 | Department Head | Final repository audit report generated after creation and validation of all registered ACB documents. | Chief Compliance Officer |"
Write-Markdown $FinalAuditPath $audit

if ($validationFailures.Count -gt 0 -or $finalAudit.IssueCount -gt 0) {
  Write-Output "Repository build completed with validation issues."
  Write-Output "ValidationFailures=$($validationFailures.Count)"
  Write-Output "AuditIssues=$($finalAudit.IssueCount)"
  exit 1
}

Write-Output "Repository build completed successfully."
Write-Output "TotalDocuments=$($records.Count)"
Write-Output "Created=$created"
Write-Output "ExistingValidated=$existingValidated"
Write-Output "ValidationFailures=0"
Write-Output "AuditIssues=0"
