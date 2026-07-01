explain what we are trying to build to an ai like swifting the context

Here's a comprehensive context prompt you can give to another AI (like Swifting, Claude, Gemini, Cursor, etc.) so it understands the project from the perspective of a senior architect.

Project Context

We are designing an enterprise-grade AI Knowledge Agent for the banking domain. This is not a general chatbot; it is a governed knowledge system that answers employee questions based only on approved internal documentation.

The primary objective is to reduce repetitive queries to policy and operations teams by allowing employees to ask questions in natural language and receive accurate, source-backed answers.

Business Problem

Banking operations teams frequently answer the same questions regarding:

KYC/Onboarding processes
AML and Sanctions procedures
Credit policies
Trade finance operations
Service Level Agreements (SLAs)
Standard Operating Procedures (SOPs)
KOD (Knowledge of Documents)
KOP (Knowledge of Process)
Operational manuals
Pricing exceptions
Process workflows
Previously resolved operational cases

Currently, employees search through PDFs, email SMEs, or wait for policy teams to respond. This creates delays, inconsistent answers, and repeated workload.

The goal is to centralize institutional knowledge into a searchable AI-powered assistant.

Proposed Solution

Build a centralized Knowledge Agent that:

Understands internal banking process documents.
Answers process and policy questions in natural language.
Always grounds responses in approved documents.
Provides citations for every answer.
Escalates unknown or low-confidence questions to SMEs.
Learns only from approved SME responses (controlled learning).
Maintains complete auditability.

This is essentially an enterprise RAG (Retrieval-Augmented Generation) system with human-in-the-loop learning.

Technology Stack

Current planned stack:

Backend:

Java
Spring Boot

LLM:

OpenAI / Claude / Azure OpenAI (provider abstracted)

Database:

PostgreSQL

Vector Store:

pgvector (preferred for MVP)

Document Storage:

Local storage initially
Later S3 / SharePoint

Embeddings:

Generated during document ingestion
High-Level Architecture
                User

                  │

                  ▼

          Spring Boot API

                  │

                  ▼

        Agent Orchestrator

        │      │       │

        │      │       │

        ▼      ▼       ▼

  Intent   Retrieval   Access Control

                │

                ▼

          Vector Database

                │

                ▼

         Relevant Chunks

                │

                ▼

             LLM

                │

                ▼

 Answer + Citations + Confidence

                │

      ┌─────────┴──────────┐

      ▼                    ▼

Return Answer       Escalate to SME
Knowledge Base

Documents include:

PDFs
DOCX
SOPs
Policy documents
Process manuals
KOD
KOP
FAQs
Previously approved SME responses

Every document has metadata:

{
  "documentType": "KYC SOP",
  "businessUnit": "Corporate Banking",
  "owner": "Policy Team",
  "version": "3.1",
  "effectiveDate": "...",
  "expiryDate": "...",
  "approved": true,
  "region": "India"
}
Retrieval Philosophy

The LLM should never answer from its own memory.

Instead:

Question

↓

Retrieve relevant chunks

↓

Provide retrieved context

↓

Generate grounded answer

↓

Return citations

No retrieved knowledge = no answer.

Controlled Self-Learning

This project intentionally avoids autonomous self-learning because it is a banking application.

Instead:

Unknown Question

↓

Escalate to SME

↓

SME provides answer

↓

Policy Owner approves

↓

Knowledge Base updated

↓

Future users receive answer

Only approved human responses become reusable knowledge.

Important Design Principles

The AI is not the source of truth.

The knowledge base is the source of truth.

The AI is only responsible for:

understanding the question
retrieving the right knowledge
synthesizing an answer
citing sources
determining confidence
escalating when necessary
Functional Requirements

The system should:

Answer banking process questions
Search thousands of internal documents
Cite document sources
Detect conflicting policies
Detect outdated documents
Respect user permissions
Handle multiple document versions
Support conversation history
Escalate low-confidence queries
Collect user feedback
Learn from approved responses
Log every interaction
Non-Functional Requirements

Enterprise-grade requirements include:

RBAC (Role-Based Access Control)
Audit logs
Version control
Explainability
Source citations
High availability
Low latency
Secure document handling
PII protection
Compliance with banking governance
Edge Cases

The system must handle:

Conflicting policy documents
Expired documents
Multiple document versions
Ambiguous user questions
Region-specific policies
Department-specific procedures
Restricted documents
Low retrieval confidence
Hallucination prevention
Duplicate documents
OCR failures
Prompt injection attacks
Table-heavy PDFs
Missing metadata
Future Vision

The long-term goal is to evolve from a simple RAG chatbot into an Agentic AI platform capable of:

Multi-step reasoning
Planning
Clarifying ambiguous questions
Calling internal APIs
Retrieving customer-independent operational information
Triggering workflows
Creating tickets
Escalating to SMEs
Updating the knowledge base after approval
Maintaining organizational memory
Architectural Philosophy

Think of the system as a Knowledge Operating System for Banking Operations, not as a chatbot.

It should behave like an experienced operations analyst who:

never guesses,
always cites official documentation,
knows when to ask follow-up questions,
knows when to escalate,
and continuously improves through governed human feedback rather than unsupervised learning.
