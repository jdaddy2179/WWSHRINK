# Test Cases — Phase 4.3: WW Shrink for WW1.0 and Config

| Field | Value |
|-------|-------|
| Playbook reference | `Phase04.3_WWShrinkWW1.0AndConfig.md` (Steps 1–2) |
| Priority | **P1 — destructive/irreversible** (original WW_Commercial replaced with reduced client-only DB) |
| Type | Jira hand-off + data scoping + safety + integrity |
| Owner | SQA (validation, Step 2); DBA Team executes (Step 1) |

> **Core of the WWSHRINK effort.** The shrinker reduces the Windward DB to a single client's data using Purchaser/Parent-Group/Sub-Group IDs. Wrong IDs → wrong data kept or **client data loss**. The original DB is **replaced** — backups (Phase 4.2) are the only safety net.

**Applies `TC-HO-01..09`** from [`TC_PATTERN_JiraHandoffPhase.md`](../_shared/TC_PATTERN_JiraHandoffPhase.md):
- **Step 1 Title:** `Windward Database Shrinking - REF[Tenant Name]`; AC: "Windward Database Shrinker executed successfully for REF[Environment], size reduced per specs, validation completed".
- **Step 2 Title:** `Validate Windward Database Shrink Results - REF[Tenant Name] [ENVIRONMENT]`.
- **Step 1 assignee:** DBA Team (Vasudha). **Step 2 assignee:** SQA (Joshua, Keerthan; mgr Arun Pant).
- **TC-HO-07 sequential env applies (DEV→QAR→PROD→HFX, separate tickets).**

### Preconditions
- Phases 3, 3.4, 4, 4.1 (PROD), 4.2 COMPLETE. DQ Jira + Env Variables access.
- **Data-scoping inputs documented in Env Variables** (Step 1 prereq table):
  WindwardDatabaseName, ConfigDatabaseName, PaymentDatabaseName (Generated, from AJ); Purchaser_ID, Parent_Group_ID, Sub_Group_ID (Manual, from Mandy Willms/AJ; single or comma-separated).

---

### TC-P4.3-01 (CRITICAL — Safety): Verified backup exists before shrink
**Objective:** Because the original WW_Commercial is replaced, confirm a validated backup (Phase 4.2) exists and is restorable before any shrink.

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm Phase 4.2 backup COMPLETE & integrity-validated for the env | Backup present & verified |
| 2 | Confirm restore path is known/tested | Recoverable |
| 3 | Block shrink if no verified backup | Hard stop |

**Pass/Fail:** No shrink proceeds without a verified, restorable backup. Missing = Fail (S1).

### TC-P4.3-02 (CRITICAL — Tier applicability gate): Shrink only for small/Tier-3 BUs
**Objective:** Playbook: shrink "only applicable for smaller business units with limited member populations, such as SLE (Tier 3)."

| # | Client | Expected |
|---|--------|----------|
| 1 | Tier 3 (e.g., SLE) | Shrink **applies** |
| 2 | Tier 1 / Tier 2 | Shrink **does not apply** — do not run (confirm with architect) |

**Pass/Fail:** Applicability decision matches Tier. Running shrink on a non-Tier-3 client without sign-off = Fail.

### TC-P4.3-03 (CRITICAL — Data scoping correctness): Purchaser/Parent/Sub-Group IDs correct & complete
**Objective:** These IDs define which data is **kept**. Errors cause kept-wrong-client or dropped-valid data.

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Verify Purchaser_ID(s) from Mandy Willms/AJ match the client | Exact |
| 2 | Verify Parent_Group_ID(s) complete | All groups present |
| 3 | Verify Sub_Group_ID(s) complete (often a long comma-separated list — none omitted) | Full list, correct format |
| 4 | Cross-check IDs vs an independent client definition (e.g., NBI / ClientMemCount lineage) | Consistent |
| 5 | Confirm comma-separated formatting parses as intended | No malformed/space-broken IDs |

**Pass/Fail:** All scoping IDs correct, complete, well-formed. Any gap = Fail (S1 — data correctness).

### TC-P4.3-04 (CRITICAL — Data integrity post-shrink): Verify_Shrink_Results.sql passes; no missing recent data
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Run `Testing/Verify_Shrink_Results.sql` (Step 2 link) | Pass per spec |
| 2 | Confirm reduced DB contains **only** the target client's data | No other clients' data remains |
| 3 | Confirm target client's data is **complete** — members, recent activity, claims not missing | Complete |
| 4 | Spot-check known members for the client are present | Present |

**Pass/Fail:** Reduced DB = exactly the client's complete data, nothing extra, nothing missing.

### TC-P4.3-05 (Metrics): Before/after size documented and reduction confirmed
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | DBA documents DB size before & after in Step 1 ticket | Both recorded |
| 2 | SQA confirms meaningful reduction per specs | Confirmed |

**Pass/Fail:** Size reduction documented and validated.

### TC-P4.3-06 (Connectivity): Reduced DB reachable/usable
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | SQA tests connectivity/accessibility post-shrink | OK |

**Pass/Fail:** Connectivity confirmed.

### TC-P4.3-07 (Linkage & defect flow): Step 2 ticket linked; bugs routed to DBA
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Step 2 validation story linked to Step 1 ("relates to"/"validates") | Linked |
| 2 | Any issue (unexpected size, missing data, errors) → bug on backlog assigned to DBA | Routed |

**Pass/Fail:** Traceable linkage and defect routing.

### TC-P4.3-08 (Sequential env + scope note): Per-env order; high-level validation only
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Separate run+validate per env DEV→QAR→PROD→HFX | Order honored |
| 2 | Acknowledge validation is high-level; deep functional/data validation deferred to Phase 10 | Noted |

**Pass/Fail:** Order honored; scope boundary understood.

### TC-P4.3-09 (DOC DEFECT): Broken/incorrect prerequisite reference
**Objective:** Step 1 Prereq #1 links Phase 3.3 as `Phase03.3_Infosec_IT_Intake.md`, but Phase 3.3 is **Certificates** and the InfoSec/IT-Intake content is **Phase 3.4** (`Phase03.4_Infrastructure_Security.md`).

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Follow the Prereq link | Wrong/broken target confirmed |

**Pass/Fail:** Defect D-P4.3-1 logged; correct reference should be Phase 3.4.

---

## Completion Checklist Coverage
| Deliverable | Covered by |
|-------------|-----------|
| Scoping data (Purchaser/Parent/Sub-Group) documented | TC-P4.3-03 |
| Shrink tickets created/assigned to DBA | TC-HO-01..06 |
| Shrinker executed successfully | TC-P4.3-02, 04 |
| Before/after size documented | TC-P4.3-05 |
| Validation tickets created/assigned to SQA & linked | TC-P4.3-07 |
| Size reduction confirmed | TC-P4.3-05 |
| Results documented; bugs raised as needed | TC-P4.3-04, 07 |

## Defects / Observations
| ID | Observation | Severity |
|----|-------------|----------|
| D-P4.3-1 | Prereq links Phase 3.3 as `Phase03.3_Infosec_IT_Intake.md` (wrong; InfoSec is 3.4) | S3 |
| D-P4.3-2 | Destructive replace with backup as only safety net — backup verification must be enforced, not assumed | S2 |

## Execution Record
| TC | Date | Tester | Env | Result | Defect | Notes |
|----|------|--------|-----|--------|--------|-------|
| TC-P4.3-01 | | | | | | |
| TC-P4.3-02 | | | | | | |
| TC-P4.3-03 | | | | | | |
| TC-P4.3-04 | | | | | | |
| TC-P4.3-05 | | | | | | |
| TC-P4.3-06 | | | | | | |
| TC-P4.3-07 | | | | | | |
| TC-P4.3-08 | | | | | | |
| TC-P4.3-09 | | | | | | |

---

## Playbook Reference
This suite validates the playbook item **[Phase04.3_WWShrinkWW1.0AndConfig.md](https://dev.azure.com/EnterpriseRepo/Application%20Services/_git/com-client-pilot?path=/Playbook/Phase04.3_WWShrinkWW1.0AndConfig.md&version=GBmain)** (`com-client-pilot/Playbook/`).

Related: [Jira ↔ Playbook matrix](../../JiraPlaybookMatrix.md) · [Test Strategy](../../TestStrategy.md) · [Traceability Matrix](../../TraceabilityMatrix.md)
