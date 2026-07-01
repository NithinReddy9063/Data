---
document_id: "ACB-KB-BIBLE-001"
title: "APEX Commercial Bank Knowledge Base Bible"
document_type: "Repository Canon"
department: "OPS - Banking Operations"
domain: "Repository Governance"
business_unit: "Operations"
owner: "Department Head"
approver: "Chief Compliance Officer"
version: "1.0"
status: "Frozen"
classification: "Internal"
effective_date: "2026-07-01"
review_date: "2027-07-01"
priority: "Critical"
risk_level: "Critical"
applicable_products: []
applicable_customer_types: []
keywords:
  - "ACB"
  - "knowledge base"
  - "repository canon"
  - "document governance"
  - "metadata"
  - "cross-reference"
  - "document control"
  - "APEX"
  - "Commercial"
  - "Bank"
  - "Knowledge"
  - "Base"
  - "Bible"
related_documents: []
supersedes: null
synthetic: true
---
# APEX Commercial Bank Knowledge Base Bible

## 1 Control Statement

This control artifact is the frozen Version 1.0 canon for the APEX Commercial Bank internal knowledge repository. It governs all future production-quality knowledge base documents created for ACB.

This artifact does not consume a core knowledge base document ID. Core knowledge base document IDs are reserved exclusively for the approved document types POL, SOP, KOD, EXM, and FAQ.

## 2 Binding Repository Rules

1. Never change document structure.
2. Never rename departments.
3. Never rename job roles.
4. Never invent new products.
5. Never create duplicate document IDs.
6. Always use approved metadata.
7. Always include version history.
8. Always include document ownership.
9. Always include effective and review dates.
10. Always cross-reference related documents.
11. Every Policy must reference at least three SOP documents, three KOD documents, and three Exception Matrix documents.
12. Every SOP must reference its parent Policy, related KOD documents, and related FAQ documents.
13. Every KOD must reference its parent SOP and parent Policy.
14. Every FAQ must reference a Policy, SOP, and Exception Matrix.
15. Never generate placeholder text such as Lorem Ipsum.
16. Never leave any section blank.
17. Every document must be production quality.

## 3 Enterprise Structure

```text
Board of Directors
    |
Chief Executive Officer
    |
-------------------------------------------------
|          |             |          |            |
Retail     Corporate     Treasury   Risk         Operations
Banking    Banking
|          |
|          |-------------|
|          |             |
KYC        Trade Finance Lending
AML        Payments      Cash Management
```

## 4 Approved Departments

These department names and codes are frozen and must never be changed.

| Department Code | Department |
| --- | --- |
| RET | Retail Banking |
| COR | Corporate Banking |
| OPS | Banking Operations |
| CMP | Compliance |
| AML | Financial Crime & AML |
| CRD | Credit Risk |
| TRD | Trade Finance |
| PAY | Payments |
| TRE | Treasury |
| IT | Technology |
| HR | Human Resources |
| LEG | Legal |
| CUS | Customer Service |

## 5 Approved Roles

These are the only job titles used throughout the repository.

| Code | Role |
| --- | --- |
| RM | Relationship Manager |
| RO | Relationship Officer |
| OPSO | Operations Officer |
| OPSM | Operations Manager |
| CCO | Compliance Officer |
| SCCO | Senior Compliance Officer |
| AMLA | AML Analyst |
| CRO | Credit Risk Officer |
| BM | Branch Manager |
| RGM | Regional Manager |
| HOD | Department Head |

## 6 Approved Products

These products are approved metadata tags for ACB documents. No other product names may be used unless the Knowledge Base Bible is formally updated.

### 6.1 Retail

| Product |
| --- |
| Savings Account |
| Current Account |
| Salary Account |
| Fixed Deposit |
| Recurring Deposit |

### 6.2 Corporate

| Product |
| --- |
| Business Current Account |
| Escrow Account |
| Cash Management |

### 6.3 Lending

| Product |
| --- |
| Home Loan |
| Personal Loan |
| Business Loan |
| Working Capital |
| Overdraft |

### 6.4 Trade Finance

| Product |
| --- |
| Letter of Credit (LC) |
| Bank Guarantee (BG) |
| Export Finance |
| Import Finance |
| Documentary Collection |

### 6.5 Payments

| Product |
| --- |
| NEFT |
| RTGS |
| IMPS |
| UPI |
| SWIFT |
| ACH |

## 7 Approved Customer Types

These customer types are approved for metadata, policy rules, procedures, document validation, and case handling.

| Customer Type |
| --- |
| Individual |
| Minor |
| NRI |
| Resident |
| Sole Proprietor |
| Partnership |
| Private Limited |
| Public Limited |
| Trust |
| Government Entity |
| Financial Institution |
| NGO |

## 8 Approved Risk Categories

| Level | Description |
| --- | --- |
| Low | Standard Customer |
| Medium | Enhanced Monitoring |
| High | Enhanced Due Diligence |
| Critical | Executive Approval Required |

## 9 Approval Hierarchy

This approval hierarchy is frozen and must never be changed.

1. Operations Officer
2. Operations Manager
3. Branch Manager
4. Regional Manager
5. Department Head
6. Compliance Head
7. Chief Compliance Officer

## 10 SLA Standards

| Activity | SLA |
| --- | --- |
| Document Verification | 4 Hours |
| Standard Account Opening | 2 Business Days |
| High Risk Review | 5 Business Days |
| AML Investigation | 3 Business Days |
| Trade Transaction Review | 1 Business Day |
| Complaint Resolution | 3 Business Days |

## 11 Core Document Types

These five document types form the ACB core knowledge base. Everything else in the generated repository must be derived from these types.

| Code | Document Type |
| --- | --- |
| POL | Policy |
| SOP | Standard Operating Procedure |
| KOD | Knowledge of Documents |
| EXM | Exception Matrix |
| FAQ | Case Repository |

## 12 Document Numbering

Every core knowledge base document must follow this convention:

```text
{DOCUMENT TYPE}-{DOMAIN OR APPROVED DOMAIN CODE}-{THREE DIGIT SEQUENCE}
```

Approved examples:

| Example Document ID |
| --- |
| [POL-KYC-001](./documents/policies/POL-KYC-001_Customer_Identification_and_Verification_Policy.md) |
| [POL-AML-004](./documents/policies/POL-AML-004_Transaction_Monitoring_Policy.md) |
| [SOP-KYC-003](./documents/sops/SOP-KYC-003_Enhanced_Due_Diligence_Review_SOP.md) |
| [KOD-KYC-002](./documents/kod/KOD-KYC-002_Non-Individual_Constitution_Documents_KOD.md) |
| [EXM-AML-001](./documents/exception_matrices/EXM-AML-001_Sanctions_Screening_Exception_Matrix.md) |
| FAQ-KYC-011 |

No document ID may be reused. A document ID register must be checked before any document is generated.

## 13 Approved Domains

Every core knowledge base document belongs to exactly one approved domain.

| Domain |
| --- |
| KYC |
| AML |
| Customer Onboarding |
| Trade Finance |
| Payments |
| Retail Banking |
| Corporate Banking |
| Treasury |
| Credit |
| Risk |
| Customer Service |
| Cards |
| Digital Banking |

## 14 Required Standard Metadata

Every core knowledge base document must include this exact metadata set.

| Metadata Field |
| --- |
| Document ID |
| Title |
| Document Type |
| Department |
| Domain |
| Business Unit |
| Owner |
| Approver |
| Version |
| Status |
| Classification |
| Effective Date |
| Review Date |
| Priority |
| Applicable Products |
| Applicable Customer Types |
| Risk Level |
| Keywords |
| Related Documents |
| Supersedes |

This metadata is indexed separately from document content to improve retrieval.

## 15 Cross-Reference Rules

Every core knowledge base document must reference at least two related documents. No isolated documents are permitted.

The standard relationship path is:

```text
Policy -> SOP -> KOD -> Exception Matrix -> Case Repository
```

Additional mandatory cross-reference rules:

| Document Type | Mandatory References |
| --- | --- |
| Policy | At least three SOP documents, three KOD documents, and three Exception Matrix documents |
| SOP | Parent Policy, related KOD documents, and related FAQ documents |
| KOD | Parent SOP and parent Policy |
| FAQ | Policy, SOP, and Exception Matrix |

## 16 Master Templates

Each generated core knowledge base document must use the approved structure for its document type. Sections must not be renamed, removed, reordered, or left blank.

### 16.1 Policy Template

1. Document Control
2. Purpose
3. Scope
4. Definitions
5. Policy Statements
6. Roles
7. Decision Rules
8. Exceptions
9. Escalation
10. Controls
11. Related Documents
12. Version History

### 16.2 SOP Template

1. Document Control
2. Purpose
3. Preconditions
4. Inputs
5. Procedure
6. Decision Points
7. Outputs
8. Exception Handling
9. Escalation
10. KPIs
11. References

### 16.3 KOD Template

1. Document Control
2. Purpose
3. Applicable Products
4. Required Documents
5. Validation Rules
6. Acceptance Criteria
7. Rejection Criteria
8. Common Errors
9. References

### 16.4 Exception Matrix Template

1. Scenario
2. Risk
3. Decision
4. Approval Required
5. SLA
6. Escalation
7. Reference

### 16.5 Case Repository Template

1. Case ID
2. Business Context
3. Customer Scenario
4. Question
5. Resolution
6. Reasoning
7. Supporting Documents
8. Lessons Learned

## 17 Initial Knowledge Map Version 1.0

This is the approved roadmap for the first repository release.

| Domain | Policies | SOPs | KODs | Exception Matrices | Cases |
| --- | ---: | ---: | ---: | ---: | ---: |
| KYC | 8 | 8 | 5 | 5 | 20 |
| AML | 6 | 6 | 4 | 4 | 15 |
| Customer Onboarding | 5 | 8 | 6 | 5 | 20 |
| Payments | 5 | 5 | 4 | 3 | 15 |
| Trade Finance | 6 | 6 | 4 | 5 | 15 |
| Credit | 5 | 5 | 3 | 3 | 15 |
| Customer Service | 3 | 4 | 2 | 2 | 15 |

The initial release target is approximately 220 interconnected documents. The repository must remain internally consistent, cross-referenced, and audit-ready.

## 18 Validation Controls

Before any core knowledge base document is accepted into the repository, the document must pass the following controls:

1. The document ID follows the approved numbering convention.
2. The document ID is not duplicated.
3. The document type is one of POL, SOP, KOD, EXM, or FAQ.
4. The department uses an approved department name and code.
5. The domain is one of the approved domains.
6. The business unit is consistent with the approved enterprise structure.
7. The owner and approver use approved role titles or approved approval hierarchy titles.
8. The metadata set is complete.
9. The document structure matches the approved master template for its type.
10. No section is blank.
11. No placeholder text is present.
12. All products are approved products.
13. All customer types are approved customer types.
14. All risk levels use approved risk categories.
15. Related documents satisfy mandatory cross-reference rules.
16. Effective date and review date are present.
17. Version history is present where required by the template.
18. The content does not conflict with this Knowledge Base Bible.

## 19 Revision History

| Version | Date | Author | Summary of Changes | Approved By |
| --- | --- | --- | --- | --- |
| 1.0 | 2026-07-01 | Department Head | Initial approved deployment version for ACB-KB-BIBLE-001 APEX Commercial Bank Knowledge Base Bible. | Chief Compliance Officer |

## 20 Governance

Prepared By: Department Head

Reviewed By: Compliance Head

Approved By: Chief Compliance Officer

Owner: Department Head

Next Review Date: 2027-07-01

Document Status: Frozen
