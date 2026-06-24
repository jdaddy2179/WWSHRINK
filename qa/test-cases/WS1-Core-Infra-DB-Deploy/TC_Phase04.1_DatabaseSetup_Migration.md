# Test Cases — Phase 4.1: Database Setup and Migration

| Field | Value |
|-------|-------|
| Playbook reference | `Phase04.1_DatabaseSetup_Migration.md` (Steps 1–2) — **consolidates the former Phase 4 (Setup DBs) + 4.1 (Bring COM Offline) + 4.2 (Backup/Restore)** |
| Priority | **P1 — DB foundation + data integrity + disruptive PROD operation** |
| Type | Jira hand-off + data integrity + change control + connectivity validation |
| Owner | DBA Team executes (setup, backup, restore, always-on, bring COM offline); **SQA validates connectivity** (Joshua, Keerthan; mgr Arun Pant) |

> **Scope (new structure):** one DBA hand-off ticket covers **database setup, backup, restore, always-on, and bringing the COM database offline (PROD/HFX only)**. Shrinking is Phase 4 (runs **before** this), replication is Phase 4.2. SQA's role here is **Step 2 — validate database connectivity**.

**Applies `TC-HO-01..09`** from [`TC_PATTERN_JiraHandoffPhase.md`](../_shared/TC_PATTERN_JiraHandoffPhase.md):
- **Step 1 Title:** `Complete Database Setup - REF[Tenant Name]`; AC: "Databases created and configured on all SQL Server instances, database names documented in Environment Variables spreadsheet, and database connectivity validated".
- **Step 1 assignee:** DBA Team (Vasudha Ramakrishnan, Anthony Kearney; mgr Chris Jones). **One ticket per env; Tier reference required.**
- **Step 2 (connectivity validation) assignee:** SQA (Joshua, Keerthan; mgr Arun Pant).
- **TC-HO-07 sequential env applies (DEV→QAR→PROD→HFX, separate tickets).**

### Preconditions
- Phase 3 COMPLETE; SQL Server instances installed; DB servers provisioned. **Phase 4 (WW Shrink) COMPLETE** (new prerequisite).
- For PROD/HFX offline: an **approved maintenance window** scheduled with business stakeholders.
- DQ Jira + ADO + Env Variables access.

---

## Step 1 — Database Setup, Backup/Restore, Always-On, COM Offline (DBA)

### TC-P4.1-01 (Tier — DB config): Databases created/sized per Tier architecture
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm DB names/sizes/configs follow the Tier-appropriate database-tier spec (windward-1.0 / 2.0 architecture) | Matches Tier |
| 2 | Confirm database names documented in Env Variables (no `REF[]`, correct per client) | Recorded |

**Pass/Fail:** DBs configured per Tier and documented.

### TC-P4.1-02 (CRITICAL — Backup completeness): Config, Payment, Windward all backed up
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm Config (`REF[ConfigDatabaseName]`), Payment (`REF[PaymentDatabaseName]`), Windward (`REF[WindwardDatabaseName]`) all backed up | All 3 present |
| 2 | Confirm names resolved from Env Variables (correct per client — not SLE) | Correct names |

**Pass/Fail:** All three DBs backed up with correct client-specific names.

### TC-P4.1-03 (CRITICAL — Backup integrity): Integrity validated & documented
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | DBA validates backup integrity (`RESTORE VERIFYONLY` / checksum) | Pass |
| 2 | Backup file locations, sizes, timestamps documented in ticket | Recorded |

**Pass/Fail:** Integrity verified and evidence documented.

### TC-P4.1-04 (CRITICAL — Restore completeness + integrity): All three DBs restored & verified
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm target = `REF[windward-database-server]` (01); Config, Payment, Windward all restored | All 3 on correct server |
| 2 | DBA runs integrity checks (`DBCC CHECKDB`); row counts / key objects sanity-checked vs source | Pass, no corruption, consistent |
| 3 | Permissions/access configured post-restore (least-privilege, correct logins) | Configured |

**Pass/Fail:** Restored DBs complete, pass integrity, match source, permissions set.

### TC-P4.1-05 (CRITICAL — Env gating, COM offline): Offline restricted to PROD/HFX only
**Objective:** Bringing the COM database offline must NEVER be performed for DEV/QAR.

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm offline task targets PROD (or HFX) | Correct env |
| 2 | Attempt to scope offline for DEV/QAR | Rejected — applies to PROD/HFX only |
| 3 | Confirm target = `Windward_Commercial` (COM); no unrelated DB offlined | Scope correct |

**Pass/Fail:** Only PROD/HFX + only COM offlined. Any DEV/QAR offline = Fail (S1).

### TC-P4.1-06 (CRITICAL — Change control): Approved window + graceful drain before offline
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm PM/BA + business approved a window; real date/time present (no `[INSERT DATE AND TIME]` placeholder) | Documented window |
| 2 | Application teams notified; all active connections terminated gracefully | Notified + drained |
| 3 | Exact offline time recorded; DB fully offline before any dependent step | Verified offline |

**Pass/Fail:** Offline only under an approved, documented window with graceful drain. Placeholder unfilled = Fail.

### TC-P4.1-07 (Rollback/contingency): Path exists if offline fails or window overruns
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Define behavior if connections won't drain or window expires | Documented rollback/abort (bring back online, reschedule) |

**Pass/Fail:** Contingency defined (playbook omits one → potential gap, D-P4.1-2).

## Step 2 — Validate Database Connectivity (SQA)

### TC-P4.1-08 (SQA validation — connectivity via SSMS): Connect using comma-port format
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Add credential in Windows Credential Manager: `REF[windward-database-server-ip]:1437` + DQ creds | Saved |
| 2 | SSMS → Connect to Server: `REF[windward-database-server-ip],1437` (**comma, not colon**) + Windows Auth | Connects (wait 30–60s) |
| 3 | Expand Databases; confirm all expected DBs present/accessible (Config, Payment, Windward) | All visible |

**Pass/Fail:** Connects and all databases visible.

### TC-P4.1-09 (Negative — known issue): Colon-before-port causes failure
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Attempt `IP:1437` (colon) | Connection error (reproduces Common Issue) |
| 2 | Switch to `IP,1437` (comma) | Connects |

**Pass/Fail:** Comma format required; colon fails as documented.

### TC-P4.1-10 (Sequential env): One setup+validate cycle per env, in order
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | DEV completed/validated before QAR ticket; then PROD, then HFX | Strict order honored |

**Pass/Fail:** Sequential per-env order honored.

### TC-P4.1-11 (DOC DEFECT): Recurring infosec/prereq mis-reference
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Follow prerequisite cross-references to Phase 3.x security/infosec | Verify against current Phase 3.x numbering (recurring mis-reference across phases) |

**Pass/Fail:** Defect D-P4.1-1 logged; correct reference confirmed.

---

## Completion Checklist Coverage
| Deliverable | Covered by |
|-------------|-----------|
| DB setup ticket created/assigned to DBA | TC-HO-01..06 |
| DBs created/configured per Tier; names documented | TC-P4.1-01 |
| Config/Payment/Windward backed up; integrity validated | TC-P4.1-02, 03 |
| All three restored; integrity + permissions | TC-P4.1-04 |
| COM DB brought offline (PROD/HFX) under approved window | TC-P4.1-05, 06 |
| Connectivity validated by SQA | TC-P4.1-08, 09 |
| Sequential env order | TC-P4.1-10 |

## Defects / Observations
| ID | Observation | Severity |
|----|-------------|----------|
| D-P4.1-1 | Recurring infosec/prereq mis-reference to Phase 3.x | S3 |
| D-P4.1-2 | No documented rollback/abort if COM offline fails or window overruns | S3 |
| D-P4.1-3 | COM-offline env scope ("PROD only" vs "PROD and HFX") stated inconsistently across the playbook — confirm intended scope | S2 |

## Execution Record
| TC | Date | Tester | Env | Result | Defect | Notes |
|----|------|--------|-----|--------|--------|-------|
| TC-P4.1-01 | | | | | | |
| TC-P4.1-02 | | | | | | |
| TC-P4.1-03 | | | | | | |
| TC-P4.1-04 | | | | | | |
| TC-P4.1-05 | | | PROD/HFX | | | |
| TC-P4.1-06 | | | PROD/HFX | | | |
| TC-P4.1-07 | | | PROD/HFX | | | |
| TC-P4.1-08 | | | | | | |
| TC-P4.1-09 | | | | | | |
| TC-P4.1-10 | | | | | | |
| TC-P4.1-11 | | | | | | |

---

## Playbook Reference
This suite validates the playbook item **[Phase04.1_DatabaseSetup_Migration.md](https://dev.azure.com/EnterpriseRepo/Application%20Services/_git/com-client-pilot?path=/Playbook/Phase04.1_DatabaseSetup_Migration.md&version=GBmain)** (`com-client-pilot/Playbook/`).

Related: [Jira ↔ Playbook matrix](../../JiraPlaybookMatrix.md) · [Test Strategy](../../TestStrategy.md) · [Traceability Matrix](../../TraceabilityMatrix.md)
