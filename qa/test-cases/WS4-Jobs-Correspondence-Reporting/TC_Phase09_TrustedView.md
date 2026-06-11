# Test Cases — Phase 9: Trusted View Setup and Configuration

| Field | Value |
|-------|-------|
| Playbook reference | `Phase09_TrustedView.md` (Steps 1–2) | WS | 4 |
| Priority | **P1 — Step 2 rebuild repopulates member/provider-derived tables (data integrity, potentially irreversible)** | Type | Jira hand-off + data integrity |
| Owner | DBA Team executes/validates |

**Applies `TC-HO-01..06,08,09`** from [`TC_PATTERN_JiraHandoffPhase.md`](../_shared/TC_PATTERN_JiraHandoffPhase.md):
- **Titles:** Step 1 `Configure Trusted View Jobs - REF[Tenant Name]`; Step 2 `Rebuild Trusted View - REF[Tenant Name]`.
- **AC Step 1:** "...configured with correct database connection strings, scheduled at appropriate intervals, validate successful execution with data refresh confirmation". **AC Step 2:** "...rebuilt successfully with all tables populated, data integrity validated, and rebuild completion documented".
- **Assignee:** DBA Team (Vasudha, Anthony, Nabeel; mgr TBD). **Single ticket per step; Step 2 depends on Step 1.**

### Preconditions
Phases 4, 5, 6 COMPLETE.

## Phase-specific cases
### TC-P9-01 (CRITICAL — cross-tenant): Connection strings point at the new tenant DB
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Inspect Trusted View job connection strings | New tenant DB only |

**Pass/Fail:** No cross-tenant rebuild risk. Wrong DB = Fail (S1).

### TC-P9-02 (Step 1 — scheduling/refresh): Jobs scheduled & refresh confirmed
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm jobs scheduled at appropriate intervals | Scheduled |
| 2 | Confirm successful execution + data refresh | Refresh confirmed |
| 3 | Confirm off-peak scheduling to avoid rebuild timeouts on large volumes | Off-peak |

**Pass/Fail:** Jobs scheduled and refreshing.

### TC-P9-03 (CRITICAL — Step 2 rebuild integrity): All tables populated, counts/integrity correct
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Run rebuild stored procedures (Step 2) | Complete without error |
| 2 | Verify **no table left unpopulated** | All populated |
| 3 | Verify row counts / integrity vs business rules | Consistent |

**Pass/Fail:** Rebuild leaves a complete, integral Trusted View. Empty/partial table = Fail (S1).

### TC-P9-04 (Sequencing): Step 2 only after Step 1 COMPLETE
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm rebuild runs only after jobs configured | Order honored |

**Pass/Fail:** Step order respected.

### TC-P9-05 (DOC DEFECTS): Mermaid node concat; typo; no distinctive ref link
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Mermaid `S7[...]S8[...]` nodes concatenated on one line | Logged |
| 2 | "checksvalidation" typo (Step 2 desc) | Logged |
| 3 | Only generic `/architecture` link (no Trusted View spec) | Logged |

**Pass/Fail:** Defects D-P9-1..3 logged.

## Completion Checklist Coverage
| Deliverable | Covered by |
|-------------|-----------|
| Config + rebuild tickets created/assigned | TC-HO-01..06 |
| Jobs configured/scheduled/refresh | TC-P9-02 |
| Rebuild complete, tables populated, integrity validated | TC-P9-03 |

## Defects
| ID | Observation | Sev |
|----|-------------|-----|
| D-P9-1 | Mermaid nodes S7/S8 concatenated (diagram renders wrong) | S4 |
| D-P9-2 | Typo "checksvalidation" in Step 2 description | S4 |
| D-P9-3 | No distinctive Trusted View reference doc linked | S3 |

## Execution Record
| TC | Date | Tester | Env | Result | Defect | Notes |
|----|------|--------|-----|--------|--------|-------|
| TC-HO-01..09 | | | | | | |
| TC-P9-01 | | | | | | |
| TC-P9-02 | | | | | | |
| TC-P9-03 | | | | | | |
| TC-P9-04 | | | | | | |
| TC-P9-05 | | | | | | |

---

## Playbook Reference
This suite validates the playbook item **[Phase09_TrustedView.md](https://dev.azure.com/EnterpriseRepo/Application%20Services/_git/com-client-pilot?path=/Playbook/Phase09_TrustedView.md&version=GBmain)** (`com-client-pilot/Playbook/`).

Related: [Jira ↔ Playbook matrix](../../JiraPlaybookMatrix.md) · [Test Strategy](../../TestStrategy.md) · [Traceability Matrix](../../TraceabilityMatrix.md)
