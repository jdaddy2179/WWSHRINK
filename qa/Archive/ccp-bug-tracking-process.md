# CCP Jira Board — Bug Tracking Process

## Purpose

This document defines the standard process for the **Com Client Pilot (CCP) Jira board** for handling bugs discovered during testing — specifically clarifying when to track a bug as a task/sub-task vs. when to open a dedicated Bug ticket.

---

## Bug vs. Task — Decision Guide

| Scenario | Use a Bug | Use a Task/Sub-task |
|---|:---:|:---:|
| Defect found during SQA / QA testing of a feature | ✅ Yes | ❌ No |
| Defect found during UAT | ✅ Yes | ❌ No |
| Defect found in Production or a higher environment | ✅ Yes | ❌ No |
| Something is broken and blocking testing | ✅ Yes | ❌ No |
| Work item is a configuration change needed to enable testing | ❌ No | ✅ Yes |
| Work item is a setup or infrastructure task | ❌ No | ✅ Yes |
| Work item was known before testing started (pre-planned work) | ❌ No | ✅ Yes |
| Small fix that is a natural part of completing a story | ❌ No | ✅ Sub-task |

---

## When to Open a Bug

Open a **Bug** in Jira when:

- A feature, API, or service behaves differently than the acceptance criteria or expected behavior
- A defect is found during SQA, UAT, smoke testing, or regression testing
- A previously passing test is now failing (regression)
- An error, crash, or unexpected response occurs in a deployed environment

### Required Fields When Opening a Bug

| Field | Description |
|---|---|
| **Summary** | Brief description of what is broken |
| **Environment** | Dev / QAR / UAT / Prod |
| **Steps to Reproduce** | Numbered steps to reliably reproduce the issue |
| **Expected Result** | What should happen |
| **Actual Result** | What actually happens |
| **Severity** | Critical / High / Medium / Low |
| **Linked Story/Epic** | Link to the feature or epic under test |
| **Attachments** | Screenshots, logs, Postman response bodies |

---

## When to Use a Task or Sub-task

Use a **Task** or **Sub-task** when:

- The work is a planned configuration, setup, or infrastructure change
- The work is needed to enable testing (not a result of a test failure)
- The item was identified during story breakdown before any testing occurred

> **Real Example:** "Update API Gateway resource policy" (CCP-656) is a **Task**, not a Bug — it is a known configuration requirement, not a defect introduced by code.

---

## Bug Severity Definitions

| Severity | Definition | Example |
|---|---|---|
| **Critical** | System is down or core function completely broken. Testing cannot proceed. | Auth service returns 500 for all users |
| **High** | Major feature is broken. Workaround is difficult or impossible. | Claims API returns 403 for all SQA test roles |
| **Medium** | Feature is partially broken. Workaround exists. | One claims filter returns wrong results |
| **Low** | Minor issue. Cosmetic or edge case. | Typo in an error message |

---

## Bug Lifecycle on the CCP Board

```
Open → In Progress → In Review → Done
```

1. **Open** — Bug is logged with all required fields. Assigned to the responsible dev/infra team.
2. **In Progress** — Assignee is actively working the fix.
3. **In Review** — Fix is deployed to the environment. QA is re-testing.
4. **Done** — Bug is verified fixed by QA. Closed with a comment confirming resolution.

---

## CCP-Specific Notes

- For **Next Gen testing (CCP-550)**, bugs found during API/domain service testing should be opened as Bugs and linked back to CCP-550.
- **Infrastructure blockers** like the API Gateway resource policy fix (CCP-651) should remain as Stories with Sub-tasks — not Bugs.
- Bugs found during **Windward Smoke Testing (CCP-542)** should be linked to that epic.
- All bugs impacting the **dev AWS environment** should include: Account ID, API Gateway ID, and Stage in the description.
