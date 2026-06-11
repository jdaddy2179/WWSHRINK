# Test Cases — Phase 4: Setup Databases on SQL Servers

| Field | Value |
|-------|-------|
| Playbook reference | `Phase04_SetupDBs.md` (Steps 1–2) | WS | 1 |
| Priority | P1 (DB foundation for all data phases) | Type | Jira hand-off + connectivity validation |
| Owner | DBA Team creates/configures; SQA validates connectivity |

**Applies `TC-HO-01..06,08,09`** from [`TC_PATTERN_JiraHandoffPhase.md`](../_shared/TC_PATTERN_JiraHandoffPhase.md):
- **Title:** `Database Setup - REF[Tenant Name]`.
- **AC:** "Databases created and configured on all SQL Server instances, database details (names, sizes, configurations) documented in Environment Variables spreadsheet, and database connectivity validated".
- **Links:** windward-1.0, windward-2.0, **Costing.xlsx**.
- **Assignee:** DBA Team (Vasudha, Anthony; mgr Chris Jones). **Single ticket; Tier reference required.**

### Preconditions
Phase 3 COMPLETE; SQL Server instances installed; DB servers provisioned. (Prereq cites "Phase 3.1 Security setup" as `Phase03.1_Infosec.md` — see defect.)

## Phase-specific cases
### TC-P4-01 (Tier — DB config): Databases created/sized per Tier architecture
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm DB names/sizes/configs follow the Tier-appropriate database-tier spec | Matches Tier |
| 2 | Confirm details documented in Env Variables | Recorded |

**Pass/Fail:** DBs configured per Tier and documented.

### TC-P4-02 (SQA validation — connectivity via SSMS): Connect using comma-port format
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Add credential in Windows Credential Manager: `REF[windward-database-server-ip]:1437` + DQ creds | Saved |
| 2 | SSMS → Connect to Server: `REF[windward-database-server-ip],1437` (**comma, not colon**) + Windows Auth | Connects (wait 30–60s) |
| 3 | Expand Databases; confirm all expected DBs present/accessible | All visible |

**Pass/Fail:** Connects and all databases visible.

### TC-P4-03 (Negative — known issue): Colon-before-port causes failure
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Attempt `IP:1437` (colon) | Connection error (reproduces Common Issue) |
| 2 | Switch to `IP,1437` (comma) | Connects |

**Pass/Fail:** Comma format required; colon fails as documented.

### TC-P4-04 (Sequential env): DEV validated before QAR, then PROD
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Validate DEV first; QAR configured after DEV approved | Order honored (note: doc lists DEV→QAR→Prod; confirm HFX handling) |

**Pass/Fail:** Sequential order honored.

### TC-P4-05 (DOC DEFECT): Broken infosec prereq reference
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Follow "Phase 3.1 Security setup" → `Phase03.1_Infosec.md` (infosec is Phase 3.4; 3.1 is Kerberos) | Broken/wrong ref |

**Pass/Fail:** Defect D-P4-1 logged (recurring infosec mis-reference).

## Completion Checklist Coverage
| Deliverable | Covered by |
|-------------|-----------|
| Ticket created/assigned | TC-HO-01..06 |
| DBs created/configured | TC-P4-01 |
| Details documented | TC-P4-01 |
| Connectivity validated | TC-P4-02, 03 |

## Defects
| ID | Observation | Sev |
|----|-------------|-----|
| D-P4-1 | "Phase 3.1 Security setup" → `Phase03.1_Infosec.md` (infosec is 3.4) — recurring | S3 |

## Execution Record
| TC | Date | Tester | Env | Result | Defect | Notes |
|----|------|--------|-----|--------|--------|-------|
| TC-HO-01..09 | | | | | | |
| TC-P4-01 | | | | | | |
| TC-P4-02 | | | | | | |
| TC-P4-03 | | | | | | |
| TC-P4-04 | | | | | | |
| TC-P4-05 | | | | | | |

---

## Playbook Reference
This suite validates the playbook item **[Phase04_SetupDBs.md](https://dev.azure.com/EnterpriseRepo/Application%20Services/_git/com-client-pilot?path=/Playbook/Phase04_SetupDBs.md&version=GBmain)** (`com-client-pilot/Playbook/`).

Related: [Jira ↔ Playbook matrix](../../JiraPlaybookMatrix.md) · [Test Strategy](../../TestStrategy.md) · [Traceability Matrix](../../TraceabilityMatrix.md)
