# Test Cases — Phase 3: Provision Tenant Infrastructure on AWS

| Field | Value |
|-------|-------|
| Playbook reference | `Phase03_Infrastructure.md` (Steps 1–2) |
| Priority | P2 (provisions all tenant servers; Tier-driven sizing) |
| Environment | Jira (request) → AWS (DEV→QAR→PROD→HFX validation) |
| Requires PHI access | No (server-existence validation only) |
| Owner | SQA (validation); Cloud Infra (provisioning) |

### Preconditions
- Phase 2 and Phase 2.1 deliverables COMPLETE (accounts validated).
- Access to Azure DevOps, DQ Jira, Environment Variables, AWS platform.

---

## Step 1 — Create Jira provisioning ticket

### TC-P3-01: User Story created with correct title, Tier-referenced description, links
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Create story in the client's Jira backlog | Story created |
| 2 | Title = "Tenant AWS Provisioning - <Tenant Name>" (from Env Variables) | Exact format, real tenant name (no `REF[]`) |
| 3 | Description references **Tier from Phase 1** and links: architecture folder, windward-1.0, windward-2.0, Env Variables, Costing.xls | All present and resolve |
| 4 | Acceptance Criteria matches playbook wording (server setup complete, names/IPs documented, validated) | Present |
| 5 | Assign to Cloud Infra (Erik / mgr David DiPerna) | Assigned |

**Pass/Fail:** Ticket complete, Tier correct, links resolve, assigned correctly.

### TC-P3-02 (Negative): Wrong Tier referenced → wrong architecture sizing
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Cross-check Tier in ticket vs Phase 1 Env Variables | Identical |
| 2 | Inject a mismatched Tier (e.g., Tier 2 for a Tier 3 client) | Caught in review before assignment |

**Pass/Fail:** Tier in ticket always equals Phase 1 Tier (drives server list).

## Step 2 — Validate AWS Infrastructure

### TC-P3-03 (Sequential order): Validate per environment in DEV→QAR→PROD→HFX order
**Objective:** Verify the documented provisioning/validation order is honored (DEV validated & approved before QAR provisioned, etc.).

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Validate DEV first | DEV validated before QAR appears |
| 2 | Proceed only after each env approved | Order preserved through HFX |

**Pass/Fail:** Environments validated strictly in sequence.

### TC-P3-04 (CRITICAL — Naming): All servers exist with correct naming per Env Variables
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | AWS Console → EC2 → Instances (running) | Instance list loads |
| 2 | Compare running instances to the expected server list for the Tier (architecture + Env Variables tab) | Every expected server present |
| 3 | Verify each server name matches the naming convention exactly | All match |
| 4 | Confirm no missing and no unexpected extra servers | Set matches expected |

**Pass/Fail:** Full server set present with correct names. Missing/misnamed = Fail → Cloud Infra.

### TC-P3-05: Server names & IPs documented in Env Variables by Cloud Infra
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Open client tab in Env Variables | Server names + IPs populated |
| 2 | Cross-check against AWS console | Consistent |

**Pass/Fail:** Documentation complete and matches AWS.

### TC-P3-06 (Negative): Missing component / wrong naming is logged and escalated
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Encounter missing/misnamed server | Logged as issue |
| 2 | Escalate to Cloud Infra (Erik/Lindsay) | Routed correctly |

**Pass/Fail:** Issue detected and escalated, not passed.

### TC-P3-07 (Documentation defect): Incomplete "Connect to AWS server" step
**Objective:** Flag that Step 2.3.d is an unfinished `TODO` ("Add steps here for Connect to AWS server").

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Attempt to follow Step 2.3.d | No instructions present → cannot execute |

**Pass/Fail:** Gap confirmed and logged (defect D-P3-1); connect-to-server validation deferred until authored. Scope note acknowledged: detailed functional/LB/connectivity testing is out of this phase (separate testing playbook).

---

## Phase 3 Completion Checklist Coverage
| Deliverable | Covered by |
|-------------|-----------|
| Provisioning Jira ticket created | TC-P3-01, 02 |
| Infra provisioned, names/IPs documented, validated | TC-P3-03, 04, 05, 06 |

## Defects / Observations
| ID | Observation | Severity |
|----|-------------|----------|
| D-P3-1 | Step 2.3.d "Connect to AWS server" is an unfinished TODO | S3 |

## Execution Record
| TC | Date | Tester | Env | Result | Defect | Notes |
|----|------|--------|-----|--------|--------|-------|
| TC-P3-01 | | | | | | |
| TC-P3-02 | | | | | | |
| TC-P3-03 | | | | | | |
| TC-P3-04 | | | | | | |
| TC-P3-05 | | | | | | |
| TC-P3-06 | | | | | | |
| TC-P3-07 | | | | | | |
