# Test Cases — Phase 7: TWS Jobs Setup and Configuration

| Field | Value |
|-------|-------|
| Playbook reference | `Phase07_TWSJobs.md` (Step 1) | WS | 4 |
| Priority | P2 (batch/integration; data-movement heavy) + functional in scope | Type | Jira hand-off + functional |
| Owner | TWS Team + DBA Team execute/validate |

**Applies `TC-HO-01..06,08,09`** from [`TC_PATTERN_JiraHandoffPhase.md`](../_shared/TC_PATTERN_JiraHandoffPhase.md):
- **Title:** `TWS Jobs Configuration - REF[Tenant Name]`.
- **AC:** "All TWS jobs configured with correct database connection strings, business unit entries added to configuration tables, batch scripts updated with tenant-specific parameters, and automated job executions validated for the new tenant".
- **Links:** **tws-jobs** (`/architecture/job-execution-tier/tws-jobs`).
- **Assignee:** TWS Team (TBD) + DBA Team (Vasudha, Anthony, Nabeel). **Single ticket (not per-env).**

### Preconditions
Phases 3, 4, 5 COMPLETE.

## Phase-specific cases
### TC-P7-01 (CRITICAL — cross-tenant safety): SSIS connection strings updated for the new tenant
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Inspect SSIS `.dtsConfig` connection strings | Point at the new tenant's DBs only |
| 2 | Confirm no residual pointer to another tenant/source | No cross-tenant string |

**Pass/Fail:** All connection strings tenant-correct. A wrong string = cross-tenant data leak = Fail (S1).

### TC-P7-02 (Config data): Business unit entries added to config tables
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm BU entries added in `WindwardInterfaces` config table(s) | Present |
| 2 | Verify exact table name (doc hedges "`tblClient_BU` or equivalent") with DBA | Confirmed authoritative name |

**Pass/Fail:** BU entries present in the correct table.

### TC-P7-03 (Integration): FTP connections/paths for Oracle integration correct
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm FTP connections and file paths configured | Correct endpoints/paths |

**Pass/Fail:** FTP/Oracle file movement configured correctly.

### TC-P7-04 (Functional — job execution): Automated jobs run successfully for the tenant
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Trigger/observe scheduled TWS jobs | Run, complete, correct data refresh |
| 2 | Verify dependency chains and restart/error handling | Behave correctly |
| 3 | Confirm Tier-appropriate job spec set applied | Correct set |

**Pass/Fail:** Jobs execute correctly end-to-end.

### TC-P7-05 (DOC DEFECTS): TBD owners; non-authoritative table name; status
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Most owners + all managers "TBD"; checklist "NOT STARTED"; "`tblClient_BU` or equivalent" | Logged D-P7-1..2 |

**Pass/Fail:** Defects logged.

## Completion Checklist Coverage
| Deliverable | Covered by |
|-------------|-----------|
| Ticket created/assigned | TC-HO-01..06 |
| Connection strings configured | TC-P7-01 |
| BU entries added | TC-P7-02 |
| Batch scripts/params + jobs validated | TC-P7-03, 04 |

## Defects
| ID | Observation | Sev |
|----|-------------|-----|
| D-P7-1 | Most Work Assignment owners/managers "TBD" | S3 |
| D-P7-2 | Non-authoritative config table name ("`tblClient_BU` or equivalent") | S3 |

## Execution Record
| TC | Date | Tester | Result | Defect | Notes |
|----|------|--------|--------|--------|-------|
| TC-HO-01..09 | | | | | |
| TC-P7-01 | | | | | |
| TC-P7-02 | | | | | |
| TC-P7-03 | | | | | |
| TC-P7-04 | | | | | |
| TC-P7-05 | | | | | |
