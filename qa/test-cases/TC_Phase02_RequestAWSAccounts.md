# Test Cases — Phase 2: Request AWS Accounts

| Field | Value |
|-------|-------|
| Playbook reference | `Phase02_RequestAWSAccounts.md` (Step 1) |
| Priority | P2 (gates account creation → all infrastructure) |
| Environment | ServiceNow (request) → AWS (created by Cloud Infra) |
| Requires PHI access | No |
| Owner | SQA Team; fulfillment: Cloud Infra (Erik / Kenneth Holton) |

### Preconditions
- Phase 1 deliverables COMPLETE (Environment Variables populated for the client).
- Access to DQ ServiceNow (Okta tile).
- Access to the Environment Variables spreadsheet.

### Test Data
- A client tab in Env Variables with all `REF[]` source values populated (AWS Accounts, Cost Center, Environment, Environment Prefix, Primary/Secondary Owner, Support Group, Account Type, Application (CMDB), ATG, New/Existing role).
- Multi-value fields (AWS Accounts, Environment, Environment Prefix) spanning spreadsheet Columns C–F.

---

### TC-P2-01: ServiceNow navigation path is correct
**Objective:** Verify the request is raised via the documented catalog path.

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Service Catalog → "Are you requesting something new?" → Infrastructure Request | Form opens |
| 2 | Type of Request = "Cloud Request" | Selected |
| 3 | Cloud Provider = "AWS" | Selected |
| 4 | Short Description = "AWS Accounts Request" | Entered |

**Pass/Fail:** Correct catalog item and field selections reached.

### TC-P2-02 (CRITICAL — Data): All REF[] placeholders replaced with Env Variables values
**Objective:** Verify every `REF[]` token in the Additional Comments table is replaced with the matching Column C value; **no placeholder remains**.

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Paste the 11-row request table into Additional Comments | Table present |
| 2 | Replace each REF[] (AWS Accounts, Cost Center, Environment, Environment Prefix, Primary Owner, Secondary Owner, Support Group, Account Type, Application (CMDB), ATG, New/Existing role) | All replaced |
| 3 | Search the comment for the literal string "REF[" | Zero matches |

**Pass/Fail:** No unresolved `REF[]` remains. Any leftover = Fail (S2).

### TC-P2-03 (Multi-value fields): AWS Accounts / Environment / Environment Prefix expanded as separate columns
**Objective:** Verify multi-value fields (spreadsheet Columns C–F) are entered as separate columns per the example, not collapsed into one cell.

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Identify DEV/QAR/PROD/HFX values for AWS Accounts, Environment, Environment Prefix | All values listed |
| 2 | Render each as its own column in the request table | Matches `aws-account-request-details.png` example |

**Pass/Fail:** Multi-value fields expanded correctly and completely.

### TC-P2-04 (Data validation): Ticket content matches Env Variables exactly
**Objective:** Verify no discrepancy between ticket values and spreadsheet (Instruction #7).

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Compare each ticket value to spreadsheet Column C–F | Character-for-character match |
| 2 | Confirm no extra/missing fields | All 11 keys present |

**Pass/Fail:** Zero discrepancies before submission.

### TC-P2-05: Ticket submitted and routed to Cloud Infra
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Click "Order Now" | Ticket created with a number |
| 2 | Confirm work routes to Cloud Infra (Erik / mgr Kenneth Holton) | Assignment correct |
| 3 | Record ticket number for Phase 2.1 reference | Captured |

**Pass/Fail:** Ticket submitted, numbered, and routed correctly.

### TC-P2-06 (Negative): Phase 1 incomplete blocks Phase 2
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Attempt Phase 2 with missing/blank Env Variables values | Cannot complete — REF[] values unavailable |

**Pass/Fail:** Phase correctly blocked when prerequisite incomplete.

### TC-P2-07 (Handoff outcome): Accounts created and documented post-resolution
**Objective:** Verify the completion-checklist hand-off: after ticket Resolved, accounts exist and Account ID/IAM Role are documented in Env Variables by Cloud Infra (filter Column A = "AWS Account").

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | After ticket Resolved, check Env Variables Column A filtered to "AWS Account" | Account ID & IAM Role populated for all envs |
| 2 | Confirm accounts exist in AWS | Validated in Phase 2.1 |

**Pass/Fail:** Accounts created and documented; otherwise re-engage Cloud Infra. (Detailed account/naming validation lives in `TC_Phase02.1`.)

### TC-P2-08 (Static): Links, image, and Jira-vs-ServiceNow note
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm `aws-account-request-details.png` present | Exists |
| 2 | Follow Env Variables link | Resolves |
| 3 | Note: playbook states ServiceNow is preferred over Jira going forward | Operator uses ServiceNow (not the legacy Jira backlog) |

**Pass/Fail:** No broken links/images; operator uses the correct (ServiceNow) channel.

---

## Phase 2 Completion Checklist Coverage
| Deliverable | Covered by |
|-------------|-----------|
| ServiceNow ticket created | TC-P2-01..04 |
| Ticket submitted & assigned to Cloud Infra | TC-P2-05 |
| Accounts created after ticket Resolved | TC-P2-07 |
| Account details documented in Env Variables | TC-P2-07 |

## Execution Record
| TC | Date | Tester | Env | Result | Defect | Notes |
|----|------|--------|-----|--------|--------|-------|
| TC-P2-01 | | | | | | |
| TC-P2-02 | | | | | | |
| TC-P2-03 | | | | | | |
| TC-P2-04 | | | | | | |
| TC-P2-05 | | | | | | |
| TC-P2-06 | | | | | | |
| TC-P2-07 | | | | | | |
| TC-P2-08 | | | | | | |
