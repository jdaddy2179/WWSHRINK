# Test Cases — Phase 5: Deploy WW1.0 & Config

| Field | Value |
|-------|-------|
| Playbook reference | `Phase05_DeployWW1.0AndConfig.md` (Steps 1–2) | WS | 1 |
| Priority | P2 (core app deploy) + **functional + performance in scope** | Type | Jira hand-off + functional validation |
| Owner | SQA / executor (Citrix validation); Application Services Team deploys |

**Applies `TC-HO-01..09`** from [`TC_PATTERN_JiraHandoffPhase.md`](TC_PATTERN_JiraHandoffPhase.md):
- **Titles:** Step 1 `Windward 1.0 Application Deployment - REF[Tenant Name]`; Step 2 `Windward Config Module Deployment - REF[Tenant Name]`.
- **AC:** "...deployed successfully to REF[Environment], application/Configuration module is accessible and running".
- **Links:** windward-1.0, windward-2.0, **applications-deployment-WW** (`/architecture/applications-deployment-WW`).
- **Assignee:** Application Services Team — Daniel Hobert (mgr William Munns).
- **TC-HO-07 sequential env applies (DEV→QAR→PROD→HFX; QAR not provisioned until DEV approved).**

### Preconditions
Phases 3, 3.3, 4, 4.1 (PROD), 4.2, 4.3, 4.4, 4.5 COMPLETE. Step 2 requires Step 1 COMPLETE.

## Phase-specific cases
### TC-P5-01 (Functional — WW1.0 accessible): App reachable via Citrix/Edge on internal network
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Open WW1.0 URL built from `REF[windward-app-NLB-loadbalancer-https-Alias]` (verify alias value, not hardcoded) | App loads |
| 2 | Confirm access is internal-only (Citrix/Edge), not externally exposed | Internal-only |
| 3 | Daniel Hobert sanity test + executor login | Running, no errors |

**Pass/Fail:** WW1.0 accessible and running via the correct alias on the internal network.

### TC-P5-02 (Functional — Config module navigation): Config reached through WW1.0 URL
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | From WW1.0, perform Group/Standard search | Lands on WW2.0 Group Config page |
| 2 | Click "Home" | "Welcome to Configuration UI" displayed |

**Pass/Fail:** Config module reachable and rendering correctly through WW1.0.

### TC-P5-03 (Performance): Tier-sized app/DB sustains expected load
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Drive representative member/claims navigation load for the Tier | Response times within threshold |
| 2 | Monitor server/DB resource use (incl. WW-Shrink-reduced DB) | Within Tier capacity |

**Pass/Fail:** Meets performance thresholds for the Tier.

### TC-P5-04 (DOC DEFECT): Config mislabeled "Windward 2.0"; broken cross-link from 5.2
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Step 2 prereq calls the Config module "Windward 2.0" (vs title "Config Module") | Inconsistency confirmed |
| 2 | Phase 5.2 links this phase as `Phase05_DeployWWApplications.md` (actual file `Phase05_DeployWW1.0AndConfig.md`) | Broken link confirmed |

**Pass/Fail:** Defects D-P5-1 (mislabel) and D-P5-2 (broken cross-link) logged.

## Completion Checklist Coverage
| Deliverable | Covered by |
|-------------|-----------|
| Deploy tickets created/assigned | TC-HO-01..06 |
| WW1.0 deployed & accessible | TC-P5-01, TC-HO-08 |
| Config deployed & accessible | TC-P5-02 |
| Functional + performance validated | TC-P5-01..03 |

## Defects
| ID | Observation | Sev |
|----|-------------|-----|
| D-P5-1 | Config module mislabeled "Windward 2.0" in Step 2 prereq | S3 |
| D-P5-2 | Phase 5.2 → `Phase05_DeployWWApplications.md` broken link to this phase | S3 |

## Execution Record
| TC | Date | Tester | Env | Result | Defect | Notes |
|----|------|--------|-----|--------|--------|-------|
| TC-HO-01..09 | | | | | | |
| TC-P5-01 | | | | | | |
| TC-P5-02 | | | | | | |
| TC-P5-03 | | | | | | |
| TC-P5-04 | | | | | | |
