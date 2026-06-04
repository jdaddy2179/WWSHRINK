# Test Cases — Phase 3.3: SSL/TLS Certificate Setup

| Field | Value |
|-------|-------|
| Playbook reference | `Phase03.3_Certificates.md` (Step 1) |
| Priority | P2 (HTTPS / encryption in transit) | Type | Jira hand-off + security validation |
| Owner | SQA (ticket QA); Application & Network + Infra teams execute/validate |

**Applies `TC-HO-01..09`** from [`TC_PATTERN_JiraHandoffPhase.md`](../_shared/TC_PATTERN_JiraHandoffPhase.md):
- **Title:** `Certificate Setup - REF[Tenant Name]`.
- **Links:** architecture folder, windward-1.0/2.0, Env Variables, **Certificate Setup steps** (`/architecture/certificates`, incl. CSR & renewal), **Security Requirements** (`/architecture/infosec`).
- **Acceptance Criteria:** "SSL/TLS certificates should be generated and applied to AWS servers and load balancers".
- **Assignees:** App & Network (Daniel Hobert, Alex Tang) generate + validate; Infra (Erik) applies to LBs.
- **Tier reference:** required.

### Preconditions (dependency-critical)
- **Phase 3 AND Phase 3.2 COMPLETE.** At minimum, **LB + alias details documented in Env Variables** and confirmed sufficient by both teams (certs bind to LB/alias names). Access: ADO, DQ Jira, Env Variables.

## Phase-specific cases
### TC-P3.3-01 (Dependency gate): Cert work blocked until LB/alias details confirmed
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Attempt cert setup with LB/alias details missing/incomplete | Blocked — prerequisite not met |
| 2 | Proceed only after both teams confirm Phase 3.2 output sufficient | Allowed |

**Pass/Fail:** Hard dependency on Phase 3.2 enforced.

### TC-P3.3-02 (CRITICAL — Security): Certificates valid, trusted, and correctly bound
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | After application, browse each HTTPS endpoint / inspect cert | Valid chain, trusted CA, not expired |
| 2 | Confirm CN/SAN matches the DNS alias/hostname | Match (no name mismatch) |
| 3 | Confirm cert applied to all servers and load balancers in scope | All covered |
| 4 | Confirm HTTPS/TLS negotiated (encrypted in transit) | Secure connection established |

**Pass/Fail:** Valid, trusted, correctly-bound certs on all endpoints.

### TC-P3.3-03: CSR & renewal process documented/followed
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm CSR generated per documented steps (PowerShell script) and ServiceNow request used to attach | Followed |
| 2 | Confirm renewal/expiry tracking exists | Renewal plan documented (avoids future outage) |

**Pass/Fail:** CSR/renewal handled per `/architecture/certificates`.

## Completion Checklist Coverage
| Deliverable | Covered by |
|-------------|-----------|
| Ticket created w/ CSR steps & LB details, assigned | TC-HO-01..06, TC-P3.3-01 |
| Certificates generated | TC-P3.3-03 / TC-HO-08 |
| Certificates applied to LBs | TC-P3.3-02 |
| Certificates validated & working | TC-P3.3-02 |

## Execution Record
| TC | Date | Tester | Result | Defect | Notes |
|----|------|--------|--------|--------|-------|
| TC-HO-01..09 | | | | | |
| TC-P3.3-01 | | | | | |
| TC-P3.3-02 | | | | | |
| TC-P3.3-03 | | | | | |
