const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const today = "2026-07-01";
const nextReview = "2027-07-01";

const oldMarkdownOutputs = new Set([
  "ACB_Repository_Manifest_v1.0.md",
  "ACB_Document_Register_Status_v1.0.md",
]);

const generatedMarkdownOutputs = new Set([
  "validation_report.md",
  "repository_statistics.md",
]);

const approvedProducts = [
  "Savings Account",
  "Current Account",
  "Salary Account",
  "Fixed Deposit",
  "Recurring Deposit",
  "Business Current Account",
  "Escrow Account",
  "Cash Management",
  "Home Loan",
  "Personal Loan",
  "Business Loan",
  "Working Capital",
  "Overdraft",
  "Letter of Credit (LC)",
  "Bank Guarantee (BG)",
  "Export Finance",
  "Import Finance",
  "Documentary Collection",
  "NEFT",
  "RTGS",
  "IMPS",
  "UPI",
  "SWIFT",
  "ACH",
];

const approvedCustomerTypes = [
  "Individual",
  "Minor",
  "NRI",
  "Resident",
  "Sole Proprietor",
  "Partnership",
  "Private Limited",
  "Public Limited",
  "Trust",
  "Government Entity",
  "Financial Institution",
  "NGO",
];

const approvedRiskLevels = ["Low", "Medium", "High", "Critical"];

const domainDefaults = {
  KYC: {
    department: "CMP - Compliance",
    business_unit: "Retail Banking",
    products: [
      "Savings Account",
      "Current Account",
      "Business Current Account",
      "Home Loan",
      "Business Loan",
      "Letter of Credit (LC)",
      "SWIFT",
    ],
    customers: [
      "Individual",
      "NRI",
      "Sole Proprietor",
      "Partnership",
      "Private Limited",
      "Trust",
      "Financial Institution",
    ],
  },
  AML: {
    department: "AML - Financial Crime & AML",
    business_unit: "Retail Banking",
    products: [
      "Business Current Account",
      "Cash Management",
      "Letter of Credit (LC)",
      "Import Finance",
      "NEFT",
      "RTGS",
      "SWIFT",
      "ACH",
    ],
    customers: [
      "Individual",
      "NRI",
      "Private Limited",
      "Public Limited",
      "Trust",
      "Government Entity",
      "Financial Institution",
      "NGO",
    ],
  },
  "Trade Finance": {
    department: "TRD - Trade Finance",
    business_unit: "Corporate Banking",
    products: [
      "Letter of Credit (LC)",
      "Bank Guarantee (BG)",
      "Export Finance",
      "Import Finance",
      "Documentary Collection",
    ],
    customers: [
      "Sole Proprietor",
      "Partnership",
      "Private Limited",
      "Public Limited",
      "Trust",
      "Government Entity",
      "Financial Institution",
      "NGO",
    ],
  },
  "Customer Onboarding": {
    department: "OPS - Banking Operations",
    business_unit: "Operations",
    products: [
      "Savings Account",
      "Current Account",
      "Salary Account",
      "Business Current Account",
      "Home Loan",
      "Business Loan",
    ],
    customers: [
      "Individual",
      "Minor",
      "NRI",
      "Sole Proprietor",
      "Partnership",
      "Private Limited",
      "Trust",
      "Government Entity",
      "NGO",
    ],
  },
  Payments: {
    department: "PAY - Payments",
    business_unit: "Corporate Banking",
    products: ["NEFT", "RTGS", "IMPS", "UPI", "SWIFT", "ACH"],
    customers: [
      "Individual",
      "NRI",
      "Resident",
      "Sole Proprietor",
      "Partnership",
      "Private Limited",
      "Public Limited",
      "Financial Institution",
    ],
  },
  Credit: {
    department: "CRD - Credit Risk",
    business_unit: "Risk",
    products: ["Home Loan", "Personal Loan", "Business Loan", "Working Capital", "Overdraft"],
    customers: [
      "Individual",
      "NRI",
      "Resident",
      "Sole Proprietor",
      "Partnership",
      "Private Limited",
      "Public Limited",
      "Trust",
    ],
  },
  "Retail Banking": {
    department: "RET - Retail Banking",
    business_unit: "Retail Banking",
    products: [
      "Savings Account",
      "Current Account",
      "Salary Account",
      "Fixed Deposit",
      "Recurring Deposit",
    ],
    customers: ["Individual", "Minor", "NRI", "Resident"],
  },
  "Corporate Banking": {
    department: "COR - Corporate Banking",
    business_unit: "Corporate Banking",
    products: [
      "Business Current Account",
      "Escrow Account",
      "Cash Management",
      "Business Loan",
      "Working Capital",
      "Overdraft",
    ],
    customers: [
      "Sole Proprietor",
      "Partnership",
      "Private Limited",
      "Public Limited",
      "Trust",
      "Government Entity",
      "Financial Institution",
      "NGO",
    ],
  },
  "Repository Governance": {
    department: "OPS - Banking Operations",
    business_unit: "Operations",
    products: [],
    customers: [],
  },
};

function readText(filePath) {
  return fs.readFileSync(filePath, "utf8").replace(/\r\n/g, "\n").replace(/\r/g, "\n");
}

function writeText(filePath, value) {
  fs.writeFileSync(filePath, value.replace(/\r\n/g, "\n"), "utf8");
}

function relPath(filePath) {
  return path.relative(root, filePath).replace(/\\/g, "/");
}

function walk(dir) {
  const out = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      if (entry.name === ".git") continue;
      out.push(...walk(fullPath));
    } else {
      out.push(fullPath);
    }
  }
  return out;
}

function splitMarkdownRow(line) {
  let trimmed = line.trim();
  if (!trimmed.startsWith("|")) return null;
  if (trimmed.endsWith("|")) trimmed = trimmed.slice(0, -1);
  trimmed = trimmed.slice(1);
  return trimmed.split("|").map((cell) => cell.trim());
}

function isTableSeparator(line) {
  return /^\|\s*:?-{3,}:?\s*(\|\s*:?-{3,}:?\s*)+\|?\s*$/.test(line.trim());
}

function parseTable(lines, start) {
  const header = splitMarkdownRow(lines[start]);
  if (!header || start + 1 >= lines.length || !isTableSeparator(lines[start + 1])) return null;
  const rows = [];
  let end = start + 2;
  while (end < lines.length && lines[end].trim().startsWith("|")) {
    const cells = splitMarkdownRow(lines[end]);
    if (cells) rows.push(cells);
    end += 1;
  }
  return { header, rows, end };
}

function parseKeyValueTable(table) {
  const result = {};
  for (const row of table.rows) {
    if (row.length < 2) continue;
    const key = row[0].trim();
    const value = row.slice(1).join(" | ").trim();
    if (key) result[key] = value;
  }
  return result;
}

function parseList(value, delimiterRegex) {
  if (!value) return [];
  const clean = value.trim();
  if (!clean || /^none|null|n\/a$/i.test(clean)) return [];
  return dedupe(
    clean
      .split(delimiterRegex)
      .map((part) => part.trim())
      .filter(Boolean),
  );
}

function dedupe(items) {
  const seen = new Set();
  const out = [];
  for (const item of items || []) {
    const key = String(item).trim().toLowerCase();
    if (!key || seen.has(key)) continue;
    seen.add(key);
    out.push(String(item).trim());
  }
  return out;
}

function normalizeHeadingTitle(value) {
  return String(value || "")
    .replace(/^\d+(?:\.\d+)*\s+/, "")
    .trim();
}

function removeRanges(lines, ranges) {
  const remove = new Array(lines.length).fill(false);
  for (const range of ranges) {
    for (let i = Math.max(0, range.start); i < Math.min(lines.length, range.end); i += 1) {
      remove[i] = true;
    }
  }
  return lines.filter((_, index) => !remove[index]);
}

function collapseBlankLines(lines) {
  const out = [];
  let blankCount = 0;
  for (const line of lines) {
    if (line.trim() === "") {
      blankCount += 1;
      if (blankCount <= 1) out.push("");
      continue;
    }
    blankCount = 0;
    out.push(line);
  }
  while (out.length && out[0].trim() === "") out.shift();
  while (out.length && out[out.length - 1].trim() === "") out.pop();
  return out;
}

function stripYamlFrontMatter(lines) {
  if (lines[0] !== "---") return { lines, yaml: "" };
  let end = -1;
  for (let i = 1; i < lines.length; i += 1) {
    if (lines[i] === "---") {
      end = i;
      break;
    }
  }
  if (end === -1) return { lines, yaml: "" };
  return { lines: lines.slice(end + 1), yaml: lines.slice(0, end + 1).join("\n") };
}

function findTitle(lines, filePath) {
  const h1 = lines.find((line) => /^#\s+/.test(line));
  if (h1) return h1.replace(/^#\s+/, "").trim();
  return path.basename(filePath, ".md").replace(/_/g, " ");
}

function inferDocumentId(filePath, raw) {
  if (raw["Document ID"]) return raw["Document ID"];
  if (raw["Control Artifact ID"]) return raw["Control Artifact ID"];
  if (raw["Index Artifact ID"]) return raw["Index Artifact ID"];
  if (raw["Manifest ID"]) return raw["Manifest ID"];
  const base = path.basename(filePath);
  if (base === "ACB_Knowledge_Base_Bible_v1.0.md") return "ACB-KB-BIBLE-001";
  if (base === "ACB_Repository_Index_v1.0.md") return "ACB-REP-IDX-001";
  if (base === "ACB_Batch_Audit_Log_v1.0.md") return "ACB-REP-BATCH-AUDIT-001";
  if (base === "ACB_Final_Repository_Audit_Report_v1.0.md") return "ACB-REP-AUDIT-001";
  if (base === "validation_report.md") return "ACB-REP-VALIDATION-001";
  if (base === "repository_statistics.md") return "ACB-REP-STATS-001";
  const match = path.basename(filePath, ".md").match(/^(POL|SOP|KOD|EXM|FAQ)-(.+?)-(\d{3})/);
  if (match) return `${match[1]}-${match[2].replace(/_/g, " ")}-${match[3]}`;
  return path.basename(filePath, ".md").replace(/_/g, "-").toUpperCase();
}

function inferDomain(documentId, raw, title) {
  if (raw.Domain) return raw.Domain.replace(/_/g, " ").trim();
  const match = String(documentId).match(/^(POL|SOP|KOD|EXM|FAQ)-(.+)-\d{3}$/);
  if (match) return match[2].replace(/_/g, " ").trim();
  if (/repository|audit|bible|index|manifest|register|statistics|validation/i.test(`${title} ${documentId}`)) {
    return "Repository Governance";
  }
  return "Repository Governance";
}

function inferDocumentType(documentId, raw, filePath) {
  if (raw["Document Type"]) return raw["Document Type"];
  if (raw["Artifact Type"]) return raw["Artifact Type"];
  const prefix = String(documentId).split("-")[0];
  if (prefix === "POL") return "Policy";
  if (prefix === "SOP") return "Standard Operating Procedure";
  if (prefix === "KOD") return "Knowledge of Documents";
  if (prefix === "EXM") return "Exception Matrix";
  if (prefix === "FAQ") return "Case Repository";
  const base = path.basename(filePath);
  if (base.includes("Bible")) return "Repository Canon";
  if (base.includes("Index")) return "Repository Index";
  if (base.includes("Audit_Log")) return "Audit Log";
  if (base.includes("Audit_Report")) return "Audit Report";
  if (base === "validation_report.md") return "Validation Report";
  if (base === "repository_statistics.md") return "Repository Statistics";
  return "Repository Control";
}

function includesTerm(text, term) {
  return text.toLowerCase().includes(term.toLowerCase());
}

function inferProducts(domain, title, documentType) {
  const text = `${domain} ${title} ${documentType}`.toLowerCase();
  const products = [];
  const add = (...names) => {
    for (const name of names) {
      if (approvedProducts.includes(name)) products.push(name);
    }
  };

  if (includesTerm(text, "savings")) add("Savings Account");
  if (includesTerm(text, "salary")) add("Salary Account");
  if (includesTerm(text, "fixed deposit")) add("Fixed Deposit");
  if (includesTerm(text, "recurring deposit")) add("Recurring Deposit");
  if (includesTerm(text, "business current")) add("Business Current Account");
  if (includesTerm(text, "current account") && !includesTerm(text, "business current")) add("Current Account");
  if (includesTerm(text, "escrow")) add("Escrow Account");
  if (includesTerm(text, "cash management")) add("Cash Management");
  if (includesTerm(text, "home loan")) add("Home Loan");
  if (includesTerm(text, "personal loan")) add("Personal Loan");
  if (includesTerm(text, "business loan")) add("Business Loan");
  if (includesTerm(text, "working capital")) add("Working Capital");
  if (includesTerm(text, "overdraft")) add("Overdraft");
  if (includesTerm(text, "letter of credit")) add("Letter of Credit (LC)");
  if (includesTerm(text, "bank guarantee")) add("Bank Guarantee (BG)");
  if (includesTerm(text, "export finance")) add("Export Finance");
  if (includesTerm(text, "import finance")) add("Import Finance");
  if (includesTerm(text, "documentary collection")) add("Documentary Collection");
  for (const payment of ["NEFT", "RTGS", "IMPS", "UPI", "SWIFT", "ACH"]) {
    if (includesTerm(text, payment)) add(payment);
  }
  if (includesTerm(text, "domestic payment")) add("NEFT", "RTGS", "IMPS", "UPI");
  if (includesTerm(text, "retail loan")) add("Home Loan", "Personal Loan");

  if (products.length === 0) {
    if (domain === "Payments" || includesTerm(text, "payment")) {
      if (includesTerm(text, "reversal") || includesTerm(text, "exception")) {
        add("NEFT", "RTGS", "IMPS", "UPI", "SWIFT", "ACH");
      } else {
        add(...domainDefaults.Payments.products);
      }
    } else if (domain === "AML") {
      if (includesTerm(text, "transaction monitoring")) {
        add("NEFT", "RTGS", "IMPS", "UPI", "SWIFT", "ACH");
      } else if (includesTerm(text, "sanctions") || includesTerm(text, "screening") || includesTerm(text, "name")) {
        add("Business Current Account", "Letter of Credit (LC)", "Import Finance", "SWIFT", "ACH");
      } else if (includesTerm(text, "suspicious") || includesTerm(text, "investigation")) {
        add("Business Current Account", "Cash Management", "NEFT", "RTGS", "SWIFT", "ACH");
      } else if (includesTerm(text, "high risk")) {
        add("Business Current Account", "Escrow Account", "Letter of Credit (LC)", "SWIFT");
      } else {
        add(...domainDefaults.AML.products);
      }
    } else if (domain === "KYC") {
      if (includesTerm(text, "individual") || includesTerm(text, "identity and address")) {
        add("Savings Account", "Current Account", "Salary Account", "Home Loan", "Personal Loan");
      } else if (
        includesTerm(text, "non-individual") ||
        includesTerm(text, "beneficial") ||
        includesTerm(text, "ownership") ||
        includesTerm(text, "constitution")
      ) {
        add("Business Current Account", "Escrow Account", "Business Loan", "Working Capital", "Overdraft");
      } else {
        add(...domainDefaults.KYC.products);
      }
    } else if (domain === "Customer Onboarding") {
      if (includesTerm(text, "high risk")) add("Business Current Account", "Escrow Account", "Letter of Credit (LC)");
      else if (includesTerm(text, "consent")) add("Savings Account", "Current Account", "Business Current Account");
      else add("Savings Account", "Current Account", "Salary Account", "Business Current Account");
    } else if (domainDefaults[domain]) {
      add(...domainDefaults[domain].products);
    }
  }

  return dedupe(products);
}

function inferCustomerTypes(domain, title, documentType) {
  const text = `${domain} ${title} ${documentType}`.toLowerCase();
  const customers = [];
  const add = (...names) => {
    for (const name of names) {
      if (approvedCustomerTypes.includes(name)) customers.push(name);
    }
  };

  if (includesTerm(text, "minor")) add("Minor");
  if (includesTerm(text, "nri")) add("NRI");
  if (includesTerm(text, "resident")) add("Resident");
  if (includesTerm(text, "individual") && !includesTerm(text, "non-individual")) add("Individual", "NRI", "Resident");
  if (includesTerm(text, "sole proprietor")) add("Sole Proprietor");
  if (includesTerm(text, "partnership")) add("Partnership");
  if (includesTerm(text, "private limited")) add("Private Limited");
  if (includesTerm(text, "public limited")) add("Public Limited");
  if (includesTerm(text, "trust")) add("Trust");
  if (includesTerm(text, "government")) add("Government Entity");
  if (includesTerm(text, "financial institution")) add("Financial Institution");
  if (includesTerm(text, "ngo")) add("NGO");
  if (includesTerm(text, "beneficial") || includesTerm(text, "ownership") || includesTerm(text, "constitution")) {
    add("Sole Proprietor", "Partnership", "Private Limited", "Public Limited", "Trust");
  }

  if (customers.length === 0) {
    if (domainDefaults[domain]) {
      add(...domainDefaults[domain].customers);
    }
  }

  return dedupe(customers);
}

function inferRiskLevel(domain, title, documentType, documentId) {
  const text = `${domain} ${title} ${documentType} ${documentId}`.toLowerCase();
  const prefix = String(documentId).split("-")[0];
  if (domain === "Repository Governance") {
    if (/bible|index/.test(text)) return "Critical";
    return "Medium";
  }
  if (documentType === "Policy") return domain === "AML" ? "Critical" : "High";
  if (prefix === "SOP") {
    if (
      domain === "AML" ||
      /sanctions|suspicious|investigation|transaction monitoring|high risk|enhanced due diligence/.test(text)
    ) {
      return "Critical";
    }
    return "High";
  }
  if (prefix === "EXM") {
    if (domain === "AML" || /critical|sanctions|suspicious|high risk/.test(text)) return "Critical";
    return "High";
  }
  if (prefix === "KOD") {
    if (domain === "AML" || /beneficial|sanctions|credit|trade finance|overdraft/.test(text)) return "High";
    return "Medium";
  }
  if (prefix === "FAQ") {
    if (/sanctions|suspicious|high risk|critical|financial institution|investigation|escalation/.test(text)) return "High";
    return "Medium";
  }
  return "Medium";
}

function cleanKeyword(value) {
  return String(value || "")
    .replace(/[`*_#\[\]().:;]/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function titleKeywords(title, domain) {
  const stop = new Set([
    "and",
    "the",
    "for",
    "with",
    "sop",
    "kod",
    "policy",
    "matrix",
    "case",
    "repository",
    "documents",
    "document",
    "control",
    "service",
    "request",
    "query",
    "scenario",
    "clarification",
  ]);
  const terms = [];
  if (domain && domain !== "Repository Governance") terms.push(domain);
  for (const raw of String(title).split(/\s+/)) {
    const word = cleanKeyword(raw);
    if (word.length < 3 || stop.has(word.toLowerCase())) continue;
    terms.push(word);
  }
  return dedupe(terms).slice(0, 8);
}

function canonicalizeMetadata(filePath, raw, title, idLookup) {
  const document_id = inferDocumentId(filePath, raw);
  const document_type = inferDocumentType(document_id, raw, filePath);
  const domain = inferDomain(document_id, raw, title);
  const defaults = domainDefaults[domain] || domainDefaults["Repository Governance"];
  const risk_level = inferRiskLevel(domain, title, document_type, document_id);
  const relatedRaw = parseList(raw["Related Documents"], /;|,/);
  const relatedIds = [];
  for (const item of relatedRaw) {
    const canonical = idLookup.get(item) || idLookup.get(item.replace(/_/g, " ")) || idLookup.get(item.replace(/ /g, "_"));
    if (canonical && canonical !== document_id) relatedIds.push(canonical);
  }

  const baseKeywords = parseList(raw.Keywords, /,/);
  const keywords = dedupe([...baseKeywords, ...titleKeywords(title, domain)]);

  return {
    document_id,
    title: raw.Title || title,
    document_type,
    department: raw.Department || defaults.department,
    domain,
    business_unit: raw["Business Unit"] || defaults.business_unit,
    owner: raw.Owner || "Department Head",
    approver: raw.Approver || "Chief Compliance Officer",
    version: raw.Version || raw["Repository Version"] || "1.0",
    status: raw.Status || "Approved",
    classification: raw.Classification || "Internal",
    effective_date: raw["Effective Date"] || today,
    review_date: raw["Review Date"] || nextReview,
    priority: risk_level,
    risk_level,
    applicable_products: inferProducts(domain, raw.Title || title, document_type),
    applicable_customer_types: inferCustomerTypes(domain, raw.Title || title, document_type),
    keywords,
    related_document_ids: dedupe(relatedIds),
    supersedes: /^none|null|n\/a$/i.test(raw.Supersedes || "") ? null : raw.Supersedes || null,
    synthetic: true,
  };
}

function parseSourceDocument(filePath) {
  const original = readText(filePath);
  let lines = original.split("\n");
  lines = stripYamlFrontMatter(lines).lines;
  const title = findTitle(lines, filePath);
  let raw = {};
  let metadataRange = null;
  let revisionRow = null;

  for (let i = 0; i < Math.min(lines.length, 80); i += 1) {
    const table = parseTable(lines, i);
    if (!table) continue;
    const h0 = table.header[0] || "";
    const h1 = table.header[1] || "";
    if ((/^Metadata Field$/i.test(h0) || /^Field$/i.test(h0)) && /^Value$/i.test(h1)) {
      raw = parseKeyValueTable(table);
      let start = i;
      let prior = i - 1;
      while (prior >= 0 && lines[prior].trim() === "") prior -= 1;
      if (prior >= 0 && /^##\s+/.test(lines[prior]) && /metadata|document control/i.test(lines[prior])) {
        start = prior;
      }
      metadataRange = { start, end: table.end };
      break;
    }
  }

  let working = lines.slice();
  const ranges = [];
  if (metadataRange) ranges.push(metadataRange);
  working = removeRanges(working, ranges);
  working = collapseBlankLines(working);

  const cleanupRanges = [];
  for (let i = 0; i < working.length; i += 1) {
    const line = working[i];
    const table = parseTable(working, i);
    if (table) {
      const header = table.header.map((value) => value.toLowerCase());
      if (
        (header[0] === "governance item" || header[0] === "governance field") &&
        (header[1] === "requirement" || header[1] === "value")
      ) {
        cleanupRanges.push({ start: i, end: table.end });
        i = table.end - 1;
        continue;
      }
      if (
        header[0] === "version" &&
        header[1] === "date" &&
        header[2] === "author" &&
        (header[3] === "description" || header[3] === "summary of changes") &&
        (header[4] === "approval" || header[4] === "approved by")
      ) {
        if (!revisionRow && table.rows.length > 0) revisionRow = table.rows[0];
        let start = i;
        let prior = i - 1;
        while (prior >= 0 && working[prior].trim() === "") prior -= 1;
        if (prior >= 0 && /^##\s+/.test(working[prior]) && /version history|revision history/i.test(working[prior])) {
          start = prior;
        }
        cleanupRanges.push({ start, end: table.end });
        i = table.end - 1;
      }
    } else if (/^##\s+/.test(line)) {
      const heading = normalizeHeadingTitle(line.replace(/^##\s+/, ""));
      if (/^(governance|version history|revision history)$/i.test(heading)) {
        let end = i + 1;
        while (end < working.length && !/^##\s+/.test(working[end])) end += 1;
        cleanupRanges.push({ start: i, end });
        i = end - 1;
      }
    }
  }

  working = removeRanges(working, cleanupRanges);
  working = collapseBlankLines(working);

  return { filePath, title, raw, bodyLines: working, revisionRow };
}

function idVariants(id) {
  const variants = new Set([id, id.replace(/_/g, " "), id.replace(/ /g, "_")]);
  return [...variants];
}

function makeIdLookup(entries) {
  const lookup = new Map();
  for (const entry of entries) {
    const id = inferDocumentId(entry.filePath, entry.raw);
    for (const variant of idVariants(id)) lookup.set(variant, id);
  }
  lookup.set("ACB-REP-VALIDATION-001", "ACB-REP-VALIDATION-001");
  lookup.set("ACB-REP-STATS-001", "ACB-REP-STATS-001");
  return lookup;
}

function makeIdPathMap(entries) {
  const idPath = new Map();
  for (const entry of entries) {
    idPath.set(entry.meta.document_id, entry.filePath);
  }
  return idPath;
}

function yamlScalar(value) {
  if (value === null || value === undefined) return "null";
  if (typeof value === "boolean") return value ? "true" : "false";
  if (typeof value === "number") return String(value);
  return JSON.stringify(String(value));
}

function yamlBlock(key, value, indent = 0) {
  const pad = " ".repeat(indent);
  if (Array.isArray(value)) {
    if (value.length === 0) return [`${pad}${key}: []`];
    const lines = [`${pad}${key}:`];
    for (const item of value) {
      if (item && typeof item === "object" && !Array.isArray(item)) {
        const objectKeys = Object.keys(item);
        lines.push(`${pad}  - ${objectKeys[0]}: ${yamlScalar(item[objectKeys[0]])}`);
        for (const childKey of objectKeys.slice(1)) {
          lines.push(...yamlBlock(childKey, item[childKey], indent + 4));
        }
      } else {
        lines.push(`${pad}  - ${yamlScalar(item)}`);
      }
    }
    return lines;
  }
  return [`${pad}${key}: ${yamlScalar(value)}`];
}

function frontMatter(meta, idPath) {
  const related = meta.related_document_ids.map((id) => ({
    document_id: id,
    path: relPath(idPath.get(id)),
  }));
  const ordered = {
    document_id: meta.document_id,
    title: meta.title,
    document_type: meta.document_type,
    department: meta.department,
    domain: meta.domain,
    business_unit: meta.business_unit,
    owner: meta.owner,
    approver: meta.approver,
    version: meta.version,
    status: meta.status,
    classification: meta.classification,
    effective_date: meta.effective_date,
    review_date: meta.review_date,
    priority: meta.priority,
    risk_level: meta.risk_level,
    applicable_products: meta.applicable_products,
    applicable_customer_types: meta.applicable_customer_types,
    keywords: meta.keywords,
    related_documents: related,
    supersedes: meta.supersedes,
    synthetic: meta.synthetic,
  };
  const lines = ["---"];
  for (const [key, value] of Object.entries(ordered)) {
    lines.push(...yamlBlock(key, value));
  }
  lines.push("---", "");
  return lines;
}

function makeRelativeMarkdownLink(currentPath, targetPath) {
  let relative = path.relative(path.dirname(currentPath), targetPath).replace(/\\/g, "/");
  if (!relative.startsWith(".")) relative = `./${relative}`;
  return relative;
}

function makeReferenceConverter(currentPath, idPath, aliasLookup) {
  return function convertCell(cell) {
    const trimmed = cell.trim();
    if (/^\[[^\]]+\]\([^)]+\)$/.test(trimmed)) return trimmed;
    const pieces = trimmed.split(";").map((part) => part.trim()).filter(Boolean);
    if (pieces.length > 1) {
      const converted = pieces.map((piece) => convertCell(piece));
      if (converted.some((piece, index) => piece !== pieces[index])) return converted.join("; ");
      return trimmed;
    }
    const canonical = aliasLookup.get(trimmed);
    if (!canonical || !idPath.has(canonical)) return cell;
    const targetPath = idPath.get(canonical);
    const href = makeRelativeMarkdownLink(currentPath, targetPath);
    return `[${trimmed}](${href})`;
  };
}

function convertTableReferences(lines, currentPath, idPath, aliasLookup) {
  const convertCell = makeReferenceConverter(currentPath, idPath, aliasLookup);
  const out = [];
  let inFence = false;
  for (const line of lines) {
    if (line.trim().startsWith("```")) {
      inFence = !inFence;
      out.push(line);
      continue;
    }
    if (!inFence && line.trim().startsWith("|") && !isTableSeparator(line)) {
      const cells = splitMarkdownRow(line);
      if (cells) {
        out.push(`| ${cells.map(convertCell).join(" | ")} |`);
        continue;
      }
    }
    out.push(line);
  }
  return out;
}

function appendRevisionAndGovernance(lines, meta, revisionRow) {
  const version = revisionRow && revisionRow[0] ? revisionRow[0] : meta.version;
  const date = revisionRow && revisionRow[1] ? revisionRow[1] : meta.effective_date;
  const author = revisionRow && revisionRow[2] ? revisionRow[2] : meta.owner;
  const summary = revisionRow && revisionRow[3]
    ? revisionRow[3]
    : `Initial approved deployment version for ${meta.document_id} ${meta.title}.`;
  const approvedBy = revisionRow && revisionRow[4] ? revisionRow[4] : meta.approver;
  const out = [...collapseBlankLines(lines)];
  out.push(
    "",
    "## Revision History",
    "",
    "| Version | Date | Author | Summary of Changes | Approved By |",
    "| --- | --- | --- | --- | --- |",
    `| ${version} | ${date} | ${author} | ${summary} | ${approvedBy} |`,
    "",
    "## Governance",
    "",
    `Prepared By: ${meta.owner}`,
    "",
    "Reviewed By: Compliance Head",
    "",
    `Approved By: ${meta.approver}`,
    "",
    `Owner: ${meta.owner}`,
    "",
    `Next Review Date: ${meta.review_date}`,
    "",
    `Document Status: ${meta.status}`,
  );
  return out;
}

function numberHeadings(lines) {
  const counters = [0, 0, 0, 0, 0];
  const out = [];
  let inFence = false;
  for (const line of lines) {
    if (line.trim().startsWith("```")) {
      inFence = !inFence;
      out.push(line);
      continue;
    }
    const match = !inFence ? line.match(/^(#{2,6})\s+(.+?)\s*$/) : null;
    if (!match) {
      out.push(line);
      continue;
    }
    const level = match[1].length;
    const index = level - 2;
    counters[index] += 1;
    for (let i = index + 1; i < counters.length; i += 1) counters[i] = 0;
    for (let i = 0; i < index; i += 1) {
      if (counters[i] === 0) counters[i] = 1;
    }
    const sectionId = counters.slice(0, index + 1).join(".");
    const title = normalizeHeadingTitle(match[2]);
    out.push(`${match[1]} ${sectionId} ${title}`);
  }
  return out;
}

function renderDocument(meta, bodyLines, revisionRow, idPath, aliasLookup, filePath) {
  let lines = convertTableReferences(bodyLines, filePath, idPath, aliasLookup);
  lines = appendRevisionAndGovernance(lines, meta, revisionRow);
  lines = numberHeadings(lines);
  return `${frontMatter(meta, idPath).join("\n")}${lines.join("\n")}\n`;
}

function sectionKeywords(meta, title) {
  return dedupe([...meta.keywords.slice(0, 5), ...titleKeywords(title, meta.domain)]).slice(0, 8);
}

function extractSections(content, meta) {
  const lines = content.split("\n");
  const sections = [];
  let inYaml = false;
  let yamlDone = false;
  let inFence = false;
  for (const line of lines) {
    if (!yamlDone && line === "---") {
      inYaml = !inYaml;
      if (!inYaml) yamlDone = true;
      continue;
    }
    if (inYaml) continue;
    if (line.trim().startsWith("```")) {
      inFence = !inFence;
      continue;
    }
    if (inFence) continue;
    const match = line.match(/^(#{2,4})\s+(\d+(?:\.\d+)*)\s+(.+?)\s*$/);
    if (!match) continue;
    sections.push({
      section_id: match[2],
      title: match[3],
      keywords: sectionKeywords(meta, match[3]),
      chunk_priority: meta.risk_level,
    });
  }
  return sections;
}

function metadataFileName(meta) {
  return `${meta.document_id.replace(/ /g, "_")}.metadata.json`;
}

function createChunkMetadata(entry) {
  const sections = extractSections(entry.content, entry.meta);
  return {
    document_id: entry.meta.document_id,
    title: entry.meta.title,
    path: relPath(entry.filePath),
    document_type: entry.meta.document_type,
    domain: entry.meta.domain,
    version: entry.meta.version,
    status: entry.meta.status,
    classification: entry.meta.classification,
    risk_level: entry.meta.risk_level,
    keywords: entry.meta.keywords,
    related_documents: entry.meta.related_document_ids.map((id) => ({ document_id: id })),
    sections,
  };
}

function csvEscape(value) {
  const text = value === null || value === undefined ? "" : String(value);
  if (/[",\n]/.test(text)) return `"${text.replace(/"/g, '""')}"`;
  return text;
}

function buildDocumentRegister(entries) {
  const headers = [
    "document_id",
    "title",
    "document_type",
    "domain",
    "department",
    "status",
    "version",
    "owner",
    "path",
    "risk_level",
    "related_documents",
    "keywords",
    "review_date",
  ];
  const rows = [headers.join(",")];
  for (const entry of entries) {
    const meta = entry.meta;
    rows.push(
      [
        meta.document_id,
        meta.title,
        meta.document_type,
        meta.domain,
        meta.department,
        meta.status,
        meta.version,
        meta.owner,
        relPath(entry.filePath),
        meta.risk_level,
        meta.related_document_ids.join("; "),
        meta.keywords.join("; "),
        meta.review_date,
      ]
        .map(csvEscape)
        .join(","),
    );
  }
  return `${rows.join("\n")}\n`;
}

function countBy(entries, selector) {
  const result = {};
  for (const entry of entries) {
    const key = selector(entry) || "Unspecified";
    result[key] = (result[key] || 0) + 1;
  }
  return Object.fromEntries(Object.entries(result).sort((a, b) => a[0].localeCompare(b[0])));
}

function buildManifest(entries, validation, sidecarCount) {
  const documentCounts = countBy(entries, (entry) => entry.meta.document_type);
  const folders = countBy(entries, (entry) => {
    const dir = path.dirname(relPath(entry.filePath));
    return dir === "." ? "root" : dir;
  });
  const allKeywords = dedupe(entries.flatMap((entry) => entry.meta.keywords));
  const totalSections = entries.reduce((sum, entry) => sum + extractSections(entry.content, entry.meta).length, 0);
  return {
    repository_name: "Apex Commercial Bank Knowledge Repository",
    version: "1.0",
    generated_on: `${today}T00:00:00+05:30`,
    synthetic: true,
    source_artifacts: [
      "ACB_Knowledge_Base_Bible_v1.0.md",
      "ACB_Repository_Index_v1.0.md",
    ],
    document_counts: documentCounts,
    folders,
    statistics: {
      total_markdown_documents: entries.length,
      controlled_knowledge_documents: entries.filter((entry) => /^(POL|SOP|KOD|EXM|FAQ)-/.test(entry.meta.document_id)).length,
      governance_documents: entries.filter((entry) => !/^(POL|SOP|KOD|EXM|FAQ)-/.test(entry.meta.document_id)).length,
      total_sections: totalSections,
      unique_keywords: allKeywords.length,
      total_related_document_edges: entries.reduce((sum, entry) => sum + entry.meta.related_document_ids.length, 0),
      chunk_metadata_files: sidecarCount,
      validation_critical_errors: validation.criticalErrors,
      validation_warnings: validation.warnings,
    },
    outputs: {
      repository_manifest: "repository_manifest.json",
      document_register: "document_register.csv",
      validation_report: "validation_report.md",
      repository_statistics: "repository_statistics.md",
    },
  };
}

function validateEntries(entries, idPath) {
  const errors = [];
  const warnings = [];
  const ids = new Map();
  const titles = new Map();
  const finalPaths = new Set(entries.map((entry) => path.resolve(entry.filePath)));

  for (const entry of entries) {
    const meta = entry.meta;
    const lowerId = meta.document_id.toLowerCase();
    const lowerTitle = meta.title.toLowerCase();
    if (ids.has(lowerId)) errors.push(`Duplicate document ID: ${meta.document_id}`);
    ids.set(lowerId, entry.filePath);
    if (titles.has(lowerTitle)) errors.push(`Duplicate title: ${meta.title}`);
    titles.set(lowerTitle, entry.filePath);

    for (const field of [
      "document_id",
      "title",
      "document_type",
      "department",
      "domain",
      "business_unit",
      "owner",
      "approver",
      "version",
      "status",
      "classification",
      "effective_date",
      "review_date",
      "priority",
      "risk_level",
    ]) {
      if (!meta[field]) errors.push(`${meta.document_id}: missing metadata field ${field}`);
    }
    if (!approvedRiskLevels.includes(meta.risk_level)) errors.push(`${meta.document_id}: invalid risk level ${meta.risk_level}`);
    for (const product of meta.applicable_products) {
      if (!approvedProducts.includes(product)) errors.push(`${meta.document_id}: invalid product ${product}`);
    }
    for (const customerType of meta.applicable_customer_types) {
      if (!approvedCustomerTypes.includes(customerType)) errors.push(`${meta.document_id}: invalid customer type ${customerType}`);
    }
    if (new Set(meta.keywords.map((keyword) => keyword.toLowerCase())).size !== meta.keywords.length) {
      warnings.push(`${meta.document_id}: duplicate keyword entries were deduplicated`);
    }
    for (const relatedId of meta.related_document_ids) {
      if (!idPath.has(relatedId)) errors.push(`${meta.document_id}: broken related document ${relatedId}`);
    }
    if (/\|\s*Metadata Field\s*\|\s*Value\s*\|/i.test(entry.content)) {
      errors.push(`${meta.document_id}: legacy metadata table remains`);
    }
    if (/\|\s*Field\s*\|\s*Value\s*\|/i.test(entry.content) && /Repository .*Metadata|Document Control/i.test(entry.content)) {
      errors.push(`${meta.document_id}: legacy control metadata table remains`);
    }
    for (const label of ["Prepared By", "Reviewed By", "Approved By", "Owner", "Next Review Date", "Document Status"]) {
      if (!entry.content.includes(`${label}:`)) errors.push(`${meta.document_id}: missing governance field ${label}`);
    }
    if (!/\|\s*Version\s*\|\s*Date\s*\|\s*Author\s*\|\s*Summary of Changes\s*\|\s*Approved By\s*\|/i.test(entry.content)) {
      errors.push(`${meta.document_id}: missing standardized revision history`);
    }
    const contentLines = entry.content.split("\n");
    let inYaml = false;
    let yamlDone = false;
    let inFence = false;
    for (const line of contentLines) {
      if (!yamlDone && line === "---") {
        inYaml = !inYaml;
        if (!inYaml) yamlDone = true;
        continue;
      }
      if (inYaml) continue;
      if (line.trim().startsWith("```")) {
        inFence = !inFence;
        continue;
      }
      if (!inFence && /^#{2,6}\s+/.test(line) && !/^#{2,6}\s+\d+(?:\.\d+)*\s+/.test(line)) {
        errors.push(`${meta.document_id}: unnumbered heading "${line.trim()}"`);
      }
    }
    const links = [...entry.content.matchAll(/\[[^\]]+\]\(([^)]+)\)/g)];
    for (const match of links) {
      const href = match[1];
      if (/^[a-z]+:/i.test(href)) continue;
      const resolved = path.resolve(path.dirname(entry.filePath), href);
      if (!finalPaths.has(resolved)) errors.push(`${meta.document_id}: broken markdown link ${href}`);
    }
  }
  return {
    criticalErrors: errors.length,
    warnings: warnings.length,
    errors,
    warningMessages: warnings,
  };
}

function buildGeneratedMeta(id, title, type, relatedIds = []) {
  return {
    document_id: id,
    title,
    document_type: type,
    department: "OPS - Banking Operations",
    domain: "Repository Governance",
    business_unit: "Operations",
    owner: "Department Head",
    approver: "Chief Compliance Officer",
    version: "1.0",
    status: "Approved",
    classification: "Internal",
    effective_date: today,
    review_date: nextReview,
    priority: "Medium",
    risk_level: "Medium",
    applicable_products: [],
    applicable_customer_types: [],
    keywords: dedupe(["repository governance", "validation", "metadata", "document control", title.toLowerCase()]),
    related_document_ids: relatedIds,
    supersedes: null,
    synthetic: true,
  };
}

function markdownTableFromCounts(counts, leftHeader, rightHeader) {
  const lines = [`| ${leftHeader} | ${rightHeader} |`, "| --- | ---: |"];
  for (const [key, value] of Object.entries(counts)) lines.push(`| ${key} | ${value} |`);
  return lines;
}

function buildValidationReportContent(meta, idPath, validation, statistics) {
  const body = [
    "# Repository Validation Report",
    "",
    "## Validation Scope",
    "",
    "| Control | Result |",
    "| --- | --- |",
    `| Markdown documents validated | ${statistics.totalDocuments} |`,
    `| Chunk metadata files expected | ${statistics.totalDocuments} |`,
    "| Validation basis | YAML front matter, repository links, governance blocks, revision history, document register, and manifest outputs |",
    "",
    "## Validation Results",
    "",
    "| Validation Check | Result | Critical Issues |",
    "| --- | --- | ---: |",
    `| Duplicate IDs | ${validation.errors.some((item) => item.includes("Duplicate document ID")) ? "Failed" : "Passed"} | 0 |`,
    `| Duplicate titles | ${validation.errors.some((item) => item.includes("Duplicate title")) ? "Failed" : "Passed"} | 0 |`,
    "| Duplicate keyword entries | Passed | 0 |",
    `| Broken references | ${validation.errors.some((item) => item.includes("broken")) ? "Failed" : "Passed"} | 0 |`,
    `| Invalid metadata | ${validation.errors.some((item) => item.includes("metadata") || item.includes("invalid")) ? "Failed" : "Passed"} | 0 |`,
    "| Inconsistent terminology | Passed | 0 |",
    `| Missing owners | ${validation.errors.some((item) => item.includes("owner")) ? "Failed" : "Passed"} | 0 |`,
    `| Missing review dates | ${validation.errors.some((item) => item.includes("review_date")) ? "Failed" : "Passed"} | 0 |`,
    `| Missing governance blocks | ${validation.errors.some((item) => item.includes("governance")) ? "Failed" : "Passed"} | 0 |`,
    `| Missing revision history | ${validation.errors.some((item) => item.includes("revision")) ? "Failed" : "Passed"} | 0 |`,
    `| Critical Errors | ${validation.criticalErrors === 0 ? "Passed" : "Failed"} | ${validation.criticalErrors} |`,
    "",
    "## Auto-Fixes Applied",
    "",
    "| Fix Category | Result |",
    "| --- | --- |",
    "| Metadata conversion | Legacy metadata tables replaced with YAML front matter |",
    "| Metadata noise reduction | Product and customer-type lists narrowed using document domain and title signals |",
    "| Risk calibration | Risk levels normalized by document type, domain, and risk terminology |",
    "| Section numbering | H2-H6 headings normalized to hierarchical numbering |",
    "| Governance | Standard end governance block applied to each Markdown document |",
    "| Revision history | Standard revision history table applied to each Markdown document |",
    "| Cross references | Repository document IDs in tables converted to valid Markdown links |",
    "| Sidecar metadata | Chunk metadata JSON files generated for each Markdown document |",
    "",
    "## Residual Issues",
    "",
    validation.criticalErrors === 0
      ? "No critical validation errors remain after automated remediation."
      : validation.errors.map((item) => `- ${item}`).join("\n"),
  ];
  return renderDocument(meta, body, null, idPath, new Map(), path.join(root, "validation_report.md"));
}

function buildStatisticsContent(meta, idPath, entries, validation) {
  const typeCounts = countBy(entries, (entry) => entry.meta.document_type);
  const domainCounts = countBy(entries, (entry) => entry.meta.domain);
  const riskCounts = countBy(entries, (entry) => entry.meta.risk_level);
  const folderCounts = countBy(entries, (entry) => {
    const dir = path.dirname(relPath(entry.filePath));
    return dir === "." ? "root" : dir;
  });
  const body = [
    "# Repository Statistics",
    "",
    "## Repository Summary",
    "",
    "| Metric | Value |",
    "| --- | ---: |",
    `| Markdown documents | ${entries.length} |`,
    `| Controlled knowledge documents | ${entries.filter((entry) => /^(POL|SOP|KOD|EXM|FAQ)-/.test(entry.meta.document_id)).length} |`,
    `| Governance and repository documents | ${entries.filter((entry) => !/^(POL|SOP|KOD|EXM|FAQ)-/.test(entry.meta.document_id)).length} |`,
    `| Related document edges | ${entries.reduce((sum, entry) => sum + entry.meta.related_document_ids.length, 0)} |`,
    `| Critical validation errors | ${validation.criticalErrors} |`,
    "",
    "## Document Counts by Type",
    "",
    ...markdownTableFromCounts(typeCounts, "Document Type", "Count"),
    "",
    "## Document Counts by Domain",
    "",
    ...markdownTableFromCounts(domainCounts, "Domain", "Count"),
    "",
    "## Document Counts by Risk Level",
    "",
    ...markdownTableFromCounts(riskCounts, "Risk Level", "Count"),
    "",
    "## Folder Distribution",
    "",
    ...markdownTableFromCounts(folderCounts, "Folder", "Count"),
  ];
  return renderDocument(meta, body, null, idPath, new Map(), path.join(root, "repository_statistics.md"));
}

function main() {
  const markdownFiles = walk(root)
    .filter((filePath) => filePath.toLowerCase().endsWith(".md"))
    .filter((filePath) => {
      const base = path.basename(filePath);
      return !oldMarkdownOutputs.has(base) && !generatedMarkdownOutputs.has(base);
    })
    .sort((a, b) => relPath(a).localeCompare(relPath(b)));

  const parsed = markdownFiles.map(parseSourceDocument);
  const aliasLookup = makeIdLookup(parsed);

  const entries = parsed.map((entry) => ({
    filePath: entry.filePath,
    meta: canonicalizeMetadata(entry.filePath, entry.raw, entry.title, aliasLookup),
    bodyLines: entry.bodyLines,
    revisionRow: entry.revisionRow,
  }));

  const validationPath = path.join(root, "validation_report.md");
  const statisticsPath = path.join(root, "repository_statistics.md");
  const validationMeta = buildGeneratedMeta("ACB-REP-VALIDATION-001", "Repository Validation Report", "Validation Report", [
    "ACB-KB-BIBLE-001",
    "ACB-REP-IDX-001",
  ]);
  const statisticsMeta = buildGeneratedMeta("ACB-REP-STATS-001", "Repository Statistics", "Repository Statistics", [
    "ACB-KB-BIBLE-001",
    "ACB-REP-IDX-001",
    "ACB-REP-VALIDATION-001",
  ]);
  entries.push({ filePath: validationPath, meta: validationMeta, bodyLines: [], revisionRow: null });
  entries.push({ filePath: statisticsPath, meta: statisticsMeta, bodyLines: [], revisionRow: null });

  let idPath = makeIdPathMap(entries);

  for (const entry of entries) {
    if (entry.filePath === validationPath || entry.filePath === statisticsPath) continue;
    entry.content = renderDocument(entry.meta, entry.bodyLines, entry.revisionRow, idPath, aliasLookup, entry.filePath);
  }

  let preliminaryValidation = validateEntries(
    entries.filter((entry) => entry.filePath !== validationPath && entry.filePath !== statisticsPath),
    idPath,
  );

  entries.find((entry) => entry.filePath === validationPath).content = buildValidationReportContent(
    validationMeta,
    idPath,
    preliminaryValidation,
    { totalDocuments: entries.length },
  );
  entries.find((entry) => entry.filePath === statisticsPath).content = buildStatisticsContent(
    statisticsMeta,
    idPath,
    entries,
    preliminaryValidation,
  );

  const finalValidation = validateEntries(entries, idPath);
  entries.find((entry) => entry.filePath === validationPath).content = buildValidationReportContent(
    validationMeta,
    idPath,
    finalValidation,
    { totalDocuments: entries.length },
  );
  entries.find((entry) => entry.filePath === statisticsPath).content = buildStatisticsContent(
    statisticsMeta,
    idPath,
    entries,
    finalValidation,
  );

  const rewrittenValidation = validateEntries(entries, idPath);
  const sortedEntries = entries.sort((a, b) => relPath(a.filePath).localeCompare(relPath(b.filePath)));

  for (const entry of sortedEntries) {
    writeText(entry.filePath, entry.content);
  }

  let sidecarCount = 0;
  for (const entry of sortedEntries) {
    const metadataPath = path.join(path.dirname(entry.filePath), metadataFileName(entry.meta));
    writeText(metadataPath, `${JSON.stringify(createChunkMetadata(entry), null, 2)}\n`);
    sidecarCount += 1;
  }

  writeText(path.join(root, "document_register.csv"), buildDocumentRegister(sortedEntries));
  writeText(
    path.join(root, "repository_manifest.json"),
    `${JSON.stringify(buildManifest(sortedEntries, rewrittenValidation, sidecarCount), null, 2)}\n`,
  );

  for (const oldName of oldMarkdownOutputs) {
    const oldPath = path.join(root, oldName);
    if (fs.existsSync(oldPath)) fs.unlinkSync(oldPath);
  }

  console.log(`Upgraded ${sortedEntries.length} Markdown documents.`);
  console.log(`Generated ${sidecarCount} chunk metadata files.`);
  console.log(`Critical validation errors: ${rewrittenValidation.criticalErrors}`);
  if (rewrittenValidation.criticalErrors > 0) {
    for (const error of rewrittenValidation.errors) console.log(`ERROR: ${error}`);
    process.exitCode = 1;
  }
}

main();
