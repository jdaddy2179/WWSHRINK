# Test Cases — Phase 4.2: Database Backup and Restore

| Field | Value |
|-------|-------|
| Playbook reference | `Phase04.2_BackupRestore.md` (Steps 1–2) |
| Priority | **P1 — data integrity** (PROD backup → restore to AWS) |
| Type | Jira hand-off + data integrity + sequential env |
| Owner | SQA (connectivity validation); DBA Team executes |

**Applies `TC-HO-01..09`** from [`TC_PATTERN_JiraHandoffPhase.md`](../_shared/TC_PATTERN_JiraHandoffPhase.md), per step:
- **Step 1 Title:** `Database Backup from Production - REF[Tenant Name] [ENVIRONMENT]`; AC: "All three DBs (Config, Payment, Windward) backed up from production, integrity validated, file locations documented".
- **Step 2 Title:** `Database Restore to windward-database-server - REF[Tenant Name] [ENVIRONMENT]`; AC: "All three DBs restored to windward-database-server, integrity validated, permissions configured".
- **Assignee:** DBA Team (Vasudha, Anthony; mgr Chris Jones). **TC-HO-07 sequential env applies (DEV→QAR→PROD→HFX, one ticket per env, wait between).**

### Preconditions
- **Step 1:** Phase 4.1 COMPLETE for PROD; Phase 4 COMPLETE for DEV/QAR.
- **Step 2:** Step 1 COMPLETE; DB servers provisioned (Phase 3). Access: ADO, DQ Jira, Env Variables.

---

## Step 1 — Backup from Production

### TC-P4.2-01 (CRITICAL — Completeness): All three databases backed up
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm Config (`REF[ConfigDatabaseName]`), Payment (`REF[PaymentDatabaseName]`), Windward (`REF[WindwardDatabaseName]`) all backed up | All 3 present |
| 2 | Confirm DB names resolved from Env Variables (no `REF[]`, correct per client) | Correct names |

**Pass/Fail:** All three DBs backed up with correct client-specific names.

### TC-P4.2-02 (CRITICAL — Integrity): Backup integrity validated & documented
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | DBA validates backup integrity (e.g., RESTORE VERIFYONLY / checksum) | Pass |
| 2 | Backup file locations, sizes, timestamps documented in ticket | Recorded |

**Pass/Fail:** Integrity verified and evidence documented.

### TC-P4.2-03 (Sequencing — PROD source): PROD backup only after Phase 4.1 offline
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm PROD backup taken only after COM DB offline (Phase 4.1) | Order correct |

**Pass/Fail:** PROD backup follows offline; consistent snapshot.

## Step 2 — Restore to windward-database-server

### TC-P4.2-04 (CRITICAL — Completeness): All three DBs restored to windward-database-server (01)
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm target = `REF[windward-database-server]` (01) | Correct server |
| 2 | Confirm Config, Payment, Windward all restored | All 3 restored |

**Pass/Fail:** All three restored to the correct server.

### TC-P4.2-05 (CRITICAL — Integrity post-restore): Integrity validated after restore
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | DBA runs integrity checks (e.g., DBCC CHECKDB) | Pass, no corruption |
| 2 | Row counts / key objects sanity-checked vs source | Consistent |

**Pass/Fail:** Restored DBs pass integrity and match source.

### TC-P4.2-06 (Permissions/access): Permissions configured post-restore
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm DB permissions/access configured | Least-privilege, correct logins |

**Pass/Fail:** Access configured correctly.

### TC-P4.2-07 (SQA validation): Connectivity verified via SSMS
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | SQA connects via SQL Server Management Studio (per Phase 4 Step 2) | Connects successfully |
| 2 | Connectivity confirmed from application servers | Reachable |

**Pass/Fail:** SQA confirms connectivity (Joshua/Keerthan; mgr Arun Pant).

### TC-P4.2-08 (Sequential env): One backup+restore cycle per env, in order
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | DEV completed before QAR ticket; etc. through HFX | Strict order |

**Pass/Fail:** Sequential per-env order honored across both steps.

---

## Completion Checklist Coverage
| Deliverable | Covered by |
|-------------|-----------|
| Backup tickets created/assigned | TC-HO-01..06 |
| Config/Payment/Windward backed up | TC-P4.2-01 |
| Backup integrity validated; locations/sizes documented | TC-P4.2-02 |
| Restore tickets created/assigned | TC-HO-01..06 |
| Config/Payment/Windward restored | TC-P4.2-04 |
| Integrity validated post-restore | TC-P4.2-05 |
| Permissions configured | TC-P4.2-06 |
| Connectivity validated by SQA | TC-P4.2-07 |

## Execution Record
| TC | Date | Tester | Env | Result | Defect | Notes |
|----|------|--------|-----|--------|--------|-------|
| TC-P4.2-01 | | | | | | |
| TC-P4.2-02 | | | | | | |
| TC-P4.2-03 | | | | | | |
| TC-P4.2-04 | | | | | | |
| TC-P4.2-05 | | | | | | |
| TC-P4.2-06 | | | | | | |
| TC-P4.2-07 | | | | | | |
| TC-P4.2-08 | | | | | | |

---

## Playbook Reference
This suite validates the playbook item **[Phase04.2_BackupRestore.md](https://dev.azure.com/EnterpriseRepo/Application%20Services/_git/com-client-pilot?path=/Playbook/Phase04.2_BackupRestore.md&version=GBmain)** (`com-client-pilot/Playbook/`).

Related: [Jira ↔ Playbook matrix](../../JiraPlaybookMatrix.md) · [Test Strategy](../../TestStrategy.md) · [Traceability Matrix](../../TraceabilityMatrix.md)
