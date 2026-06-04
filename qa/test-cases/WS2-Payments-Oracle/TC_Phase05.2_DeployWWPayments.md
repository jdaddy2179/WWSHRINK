# Test Cases — Phase 5.2: Deploy WW Payments

| Field | Value |
|-------|-------|
| Playbook reference | `Phase05.2_DeployWWPayments.md` (Step 1) | WS | 2 |
| Priority | **P1 — financial module** + functional in scope | Type | Jira hand-off + functional |
| Owner | SQA / executor (Citrix validation); Application Services Team deploys |

**Applies `TC-HO-01..09`** from [`TC_PATTERN_JiraHandoffPhase.md`](../_shared/TC_PATTERN_JiraHandoffPhase.md):
- **Title:** `Windward Payments Module Deployment - REF[Tenant Name]`.
- **AC:** "Windward Payments module deployed successfully to REF[Environment], Payment module is accessible and running".
- **Links:** windward-2.0, **applications-deployment-WW**.
- **Assignee:** Application Services Team — Daniel Hobert (mgr William Munns). **TC-HO-07 sequential env applies.**

### Preconditions
Phase 5 (WW1.0 + Config) COMPLETE.

## Phase-specific cases
### TC-P5.2-01 (Functional — Payments navigation): Reach Payment UI via WW1.0 → Commercial BU
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | From WW1.0 URL, select **"Commercial"** business unit | BU selected |
| 2 | Navigate "Misc Payment Transaction" → Miscellaneous Transactions page | Page loads |
| 3 | Click "Home" → "Welcome to Payment UI" | Displayed |

**Pass/Fail:** Payment module reachable; business-unit dropdown step works.

### TC-P5.2-02 (CRITICAL — Tier file): Correct Tier deployment file selected
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm "select appropriate tier file" uses the Tier from Phase 1 | Correct Tier file |

**Pass/Fail:** Correct Tier file used. Wrong tier = wrong payment deploy = Fail.

### TC-P5.2-03 (Functional — payment integrity): Core payment transaction works on reduced DB
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Execute a representative miscellaneous payment transaction (test data) | Processes correctly |
| 2 | Confirm operates against the correctly-scoped (WW-Shrink) Payment DB | Client data only |

**Pass/Fail:** Payment transaction functions correctly against the right data.

### TC-P5.2-04 (DOC DEFECTS): Broken Phase 5 link; duplicate description link
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Prereqs link Phase 5 as `Phase05_DeployWWApplications.md` (actual `Phase05_DeployWW1.0AndConfig.md`) | Broken link (3×) |
| 2 | Description link #4 duplicates #3 (`applications-deployment-WW`) | Placeholder/wrong link |

**Pass/Fail:** Defects D-P5.2-1/2 logged.

## Completion Checklist Coverage
| Deliverable | Covered by |
|-------------|-----------|
| Deploy ticket created/assigned | TC-HO-01..06 |
| Payments deployed & accessible | TC-P5.2-01, TC-HO-08 |
| Correct Tier deployment | TC-P5.2-02 |
| Payment functionality validated | TC-P5.2-03 |

## Defects
| ID | Observation | Sev |
|----|-------------|-----|
| D-P5.2-1 | Broken link to Phase 5 (`Phase05_DeployWWApplications.md`) | S3 |
| D-P5.2-2 | Duplicate/placeholder description link #4 | S4 |

## Execution Record
| TC | Date | Tester | Env | Result | Defect | Notes |
|----|------|--------|-----|--------|--------|-------|
| TC-HO-01..09 | | | | | | |
| TC-P5.2-01 | | | | | | |
| TC-P5.2-02 | | | | | | |
| TC-P5.2-03 | | | | | | |
| TC-P5.2-04 | | | | | | |
