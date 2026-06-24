# Test Cases — Phase 4.2: Database Replication Setup

| Field | Value |
|-------|-------|
| Playbook reference | `Phase04.2_Replication.md` (Steps 1–2) | WS | 1 |
| Priority | P2 (replication consistency; on-prem reporting) + performance in scope | Type | Jira hand-off + data consistency |
| Owner | DBA Team executes; SQA validates read-only replica |

**Applies `TC-HO-01..09`** from [`TC_PATTERN_JiraHandoffPhase.md`](../_shared/TC_PATTERN_JiraHandoffPhase.md):
- **Titles:** Step 1 `Database Replication Setup and AG Configuration - REF[Tenant Name] [ENVIRONMENT]`; Step 2 `Replication to On-Prem Reporting Servers - REF[Tenant Name] [ENVIRONMENT]`.
- **AC Step 1:** transactional replication source→read-only via distribution server, AG configured (if applicable), validated/synchronized, documented. **AC Step 2:** AWS→on-prem reporting replication validated/synchronized, performance impact acceptable, documented.
- **Assignee:** DBA Team (Vasudha, Anthony; mgr Chris Jones) + Infra/Network for on-prem connectivity. **TC-HO-07 sequential env applies.**

### Preconditions
**Phase 4.1 COMPLETE**; **either Phase 4 (WW1.0 & Config Shrink) OR Phase 4.3 (Payment Shrink) COMPLETE** (per restructured playbook); distribution + read-only servers provisioned (Phase 3). Step 2 requires Step 1 COMPLETE + on-prem reporting server + AWS↔on-prem network connectivity. *(May run in parallel with Phase 5.)*

## Phase-specific cases
### TC-P4.2-01 (CRITICAL — data consistency): Replica matches source
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | SQA connects to read-only server via SSMS using `REF[windward-database-read-only-server-ip]` (comma-port format) | Connects |
| 2 | Confirm Windward/Config/Payment DBs present and accessible | All present |
| 3 | Confirm replicated data matches source | Consistent |

**Pass/Fail:** Replica complete and matching source.

### TC-P4.2-02 (Replication topology): Distribution, publications, subscriptions configured
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm distribution DB on distribution server | Configured |
| 2 | Confirm publications on source, subscriptions on read-only | Created |
| 3 | Confirm synchronized + low latency | Synced, minimal lag |

**Pass/Fail:** Topology correct and synchronized.

### TC-P4.2-03 (Always On AG + failover): AG configured and failover tested (if applicable)
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | If AG applicable, confirm configured | Configured |
| 2 | Test failover scenario | Fails over cleanly |
| 3 | Confirm monitoring/alerts on replication | Active |

**Pass/Fail:** AG + failover validated (or N/A documented).

### TC-P4.2-04 (Performance — on-prem): On-prem replication does not impact production
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm network connectivity + firewall/security groups for replication traffic | Established |
| 2 | Performance test: minimal impact on production DB | Acceptable |
| 3 | BI/reporting team confirms data matches AWS source; sample reports accurate | Validated |

**Pass/Fail:** On-prem replication accurate with acceptable production impact.

### TC-P4.2-05 (DOC DEFECT): Phase 4.2 playbook header/typo defects
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Completion-checklist header reads "Upon successful completion of Phase **4.5**" | Should read **Phase 4.2** (D-P4.2-1) |
| 2 | Checklist row reads "validated by DBA & **SWA** Teams" | Typo — should be **SQA** (D-P4.2-2) |
| 3 | QA/Testing References → "Phase Test Cases: **TBD**" | Should link this suite (D-P4.2-3) |

**Pass/Fail:** Doc defects logged; not execution blockers.

## Completion Checklist Coverage
| Deliverable | Covered by |
|-------------|-----------|
| Replication tickets created/assigned | TC-HO-01..06 |
| Distribution/pub/sub configured, synced | TC-P4.2-02 |
| AG configured (if applicable) | TC-P4.2-03 |
| On-prem replication validated, perf acceptable | TC-P4.2-01, 04 |

## Defects
| ID | Observation | Sev |
|----|-------------|-----|
| D-P4.2-1 | Completion-checklist header says "Phase 4.5" (copy-paste); should be "Phase 4.2" | S4 |
| D-P4.2-2 | Checklist typo "SWA Teams" → should be "SQA Teams" | S4 |
| D-P4.2-3 | QA/Testing References → "Phase Test Cases: TBD" (missing link to this suite) | S4 |

## Execution Record
| TC | Date | Tester | Env | Result | Defect | Notes |
|----|------|--------|-----|--------|--------|-------|
| TC-HO-01..09 | | | | | | |
| TC-P4.2-01 | | | | | | |
| TC-P4.2-02 | | | | | | |
| TC-P4.2-03 | | | | | | |
| TC-P4.2-04 | | | | | | |
| TC-P4.2-05 | | | | | | |

---

## Playbook Reference
This suite validates the playbook item **[Phase04.2_Replication.md](https://dev.azure.com/EnterpriseRepo/Application%20Services/_git/com-client-pilot?path=/Playbook/Phase04.2_Replication.md&version=GBmain)** (`com-client-pilot/Playbook/`).

Related: [Jira ↔ Playbook matrix](../../JiraPlaybookMatrix.md) · [Test Strategy](../../TestStrategy.md) · [Traceability Matrix](../../TraceabilityMatrix.md)
