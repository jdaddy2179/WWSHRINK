# Test Cases — Phase 2.1: AWS Platform Access & Test AWS Accounts

| Field | Value |
|-------|-------|
| Playbook reference | `Phase02.1_TestAWSAccounts.md` (Step 1, Parts A/B/C) — aligned to Hetal's update *"Refined for CCP‑1745"* (2026‑06‑12) |
| Priority | P2 (gates all infrastructure provisioning) |
| Environment | AWS (DEV, QAR, PROD, HFX) |
| Requires PHI access | No direct PHI, but PROD account access is privileged |
| Owner | SQA Team (validation); Cloud Infra (account creation); InfoSec (access) |

### Preconditions
- Phase 2 deliverables COMPLETE (AWS account ServiceNow ticket raised, accounts created).
- SailPoint tile available via Okta.
- At least one AWS account created by Cloud Infra Team.
- **Account ID** and **IAM Role** documented in Environment Variables by Cloud Infra for the environment(s) under test.

### Test Data
| Field | Example |
|-------|---------|
| Account ID | 150411087997 (12 digits) |
| IAM Role | aws-oktaSSO-windward-devrole |
| Region | us-east-1 |
| Environments | DEV, QAR, PROD, HFX |

---

## Part A — Request AWS Access

> **Skip condition (new — playbook "Refined for CCP‑1745"):** if the tester already has the **"AWS Development"** role active in SailPoint, Part A (steps 1–7) is skipped and they go straight to Part B. Validated by **TC‑P2.1‑11**.

### TC-P2.1-01: SailPoint request for "AWS Development" role
**Objective:** Verify the access request is raised correctly and references the Phase 2 ticket.

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Open DQ SailPoint (Okta tile) → Request Center | Request Center loads |
| 2 | Search "AWS Development" role | Role found |
| 3 | Add comment with Tenant Name + Phase 2 ticket number/link | Comment saved |
| 4 | Submit request | Request submitted; pending approval |

**Pass/Fail:** Correct role requested with required comment/ticket reference.

### TC-P2.1-02 (Negative): Wrong/ambiguous role selection is caught
**Objective:** Verify operator can identify the correct role despite SailPoint naming ambiguity (per Common Issues).

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Search roles; observe unclear names | Ambiguity reproduced |
| 2 | Escalate to InfoSec (Jamie Smith) per documented resolution | "AWS Development" confirmed as correct role |

**Pass/Fail:** Operator lands on the correct role; resolution path works.

### TC-P2.1-11 (Decision path — NEW): Part A skipped when "AWS Development" role already active
**Objective:** Verify the new skip path — if the tester already holds the "AWS Development" role in SailPoint, the request (Part A) is skipped and they proceed to Part B.

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Open DQ SailPoint → check current access for "AWS Development" | If listed/active → no new request needed (per the new NOTE + screenshot) |
| 2 | When the role is active, proceed directly to Part B (login) | Part A steps 1–7 skipped |
| 3 | When the role is NOT active, perform the request (TC‑P2.1‑01) | Falls back to the request path |

**Pass/Fail:** Tester skips Part A when the role is already active, or requests it when it isn't.

---

## Part B — Login to AWS Console

### TC-P2.1-03: Login to AWS landing account via Okta Federation
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | After approval, open Okta → AWS Account Federation tile | Lands in default/landing account (NOT client account) |
| 2 | Confirm dev/qar/stage roles visible | Roles listed |
| 3 | Select a role (e.g., aws-oktaSSO-windward-devrole) → Sign in | AWS Console Home loads |

**Pass/Fail:** Successful login; operator understands landing ≠ client account.

### TC-P2.1-04 (Negative): PROD account may require separate InfoSec request
**Objective:** Verify the documented exception that PROD may need a separate account/request.

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Attempt to reach PROD role from landing page | If absent, operator contacts InfoSec for separate PROD account |

**Pass/Fail:** PROD access gap recognized and routed correctly (gap G6).

---

## Part C — Validate AWS Accounts

### TC-P2.1-05 (CRITICAL): Region pinned to us-east-1 before any action
**Objective:** Verify region is set to us-east-1 first (playbook: "DO NOT skip this step").

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Check region selector | Shows us-east-1 (or operator switches to it) |
| 2 | Proceed only after region confirmed | All subsequent validation in us-east-1 |

**Pass/Fail:** Region is us-east-1 before switching roles. Wrong region = Fail.

### TC-P2.1-06: Switch Role into the client account
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Top-right account dropdown → Switch Role | Switch Role form opens |
| 2 | Paste Account ID + IAM role from Env Variables for the target env | Values entered; optional fields blank |
| 3 | Click Switch Role | Top-right shows new client account name + ID |

**Pass/Fail:** Switch succeeds into the correct client account.

### TC-P2.1-07 (Data validation, CRITICAL): Account details match Env Variables — Account ID + AWS Accounts alias
**Objective:** Verify the created account **details match** the Environment Variables values for **`REF[Account ID (account #)]`** and **`REF[AWS Accounts]`** (per updated Step 19). The playbook now frames this as *details match / no major mistakes*, not strict naming only.

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Read the account name/alias in the AWS top-right | Matches `REF[AWS Accounts]` (e.g., `DQ-KCL-DEV-US`) |
| 2 | Confirm **Account ID = 12 digits** and matches `REF[Account ID (account #)]` for that env | Exact match |
| 3 | Confirm IAM role matches the env (devrole/qarrole/…) | Matches |

**Pass/Fail:** Account ID matches exactly and the account name matches the spreadsheet with **no major naming mistakes**. An Account‑ID mismatch or major naming error = Fail (route to Cloud Infra/InfoSec).

### TC-P2.1-08: Validate ALL environments (DEV, QAR, PROD, HFX)
**Objective:** Verify the switch-and-validate procedure is repeated for every environment.

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | For each of DEV, QAR, PROD, HFX: close console, re-open Federation tile, pick the env role, sign in | Lands in correct env landing |
| 2 | Repeat region check + switch role + details validation (TC-05..07) | Each env validated |
| 3 | Confirm none missing | All four accounts exist & valid |

**Pass/Fail:** All four environments validated; Account IDs + account names match Env Variables. Missing env = Fail (gap → Cloud Infra).

### TC-P2.1-09 (Negative): Missing account, incorrect Account ID, or major naming mistake detected & routed
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Encounter a missing account, **incorrect Account ID**, or **major mistake in naming convention** | Detected during validation |
| 2 | Follow documented escalation | Contact Cloud Infra (Erik/Lindsay) or InfoSec (Jamie Smith) |

**Pass/Fail:** Issue detected and escalated per playbook (not silently passed).

---

## Documentation / Static Review (Phase 2.1)

### TC-P2.1-10: Screenshots & links present and current
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm referenced images exist (aws-development-role-sailpoint, aws-landing, console-home-page, us-east-1, switch-role-dropdown, accountid-iamrole, switch-success-2, account-confirm, aws-landing-qar) | All present |
| 2 | Follow Phase 2 / Env Variables links | Resolve correctly |

**Pass/Fail:** No missing screenshots or broken links.

---

## Phase 2.1 Completion Checklist Coverage
| Deliverable | Covered by |
|-------------|-----------|
| Part A — AWS Development role verified or requested/approved (skip if already active) | TC-P2.1-01, 02, 11 |
| Part B — login to AWS Console via Okta Federation | TC-P2.1-03, 04 |
| Part C — AWS accounts validated post-ticket | TC-P2.1-05, 06, 07, 08, 09 |
| Account details match Env Variables (no major mistakes) | TC-P2.1-07, 08 |

## Execution Record
| TC | Date | Tester | Env | Result | Defect | Notes |
|----|------|--------|-----|--------|--------|-------|
| TC-P2.1-01 | | | | | | |
| TC-P2.1-02 | | | | | | |
| TC-P2.1-03 | | | | | | |
| TC-P2.1-04 | | | | | | |
| TC-P2.1-05 | | | | | | |
| TC-P2.1-06 | | | | | | |
| TC-P2.1-07 | | | | | | |
| TC-P2.1-08 | | | | | | |
| TC-P2.1-09 | | | | | | |
| TC-P2.1-10 | | | | | | |
| TC-P2.1-11 | | | | | | |

---

## Playbook Reference
This suite validates the playbook item **[Phase02.1_TestAWSAccounts.md](https://dev.azure.com/EnterpriseRepo/Application%20Services/_git/com-client-pilot?path=/Playbook/Phase02.1_TestAWSAccounts.md&version=GBmain)** (`com-client-pilot/Playbook/`).

Related: [Jira ↔ Playbook matrix](../../JiraPlaybookMatrix.md) · [Test Strategy](../../TestStrategy.md) · [Traceability Matrix](../../TraceabilityMatrix.md)
