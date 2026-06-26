# Test Cases — Phase 4: WW Shrink for WW1.0 and Config

| Field | Value |
|-------|-------|
| Playbook reference | `Phase04_WWShrinkWW1AndConfig.md` (Steps 1–2) — **restructured 2026‑06: old Phase 4.3 is now the main Phase 4** |
| Priority | **P1 — destructive/irreversible** (original WW_Commercial replaced with reduced client‑only DB) |
| Type | Jira hand‑off + data scoping + safety + integrity |
| Owner | SQA (validation, Step 2 — **Joshua Ernstoff, Keerthan Tumuganti**); WW Shrinker Owner executes (Step 1 — Nabeel Syed) |

> **Core of the WWSHRINK effort.** The shrinker reduces the Windward DB to a single client's data using Purchaser/Parent‑Group/Sub‑Group IDs. Wrong IDs → wrong data kept or **client data loss**. The original DB is **replaced** — backups (Phase 4.1) are the only safety net.

> **Sequence note (new):** Phase 4 (Shrink) now runs **before** Phase 4.1 (DB Setup & Migration). Per the restructured playbook, 4.1's prerequisites require Phase 4 complete.

**Applies `TC-HO-01..09`** from [`TC_PATTERN_JiraHandoffPhase.md`](../_shared/TC_PATTERN_JiraHandoffPhase.md):
- **Step 1 Title:** `Shrink Windward 1.0 & Config Databases - REF[Tenant Name]`; AC: "Windward Database Shrinker executed successfully for WW1.0 & Config under REF[Environment], size reduced per specs, validation completed".
- **Step 2 Title:** `Validate Windward Database Shrink Results for WW1.0 & Config - REF[Tenant Name] [ENVIRONMENT]`.
- **Step 1 assignee:** WW Shrinker Owner (Nabeel Syed). **Step 2 assignee:** SQA (Joshua, Keerthan; mgr Arun Pant).
- **TC-HO-07 sequential env applies (DEV→QAR→PROD→HFX, separate tickets).**

### Preconditions
- Phases 3, 3.4 COMPLETE. DQ Jira + Env Variables access.
- **Data-scoping inputs documented in Env Variables** (Step 1 prereq table):
  WindwardDatabaseName, ConfigDatabaseName, PaymentDatabaseName (Generated); **Purchaser_ID, Parent_Group_ID, Sub_Group_ID** (Manual, from `DL-ClientSet-Up@greatdentalplans.com` / Mandy Willms; single or comma-separated).
- **NA rule (new):** per the playbook note, `Parent_Group_ID` and `Sub_Group_ID` may be recorded as **NA** when the `Purchaser_ID` already encompasses all associated parent/sub groups.

---

### TC-P4-01 (CRITICAL — Safety): Verified backup exists before shrink
**Objective:** Because the original WW_Commercial is replaced, confirm a validated backup (Phase 4.1 DB Setup/Migration) exists and is restorable before any shrink.

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm a backup is COMPLETE & integrity-validated for the env | Backup present & verified |
| 2 | Confirm restore path is known/tested | Recoverable |
| 3 | Block shrink if no verified backup | Hard stop |

**Pass/Fail:** No shrink proceeds without a verified, restorable backup. Missing = Fail (S1).

### TC-P4-02 (CRITICAL — Tier applicability gate): Shrink only for small/Tier‑3 BUs
**Objective:** Playbook: shrink "only applicable for smaller business units with limited member populations, such as KCL (Tier 3)."

| # | Client | Expected |
|---|--------|----------|
| 1 | Tier 3 (e.g., KCL) | Shrink **applies** |
| 2 | Tier 1 / Tier 2 | Shrink **does not apply** — do not run (confirm with architect) |

**Pass/Fail:** Applicability decision matches Tier. Running shrink on a non-Tier-3 client without sign-off = Fail.

### TC-P4-03 (CRITICAL — Data scoping correctness): Purchaser/Parent/Sub‑Group IDs correct & complete
**Objective:** These IDs define which data is **kept**. Errors cause kept-wrong-client or dropped-valid data. **Ties to bug CCP‑1897** (KCL IDs were SLE‑cloned; now `tbd` pending Mandy Willms).

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Verify Purchaser_ID(s) from Mandy Willms / `DL-ClientSet-Up` match the client | Exact (not the SLE `090033` example) |
| 2 | Verify Parent_Group_ID(s) complete — **or correctly marked NA** if encompassed by Purchaser_ID | Complete or valid NA |
| 3 | Verify Sub_Group_ID(s) complete — **or correctly marked NA** (often a long comma-separated list — none omitted) | Full list / valid NA, correct format |
| 4 | Cross-check IDs vs an independent client definition (e.g., NBI / ClientMemCount lineage) | Consistent |
| 5 | Confirm comma-separated formatting parses as intended | No malformed/space-broken IDs |

**Pass/Fail:** All scoping IDs correct, complete, well-formed (or validly NA). Any gap = Fail (S1 — data correctness). **Gated by CCP‑1897 until KCL's real IDs are confirmed.**

### TC-P4-04 (CRITICAL — Data integrity post‑shrink): Verify_Shrink_Results.sql passes; no missing recent data
**Primary tool (KCL):** [`qa/automation/WWShrink_KCL_SourceTarget_Reconciliation.sql`](../../automation/WWShrink_KCL_SourceTarget_Reconciliation.sql) — reconciles the KCL member set between `windward_commercial` (source) and `windward_KCL` (shrunk target) on `AWWW2SQLKCL01D`, scoped to the KCL purchaser set ([`KCL_Purchasers_discovery.sql`](../../automation/KCL_Purchasers_discovery.sql), TC-P4-03). One execution returns a `PASS`/`FAIL` verdict for **both TOTAL and ACTIVE** scopes plus row-level diffs. This is the clean KCL replacement for the SLE-hardcoded `Verify_Shrink_Results.sql` (D-P4-2).

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Run the shrink-verification query (see TC-P4-09 for location/parameterization) | Run State = `Succeeded`, no failed steps |
| 2 | Run `WWShrink_KCL_SourceTarget_Reconciliation.sql`; read the verdict rows | `reconciliation_result = PASS` for TOTAL **and** ACTIVE (`count_delta = 0`) |
| 3 | Confirm reduced DB contains **only** the target client's data | Section 5 (`extra_member...`) returns **0 rows** — no other clients' data leaked in |
| 4 | Confirm target client's data is **complete** — members not missing | Section 4 (`lost_member...`) returns **0 rows**; Section 6 (active-status mismatch) returns 0 rows |
| 5 | Spot-check known members for the client are present | Present |

**Pass/Fail:** Reduced DB = exactly the client's complete data, nothing extra, nothing missing. Reconciliation `PASS` for both scopes with all three diagnostic sections empty.

### TC-P4-05 (Metrics): Before/after size documented and reduction confirmed
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Shrinker Owner documents DB size before & after in Step 1 ticket | Both recorded |
| 2 | SQA confirms meaningful reduction per specs (file-size section of the verify query) | Confirmed |

**Pass/Fail:** Size reduction documented and validated.

### TC-P4-06 (Connectivity): Reduced DB reachable/usable
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | SQA tests connectivity/accessibility post-shrink (SSMS, per Phase 4.1 Step 2) | OK |

**Pass/Fail:** Connectivity confirmed.

### TC-P4-07 (Linkage & defect flow): Step 2 ticket linked; bugs routed to Shrinker Owner
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Step 2 validation story linked to Step 1 ("relates to"/"validates") | Linked |
| 2 | Any issue (unexpected size, missing recent data, execution errors) → bug on backlog assigned to WW Shrinker Owner (Nabeel Syed) | Routed |

**Pass/Fail:** Traceable linkage and defect routing.

### TC-P4-08 (Sequential env + scope note): Per‑env order; high‑level validation only
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Separate run+validate per env DEV→QAR→PROD→HFX | Order honored |
| 2 | Acknowledge validation is high-level; deep functional/data validation deferred to **Phase X – Environment Testing** | Noted |

**Pass/Fail:** Order honored; scope boundary understood.

### TC-P4-09 (CRITICAL — DOC/SCRIPT DEFECT): Verify_Shrink_Results.sql wrong path **and** hardcoded to SLE database
**Objective:** The playbook's Step 2 links the verification script as `Testing/Verify_Shrink_Results.sql`, but the file actually lives at **`qa/Archive/Verify_Shrink_Results.sql`** (broken link). The script also hardcodes the **SLE** database: `USE Windward_Commercial_SunLife;` and `USE TempDB_WW;`.

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Follow the Step 2 `Testing/Verify_Shrink_Results.sql` link | 404 — confirm broken link (D-P4-1) |
| 2 | Inspect the script's `USE` statements | `Windward_Commercial_SunLife` hardcoded — must be re-pointed to **`Windward_KCL`** (`REF[WindwardDatabaseName]`) for KCL, else the verify runs against the wrong DB (D-P4-2) |
| 3 | Confirm the script is parameterized per client/env before SQA uses it | Re-pointed to the client's shrunk DB |

**Pass/Fail:** Broken link fixed and script re-pointed to the client DB before validation. Running the SLE-hardcoded script as-is = Fail (validates the wrong database — same SLE-clone class as CCP‑1897/1898).

### TC-P4-10 (DOC DEFECT): Prerequisite & checklist errors in Phase 4 playbook
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Step 1 Prereq #1 links Phase 3.3 as `Phase03.3_Infosec_IT_Intake.md` | Verify intended target (InfoSec/IT‑Intake) vs Phase 3.3/3.4 numbering (D-P4-3) |
| 2 | Completion-checklist header reads "Upon successful completion of Phase **4.3**" | Should read **Phase 4** (D-P4-4) |
| 3 | QA/Testing References → "Phase Test Cases: **TBD**" | Should link this suite (D-P4-5) |

**Pass/Fail:** Doc defects logged; not a blocker for execution but tracked for fix.

---

## Completion Checklist Coverage
| Deliverable | Covered by |
|-------------|-----------|
| Scoping data (Purchaser/Parent/Sub‑Group, incl. NA rule) documented | TC-P4-03 |
| Shrink tickets created/assigned to WW Shrinker Owner | TC-HO-01..06 |
| Shrinker executed successfully | TC-P4-02, 04 |
| Before/after size documented | TC-P4-05 |
| Validation tickets created/assigned to SQA & linked | TC-P4-07 |
| Size reduction confirmed | TC-P4-05 |
| Results documented; bugs raised as needed | TC-P4-04, 07 |

## Defects / Observations
| ID | Observation | Severity |
|----|-------------|----------|
| D-P4-1 | Step 2 links `Testing/Verify_Shrink_Results.sql` — file is at `qa/Archive/Verify_Shrink_Results.sql` (broken link) | S3 |
| D-P4-2 | `Verify_Shrink_Results.sql` hardcodes `Windward_Commercial_SunLife` / `TempDB_WW` — must be re-pointed to the client's shrunk DB (`Windward_KCL`) before use | **S1** |
| D-P4-3 | Prereq links Phase 3.3 as `Phase03.3_Infosec_IT_Intake.md` — verify against current Phase 3.x numbering | S3 |
| D-P4-4 | Completion-checklist header says "Phase 4.3" (copy-paste); should be "Phase 4" | S4 |
| D-P4-5 | QA/Testing References → "Phase Test Cases: TBD" (missing link to this suite) | S4 |
| D-P4-6 | Destructive replace with backup as only safety net — backup verification must be enforced, not assumed | S2 |
| D-P4-7 | Playbook example scoping IDs are the SLE values (`090033`, `0900331001`, `0900332001‑12`) — label "example only" to avoid re-cloning (see CCP‑1897) | S2 |

## Execution Record
| TC | Date | Tester | Env | Result | Defect | Notes |
|----|------|--------|-----|--------|--------|-------|
| TC-P4-01 | | | | | | |
| TC-P4-02 | | | | | | |
| TC-P4-03 | | | | | | |
| TC-P4-04 | | | | Pending exec | | Tool ready: `WWShrink_KCL_SourceTarget_Reconciliation.sql` (purchaser-scoped, source vs target, TOTAL+ACTIVE). Awaiting operator run on AWWW2SQLKCL01D |
| TC-P4-05 | | | | | | |
| TC-P4-06 | | | | | | |
| TC-P4-07 | | | | | | |
| TC-P4-08 | | | | | | |
| TC-P4-09 | | | | | | |
| TC-P4-10 | | | | | | |

---

## Playbook Reference
This suite validates the playbook item **[Phase04_WWShrinkWW1AndConfig.md](https://dev.azure.com/EnterpriseRepo/Application%20Services/_git/com-client-pilot?path=/Playbook/Phase04_WWShrinkWW1AndConfig.md&version=GBmain)** (`com-client-pilot/Playbook/`).

Related: [Jira ↔ Playbook matrix](../../JiraPlaybookMatrix.md) · [Test Strategy](../../TestStrategy.md) · [Traceability Matrix](../../TraceabilityMatrix.md) · [`WWShrink_KCL_SourceTarget_Reconciliation.sql`](../../automation/WWShrink_KCL_SourceTarget_Reconciliation.sql) · [`KCL_Purchasers_discovery.sql`](../../automation/KCL_Purchasers_discovery.sql) · [`Verify_Shrink_Results.sql`](../../Archive/Verify_Shrink_Results.sql)
