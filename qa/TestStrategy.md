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

### 3.2 Out of Scope
- Functional testing of the Windward application's business features (claims adjudication logic, etc.) beyond what PhaseX UAT covers at an onboarding level.
- Performance/load testing of provisioned infrastructure (covered separately by architecture/perf teams) except Tier-sizing *correctness*.
- Penetration testing of AWS accounts (owned by InfoSec).
- Third-party tool internals (SailPoint, Okta, ServiceNow platform behavior).

### 3.3 Phase Coverage Status
Detailed, executable test cases exist today only for the phases whose full content is available. The rest are covered by the **Traceability Matrix** with planned test-case IDs and `Pending Content` status; they are drafted against each phase's standard sections (`Prerequisites`, `Instructions`, `How to validate`, `Output`, `Completion Checklist`) as content is delivered.

| Phase | Content available | Test cases |
|-------|------------------|-----------|
| Phase 1 — Gather Client & AWS Info | Yes | Detailed (`TC_Phase01_*`) |
| Phase 2.1 — Test AWS Accounts | Yes | Detailed (`TC_Phase02.1_*`) |
| ClientMemCount.sql | Yes | Detailed (`TC_SQL_ClientMemCount_*`) |
| Phase 2, 3.x, 4.x, 5.x, 6.x, 7.x, 8, 9.x, 10, 11, 12, X | Not yet provided | Planned (matrix) |

## 4. Test Approach

### 4.1 Test Types
| Type | What it validates | Where it applies |
|------|-------------------|------------------|
| **Documentation review (static)** | Clarity, completeness, ordering, dead links, glossary consistency, screenshot presence | Every phase |
| **Procedure execution (dynamic, dry-run)** | Steps can be followed end-to-end in a non-prod environment | DEV/QAR phases |
| **Procedure execution (production)** | PROD-only steps (e.g., Phase 4.1 offline, Phase 11 online) under change control | PROD-only phases |
| **Data validation** | Inputs match stakeholder source; generated values match rules | Phase 1, 2.1, naming |
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
