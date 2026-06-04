# Test Cases — Phase 3.4: Infrastructure-level Security

| Field | Value |
|-------|-------|
| Playbook reference | `Phase03.4_Infrastructure_Security.md` (Steps 1–2) |
| Priority | P1 (security controls on PHI-bearing infrastructure) |
| Type | Decision branch + Jira hand-off + security |
| Owner | SQA (process QA); InfoSec Team executes & validates |

### Preconditions
- Phase 3 COMPLETE; servers provisioned in AWS; server/IP/LB details in Env Variables.
- Access: ADO InfoSec folder, IT Intake portal (Step 1), DQ Jira (Step 2).

---

## Step 1 — IT Intake (conditional)

### TC-P3.4-01 (CRITICAL — Decision table): IT Intake submitted only when required
**Objective:** Verify the operator correctly decides whether Step 1 applies. Step 1 is **project-level**, not per-client.

| # | Scenario | Expected decision |
|---|----------|-------------------|
| 1 | New project; InfoSec not yet engaged | **Submit** IT Intake |
| 2 | Project restarted after a multi-month pause; resources may be re-assigned | **Submit** IT Intake (re-allocate) |
| 3 | Project active; InfoSec currently allocated & engaged | **Skip** to Step 2 |
| 4 | New client within a running project, no InfoSec gap | **Skip** to Step 2 |

**Pass/Fail:** Operator's submit/skip choice matches the expected decision for each scenario. Wrong choice = Fail (either wasted intake or unallocated InfoSec).

### TC-P3.4-02: IT Intake form completed correctly (when submitted)
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Initiative Type = "Project" | Selected |
| 2 | Subject = "InfoSec Security Controls Setup - <Tenant Name>" (real name, no `REF[]`) | Correct |
| 3 | Reported By + email completed | Present |
| 4 | Additional Details include Env Variables + InfoSec Requirements links | Both resolve |
| 5 | Submit; capture ticket number | Number saved/tracked |
| 6 | Notify InfoSec team with ticket number (email/Teams) | Notification sent |

**Pass/Fail:** Form correct, ticket number captured & tracked, InfoSec notified.

### TC-P3.4-03 (Prereq data): Server/IP/LB details present before intake
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm Env Variables has servers, IPs, load balancers, components | Complete |
| 2 | If missing → contact Cloud Infra before submitting | Gap routed |

**Pass/Fail:** InfoSec receives complete infrastructure details.

---

## Step 2 — Jira Security Backlog (always required)

### TC-P3.4-04 (CRITICAL): Step 2 performed for EVERY client regardless of Step 1
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm Step 2 executed even when Step 1 was skipped | Always done |

**Pass/Fail:** Step 2 never skipped.

### TC-P3.4-05: All 5 security user stories created with correct titles, references, assignment
**Objective:** Verify each user story exists with `REF[Tenant ID]` substituted, correct reference doc(s), AC, and InfoSec assignment.

| US | Title (Tenant ID substituted) | Reference file(s) |
|----|-------------------------------|-------------------|
| 1 | AWS Server Setup - <Tenant ID> | `aws-server-setup.md` |
| 2 | Create Access Roles - <Tenant ID> | `aws-server-setup.md`, `windward-okta-sso-integration.md` |
| 3 | Kerberos / AD Prerequisites (OAG) - <Tenant ID> | `oag-instructions.md` |
| 4 | Security Control Validations - <Tenant ID> | `security-controls-validation.md` |
| 5 | ForcePoint DSS Server Provisioning - <Tenant ID> *(requires PHI-ready servers)* | `forcepoint-dss-fingerprinting.md` |

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Verify all 5 stories present with exact titles (Tenant ID, no `REF[]`) | All present |
| 2 | Verify each links its reference file(s) and they resolve | All resolve |
| 3 | Verify AC = "All tasks in the referenced document(s) are created under this user story and completed by the InfoSec team" | Present |
| 4 | Verify all assigned to Information Security Team | Assigned |

**Pass/Fail:** All 5 stories correct, linked, and assigned.

### TC-P3.4-06 (Sequencing — US5 PHI gate): ForcePoint DSS requires PHI-ready servers
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm US5 is gated on PHI-ready servers | Not executed before servers PHI-ready |

**Pass/Fail:** US5 dependency respected (DLP fingerprinting on PHI-bearing servers).

### TC-P3.4-07 (Hand-off outcome): Security controls deployed & validated by InfoSec
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Await InfoSec confirmation (email/Teams) | Controls deployed & validated |
| 2 | Confirm all backlog stories/tasks closed | Closed |

**Pass/Fail:** InfoSec confirms controls deployed and validated.

### TC-P3.4-08 (Negative — prereq): If Step 1 applied, it must be COMPLETE before Step 2 closure
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Where Step 1 applied, verify intake submitted & InfoSec notified before relying on Step 2 execution | Enforced |

**Pass/Fail:** Conditional prerequisite honored.

---

## Completion Checklist Coverage
| Deliverable | Covered by |
|-------------|-----------|
| IT Intake submitted (when applicable) & assigned | TC-P3.4-01, 02, 03 |
| Security user stories/tasks created in Jira | TC-P3.4-04, 05, 06 |
| Stories/tasks assigned to InfoSec | TC-P3.4-05 |
| Controls deployed & validated by InfoSec | TC-P3.4-07 |

## Execution Record
| TC | Date | Tester | Result | Defect | Notes |
|----|------|--------|--------|--------|-------|
| TC-P3.4-01 | | | | | |
| TC-P3.4-02 | | | | | |
| TC-P3.4-03 | | | | | |
| TC-P3.4-04 | | | | | |
| TC-P3.4-05 | | | | | |
| TC-P3.4-06 | | | | | |
| TC-P3.4-07 | | | | | |
| TC-P3.4-08 | | | | | |
