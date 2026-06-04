# Test Cases — Phase 9.1: Provider Copy Job Setup

| Field | Value |
|-------|-------|
| Playbook reference | `Phase09.1_ProviderCopyJob.md` (Step 1) | WS | TBD |
| Priority | P2 (provider data sync) | Type | Jira hand-off + data sync |
| Owner | DBA Team executes/validates |

**Applies `TC-HO-01..06,08,09`** from [`TC_PATTERN_JiraHandoffPhase.md`](../_shared/TC_PATTERN_JiraHandoffPhase.md):
- **Title:** `Configure Provider Copy Job - REF[Tenant Name]`.
- **AC:** "Provider Copy Job configured with correct database connection strings, scheduled at appropriate intervals, and validate successful execution with provider data synchronization confirmed".
- **Assignee:** DBA Team (Vasudha, Anthony, Nabeel; mgr TBD). **Single ticket per tenant.**

### Preconditions
Phases 4 and 9 COMPLETE.

## Phase-specific cases
### TC-P9.1-01 (CRITICAL — sync correctness): Provider data synchronized completely
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Run job; compare provider counts source vs target | Counts match; no partial sync |
| 2 | Spot-check known providers copied | Present and correct |

**Pass/Fail:** Full, accurate provider sync. Partial sync = Fail.

### TC-P9.1-02 (Cross-tenant safety): Connection strings tenant-specific
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Inspect job connection strings | New tenant source/target only |

**Pass/Fail:** No cross-tenant copy risk.

### TC-P9.1-03 (Permissions): Service account permissions sufficient
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm job service account has required DB permissions | No permission errors (per Common Issues) |

**Pass/Fail:** Job runs without permission failure.

### TC-P9.1-04 (Scheduling): Runs at appropriate intervals
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm schedule configured | Correct interval |

**Pass/Fail:** Scheduled correctly.

### TC-P9.1-05 (DOC DEFECTS): Embedded "links" are tasks; TBD managers; status
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Description items 3–6 are instructions, not links; managers TBD; checklist "IN PROGRESS" | Logged D-P9.1-1 |

**Pass/Fail:** Defect logged.

## Completion Checklist Coverage
| Deliverable | Covered by |
|-------------|-----------|
| Ticket created/assigned | TC-HO-01..06 |
| Connection strings + schedule configured | TC-P9.1-02, 04 |
| Provider sync confirmed | TC-P9.1-01 |

## Defects
| ID | Observation | Sev |
|----|-------------|-----|
| D-P9.1-1 | Tasks mislabeled as "links"; managers TBD; status inconsistent | S4 |

## Execution Record
| TC | Date | Tester | Result | Defect | Notes |
|----|------|--------|--------|--------|-------|
| TC-HO-01..09 | | | | | |
| TC-P9.1-01 | | | | | |
| TC-P9.1-02 | | | | | |
| TC-P9.1-03 | | | | | |
| TC-P9.1-04 | | | | | |
| TC-P9.1-05 | | | | | |
