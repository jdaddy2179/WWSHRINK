# Test Cases — Phase 10: Remove SLE Data from Original COM DB

| Field | Value |
|-------|-------|
| Playbook reference | `Phase10_RemoveSLEData.md` (Steps 1–4) | WS | TBD |
| Priority | **P1 — DESTRUCTIVE / IRREVERSIBLE deletion from original PRODUCTION COM databases** | Type | Jira hand-off + safety + data scoping + integrity |
| Owner | DBA Team executes/validates; business sign-off required |

> Removes the migrated tenant's (SLE/Selector) data from the **original COM** databases after the tenant is live on AWS. Deletion from production source-of-truth — the single most dangerous data operation in the playbook. Over-deletion = other clients' data loss; under-deletion = residual tenant data left in COM.

**Applies `TC-HO-01..06,08,09`** from [`TC_PATTERN_JiraHandoffPhase.md`](../_shared/TC_PATTERN_JiraHandoffPhase.md), once per step (4 sequential tickets):
| Step | Target DB | Title |
|------|-----------|-------|
| 1 | Original Windward DB | `Remove SLE Data from Original Windward DB - REF[Tenant Name]` |
| 2 | Original Payment DB | `Remove SLE Data from Original Payment DB - REF[Tenant Name]` |
| 3 | Original Config DB | `Remove SLE Data from Original Config DB - REF[Tenant Name]` |
| 4 | AWS Claims Domain DB | `Remove SLE Data from AWS Claims Domain - REF[Tenant Name]` |
- **AC (each):** "SLE data removed from <DB>, data removal validated with before/after record counts, backup taken prior to removal, and removal completion documented".
- **Assignee:** DBA Team (Vasudha, Anthony, Nabeel; mgr TBD). **Steps strictly sequential (1→2→3→4).**

### Preconditions (gating — all mandatory)
1. Tenant migration to AWS complete **and validated** (references "Phase 10 - Environment Testing complete" — i.e., the tenant is verified live).
2. Tenant **live and operational** on AWS.
3. **Business sign-off received** for removal from original COM.
4. SLE (Selector Type + Selector Values) documented in Env Variables.

---

### TC-P10-01 (CRITICAL — Safety): Backup taken & verified before EVERY removal
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | For each target DB, confirm a backup is taken **before** running removal scripts | Backup exists |
| 2 | Confirm backup is restorable (integrity verified) | Restorable |
| 3 | Block removal if no verified backup | Hard stop |

**Pass/Fail:** No deletion without a verified, restorable backup. Missing = Fail (S1).

### TC-P10-02 (CRITICAL — Go/no-go gate): Tenant live on AWS + business sign-off before removal
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm tenant verified live/operational on AWS | Confirmed |
| 2 | Confirm documented business sign-off for COM data removal | Sign-off on file |
| 3 | Confirm migration validated (environment testing complete) | Validated |

**Pass/Fail:** All go/no-go gates satisfied and documented before any removal. Any missing = Fail (S1).

### TC-P10-03 (CRITICAL — Scope correctness): Only the tenant's SLE/Selector data removed
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Verify Selector Type + Selector Values match the migrated tenant exactly (from Env Variables) | Exact |
| 2 | Confirm removal scripts target only those selectors | Scoped correctly |
| 3 | Confirm **no other client's** data is in scope | Isolated |

**Pass/Fail:** Deletion strictly limited to this tenant's SLE data. Over-scope = Fail (S1, other-client data loss).

### TC-P10-04 (CRITICAL — Before/after validation): Record counts prove correct removal
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Capture record counts **before** removal | Baseline recorded |
| 2 | Capture counts **after** removal | Recorded |
| 3 | Delta equals expected tenant-data volume; SLE data confirmed gone; non-tenant counts unchanged | Reconciles |

**Pass/Fail:** Before/after counts reconcile; SLE data gone, everything else intact.

### TC-P10-05 (Integrity — FK/dependencies): Removal handles constraints without corruption
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | If FK constraints/dependencies block removal, follow documented resolution (remove dependents first / temporarily disable) | Clean removal |
| 2 | Post-removal integrity check on remaining COM data | No corruption/orphans |

**Pass/Fail:** Constraints handled; COM remains integral.

### TC-P10-06 (Sequencing): Steps executed in order 1→2→3→4
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Windward (1) → Payment (2) → Config (3) → AWS Claims Domain (4), each prior COMPLETE | Order honored |

**Pass/Fail:** Strict step order respected.

### TC-P10-07 (Performance/timing): Removal scheduled off-peak; batched for large volumes
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm large-volume removals scheduled off-peak / batched (per Common Issues) | No production impact |

**Pass/Fail:** Production unaffected during removal.

### TC-P10-08 (DOC / open question): Applicability TODO for KCL & Prebuild BU
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Note the phase-top TODO: "Double-check with Mel how relevant this activity is with KCL & Prebuild BU" | Resolve before running for those clients |
| 2 | Managers "TBD" throughout | Logged |

**Pass/Fail:** Applicability confirmed with Mel before execution for KCL/Prebuild; defect D-P10-1 logged.

---

## Completion Checklist Coverage
| Deliverable | Covered by |
|-------------|-----------|
| Removal tickets (4) created/assigned | TC-HO-01..06 |
| Backup before each removal | TC-P10-01 |
| SLE data removed & validated (per DB) | TC-P10-03, 04, 05 |
| Before/after counts documented | TC-P10-04 |

## Defects / Observations
| ID | Observation | Sev |
|----|-------------|-----|
| D-P10-1 | Unresolved applicability TODO (KCL/Prebuild — "check with Mel"); managers TBD | S3 |
| D-P10-2 | Irreversible production deletion — backup + sign-off + scope gates must be enforced, not assumed | S2 |

## Execution Record
| TC | Date | Tester | Env | Result | Defect | Notes |
|----|------|--------|-----|--------|--------|-------|
| TC-P10-01 | | | COM/PROD | | | |
| TC-P10-02 | | | | | | |
| TC-P10-03 | | | | | | |
| TC-P10-04 | | | | | | |
| TC-P10-05 | | | | | | |
| TC-P10-06 | | | | | | |
| TC-P10-07 | | | | | | |
| TC-P10-08 | | | | | | |
