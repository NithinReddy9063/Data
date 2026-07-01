---
document_id: "EXM-Payments-002"
title: "SWIFT Payment Exception Matrix"
document_type: "Exception Matrix"
department: "PAY - Payments"
domain: "Payments"
business_unit: "Corporate Banking"
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
  - "SWIFT"
applicable_customer_types:
  - "Individual"
  - "NRI"
  - "Resident"
  - "Sole Proprietor"
  - "Partnership"
  - "Private Limited"
  - "Public Limited"
  - "Financial Institution"
keywords:
  - "payments"
  - "NEFT"
  - "RTGS"
  - "IMPS"
  - "UPI"
  - "SWIFT"
  - "ACH"
  - "swift payment exception matrix"
  - "EXM-Payments-002"
  - "Payment"
  - "Exception"
related_documents:
  - document_id: "POL-Payments-002"
    path: "documents/policies/POL-Payments-002_RTGS_Processing_Policy.md"
  - document_id: "SOP-Payments-002"
    path: "documents/sops/SOP-Payments-002_RTGS_Payment_Processing_SOP.md"
  - document_id: "KOD-Payments-002"
    path: "documents/kod/KOD-Payments-002_SWIFT_Payment_Instruction_KOD.md"
  - document_id: "FAQ-Payments-002"
    path: "documents/case_repository/FAQ-Payments-002_RTGS_Cutoff_Handling_Query.md"
supersedes: null
synthetic: true
---
# SWIFT Payment Exception Matrix

## 1 Scenario

| Scenario | Description | Initial Handler |
| --- | --- | --- |
| Standard discrepancy | Customer, product, or evidence information requires clarification but does not alter risk outcome | Operations Officer |
| Evidence gap | Mandatory document or approval evidence is missing, expired, unclear, or not linked to the correct record | Operations Officer |
| Material mismatch | Evidence conflicts with identity, authority, ownership, eligibility, transaction purpose, or facility details | Operations Manager |
| High risk concern | Enhanced review is required because the case meets High risk conditions | Senior Compliance Officer |
| Critical risk concern | Executive approval is required before completion or activation | Chief Compliance Officer |

## 2 Risk

| Scenario | Risk Level | Risk Rationale |
| --- | --- | --- |
| Standard discrepancy | Medium | Enhanced monitoring is required until the discrepancy is corrected and recorded. |
| Evidence gap | High | Enhanced due diligence is required because the control cannot be completed. |
| Material mismatch | High | Customer, authority, product, transaction, or facility integrity may be affected. |
| High risk concern | High | Senior compliance review is required before completion. |
| Critical risk concern | Critical | Executive approval is required before any final action. |

## 3 Decision

| Scenario | Decision | Completion Condition |
| --- | --- | --- |
| Standard discrepancy | Correct and proceed after supervisory review | Correction note and Operations Manager approval are recorded. |
| Evidence gap | Hold completion until evidence is obtained or approved exception is recorded | Evidence request, follow-up date, and decision rationale are retained. |
| Material mismatch | Suspend and escalate for enhanced review | Senior Compliance Officer decision is recorded. |
| High risk concern | Complete enhanced review before operational closure | Enhanced review outcome is linked to the case. |
| Critical risk concern | Do not proceed without executive approval | Chief Compliance Officer decision is retained. |

## 4 Approval Required

| Scenario | Minimum Approval | Approval Evidence |
| --- | --- | --- |
| Standard discrepancy | Operations Manager | Supervisory decision note |
| Evidence gap | Operations Manager | Exception approval or evidence remediation note |
| Material mismatch | Senior Compliance Officer | Enhanced review decision |
| High risk concern | Senior Compliance Officer | High risk approval note |
| Critical risk concern | Chief Compliance Officer | Executive approval decision |

## 5 SLA

| Scenario | SLA | SLA Action |
| --- | --- | --- |
| Standard discrepancy | Document Verification - 4 Hours | Resolve or escalate within the verification window. |
| Evidence gap | Document Verification - 4 Hours | Record blocker and customer communication before SLA breach. |
| Material mismatch | High Risk Review - 5 Business Days | Complete enhanced review or escalate before SLA expiry. |
| High risk concern | High Risk Review - 5 Business Days | Complete senior compliance review. |
| Domain-specific review | Document Verification - 4 Hours | Apply the domain SLA where it is more specific to the case. |

## 6 Escalation

| Level | Trigger | Action |
| --- | --- | --- |
| Operations Officer | Exception identified | Record scenario and route to Operations Manager |
| Operations Manager | Exception cannot be resolved under standard handling | Approve remediation or escalate |
| Branch Manager | Customer-facing impact or service activation issue exists | Confirm operational hold and customer communication |
| Regional Manager | Repeated exception or regional inconsistency exists | Review consistency and escalate material issue |
| Department Head | Systemic control issue exists | Determine corrective action |
| Compliance Head | Material compliance concern exists | Confirm compliance position |
| Chief Compliance Officer | Critical approval is required | Record final executive decision |

## 7 Reference

| Document ID | Title | Relationship |
| --- | --- | --- |
| [POL-Payments-002](../policies/POL-Payments-002_RTGS_Processing_Policy.md) | RTGS Processing Policy | Exception matrix reference |
| [SOP-Payments-002](../sops/SOP-Payments-002_RTGS_Payment_Processing_SOP.md) | RTGS Payment Processing SOP | Exception matrix reference |
| [KOD-Payments-002](../kod/KOD-Payments-002_SWIFT_Payment_Instruction_KOD.md) | SWIFT Payment Instruction KOD | Exception matrix reference |
| [FAQ-Payments-002](../case_repository/FAQ-Payments-002_RTGS_Cutoff_Handling_Query.md) | RTGS Cutoff Handling Query | Exception matrix reference |

## 8 Revision History

| Version | Date | Author | Summary of Changes | Approved By |
| --- | --- | --- | --- | --- |
| 1.0 | 2026-07-01 | Department Head | Initial approved deployment version for EXM-Payments-002 SWIFT Payment Exception Matrix. | Chief Compliance Officer |

## 9 Governance

Prepared By: Department Head

Reviewed By: Compliance Head

Approved By: Chief Compliance Officer

Owner: Department Head

Next Review Date: 2027-07-01

Document Status: Approved
