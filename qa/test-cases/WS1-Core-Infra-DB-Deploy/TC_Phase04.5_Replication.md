# Test Cases — Phase 4.5: Database Replication Setup

| Field | Value |
|-------|-------|
| Playbook reference | `Phase04.5_Replication.md` (Steps 1–2) | WS | 1 |
| Priority | P2 (replication consistency; on-prem reporting) + performance in scope | Type | Jira hand-off + data consistency |
| Owner | DBA Team executes; SQA validates read-only replica |

**Applies `TC-HO-01..09`** from [`TC_PATTERN_JiraHandoffPhase.md`](../_shared/TC_PATTERN_JiraHandoffPhase.md):
- **Titles:** Step 1 `Database Replication Setup and AG Configuration - REF[Tenant Name] [ENVIRONMENT]`; Step 2 `Replication to On-Prem Reporting Servers - REF[Tenant Name] [ENVIRONMENT]`.
- **AC Step 1:** transactional replication source→read-only via distribution server, AG configured (if applicable), validated/synchronized, documented. **AC Step 2:** AWS→on-prem reporting replication validated/synchronized, performance impact acceptable, documented.
- **Assignee:** DBA Team (Vasudha, Anthony; mgr Chris Jones) + Infra/Network for on-prem connectivity. **TC-HO-07 sequential env applies.**

### Preconditions
Phases 4, 4.1 (PROD), 4.2, 4.3, 4.4 COMPLETE; distribution + read-only servers provisioned (Phase 3). Step 2 requires Step 1 COMPLETE + on-prem reporting server + AWS↔on-prem network connectivity.

## Phase-specific cases
### TC-P4.5-01 (CRITICAL — data consistency): Replica matches source
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | SQA connects to read-only server via SSMS using `REF[windward-database-read-only-server-ip]` (comma-port format) | Connects |
| 2 | Confirm Windward/Config/Payment DBs present and accessible | All present |
| 3 | Confirm replicated data matches source | Consistent |

**Pass/Fail:** Replica complete and matching source.

### TC-P4.5-02 (Replication topology): Distribution, publications, subscriptions configured
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm distribution DB on distribution server | Configured |
| 2 | Confirm publications on source, subscriptions on read-only | Created |
| 3 | Confirm synchronized + low latency | Synced, minimal lag |

**Pass/Fail:** Topology correct and synchronized.

### TC-P4.5-03 (Always On AG + failover): AG configured and failover tested (if applicable)
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | If AG applicable, confirm configured | Configured |
| 2 | Test failover scenario | Fails over cleanly |
| 3 | Confirm monitoring/alerts on replication | Active |

**Pass/Fail:** AG + failover validated (or N/A documented).

### TC-P4.5-04 (Performance — on-prem): On-prem replication does not impact production
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm network connectivity + firewall/security groups for replication traffic | Established |
| 2 | Performance test: minimal impact on production DB | Acceptable |
| 3 | BI/reporting team confirms data matches AWS source; sample reports accurate | Validated |

**Pass/Fail:** On-prem replication accurate with acceptable production impact.

### TC-P4.5-05 (DOC DEFECT): Broken next-phase link
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | "Next phase" links Phase 5 as `Phase05_DeployWWApplications.md` (actual `Phase05_DeployWW1.0AndConfig.md`) | Broken link |

**Pass/Fail:** Defect D-P4.5-1 logged (recurring).

## Completion Checklist Coverage
| Deliverable | Covered by |
|-------------|-----------|
| Replication tickets created/assigned | TC-HO-01..06 |
| Distribution/pub/sub configured, synced | TC-P4.5-02 |
| AG configured (if applicable) | TC-P4.5-03 |
| On-prem replication validated, perf acceptable | TC-P4.5-01, 04 |

## Defects
| ID | Observation | Sev |
|----|-------------|-----|
| D-P4.5-1 | Next-phase link `Phase05_DeployWWApplications.md` broken (recurring) | S3 |

## Execution Record
| TC | Date | Tester | Env | Result | Defect | Notes |
|----|------|--------|-----|--------|--------|-------|
| TC-HO-01..09 | | | | | | |
| TC-P4.5-01 | | | | | | |
| TC-P4.5-02 | | | | | | |
| TC-P4.5-03 | | | | | | |
| TC-P4.5-04 | | | | | | |
| TC-P4.5-05 | | | | | | |

---

## Playbook Reference
This suite validates the playbook item **[Phase04.5_Replication.md](https://dev.azure.com/EnterpriseRepo/Application%20Services/_git/com-client-pilot?path=/Playbook/Phase04.5_Replication.md&version=GBmain)** (`com-client-pilot/Playbook/`).

Related: [Jira ↔ Playbook matrix](../../JiraPlaybookMatrix.md) · [Test Strategy](../../TestStrategy.md) · [Traceability Matrix](../../TraceabilityMatrix.md)
