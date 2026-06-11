# Test Cases — Phase 4.1: Bring COM Database Offline (PROD / HFX)

| Field | Value |
|-------|-------|
| Playbook reference | `Phase04.1_BringComDBOfflinePROD.md` (Step 1) |
| Priority | **P1 — disruptive PROD operation** (takes COM DB offline) |
| Type | Jira hand-off + change control + negative/safety |
| Environment | **PROD and HFX ONLY** |
| Requires PHI access | DBA-privileged |
| Owner | SQA (process QA); DBA Team executes; PM/BA coordinates window |

**Applies `TC-HO-01..09`** from [`TC_PATTERN_JiraHandoffPhase.md`](../_shared/TC_PATTERN_JiraHandoffPhase.md):
- **Title:** `Bring COM Database Offline - REF[Tenant Name] PROD`.
- **Acceptance Criteria:** "COM database successfully brought offline in PRODUCTION during approved maintenance window, all active connections terminated, database status confirmed offline".
- **Assignee:** DBA Team (Vasudha Ramakrishnan, Anthony Kearney; mgr Chris Jones).

### Preconditions
- Phase 4 COMPLETE. **Approved maintenance window** scheduled with business stakeholders. DQ Jira + Env Variables access.

---

### TC-P4.1-01 (CRITICAL — Environment gating): Operation restricted to PROD/HFX only
**Objective:** Verify the offline operation is NEVER performed for DEV/QAR.

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm ticket targets PROD (or HFX) | Correct env |
| 2 | Attempt to scope this phase for DEV/QAR | Rejected — phase applies to PROD/HFX only |

**Pass/Fail:** Only PROD/HFX targeted. Any DEV/QAR offline attempt = Fail (S1).

### TC-P4.1-02 (CRITICAL — Change control): Approved maintenance window exists before offline
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm PM/BA + business stakeholders approved a window | Documented date/time |
| 2 | Confirm ticket Description has "Approved Maintenance Window: <date/time>" (not the `[INSERT DATE AND TIME]` placeholder) | Real value present |
| 3 | Confirm offline occurs only within the window | Within window |

**Pass/Fail:** Offline only under an approved, documented window. Placeholder left unfilled = Fail.

### TC-P4.1-03 (Safety): Connections drained & app teams notified before offline
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm application teams notified pre-offline | Notified |
| 2 | Confirm all active connections terminated gracefully | Graceful drain |
| 3 | Confirm exact offline time documented | Timestamp recorded |
| 4 | Confirm DB fully offline before any backup begins | Verified offline |

**Pass/Fail:** Graceful, notified, documented, fully-offline before downstream work.

### TC-P4.1-04 (Correct DB): Only Windward_Commercial (COM) targeted
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm target = Windward_Commercial (COM) | Correct DB |
| 2 | Confirm no unrelated DB taken offline | Scope correct |

**Pass/Fail:** Correct single DB offlined.

### TC-P4.1-05 (Hand-off outcome): DBA confirms offline status in ticket
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Await ticket Done w/ comment: exact offline time, status verification, issues | All present |

**Pass/Fail:** DBA confirmation complete.

### TC-P4.1-06 (DOC DEFECT): PROD-only vs "PROD and HFX" / acceptance-criteria inconsistency
**Objective:** Flag internal inconsistency: file name & Introduction say "PROD ONLY", but the H1 title and body say "PROD and HFX", while the Title template and Acceptance Criteria mention only "PROD"/"PRODUCTION".

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Compare filename/Intro ("PROD ONLY"), H1 ("PROD and HFX"), Title template ("... PROD"), AC ("PRODUCTION") | Inconsistency confirmed |
| 2 | Determine intended scope with DBA/architect | Clarified |

**Pass/Fail:** Inconsistency logged as defect D-P4.1-1; scope clarified so HFX is not missed or wrongly excluded.

### TC-P4.1-07 (Rollback/contingency): Path exists if offline fails or window overruns
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Define behavior if connections won't drain or window expires | Documented rollback/abort (bring back online, reschedule) |

**Pass/Fail:** Contingency defined (note: playbook does not document one → potential gap).

---

## Completion Checklist Coverage
| Deliverable | Covered by |
|-------------|-----------|
| Maintenance window coordinated/approved | TC-P4.1-02 |
| Ticket created & assigned to DBA | TC-HO-01..06 |
| COM DB brought offline in PROD | TC-P4.1-01, 03, 04 |
| Offline status confirmed/documented | TC-P4.1-05 |
| Connections terminated gracefully | TC-P4.1-03 |

## Defects / Observations
| ID | Observation | Severity |
|----|-------------|----------|
| D-P4.1-1 | PROD-only vs "PROD and HFX" vs AC "PRODUCTION" inconsistency | S2 |
| D-P4.1-2 | No documented rollback/abort if offline fails or window overruns | S3 |

## Execution Record
| TC | Date | Tester | Env | Result | Defect | Notes |
|----|------|--------|-----|--------|--------|-------|
| TC-P4.1-01 | | | PROD/HFX | | | |
| TC-P4.1-02 | | | | | | |
| TC-P4.1-03 | | | | | | |
| TC-P4.1-04 | | | | | | |
| TC-P4.1-05 | | | | | | |
| TC-P4.1-06 | | | | | | |
| TC-P4.1-07 | | | | | | |

---

## Playbook Reference
This suite validates the playbook item **[Phase04.1_BringComDBOfflinePROD.md](https://dev.azure.com/EnterpriseRepo/Application%20Services/_git/com-client-pilot?path=/Playbook/Phase04.1_BringComDBOfflinePROD.md&version=GBmain)** (`com-client-pilot/Playbook/`).

Related: [Jira ↔ Playbook matrix](../../JiraPlaybookMatrix.md) · [Test Strategy](../../TestStrategy.md) · [Traceability Matrix](../../TraceabilityMatrix.md)
