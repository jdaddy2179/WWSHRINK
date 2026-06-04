# Test Strategy — Commercial Client Pilot Playbook (AWS Onboarding & Windward Tenant Creation)

| Field | Value |
|-------|-------|
| Document | Master Test Strategy |
| Scope | Full Playbook (Phase 1 → Phase X) |
| Owner | SQA Team (Joshua Ernstoff, Keerthan Tumuganti) |
| QA Lead | Arun Pant |
| Status | Draft v1.0 |
| Last Updated | 2026-06-04 |

---

## 1. Purpose

This strategy defines **how the Commercial Client Pilot Playbook is validated** — not the software it provisions, but the *playbook itself* as an executable operational procedure. The playbook onboards a new dental client to AWS and creates a corresponding Windward tenant (Business Unit). A "passing" playbook is one where any qualified operator, following the documented steps with the documented inputs, reaches the documented outcome **consistently, safely, and repeatably**.

We are testing three layers:

1. **Documentation correctness** — steps are unambiguous, complete, ordered, and internally consistent (links, references, glossary terms, naming conventions).
2. **Procedural correctness** — executing the steps produces the stated `Output` and satisfies each phase's `How to validate` and `Completion Checklist`.
3. **Outcome correctness** — the provisioned AWS accounts, databases, infrastructure, and Windward tenant match the Environment Variables spreadsheet and architecture (Tier) designs.

## 2. Objectives & Quality Goals

| # | Objective | Measured by |
|---|-----------|-------------|
| O1 | Every phase is independently executable from its `Prerequisites` to its `Completion Checklist` | All `How to validate` checks pass |
| O2 | Inputs are correct, complete, and traceable to a stakeholder source of record | Traceability matrix; Environment Variables spreadsheet audit |
| O3 | Derived/calculated values (Tier, naming conventions, resource IDs) are computed correctly at all boundaries | Boundary & equivalence test cases pass |
| O4 | PHI/PII is handled per policy across DEV/QAR/PROD/HFX | Security test cases pass; no PHI in DEV |
| O5 | Cross-phase dependencies hold; no phase can silently start with unmet prerequisites | Dependency/negative test cases |
| O6 | The playbook is repeatable — a second operator/run yields the same result | Repeatability/idempotency test cases |
| O7 | Known operational gaps (e.g., NBI "TBD") are documented, not silently blocking | Gap register reviewed and risk-accepted |

## 3. Scope

### 3.1 In Scope
- All phases listed in `Introduction.md` (Phase 1 through Phase X — End-to-End/UAT).
- The `ClientMemCount.sql` query (correctness, safety, and result interpretation).
- The Environment Variables spreadsheet as the system of record for inputs and generated values.
- Naming-convention generation and validation across all AWS resources/accounts/databases.
- Tier classification logic.
- Access/permission prerequisites (SharePoint, Azure DevOps, Jira, ServiceNow, SailPoint, AWS).
- Documentation quality (links, cross-references, glossary alignment, screenshots present).
- **Functional testing of the Windward application's business features** for the onboarded tenant — including claims adjudication, payments/financial transactions, eligibility, EDI exchange, correspondence output, reporting (Trusted View), and member-facing portal/mobile flows. Functional testing confirms the deployed tenant behaves correctly end-to-end, not just that components were provisioned. (Aligns with and feeds Phase X UAT.)
- **Performance and load testing of the provisioned tenant infrastructure** — validating that the Tier-sized environment (servers, DB, load balancers) sustains expected member/claims volume within acceptable response times and resource thresholds, including the WW-Shrink-reduced databases. Covers Tier-sizing correctness *and* runtime performance under load.

### 3.2 Out of Scope
- Penetration testing of AWS accounts (owned by InfoSec).
- Third-party tool internals (SailPoint, Okta, ServiceNow platform behavior).

> **Scope change (2026-06-04):** Functional testing of Windward and performance/load testing were moved from Out of Scope into In Scope at stakeholder request. See §4.1 (Functional, Performance/Load test types) and §4.3 entry/exit updates.

### 3.3 Phase Coverage Status
Detailed, executable test cases exist today only for the phases whose full content is available. The rest are covered by the **Traceability Matrix** with planned test-case IDs and `Pending Content` status; they are drafted against each phase's standard sections (`Prerequisites`, `Instructions`, `How to validate`, `Output`, `Completion Checklist`) as content is delivered.

| Phase | Content available | Test cases |
|-------|------------------|-----------|
| Phase 1 — Gather Client & AWS Info | Yes | Detailed (`TC_Phase01_*`) |
| Phase 2.1 — Test AWS Accounts | Yes | Detailed (`TC_Phase02.1_*`) |
| ClientMemCount.sql | Yes | Detailed (`TC_SQL_ClientMemCount_*`) |
| Phase 2, 3.x, 4.x, 5.x, 6.x, 7.x, 8, 9.x, 10, 11, 12, X | Not yet provided | Planned (matrix) |

## 3.4 Workstream Test Breakdown

The Introduction assigns every phase to a **Workstream**. Workstreams run partly in parallel once the Workstream 1 backbone is in place, so testing is planned per workstream: each has its own theme, risk profile, environment/PHI exposure, specialist owners, and entry dependencies. The phase-by-phase coverage lives in `TraceabilityMatrix.md` (which carries a `WS` column); this section is the **workstream lens** over that matrix.

### Workstream dependency model
```
WS1 (backbone: accounts → infra → security → DB → core deploy)
 ├─► WS2  (payments + Oracle)        depends on WS1 DB + core deploy
 ├─► WS3  (EDI + Eligibility Engine) depends on WS1 core app deployed
 ├─► WS4  (TWS jobs, correspondence, Trusted View) depends on WS1 core app + DB
 └─► WS5  (business service, member portal, mobile app) depends on WS1 core app
TBD  (9.1, 9.2, 10, 11, 12, X) — cleanup, PROD cutover, DR, and final E2E/UAT
```
**Testing rule:** no downstream workstream (WS2–WS5) exits until the WS1 phases it depends on are COMPLETE and their test cases pass. Phase X (E2E/UAT) is the joint exit gate across all workstreams.

---

### Workstream 1 — Core Infrastructure, Database & Base Deployment
**Phases:** 1, 2, 2.1, 3, 3.1, 3.2, 3.3, 3.4, 4, 4.1, 4.2, 4.3, 4.5, 5, 5.1, 6
**Theme:** The backbone — gather inputs, stand up AWS accounts/infra/security, build & seed the database (including WW Shrink for WW1.0/Config), and deploy core Windward 1.0 + config + domain services.
**Risk profile:** **Highest.** Contains every P1 driver: Tier derivation (Phase 1), naming conventions, PHI provenance, PROD-only/irreversible steps (4.1 offline), backup/restore integrity (4.2), destructive WW Shrink (4.3), and app security (5.1).
**Environments / PHI:** All four (DEV/QAR/PROD/HFX); PROD + HFX carry PHI; member data enters the DB here.
**Test priorities:** boundary (Tier), data validation (member count, naming), security/compliance (PHI, least privilege, region pinning), change-controlled PROD execution, backup-before-destructive enforcement, repeatability.
**Specialist owners:** Cloud Infra, Kerberos Team, App & Network, InfoSec, DBA, App deploy.
**Entry:** project approved. **Exit gate:** all WS1 phases COMPLETE + passing — this unblocks WS2–WS5.
**Detailed suites today:** 1, 2, 2.1, 3, 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3 (4, 4.5, 5, 5.1, 6 pending content).

### Workstream 2 — Payments & Oracle Financial Integration
**Phases:** 4.4 (WW Payment Shrink), 5.2 (Deploy WW Payments), 5.3 (App Security: Payments), 8 (Oracle Integration)
**Theme:** Everything money — reduce/scope the Payment DB, deploy the Payments app, secure it, and integrate with Oracle financials.
**Risk profile:** **P1 — financial integrity.** Wrong client scoping or lost/duplicated payment records have financial and compliance impact; payment app security guards PHI + financial data.
**Environments / PHI:** DEV→QAR→PROD→HFX; PROD/HFX hold real payment + PHI data.
**Test priorities:** payment-data integrity & reconciliation (4.4), correct client scoping consistent with WS1 (same Purchaser/Group IDs), payment app authZ/secrets (5.3), Oracle data-flow correctness & reconciliation (8), sequential-env order.
**Specialist owners:** DBA (4.4), App deploy (5.2), InfoSec/App security (5.3), Integration/Oracle (8).
**Entry:** WS1 DB + core deploy COMPLETE; **4.4 entry = 4.3 COMPLETE.** **Exit gate:** payments deployed, secured, reconcile with Oracle.
**Detailed suites today:** 4.4 (5.2, 5.3, 8 pending content).

### Workstream 3 — Inbound/Outbound Data (EDI & Eligibility)
**Phases:** 7.2 (EDI Setup), 7.3 (Eligibility Engine Setup)
**Theme:** Claims/eligibility data exchange with external trading partners and the eligibility engine.
**Risk profile:** **P2 — routing & data accuracy.** Mis-routed claims (wrong Payor ID / Trading Partner ID) or wrong eligibility responses affect external partners and members.
**Environments / PHI:** QAR/PROD carry PHI in transit; external boundary increases exposure.
**Test priorities:** Payor ID / Trading Partner ID routing correctness (per Glossary relationships), EDI file round-trips, eligibility response accuracy, error/rejection handling, and security of data in transit.
**Specialist owners:** EDI/Integration team, Eligibility team.
**Entry:** WS1 core app + DB deployed. **Exit gate:** EDI round-trips and eligibility responses validated.
**Detailed suites:** pending content.

### Workstream 4 — Batch Jobs, Correspondence & Reporting
**Phases:** 7 (TWS Jobs), 7.1 (Correspondence Letters), 9 (Trusted View)
**Theme:** Scheduled batch processing (TWS), member/provider correspondence generation, and Trusted View reporting/analytics.
**Risk profile:** **P3 — operational/output correctness.** Failures degrade operations and member communications; correspondence + reporting may expose PHI in generated output.
**Environments / PHI:** QAR/PROD; generated letters and reports can contain PHI → output-handling checks.
**Test priorities:** job scheduling/run/restart & dependency chains (TWS), correct letter templates/data merge and delivery (7.1), report/view accuracy and access control (9), and PHI in generated artifacts.
**Specialist owners:** TWS/Scheduling team, Correspondence team, Reporting/Trusted View team.
**Entry:** WS1 core app + DB deployed. **Exit gate:** jobs run on schedule, correct correspondence, accurate reports.
**Detailed suites:** pending content.

### Workstream 5 — Member-Facing Services
**Phases:** 6.1 (Business Service), 7.4 (Member Portal), 7.5 (Mobile App)
**Theme:** Services and apps members/providers use directly — the externally exposed surface.
**Risk profile:** **P2–P1 for exposure.** Highest *external* PHI exposure: authentication, authorization, session handling, and data isolation must be airtight; a defect here is internet-facing.
**Environments / PHI:** QAR/PROD; member PHI exposed to end users → strongest security testing.
**Test priorities:** authN/authZ, member data isolation (no cross-client/cross-member leakage), session/security headers, portal+mobile parity, accessibility, and business-service health/contracts.
**Specialist owners:** Business Service team, Member Portal team, Mobile App team (+ InfoSec review).
**Entry:** WS1 core app deployed (and business service for portal/mobile). **Exit gate:** secure, isolated member access validated.
**Detailed suites:** pending content.

### TBD — Cleanup, PROD Cutover, DR & Final Acceptance
**Phases:** 9.1 (Provider Copy Job), 9.2 (Remove Extra Disk/CPU), 10 (Remove SLE Data from COM), 11 (Bring COM DB Online — PROD), 12 (Disaster Recovery), X (End-to-End Test & UAT)
**Theme:** Final right-sizing, **irreversible** SLE-data removal from the original COM DB, PROD cutover back online, DR readiness, and the joint end-to-end/UAT gate.
**Risk profile:** **P1 — irreversible + production cutover.** Phase 10 (data removal) and Phase 11 (bring PROD online) are the riskiest non-recoverable actions; Phase X is the cross-workstream acceptance gate.
**Environments / PHI:** PROD-critical; PHI throughout.
**Test priorities:** scope/correctness of SLE removal (no over-deletion, backups verified), right-size with no service impact (9.2), PROD online integrity + change control (11), DR failover/restore drill (12), and full onboarding acceptance (X).
**Workstream note:** the Introduction marks these **TBD** for workstream ownership — an open assignment gap; testing ownership for 10/11 (irreversible PROD) should be confirmed with the QA Lead before execution (see Gap Register).
**Detailed suites:** pending content.

---

### Per-Workstream coverage status
| Workstream | Phases | Detailed suites authored | Pending content |
|-----------|--------|--------------------------|-----------------|
| WS1 | 16 | 1, 2, 2.1, 3, 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3 | 4, 4.5, 5, 5.1, 6 |
| WS2 | 4 | 4.4 | 5.2, 5.3, 8 |
| WS3 | 2 | — | 7.2, 7.3 |
| WS4 | 3 | — | 7, 7.1, 9 |
| WS5 | 3 | — | 6.1, 7.4, 7.5 |
| TBD | 6 | — | 9.1, 9.2, 10, 11, 12, X |

> Hand-off phases in WS2–WS5 reuse `TC-HO-01..09` from `test-cases/TC_PATTERN_JiraHandoffPhase.md`; concise per-phase suites are being authored (per agreed approach).

## 4. Test Approach

### 4.1 Test Types
| Type | What it validates | Where it applies |
|------|-------------------|------------------|
| **Documentation review (static)** | Clarity, completeness, ordering, dead links, glossary consistency, screenshot presence | Every phase |
| **Procedure execution (dynamic, dry-run)** | Steps can be followed end-to-end in a non-prod environment | DEV/QAR phases |
| **Procedure execution (production)** | PROD-only steps (e.g., Phase 4.1 offline, Phase 11 online) under change control | PROD-only phases |
| **Data validation** | Inputs match stakeholder source; generated values match rules | Phase 1, 2.1, naming |
| **Functional testing** | Deployed tenant behaves correctly end-to-end: claims adjudication, payments, eligibility, EDI, correspondence, reporting, member portal/mobile flows | Post-deploy (WS2–WS5), consolidated at Phase X |
| **Performance / load testing** | Tier-sized environment sustains expected member/claims volume within response-time & resource thresholds (incl. WW-Shrink-reduced DBs) | Phase 3/4 sizing, post-deploy, Phase X |
| **Boundary & equivalence** | Tier thresholds, member-count edges | Phase 1 (Tier), SQL |
| **Negative / error-path** | Missing prereqs, wrong inputs, access denied, wrong region | All phases with prereqs |
| **Security / compliance** | PHI handling, US-based access, least privilege, region pinning | Phase 1, 2.1, 4.x |
| **Repeatability / idempotency** | Re-running or second operator yields same result | Whole playbook |
| **Traceability** | Every documented input/output maps to a test | All phases |
| **Regression** | Re-validate prior phases after playbook edits | On any playbook change |

### 4.2 Techniques
- **Equivalence partitioning & boundary value analysis** for Tier and member-count logic.
- **Decision tables** for branching steps (e.g., existing vs. new client; single- vs. multi-tenant; new vs. existing IAM role; Jumbo client data-isolation).
- **Checklist-driven verification** mirroring each phase's `Completion Checklist`.
- **Cross-reference linting** of `[...](...)` links, `REF[...]` markers, and glossary terms.
- **Four-eyes review** for any step touching PROD or PHI.

### 4.3 Entry & Exit Criteria (per phase)
**Entry:** all `Prerequisites` met and verified; required access granted (per Introduction access matrix); prior phase `Completion Checklist` is COMPLETE; test data/environment available.

**Exit:** all in-scope test cases executed; all `How to validate` checks pass; `Completion Checklist` deliverables COMPLETE; defects either fixed-and-retested or formally risk-accepted; results recorded.

**Functional & performance gates (deployment and post-deployment phases):** for any phase that deploys or configures a runnable component (WS1 Phase 5/6; WS2 Phase 5.2/8; WS3 EDI/EE; WS4 jobs/correspondence/reporting; WS5 business service/portal/mobile), the phase additionally exits only when its **functional** test cases pass for the tenant, and the environment meets its **performance/load** thresholds for the Tier. These culminate in **Phase X (E2E/UAT)** as the joint functional + performance acceptance gate across all workstreams.

## 5. Test Environments & Data

| Environment | PHI/PII | Test usage | Notes |
|-------------|---------|-----------|-------|
| **DEV (D)** | None | Free-form procedure dry-runs | No PHI may ever appear here — explicit negative check |
| **QAR (T)** | May contain PHI (COM) | Primary functional validation | Treat as PHI-bearing for access controls |
| **HFX** | PHI/PII | Prod-like validation for protected non-prod scenarios | Use when a prod-like protected env is required |
| **PROD** | PHI | PROD-only steps + member-count source of truth | US-based authorized access only; change-controlled |

**Test data principles:**
- Member counts and any PHI-derived values must be produced by a **US-based team member with authorized PROD access** (per Phase 1).
- Use representative client profiles spanning all three Tiers (a <100K, a 100K–1M, and a 1M+ client) plus **boundary** profiles (exactly 99,999 / 100,000 / 999,999 / 1,000,000).
- Maintain a "golden" reference client (e.g., a known purchaser_gid with a verified expected count) to regression-test `ClientMemCount.sql`.

## 6. Roles & Responsibilities (RACI)

| Activity | Responsible | Accountable | Consulted | Informed |
|----------|-------------|-------------|-----------|----------|
| Test strategy & cases | SQA Team | Arun Pant (QA Lead) | Architects, AJ Schmucker | PMO |
| Phase 1 data validation | SQA | Arun Pant | Architect, NBI, Finance | PMO |
| AWS account validation (Phase 2.1) | SQA | Arun Pant | Cloud Infra (Erik, Lindsay), InfoSec (Jamie Smith) | PMO |
| SQL query validation | SQA / DBA | Arun Pant | AJ Schmucker | PMO |
| PROD-only steps sign-off | DBA/Infra | Change Manager | InfoSec | Client |
| Security/PHI compliance | InfoSec (Jamie Smith) | Elie Abouzeid | SQA | PMO |
| UAT (Phase X) | Business/SQA | Arun Pant | Client | PMO |

## 7. Risk-Based Prioritization

| Priority | Criteria | Examples |
|----------|----------|----------|
| **P1 — Critical** | Touches PROD, PHI/PII, irreversible actions, or wrong-value-propagates-everywhere | Member-count accuracy, Tier calc, naming convention, Phase 4.1 DB offline, Phase 10 SLE data removal, Phase 11 bring-online |
| **P2 — High** | Blocks downstream phases or core provisioning | AWS account creation/validation, DB backup/restore, WW Shrink, replication |
| **P3 — Medium** | Configuration/feature setup with rework cost | TWS jobs, EDI, EE, portals, Trusted View |
| **P4 — Low** | Cosmetic/documentation | Link rot, screenshot freshness, glossary wording |

Highest-risk areas (test first, test hardest): **member-count & Tier derivation**, **AWS naming-convention validation**, **PHI/access controls**, and **all PROD-only / irreversible steps**.

## 8. Defect Management

- **Severity:** S1 (blocks onboarding / data loss / PHI exposure) → S4 (cosmetic).
- **Defect types unique to a playbook:** ambiguity, missing step, wrong order, broken link, stale screenshot, contradictory instruction, undocumented gap, missing rollback.
- Every defect references the **phase, step number, and test-case ID**.
- S1/S2 require fix + full retest of the affected phase and a regression pass on dependent phases before exit.
- **Operational gaps** explicitly flagged as `TBD` in the playbook (e.g., NBI process, several "Target Future State" sections) are logged in the **Gap Register** (Section 11) and must be risk-accepted by the QA Lead rather than treated as pass.

## 9. Traceability

All requirements (every documented input, output, validation check, and completion-checklist item) map to at least one test case in **`TraceabilityMatrix.md`**. No phase exits with an unmapped `How to validate` item.

## 10. Deliverables

| Artifact | Location |
|----------|----------|
| Master Test Strategy (this doc) | `qa/TestStrategy.md` |
| Traceability Matrix | `qa/TraceabilityMatrix.md` |
| Test Case Template | `qa/templates/TestCaseTemplate.md` |
| Detailed Test Cases | `qa/test-cases/` |
| Test Execution Log / Results | `qa/test-cases/` (Execution Record per case) |
| Gap & Risk Register | Section 11 below + per-phase Common Issues tables |

## 11. Gap & Risk Register (living)

| ID | Gap / Risk | Source | Impact | Disposition |
|----|-----------|--------|--------|-------------|
| G1 | NBI process for **new** clients is `TBD` (Phase 1, member count) | Phase01 | New clients cannot get a member count → cannot derive Tier | Risk-accept until NBI defined; block new-client onboarding |
| G2 | `ClientMemCount.sql` returns a **single** count, but Phase 1 asks to record **both total and active** counts | SQL vs Phase01 | Ambiguity → wrong Tier or wrong "active" figure | Raise defect; clarify query/definition (see `TC_SQL_ClientMemCount`) |
| G3 | Windward 5-year purge "not clear if running in commercial" | SQL header | Count may include data that should be purged → Tier inflation | Confirm with AJ; document assumption |
| G4 | Tier assumption: based **strictly** on member count, ignoring provider/claims volume | Phase01 Step2 | Under/over-sizing for atypical clients | Documented assumption; revisit per architecture |
| G5 | Many phases have `Target Future State = To be determined` | Multiple | Future-state validation undefined | Track; not a release blocker for pilot |
| G6 | PROD account may need a separate request via InfoSec (Phase 2.1 #10a) | Phase02.1 | Delay/missed account | Negative test + checklist item |
| G7 | Phases 7.1, 7.2, 7.3, 7.4, 7.5, 8 are **unfilled placeholder templates** (no titles/AC/owners/links) | Phase07.x, 08 | Not testable; high latent risk (EDI/EE PHI routing; portal/mobile external PHI exposure) | Blocked for QA authoring until real content supplied; must not be marked COMPLETE on an empty template |
| G8 | Workstream ownership for Phases 9.1, 9.2, 10, 11, 12, X marked **TBD** in Introduction | Introduction | Unowned testing for irreversible PROD steps (10/11) | Confirm QA ownership with QA Lead before execution |
| G9 | Recurring playbook doc defects: broken cross-links (5.2→`Phase05_DeployWWApplications.md`; 4.3→`Phase03.3_Infosec_IT_Intake.md`; 6.1→`Phase03.1_Infosec.md`), missing AC (5.1/5.3), "reduce EBS size" vs AWS limit (9.2), 4.1 PROD-vs-HFX inconsistency | Multiple | Operator confusion, wrong refs | Logged per-suite as `D-*`; batch-fix recommended |

## 12. Schedule & Milestones (template)

| Milestone | Gate |
|-----------|------|
| Strategy approved | QA Lead sign-off |
| Phase 1–2.1 detailed cases executed | Pilot data ready |
| SQL query validated against golden client | DBA sign-off |
| Remaining phase content delivered | Author handoff |
| Full dry-run (DEV/QAR) | Pre-PROD gate |
| PROD-only steps under change control | Change board |
| PhaseX UAT | Client sign-off |

## 13. Assumptions & Dependencies
- The Environment Variables spreadsheet (`Master_Sheet`) is the authoritative source for naming rules and generated values.
- Architecture Tier designs (`../architecture`) are current and approved.
- Required tool access is granted per the Introduction access matrix before each phase begins.
- Stakeholder contacts named in the playbook are reachable and authoritative.

---

*See `TraceabilityMatrix.md` for phase-by-phase coverage and `test-cases/` for executable cases.*
