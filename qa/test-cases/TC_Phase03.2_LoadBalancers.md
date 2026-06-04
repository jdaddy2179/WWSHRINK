# Test Cases — Phase 3.2: Load Balancer & DNS CNAME Setup

| Field | Value |
|-------|-------|
| Playbook reference | `Phase03.2_LoadBalancers.md` (Step 1) |
| Priority | P2/P3 | Type | Jira hand-off + config validation |
| Owner | SQA (ticket QA); Cloud Infra + Application & Network Team execute/validate |

**Applies `TC-HO-01..09`** from [`TC_PATTERN_JiraHandoffPhase.md`](TC_PATTERN_JiraHandoffPhase.md):
- **Title:** `Load Balancer and DNS Alias Setup - REF[Tenant Name]`.
- **Links:** architecture folder, windward-1.0/2.0, Env Variables, **Load Balancer Setup Steps** (`/architecture/load-balancers/LoadBalancerSetupSteps.md`).
- **Acceptance Criteria:** "Load balancer setup must be complete, DNS CNAME records configured for all servers and load balancers, and infrastructure details documented".
- **Assignees:** Cloud Infra (Erik, Daniel Hobert) + Application & Network Team (Daniel Hobert, Alex Tang).
- **Tier reference:** required. **Sequential env (TC-HO-07):** N/A single ticket.

### Preconditions
- Phase 3 COMPLETE. Access: ADO, DQ Jira, Env Variables.

## Phase-specific cases
### TC-P3.2-01 (Data): LB, alias, and listener details documented in Env Variables
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | After setup, inspect client tab for load balancer, alias, listener entries | All present, accurate, complete |
| 2 | Both Infra and App & Network teams confirm sufficiency for Phase 3.3 | Confirmed |

**Pass/Fail:** LB/alias/listener details complete (gates Phase 3.3 cert work).

### TC-P3.2-02 (CRITICAL): DNS CNAME configured for ALL servers and load balancers
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Enumerate every server + LB requiring an alias | Complete list |
| 2 | Confirm a CNAME exists and resolves for each | All resolve to correct target |
| 3 | Confirm branded/user-friendly names map correctly (not raw AWS endpoints) | Correct mapping |

**Pass/Fail:** Every server/LB has a working CNAME.

### TC-P3.2-03 (Negative / rollback): DNS change connectivity issue is handled
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Simulate/observe a bad CNAME or timing issue | Connectivity issue detected |
| 2 | App & Network Team investigates and rolls back if needed | Rollback path works (per Common Issues) |

**Pass/Fail:** Rollback/troubleshooting procedure is effective.

### TC-P3.2-04 (Change control): DNS CNAME change submitted via ServiceNow
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm DNS CNAME change went through a ServiceNow Change Request | CR exists; approver = Steven DePietro |

**Pass/Fail:** DNS changes are change-controlled, not ad hoc.

## Completion Checklist Coverage
| Deliverable | Covered by |
|-------------|-----------|
| Ticket created & assigned | TC-HO-01..06 |
| LB/alias/listener documented | TC-P3.2-01 |
| DNS CNAME configured | TC-P3.2-02, 04 |
| Setup validated & working | TC-P3.2-02, 03 / TC-HO-08 |

## Execution Record
| TC | Date | Tester | Result | Defect | Notes |
|----|------|--------|--------|--------|-------|
| TC-HO-01..09 | | | | | |
| TC-P3.2-01 | | | | | |
| TC-P3.2-02 | | | | | |
| TC-P3.2-03 | | | | | |
| TC-P3.2-04 | | | | | |
