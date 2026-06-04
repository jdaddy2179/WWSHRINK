# Test Cases — Phase 5.1: Application-level Security (WW 1.0 & Config)

| Field | Value |
|-------|-------|
| Playbook reference | `Phase05.1_AppSecurity_WW1_Config.md` (Step 1) | WS | 1 |
| Priority | **P1 — app security + PHI (ForcePoint DSS)** | Type | Jira backlog hand-off + security |
| Owner | SQA (process QA); InfoSec + Identity teams execute/validate |

**Applies `TC-HO-01,04,06,08,09`** from [`TC_PATTERN_JiraHandoffPhase.md`](TC_PATTERN_JiraHandoffPhase.md) (backlog of user stories; no per-env, no single title — TC-HO-02/03/05/07 adapted below).
- **User Stories:** US1 Okta SSO / Portal Integration; US2 Authentication Testing & Sign-Off; US3 ForcePoint DSS PHI Data Configuration.
- **Reference files:** `infosec/windward-okta-sso-integration.md`, `infosec/integrate-to-existing-gov-com-portal.md`, `infosec/forcepoint-dss-fingerprinting.md`.
- **Assignee:** story creation Jamie Smith (mgr Elie Abouzeid); execution InfoSec + Identity (US1/US2), InfoSec (US3).

### Preconditions
Phase 5 COMPLETE (WW1.0 & Config deployed).

## Phase-specific cases
### TC-P5.1-01: All three security user stories created, linked, assigned
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | US1/US2/US3 present with correct topic titles | All 3 present |
| 2 | Each links its infosec reference file(s); links resolve | Resolve |
| 3 | Assigned to InfoSec (+ Identity for US1/US2) | Correct |

**Pass/Fail:** Three stories created, linked, assigned.

### TC-P5.1-02 (Functional/security — SSO): Okta SSO + portal integration works
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Authenticate to WW1.0 via Okta SSO | Success |
| 2 | Confirm SSO app added is the **WW1.0** app | Correct app |
| 3 | RBAC matrix + SailPoint requestable role + AD group cross-checked by Identity Team | Consistent |

**Pass/Fail:** SSO login + RBAC provisioning correct.

### TC-P5.1-03 (Security — auth testing): Failed-login handling & auth-event logging
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Attempt invalid login | Proper error handling, no info leak |
| 2 | Confirm authentication events logged | Events captured |

**Pass/Fail:** Failed-login handled; auth events logged (US2 sign-off).

### TC-P5.1-04 (CRITICAL — PHI / ForcePoint DSS): DLP fingerprinting on PHI
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm ODBC connection + DB fingerprint job configured against the Government Database | Configured |
| 2 | Confirm discovery jobs target PHI with correct client-ID distinction | Correct scope |

**Pass/Fail:** ForcePoint DSS PHI fingerprinting correctly configured (US3).

### TC-P5.1-05 (DOC DEFECTS): Missing AC; relative links; status inconsistency
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Note no Acceptance Criteria given (other phases have AC) | Logged |
| 2 | Reference links are relative `../architecture/...` (may not resolve from Jira) | Logged |
| 3 | Checklist all "NOT STARTED" vs siblings "COMPLETE" | Logged |

**Pass/Fail:** Defects D-P5.1-1..3 logged.

## Completion Checklist Coverage
| Deliverable | Covered by |
|-------------|-----------|
| Security stories created/assigned | TC-P5.1-01 |
| SSO/auth deployed & validated | TC-P5.1-02, 03 |
| ForcePoint DSS PHI configured | TC-P5.1-04 |

## Defects
| ID | Observation | Sev |
|----|-------------|-----|
| D-P5.1-1 | No Acceptance Criteria defined | S3 |
| D-P5.1-2 | Relative `../architecture` links may not resolve from a Jira ticket | S4 |
| D-P5.1-3 | Checklist status inconsistent with sibling phases | S4 |

## Execution Record
| TC | Date | Tester | Result | Defect | Notes |
|----|------|--------|--------|--------|-------|
| TC-P5.1-01 | | | | | |
| TC-P5.1-02 | | | | | |
| TC-P5.1-03 | | | | | |
| TC-P5.1-04 | | | | | |
| TC-P5.1-05 | | | | | |
