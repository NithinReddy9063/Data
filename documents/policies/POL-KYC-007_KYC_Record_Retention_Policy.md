---
document_id: "POL-KYC-007"
title: "KYC Record Retention Policy"
document_type: "Policy"
department: "CMP - Compliance"
domain: "KYC"
business_unit: "Retail Banking"
owner: "Department Head"
approver: "Chief Compliance Officer"
version: "1.0"
status: "Approved"
classification: "Internal"
effective_date: "2026-07-01"
review_date: "2027-07-01"
priority: "High"
risk_level: "High"
applicable_products:
  - "Savings Account"
  - "Current Account"
  - "Business Current Account"
  - "Home Loan"
  - "Business Loan"
  - "Letter of Credit (LC)"
  - "SWIFT"
applicable_customer_types:
  - "Individual"
  - "NRI"
  - "Sole Proprietor"
  - "Partnership"
  - "Private Limited"
  - "Trust"
  - "Financial Institution"
keywords:
  - "KYC"
  - "customer identification"
  - "due diligence"
  - "beneficial ownership"
  - "verification"
  - "kyc record retention policy"
  - "POL-KYC-007"
  - "Record"
  - "Retention"
related_documents:
  - document_id: "SOP-KYC-007"
    path: "documents/sops/SOP-KYC-007_KYC_Record_Maintenance_SOP.md"
  - document_id: "SOP-KYC-001"
    path: "documents/sops/SOP-KYC-001_Customer_Identity_Verification_SOP.md"
  - document_id: "SOP-KYC-002"
    path: "documents/sops/SOP-KYC-002_Customer_Due_Diligence_Review_SOP.md"
  - document_id: "KOD-KYC-003"
    path: "documents/kod/KOD-KYC-003_Beneficial_Ownership_Documents_KOD.md"
  - document_id: "KOD-KYC-004"
    path: "documents/kod/KOD-KYC-004_KYC_Review_Supporting_Documents_KOD.md"
  - document_id: "KOD-KYC-001"
    path: "documents/kod/KOD-KYC-001_Individual_Identity_and_Address_Documents_KOD.md"
  - document_id: "EXM-KYC-003"
    path: "documents/exception_matrices/EXM-KYC-003_Beneficial_Ownership_Exception_Matrix.md"
  - document_id: "EXM-KYC-004"
    path: "documents/exception_matrices/EXM-KYC-004_Periodic_Review_Exception_Matrix.md"
  - document_id: "EXM-KYC-001"
    path: "documents/exception_matrices/EXM-KYC-001_Identity_Document_Exception_Matrix.md"
supersedes: null
synthetic: true
---
# KYC Record Retention Policy

## 1 Purpose

This policy defines the mandatory governance, control, approval, and evidence requirements for customer identification, verification, and due diligence within APEX Commercial Bank. It establishes a consistent enterprise standard for KYC activities so that customer decisions, operational actions, exception handling, and record keeping are performed in a controlled and auditable manner.

The policy supports the Operations Knowledge Assistant by providing approved decision logic, accountable roles, cross-reference points, and deployment-ready guidance for the document record POL-KYC-007.

## 2 Scope

This policy applies to the department CMP - Compliance, the business unit Retail Banking, all applicable products and customer types defined in the Document Control metadata, and all ACB personnel performing or approving KYC activity.

| Scope Area | Requirement |
| --- | --- |
| Customer Coverage | Applies to each applicable customer type recorded in the approved metadata. |
| Product Coverage | Applies only to approved products recorded in the approved metadata. |
| Operational Coverage | Applies from request receipt through validation, approval, exception handling, escalation, and record retention. |
| Control Coverage | Applies to standard, Medium, High, and Critical risk conditions using the approved risk categories. |

## 3 Definitions

| Term | Definition |
| --- | --- |
| ACB | APEX Commercial Bank, the fictional enterprise bank governed by this repository. |
| Customer Record | The controlled ACB record containing customer information, supporting evidence, approval actions, and decision rationale. |
| Control Evidence | The document, checklist, approval note, system record, or case note retained to demonstrate completion of a required control. |
| Exception | A documented departure from the standard rule that is permitted only when approved through the required hierarchy. |
| Risk Level | The approved risk category of Low, Medium, High, or Critical assigned to the customer, case, request, or transaction. |
| Related Document | A registered document listed in the ACB Repository Index and referenced by this policy for operating detail, document evidence, exception handling, or case guidance. |

## 4 Policy Statements

1. ACB must perform customer identification, verification, and due diligence in accordance with this policy and the related documents listed in the Related Documents section.
2. No operational decision may be completed where mandatory evidence is missing, inconsistent, expired, illegible, or not linked to the relevant customer record.
3. Operations Officer review is required before operational completion, approval routing, or customer communication is finalized.
4. Operations Manager review is required when a case contains an exception, unresolved discrepancy, SLA risk, or supervisory approval condition.
5. Compliance Officer or Senior Compliance Officer review is required when compliance interpretation, High risk classification, or enhanced control review is required.
6. Critical risk activity must not proceed without escalation through the approved hierarchy and documented Chief Compliance Officer decision.
7. Relationship Manager and Relationship Officer activity must support customer communication and evidence collection without overriding operations or compliance control decisions.
8. Approval decisions must be supported by a clear decision rationale and retained with the customer record or case record.
9. Exceptions must be mapped to the applicable Exception Matrix and must not be used to bypass AML, KYC, credit, payment, trade finance, or customer approval controls.
10. Records must remain retrievable for audit, quality review, customer inquiry, and control testing.

## 5 Roles

| Role | Responsibility |
| --- | --- |
| Relationship Manager | Supports customer-facing coordination and ensures customer information is routed to operations without changing control outcomes. |
| Relationship Officer | Obtains missing customer information requested by operations and records customer responses. |
| Operations Officer | Performs first-level review, records control evidence, identifies discrepancies, and routes exceptions. |
| Operations Manager | Performs supervisory review, approves operational remediation, monitors SLA adherence, and escalates unresolved issues. |
| Compliance Officer | Reviews standard compliance questions and confirms policy interpretation where required. |
| Senior Compliance Officer | Reviews High risk cases, enhanced review decisions, and material compliance concerns. |
| AML Analyst | Reviews AML-related indicators where screening, monitoring, or suspicious activity concerns are present. |
| Credit Risk Officer | Reviews lending-related evidence and risk concerns where applicable to credit products. |
| Branch Manager | Reviews branch-level escalations and confirms activation or servicing does not proceed while mandatory controls remain open. |
| Regional Manager | Reviews regional escalations and ensures consistent application of policy decisions. |
| Department Head | Owns the document, confirms annual review, and ensures procedures remain aligned to this policy. |

## 6 Decision Rules

| Condition | Risk Level | Decision | Minimum Approval | Evidence Required |
| --- | --- | --- | --- | --- |
| Mandatory evidence is complete, valid, consistent, and linked to the customer record | Low | Proceed under the applicable SOP | Operations Officer | Completed review checklist and accepted evidence record |
| Minor discrepancy exists and does not affect identity, authority, ownership, eligibility, or transaction purpose | Medium | Correct the record and proceed after supervisory review | Operations Manager | Correction note, customer confirmation, and reviewer rationale |
| Evidence is incomplete, expired, illegible, or inconsistent with customer or transaction data | High | Suspend completion until remediation or approved exception is recorded | Senior Compliance Officer | Exception assessment, customer communication, and remediation evidence |
| Concern affects AML, sanctions, ownership opacity, credit risk, payment legitimacy, or trade transaction integrity | Critical | Do not proceed until executive approval is recorded | Chief Compliance Officer | Escalation pack, risk rationale, and final decision |

| SLA Event | Approved SLA | Required Action | Escalation Trigger |
| --- | --- | --- | --- |
| Standard review request received | Document Verification - 4 Hours | Operations Officer records decision or blocker | SLA cannot be met because evidence or approval is incomplete |
| Supervisory review required | Document Verification - 4 Hours | Operations Manager reviews exception or discrepancy | Decision requires Branch Manager or higher review |
| High risk review required | High Risk Review - 5 Business Days | Senior Compliance Officer records enhanced review outcome | Risk classification becomes Critical |

## 7 Exceptions

| Exception Type | Permitted Handling | Approval Required | Control Requirement |
| --- | --- | --- | --- |
| Missing non-critical evidence with documented remediation path | Conditional continuation without final completion | Operations Manager | Evidence request and follow-up date must be recorded. |
| Minor data discrepancy that does not alter customer or transaction risk | Correction and supervisory approval | Operations Manager | Correction rationale and customer confirmation must be retained. |
| High risk evidence gap or unresolved control concern | Suspend completion and escalate | Senior Compliance Officer | Enhanced review and exception reference must be recorded. |
| Critical risk concern | Do not proceed unless executive approval is recorded | Chief Compliance Officer | Escalation pack and final decision must be retained. |

## 8 Escalation

| Escalation Level | Trigger | Required Action |
| --- | --- | --- |
| Operations Officer | First-level review identifies missing evidence, discrepancy, or workflow blocker | Record blocker, request remediation, and route for supervisory review when required |
| Operations Manager | Operational exception, SLA risk, or unresolved evidence issue | Approve remediation, reject exception, or escalate to Branch Manager |
| Branch Manager | Customer impact or branch-level activation concern remains unresolved | Confirm customer-facing position and prevent completion until controls are closed |
| Regional Manager | Repeated issue, regional inconsistency, or significant operational exposure | Review consistency and route material matters to Department Head |
| Department Head | Policy interpretation, systemic control failure, or material operational risk | Determine corrective action and coordinate compliance review |
| Compliance Head | Material compliance issue or High risk matter requiring senior compliance position | Confirm compliance decision and route Critical matters for executive approval |
| Chief Compliance Officer | Critical risk decision or executive approval condition | Approve, reject, or impose documented conditions |

## 9 Controls

| Control | Objective | Performer | Frequency | Evidence |
| --- | --- | --- | --- | --- |
| POL-KYC-007-CTRL-01 | Confirm mandatory evidence is present and linked to the customer or case record | Operations Officer | Per request | Completed checklist and evidence record |
| POL-KYC-007-CTRL-02 | Confirm discrepancies and exceptions are reviewed before completion | Operations Manager | Per exception | Exception decision and reviewer rationale |
| POL-KYC-007-CTRL-03 | Confirm High and Critical risk matters receive required escalation | Senior Compliance Officer | Per escalated case | Enhanced review note and approval trail |
| POL-KYC-007-CTRL-04 | Confirm records are retained and retrievable for audit | Department Head | Quarterly | Sample review results and remediation tracker |

## 10 Related Documents

| Document ID | Title | Relationship |
| --- | --- | --- |
| [SOP-KYC-007](../sops/SOP-KYC-007_KYC_Record_Maintenance_SOP.md) | KYC Record Maintenance SOP | Mandatory policy cross-reference |
| [SOP-KYC-001](../sops/SOP-KYC-001_Customer_Identity_Verification_SOP.md) | Customer Identity Verification SOP | Mandatory policy cross-reference |
| [SOP-KYC-002](../sops/SOP-KYC-002_Customer_Due_Diligence_Review_SOP.md) | Customer Due Diligence Review SOP | Mandatory policy cross-reference |
| [KOD-KYC-003](../kod/KOD-KYC-003_Beneficial_Ownership_Documents_KOD.md) | Beneficial Ownership Documents KOD | Mandatory policy cross-reference |
| [KOD-KYC-004](../kod/KOD-KYC-004_KYC_Review_Supporting_Documents_KOD.md) | KYC Review Supporting Documents KOD | Mandatory policy cross-reference |
| [KOD-KYC-001](../kod/KOD-KYC-001_Individual_Identity_and_Address_Documents_KOD.md) | Individual Identity and Address Documents KOD | Mandatory policy cross-reference |
| [EXM-KYC-003](../exception_matrices/EXM-KYC-003_Beneficial_Ownership_Exception_Matrix.md) | Beneficial Ownership Exception Matrix | Mandatory policy cross-reference |
| [EXM-KYC-004](../exception_matrices/EXM-KYC-004_Periodic_Review_Exception_Matrix.md) | Periodic Review Exception Matrix | Mandatory policy cross-reference |
| [EXM-KYC-001](../exception_matrices/EXM-KYC-001_Identity_Document_Exception_Matrix.md) | Identity Document Exception Matrix | Mandatory policy cross-reference |

## 11 Revision History

| Version | Date | Author | Summary of Changes | Approved By |
| --- | --- | --- | --- | --- |
| 1.0 | 2026-07-01 | Department Head | Initial approved deployment version for POL-KYC-007 KYC Record Retention Policy. | Chief Compliance Officer |

## 12 Governance

Prepared By: Department Head

Reviewed By: Compliance Head

Approved By: Chief Compliance Officer

Owner: Department Head

Next Review Date: 2027-07-01

Document Status: Approved
