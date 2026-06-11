# Test Cases — Phase 5.3: Application-level Security (WW Payments)

| Field | Value |
|-------|-------|
| Playbook reference | `Phase05.3_AppSecurity_Payments.md` (Step 1) | WS | 2 |
| Priority | **P1 — payments security + PHI (ForcePoint DSS)** | Type | Jira backlog hand-off + security |
| Owner | SQA (process QA); InfoSec + Identity teams execute/validate |

> Mirrors Phase 5.1 but scoped to the **Payments** instance. Near-duplicate content — primary risk is copy-paste error (wrong app/instance).

**Applies `TC-HO-01,04,06,08,09`**. User Stories: US1 Okta SSO/Portal Integration, US2 Authentication Testing & Sign-Off, US3 ForcePoint DSS PHI. Reference files identical to 5.1 (`infosec/windward-okta-sso-integration.md`, `integrate-to-existing-gov-com-portal.md`, `forcepoint-dss-fingerprinting.md`). Creation: Jamie Smith (mgr Elie Abouzeid).

### Preconditions
Phase 5.2 COMPLETE (WW Payments deployed).

## Phase-specific cases
### TC-P5.3-01 (CRITICAL — correct instance): SSO app added is the Payments app, not WW1.0
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Inspect the SSO app/integration created | Targets the **Payments** instance/portal |
| 2 | Confirm not a copy-paste of the WW1.0 (5.1) config | Distinct, correct app |

**Pass/Fail:** Security controls bound to the Payments instance. Wrong instance = Fail (S1).

### TC-P5.3-02 (Security — SSO + auth on Payments)
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Okta SSO login to Payments portal | Success; correct RBAC |
| 2 | Invalid login handled; auth events logged | Yes |

**Pass/Fail:** Payments SSO/auth correct.

### TC-P5.3-03 (CRITICAL — PHI / ForcePoint DSS on payments data path)
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm ForcePoint DSS fingerprinting covers the payments PHI/financial data path | Configured, correct client-ID |

**Pass/Fail:** DLP covers payments data path.

### TC-P5.3-04 (DOC DEFECTS): Missing AC; copy-paste risk; status inconsistency
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | No Acceptance Criteria; near-identical to 5.1; checklist "NOT STARTED" | Logged D-P5.3-1..2 |

**Pass/Fail:** Defects logged.

## Completion Checklist Coverage
| Deliverable | Covered by |
|-------------|-----------|
| Security stories created/assigned (Payments) | TC-HO-01/06, TC-P5.3-01 |
| SSO/auth validated | TC-P5.3-02 |
| ForcePoint DSS PHI configured | TC-P5.3-03 |

## Defects
| ID | Observation | Sev |
|----|-------------|-----|
| D-P5.3-1 | No Acceptance Criteria; near-duplicate of 5.1 (copy-paste risk) | S3 |
| D-P5.3-2 | Checklist status inconsistent with sibling phases | S4 |

## Execution Record
| TC | Date | Tester | Result | Defect | Notes |
|----|------|--------|--------|--------|-------|
| TC-P5.3-01 | | | | | |
| TC-P5.3-02 | | | | | |
| TC-P5.3-03 | | | | | |
| TC-P5.3-04 | | | | | |

---

## Playbook Reference
This suite validates the playbook item **[Phase05.3_AppSecurity_Payments.md](https://dev.azure.com/EnterpriseRepo/Application%20Services/_git/com-client-pilot?path=/Playbook/Phase05.3_AppSecurity_Payments.md&version=GBmain)** (`com-client-pilot/Playbook/`).

Related: [Jira ↔ Playbook matrix](../../JiraPlaybookMatrix.md) · [Test Strategy](../../TestStrategy.md) · [Traceability Matrix](../../TraceabilityMatrix.md)
