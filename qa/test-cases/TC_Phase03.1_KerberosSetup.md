# Test Cases — Phase 3.1: Kerberos Setup

| Field | Value |
|-------|-------|
| Playbook reference | `Phase03.1_KerberosSetup.md` (Step 1) |
| Priority | P3 | Type | Jira hand-off |
| Owner | SQA (ticket QA); Kerberos Team (Brian Hughes) executes & validates |

**Applies `TC-HO-01..09`** from [`TC_PATTERN_JiraHandoffPhase.md`](TC_PATTERN_JiraHandoffPhase.md), instantiated with:
- **Backlog:** client-specific Jira backlog (e.g., CCP).
- **Title:** `Kerberos Setup - REF[Tenant Name]`.
- **Description links:** architecture folder, windward-1.0, windward-2.0, **Kerberos Setup documentation** (`/architecture/kerberos-setup`), Env Variables.
- **Acceptance Criteria:** "Kerberos should be configured and validated for the tenant AWS environment".
- **Assignee:** Kerberos Team — Brian Hughes (lo85@greatdentalplans.com).
- **Tier reference:** required (TC-HO-03).
- **Sequential env order (TC-HO-07):** N/A (single ticket).

### Preconditions
- Phase 3 (Infrastructure) COMPLETE. Access: Azure DevOps, DQ Jira, Env Variables. (If no ADO access → SailPoint 'Azure DevOps Services - Basic'.)

## Phase-specific cases
### TC-P3.1-01: Kerberos architecture documentation link is present and correct
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm Description includes the `/architecture/kerberos-setup` link (not just generic arch) | Present & resolves |

**Pass/Fail:** Kerberos-specific doc linked.

### TC-P3.1-02 (Hand-off outcome): Kerberos configured AND validated by Kerberos Team
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Await Jira ticket → Done or completion comment | Kerberos Team confirms configured + validated |
| 2 | Confirm all three Outputs evidenced (ticket w/ link & assignment; configured; validated) | Yes |

**Pass/Fail:** Configuration and validation both confirmed by Kerberos Team (note: this phase delegates validation entirely to that team — SQA verifies the confirmation exists).

## Completion Checklist Coverage
| Deliverable | Covered by |
|-------------|-----------|
| Ticket created w/ Kerberos doc link, assigned | TC-HO-01..06, TC-P3.1-01 |
| Kerberos configured by team | TC-P3.1-02 / TC-HO-08 |
| Kerberos validated & confirmed | TC-P3.1-02 / TC-HO-08 |

## Execution Record
| TC | Date | Tester | Result | Defect | Notes |
|----|------|--------|--------|--------|-------|
| TC-HO-01..09 | | | | | |
| TC-P3.1-01 | | | | | |
| TC-P3.1-02 | | | | | |
