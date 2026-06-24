# Traceability Matrix — Full Playbook

Maps every playbook phase to its planned/authored test coverage. `Authored` = detailed cases exist in `test-cases/`. `Pending Content` = phase markdown not yet provided; coverage is drafted against the phase's standard sections and will be authored on content delivery.

Workstream and phase list per `Introduction.md`. Hand-off phases (ticket → specialist team) reuse the shared cases `TC-HO-01..09` defined in [`test-cases/_shared/TC_PATTERN_JiraHandoffPhase.md`](test-cases/_shared/TC_PATTERN_JiraHandoffPhase.md) (shown as "+ HO" below). Suites are organized into workstream folders under `test-cases/` (see README).

| Phase | Title | WS | Priority | Risk focus | Test Case ID(s) | Status |
|-------|-------|----|----------|-----------|-----------------|--------|
| 1 | Gather Client & AWS Account Info | 1 | P1 | Input accuracy, Tier calc, PHI provenance | `TC-P1-01..11` | **Authored** |
| — | ClientMemCount.sql | — | P1 | Count accuracy → Tier; PROD/PHI safety | `TC-SQL-01..10` | **Authored** |
| 2 | Request AWS Accounts | 1 | P2 | REF substitution, ticket accuracy | `TC-P2-01..08` | **Authored** |
| 2.1 | Test AWS Accounts | 1 | P2 | Access, region, naming convention | `TC-P2.1-01..10` | **Authored** |
| 3 | Provision Tenant Infrastructure | 1 | P2 | Tier-correct sizing, naming, seq order | `TC-P3-01..07` | **Authored** |
| 3.1 | Kerberos Setup | 1 | P3 | Auth config (hand-off) | `TC-P3.1-*` + HO | **Authored** |
| 3.2 | Load Balancers | 1 | P3 | LB config, DNS CNAME, rollback | `TC-P3.2-*` + HO | **Authored** |
| 3.3 | Attach SSL/TLS Certificates | 1 | P2 | Cert validity, binding, 3.2 dependency | `TC-P3.3-*` + HO | **Authored** |
| 3.4 | Infrastructure-level Security | 1 | P1 | IT-Intake decision table, PHI gate | `TC-P3.4-01..08` | **Authored** |
| 4 | **WW Shrink (WW1.0 & Config)** *(restructured — now main Phase 4)* | 1 | **P1** | Scoping IDs (CCP‑1897), no data loss, backup safety, `Verify_Shrink_Results.sql` | `TC-P4-01..10` + HO | **Authored** |
| 4.1 | Database Setup & Migration *(setup + backup/restore + COM offline + connectivity)* | 1 | **P1** | DB sizing/config, integrity, PROD/HFX offline change-ctrl, SSMS comma-port | `TC-P4.1-01..11` + HO | **Authored** |
| 4.2 | Database Replication | 1 | P2 | Replica=source consistency, AG failover, on-prem perf | `TC-P4.2-01..05` + HO | **Authored** |
| 4.3 | WW Shrink (WW Payment) | 2 | P1 | Payment integrity, scoping, backup safety | `TC-P4.3-01..07` + HO | **Authored** |
| 5 | Deploy WW1.0 & Config | 1 | P2 | Deploy + functional (Citrix), seq env | `TC-P5-*` + HO | **Authored** |
| 5.1 | App Security: WW1.0 & Config | 1 | P1 | Okta SSO, auth, ForcePoint DSS PHI | `TC-P5.1-*` | **Authored** |
| 5.2 | Deploy WW Payments | 2 | P1 | Payment deploy + functional, Tier file | `TC-P5.2-*` + HO | **Authored** |
| 5.3 | App Security: WW Payments | 2 | P1 | Payment SSO/auth, PHI, correct instance | `TC-P5.3-*` | **Authored** |
| 6 | Deploy Domain Services | 1 | P2 | 4 services deployed, health, smoke | `TC-P6-*` + HO | **Authored** |
| 6.1 | Deploy Business Service | 5 | P2 | All-env deploy, smoke, rollback | `TC-P6.1-*` + HO | **Authored** |
| 7 | TWS Jobs Setup | 4 | P2 | Conn-strings (cross-tenant), SSIS, BU, jobs | `TC-P7-*` + HO | **Authored** |
| 7.1 | Correspondence Letter Setup | 4 | P3 | Letter generation (PHI output) | `TC-P7.1-*` | **Not QA-ready** (placeholder) |
| 7.2 | EDI Setup | 3 | P2 | Payor/Trading Partner ID routing | `TC-P7.2-*` | **Not QA-ready** (placeholder) |
| 7.3 | Eligibility Engine Setup | 3 | P2 | Eligibility responses | `TC-P7.3-*` | **Not QA-ready** (placeholder) |
| 7.4 | Member Portal Setup | 5 | P3 | Portal access/PHI (external) | `TC-P7.4-*` | **Not QA-ready** (placeholder) |
| 7.5 | Mobile App Setup | 5 | P3 | App access/PHI (external) | `TC-P7.5-*` | **Not QA-ready** (placeholder) |
| 8 | Oracle Integration | 2 | P2 | Integration data flow | `TC-P8-*` | **Not QA-ready** (placeholder) |
| 9 | Trusted View Setup | 4 | **P1** | Rebuild integrity, all tables populated | `TC-P9-*` + HO | **Authored** |
| 9.1 | Provider Copy Job | TBD | P2 | Provider sync completeness, cross-tenant | `TC-P9.1-*` + HO | **Authored** |
| 9.2 | Remove Extra Disk & CPUs | TBD | **P1** | Irreversible resize, snapshot, perf | `TC-P9.2-*` + HO | **Authored** |
| 10 | Remove SLE Data from COM DB | TBD | **P1** | Irreversible deletion: backup, scope, before/after counts | `TC-P10-*` + HO | **Authored** |
| 11 | Bring COM DB Online (PROD ONLY) | TBD | **P1** | PROD cutover, Phase-10 gate, app connectivity | `TC-P11-*` + HO | **Authored** |
| 12 | Disaster Recovery Setup | TBD | P1 | DR failover/restore drill | `TC-P12-*` | **Not QA-ready** (placeholder) |
| X | End-to-End Test & UAT | TBD | **P1** | Full onboarding acceptance + functional/perf gate, bug-resolution exit | `TC-PX-*` + HO | **Authored** |

**Status legend:** **Authored** = detailed suite in `test-cases/`. **Pending Content** = phase markdown not yet provided. **Not QA-ready (placeholder)** = phase file received but is an unfilled template (no titles, acceptance criteria, owners, or reference links) — nothing testable yet; see Gap Register **G7**.

> **Placeholder phases (7.1, 7.2, 7.3, 7.4, 7.5, 8, 12):** received as empty templates. These are **blocked for QA authoring** until real content (titles, steps, acceptance criteria, owners, links) is supplied. Their latent risk is high — EDI (7.2) and Eligibility (7.3) carry PHI/claims routing; Member Portal (7.4) and Mobile App (7.5) are externally exposed member-PHI surfaces (WS5) and will be **P1 for exposure** once authored; **Disaster Recovery (12) is P1** (failover/restore integrity). They must not be marked COMPLETE on the strength of an empty template.

## Cross-cutting coverage (applies across phases)
| Concern | Where validated |
|---------|-----------------|
| Naming-convention generation/validation | TC-P2.1-07/08; every infra/DB phase |
| Tier-correct sizing propagation | TC-P1-07 → P3, P4, P9.2 |
| PHI/PII handling (DEV none; QAR/PROD/HFX protected) | TC-P1-05; P3.4, P5.1, P5.3, P7.4/7.5 |
| Access prerequisites (Introduction matrix) | Entry criteria of every phase |
| PROD-only / irreversible steps under change control | P4.1, P10, P11 |
| Documentation static review (links, glossary, screenshots) | TC-P1-11, TC-P2.1-10; every phase |
| Repeatability / second-operator | TC-P1-10, TC-SQL-08; sampled per phase |

## Completion-checklist coverage rule
A phase may not be marked COMPLETE until **every** item in its `Completion Checklist` and every `How to validate` step maps to an executed, passing test case (or a formally risk-accepted Gap Register entry).
