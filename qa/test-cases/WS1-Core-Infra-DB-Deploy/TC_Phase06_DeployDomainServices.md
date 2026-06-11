# Test Cases — Phase 6: Deploy Domain Services

| Field | Value |
|-------|-------|
| Playbook reference | `Phase06_DeployDomainServices.md` (Steps 1–4) | WS | 1 |
| Priority | P2 (NextGen domain services) + functional in scope | Type | Jira hand-off + smoke validation |
| Owner | NextGen Services Deployment Team deploys + validates with SQA |

**Applies `TC-HO-01..06,08,09`** from [`TC_PATTERN_JiraHandoffPhase.md`](../_shared/TC_PATTERN_JiraHandoffPhase.md), once per service (4 independent tickets, any order):
| Step | Service | Title | Doc link |
|------|---------|-------|----------|
| 1 | Member Domain Service | `Member Domain Service Deployment - REF[Tenant Name]` | `next-gen-deployments/MemberDomainService.md` |
| 2 | Group/Product Domain Service | `Group/Product Domain Service Deployment - REF[Tenant Name]` | `next-gen-deployments/GroupProductDomainService.md` |
| 3 | Claims Domain Service | `Claims Domain Service Deployment - REF[Tenant Name]` | `next-gen-deployments/ClaimsDomainService.md` |
| 4 | Data Publisher | `Data Publisher Deployment - REF[Tenant Name]` | `next-gen-deployments/DataPublisher.md` |
- **AC (each):** "<Service> deployed successfully on AWS Environment, service is running and validated".
- **Assignee:** NextGen Services Deployment Team — Venkata Nune (mgr TBD) + SQA (Joshua, Keerthan). Rollback: AJ & NextGen team. **Single ticket per service "to all environments".**

### Preconditions
Phases 3, 3.1, 4, 4.1 (PROD), 4.2, 4.3, 4.4, 4.5 COMPLETE.

## Phase-specific cases
### TC-P6-01 (Completeness): All four domain services ticketed and deployed
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm 4 tickets created (Member, Group/Product, Claims, Data Publisher) each with correct title + doc link | All 4 present |
| 2 | Confirm each deployed to all environments | Complete |

**Pass/Fail:** All four services deployed; none missing.

### TC-P6-02 (Functional — service health): Each service running and smoke-validated
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | NextGen + SQA confirm each service running | Healthy |
| 2 | SQA smoke test per service (note: smoke only; deep functional deferred) | Passes |

**Pass/Fail:** All four services healthy and smoke-validated.

### TC-P6-03 (Rollback): Failure handling per AJ & NextGen team
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | On failure, rollback executed | Restored |

**Pass/Fail:** Rollback works (note "AJ" unidentified — defect).

### TC-P6-04 (DOC DEFECT): Broken infosec prereq reference
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Prereq "3.1 Security setup" → `Phase03.1_Infosec.md` (infosec is 3.4) | Broken/wrong ref |

**Pass/Fail:** Defect D-P6-1 logged (recurring); managers TBD also noted.

## Completion Checklist Coverage
| Deliverable | Covered by |
|-------------|-----------|
| 4 deployment tickets created | TC-P6-01, TC-HO-01..06 |
| Each service deployed & validated | TC-P6-02 |

## Defects
| ID | Observation | Sev |
|----|-------------|-----|
| D-P6-1 | "3.1 Security setup" → `Phase03.1_Infosec.md` (infosec is 3.4); managers TBD | S3 |

## Execution Record
| TC | Date | Tester | Env | Result | Defect | Notes |
|----|------|--------|-----|--------|--------|-------|
| TC-HO-01..09 (×4) | | | | | | |
| TC-P6-01 | | | | | | |
| TC-P6-02 | | | | | | |
| TC-P6-03 | | | | | | |
| TC-P6-04 | | | | | | |

---

## Playbook Reference
This suite validates the playbook item **[Phase06_DeployDomainServices.md](https://dev.azure.com/EnterpriseRepo/Application%20Services/_git/com-client-pilot?path=/Playbook/Phase06_DeployDomainServices.md&version=GBmain)** (`com-client-pilot/Playbook/`).

Related: [Jira ↔ Playbook matrix](../../JiraPlaybookMatrix.md) · [Test Strategy](../../TestStrategy.md) · [Traceability Matrix](../../TraceabilityMatrix.md)
