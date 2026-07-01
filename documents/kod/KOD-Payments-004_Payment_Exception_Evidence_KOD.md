---
document_id: "KOD-Payments-004"
title: "Payment Exception Evidence KOD"
document_type: "Knowledge of Documents"
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
priority: "Medium"
risk_level: "Medium"
applicable_products:
  - "NEFT"
  - "RTGS"
  - "IMPS"
  - "UPI"
  - "SWIFT"
  - "ACH"
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
  - "payment exception evidence kod"
  - "KOD-Payments-004"
  - "Payment"
  - "Exception"
  - "Evidence"
related_documents:
  - document_id: "POL-Payments-004"
    path: "documents/policies/POL-Payments-004_SWIFT_Payment_Control_Policy.md"
  - document_id: "SOP-Payments-004"
    path: "documents/sops/SOP-Payments-004_SWIFT_Payment_Processing_SOP.md"
  - document_id: "EXM-Payments-004"
    path: "documents/exception_matrices/EXM-Payments-004_Payment_Reversal_Exception_Matrix.md"
supersedes: null
synthetic: true
---
# Payment Exception Evidence KOD

## 1 Purpose

This Knowledge of Documents record defines the acceptable document evidence, validation rules, acceptance criteria, rejection criteria, and common errors for Payments activity under KOD-Payments-004. It is used by Operations Officer, Operations Manager, Compliance Officer, Senior Compliance Officer, AML Analyst, and Credit Risk Officer roles where the related policy and SOP require documentary evidence.

## 2 Applicable Products

| Product | Applicability |
| --- | --- |
| NEFT | Applicable when the customer request, transaction, facility, or service record requires evidence covered by this KOD. |
| RTGS | Applicable when the customer request, transaction, facility, or service record requires evidence covered by this KOD. |
| IMPS | Applicable when the customer request, transaction, facility, or service record requires evidence covered by this KOD. |
| UPI | Applicable when the customer request, transaction, facility, or service record requires evidence covered by this KOD. |
| SWIFT | Applicable when the customer request, transaction, facility, or service record requires evidence covered by this KOD. |
| ACH | Applicable when the customer request, transaction, facility, or service record requires evidence covered by this KOD. |

## 3 Required Documents

| Document Category | Required Evidence | Applies To |
| --- | --- | --- |
| Customer identity or authority evidence | Valid document or approved record confirming the customer, signatory, owner, or authorized party | All applicable customer types |
| Product or transaction evidence | Approved form, instruction, application, facility record, or transaction support matching the requested product | Applicable products in Document Control |
| Risk and approval evidence | Risk classification, approval note, exception decision, or enhanced review record where required | Medium, High, and Critical risk cases |
| Record retention evidence | Scanned document, workflow note, checklist, and approval trail retained in the customer or case record | All completed and rejected cases |

## 4 Validation Rules

| Rule | Validation Requirement | Decision |
| --- | --- | --- |
| Completeness | Mandatory fields, signatures, dates, customer identifiers, and product references are present | Accept only when complete or approved exception exists |
| Legibility | Documents are readable and not obscured, altered, or incomplete | Reject unclear evidence and request replacement |
| Consistency | Names, customer type, product, authority, and risk details align with the customer record | Escalate material mismatch |
| Currency | Date-sensitive documents are current for the relevant activity | Reject expired evidence unless exception matrix permits handling |
| Approval Linkage | Required approvals are recorded before completion | Suspend workflow until approval is available |

## 5 Acceptance Criteria

| Criterion | Acceptance Standard | Approver Where Required |
| --- | --- | --- |
| Complete evidence | Every mandatory document category is present and linked to the customer or case record | Operations Officer |
| Consistent evidence | Evidence aligns with customer type, approved product, request purpose, and risk classification | Operations Manager |
| Exception evidence | Exception has documented scenario, risk, approval, SLA impact, and reference to the related EXM | Operations Manager |
| High risk evidence | Enhanced review is completed and retained | Senior Compliance Officer |
| Critical risk evidence | Executive decision is recorded before completion | Chief Compliance Officer |

## 6 Rejection Criteria

| Rejection Condition | Required Action | Escalation |
| --- | --- | --- |
| Evidence is missing or not linked to the correct customer record | Request corrected evidence and hold completion | Operations Manager |
| Evidence is expired, illegible, or materially inconsistent | Reject evidence and record reason | Operations Manager |
| Authority, ownership, or eligibility cannot be verified | Suspend workflow and request enhanced review | Senior Compliance Officer |
| AML, sanctions, credit, payment, or trade finance concern is identified | Do not proceed until required review is complete | Chief Compliance Officer for Critical risk |

## 7 Common Errors

| Error | Operational Impact | Prevention Control |
| --- | --- | --- |
| Document attached to the wrong customer record | Incorrect decision evidence and audit failure | Confirm customer identifier before acceptance |
| Missing approval note for exception | Incomplete governance trail | Use related EXM before closure |
| Product name inconsistent with approved catalogue | Metadata and workflow inconsistency | Select only approved products from ACB-KB-BIBLE-001 |
| Risk level not recorded | Escalation and review cannot be determined | Record Low, Medium, High, or Critical before decision |

## 8 References

| Document ID | Title | Relationship |
| --- | --- | --- |
| [POL-Payments-004](../policies/POL-Payments-004_SWIFT_Payment_Control_Policy.md) | SWIFT Payment Control Policy | KOD evidence reference |
| [SOP-Payments-004](../sops/SOP-Payments-004_SWIFT_Payment_Processing_SOP.md) | SWIFT Payment Processing SOP | KOD evidence reference |
| [EXM-Payments-004](../exception_matrices/EXM-Payments-004_Payment_Reversal_Exception_Matrix.md) | Payment Reversal Exception Matrix | KOD evidence reference |

## 9 Revision History

| Version | Date | Author | Summary of Changes | Approved By |
| --- | --- | --- | --- | --- |
| 1.0 | 2026-07-01 | Department Head | Initial approved deployment version for KOD-Payments-004 Payment Exception Evidence KOD. | Chief Compliance Officer |

## 10 Governance

Prepared By: Department Head

Reviewed By: Compliance Head

Approved By: Chief Compliance Officer

Owner: Department Head

Next Review Date: 2027-07-01

Document Status: Approved
