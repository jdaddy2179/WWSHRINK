# Test Cases — Phase 9.2: Remove Extra Disk & CPUs

| Field | Value |
|-------|-------|
| Playbook reference | `Phase09.2_RemoveExtraResources.md` (Step 1) | WS | TBD |
| Priority | **P1 — destructive/irreversible production infra change** + performance in scope | Type | Jira hand-off + safety + performance |
| Owner | Infrastructure Team executes/validates |

**Applies `TC-HO-01..06,08,09`** from [`TC_PATTERN_JiraHandoffPhase.md`](../_shared/TC_PATTERN_JiraHandoffPhase.md):
- **Title:** `Remove Extra Disk & CPUs - REF[Tenant Name]`.
- **AC:** "Extra disk space and CPU resources identified and removed while maintaining adequate performance, with cost savings documented and new configurations validated".
- **Tools:** AWS CloudWatch (metrics) + AWS Console. **Assignee:** Infrastructure Team (TBD). **Single ticket.**

### Preconditions
Phases 1–9.1 COMPLETE; system at production/near-prod baseline with CloudWatch metrics.

## Phase-specific cases
### TC-P9.2-01 (CRITICAL — Safety): Snapshot/backup exists before any downsizing
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm EC2/EBS snapshot taken before resource removal | Snapshot exists (rollback per Common Issues) |
| 2 | Block changes if no snapshot | Hard stop |

**Pass/Fail:** No downsizing without a restorable snapshot. Missing = Fail (S1).

### TC-P9.2-02 (CRITICAL — DOC defect / AWS limitation): EBS cannot be shrunk
**Objective:** Instructions/AC say "reduce EBS volume sizes," but AWS EBS volumes **cannot be shrunk** (the doc's own Common-Issues table notes "can only increase volume size"). The real method is **delete/recreate** smaller, not "reduce."

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm the approach used is delete-and-recreate (with snapshot/migration), not in-place shrink | Correct method |
| 2 | Flag the contradictory guidance | Logged |

**Pass/Fail:** Correct (delete/recreate) approach used; defect D-P9.2-1 logged. Attempting in-place EBS shrink = Fail.

### TC-P9.2-03 (Right-sizing correctness): CPU/disk reduced based on CloudWatch, headroom retained
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Base reductions on CloudWatch utilization for the Tier | Data-driven |
| 2 | Confirm adequate headroom retained (not over-reduced) | Safe margin |

**Pass/Fail:** Reductions justified by metrics with safe headroom.

### TC-P9.2-04 (Performance — CRITICAL): All apps/services validated post-change against thresholds
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | After resizing, run performance validation across all apps/services | Within thresholds |
| 2 | Confirm no degradation/outage | Healthy |

**Pass/Fail:** Performance acceptable after downsizing.

### TC-P9.2-05 (Documentation): New configs + cost savings recorded in Env Variables
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Update Env Variables spreadsheet with new configs | Updated |
| 2 | Document cost savings | Recorded |

**Pass/Fail:** Configs + savings documented.

### TC-P9.2-06 (DOC DEFECTS): TBD owners; status
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | All Work Assignment owners + Infra Team + manager "TBD"; checklist "IN PROGRESS" | Logged D-P9.2-2 |

**Pass/Fail:** Defect logged.

## Completion Checklist Coverage
| Deliverable | Covered by |
|-------------|-----------|
| Ticket created/assigned | TC-HO-01..06 |
| Resources identified & removed safely | TC-P9.2-01, 02, 03 |
| Performance maintained & validated | TC-P9.2-04 |
| Cost savings + new configs documented | TC-P9.2-05 |

## Defects
| ID | Observation | Sev |
|----|-------------|-----|
| D-P9.2-1 | Contradictory guidance: "reduce EBS volume sizes" vs AWS limit "can only increase" — EBS cannot be shrunk in place | S2 |
| D-P9.2-2 | All owners/Infra Team/manager "TBD"; status inconsistent | S3 |

## Execution Record
| TC | Date | Tester | Env | Result | Defect | Notes |
|----|------|--------|-----|--------|--------|-------|
| TC-HO-01..09 | | | | | | |
| TC-P9.2-01 | | | | | | |
| TC-P9.2-02 | | | | | | |
| TC-P9.2-03 | | | | | | |
| TC-P9.2-04 | | | | | | |
| TC-P9.2-05 | | | | | | |
| TC-P9.2-06 | | | | | | |

---

## Playbook Reference
This suite validates the playbook item **[Phase09.2_RemoveExtraResources.md](https://dev.azure.com/EnterpriseRepo/Application%20Services/_git/com-client-pilot?path=/Playbook/Phase09.2_RemoveExtraResources.md&version=GBmain)** (`com-client-pilot/Playbook/`).

Related: [Jira ↔ Playbook matrix](../../JiraPlaybookMatrix.md) · [Test Strategy](../../TestStrategy.md) · [Traceability Matrix](../../TraceabilityMatrix.md)
