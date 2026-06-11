# Test Cases — Phase 6.1: Deploy Business Service

| Field | Value |
|-------|-------|
| Playbook reference | `Phase06.1_DeployBusinessService.md` (Step 1) | WS | 5 |
| Priority | P2 (core NextGen service) + functional in scope | Type | Jira hand-off + smoke validation |
| Owner | NextGen Services Deployment Team deploys + validates **with** SQA |

**Applies `TC-HO-01..06,08,09`** from [`TC_PATTERN_JiraHandoffPhase.md`](../_shared/TC_PATTERN_JiraHandoffPhase.md):
- **Title:** `Business Service Deployment - REF[Tenant Name]`.
- **AC:** "Business Service deployed successfully on AWS Environment, service is running and validated".
- **Links:** **BusinessService.md** (`/architecture/next-gen-deployments/BusinessService.md`).
- **Assignee:** NextGen Services Deployment Team — Venkata Nune (mgr TBD); validation Venkata Nune + SQA (Joshua, Keerthan). Rollback: "AJ & NextGen Services Deployment Team".

### Preconditions
Phases 3, 3.1, 4, 4.1 (PROD), 4.2, 4.3, 4.4, 4.5, and 6 (Domain Services) COMPLETE.

## Phase-specific cases
### TC-P6.1-01 (Env coverage — single ticket): All environments covered despite one ticket
**Objective:** This phase uses a single ticket ("deploy to all environments") — verify no environment is skipped (unlike the per-env model of Phase 5).

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm the deployment covers DEV, QAR, PROD, HFX | All four deployed |
| 2 | Confirm none lost due to single-ticket model | Complete coverage |

**Pass/Fail:** Business Service deployed to every environment.

### TC-P6.1-02 (Functional — service health): Service running & validated
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | NextGen team + SQA confirm service running | Healthy |
| 2 | SQA smoke test (note: SQA does smoke only here, not full functional) | Passes |

**Pass/Fail:** Service running and smoke-validated.

### TC-P6.1-03 (Rollback): Rollback path exercised if deploy fails
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | On failure, "AJ & NextGen team" perform rollback | Service restored |

**Pass/Fail:** Rollback works. (Note ambiguity: "AJ" unidentified — see defect.)

### TC-P6.1-04 (DOC DEFECTS): Inconsistent infosec prereq ref; TBD owners; unidentified "AJ"
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Prereq references `Phase03.1_Infosec.md` (Phase 5 uses `Phase03.3_Infosec_IT_Intake.md`; actual infosec is 3.4) | Inconsistent ref |
| 2 | Manager/IT Lead = "TBD"; rollback owner "AJ" lacks full name/email | Logged |

**Pass/Fail:** Defects D-P6.1-1..2 logged.

## Completion Checklist Coverage
| Deliverable | Covered by |
|-------------|-----------|
| Deploy ticket created/assigned | TC-HO-01..06 |
| Service deployed to all envs | TC-P6.1-01 |
| Service running & validated | TC-P6.1-02 |

## Defects
| ID | Observation | Sev |
|----|-------------|-----|
| D-P6.1-1 | Infosec prereq ref `Phase03.1_Infosec.md` inconsistent (infosec is Phase 3.4) | S3 |
| D-P6.1-2 | Manager/IT Lead TBD; rollback owner "AJ" unidentified | S4 |

## Execution Record
| TC | Date | Tester | Env | Result | Defect | Notes |
|----|------|--------|-----|--------|--------|-------|
| TC-HO-01..09 | | | | | | |
| TC-P6.1-01 | | | | | | |
| TC-P6.1-02 | | | | | | |
| TC-P6.1-03 | | | | | | |
| TC-P6.1-04 | | | | | | |

---

## Playbook Reference
This suite validates the playbook item **[Phase06.1_DeployBusinessService.md](https://dev.azure.com/EnterpriseRepo/Application%20Services/_git/com-client-pilot?path=/Playbook/Phase06.1_DeployBusinessService.md&version=GBmain)** (`com-client-pilot/Playbook/`).

Related: [Jira ↔ Playbook matrix](../../JiraPlaybookMatrix.md) · [Test Strategy](../../TestStrategy.md) · [Traceability Matrix](../../TraceabilityMatrix.md)
