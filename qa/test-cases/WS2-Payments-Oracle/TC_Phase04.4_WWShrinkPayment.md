# Test Cases — Phase 4.4: WW Shrink for WW Payment

| Field | Value |
|-------|-------|
| Playbook reference | `Phase04.4_WWShrinkPayment.md` (Steps 1–2) |
| Priority | **P1 — destructive/irreversible** (original WW Payment DB replaced with reduced version) |
| Type | Jira hand-off + data scoping + safety + integrity |
| Owner | SQA (validation, Step 2); DBA Team executes (Step 1) |

> Mirrors Phase 4.3 but targets the **Payment** database. Financial/payment data — integrity and correct client scoping are paramount.

**Applies `TC-HO-01..09`** from [`TC_PATTERN_JiraHandoffPhase.md`](../_shared/TC_PATTERN_JiraHandoffPhase.md):
- **Step 1 Title:** `WW Payment Database Shrinking - REF[Tenant Name]`; AC: "WW Payment Database Shrinker executed successfully for REF[Environment], size reduced per specs, validation completed".
- **Step 2 Title:** `Validate WW Payment Database Shrink Results - REF[Tenant Name] [ENVIRONMENT]`.
- **Step 1 → DBA (Vasudha); Step 2 → SQA (Joshua, Keerthan; mgr Arun Pant).** TC-HO-07 sequential env applies.

### Preconditions
- **Phase 4.3 COMPLETE.** DQ Jira + Env Variables. Documented: PaymentDatabaseName (Generated, AJ); Purchaser_ID, Parent_Group_ID, Sub_Group_ID (Manual, Mandy Willms/AJ).

---

### TC-P4.4-01 (CRITICAL — Safety): Verified Payment DB backup before shrink
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm a validated, restorable Payment DB backup exists (Phase 4.2) | Present & verified |
| 2 | Block shrink if absent | Hard stop |

**Pass/Fail:** No shrink without verified backup. Missing = Fail (S1).

### TC-P4.4-02 (CRITICAL — Tier gate): Payment shrink only for Tier-3/small BUs
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm client is Tier 3 (e.g., SLE) | Applies |
| 2 | Non-Tier-3 → do not run without architect sign-off | Gated |

**Pass/Fail:** Applicability matches Tier.

### TC-P4.4-03 (CRITICAL — Scoping correctness): Payment DB name + group IDs correct/complete
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Verify PaymentDatabaseName resolved correctly (no `REF[]`) | Correct |
| 2 | Verify Purchaser/Parent/Sub-Group IDs match the client & are complete/well-formed | Exact & complete |
| 3 | Confirm consistency with Phase 4.3 scoping (same client definition) | Identical IDs |

**Pass/Fail:** Correct payment DB and identical, complete scoping IDs.

### TC-P4.4-04 (CRITICAL — Payment integrity post-shrink): Only client payment data, complete & balanced
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm reduced Payment DB holds only the target client's payment data | No other clients' payments |
| 2 | Confirm client payment records complete (no missing recent transactions) | Complete |
| 3 | Financial sanity checks (totals/counts vs expected) reconcile | Reconciled |

**Pass/Fail:** Payment data correctly scoped, complete, and reconciles. Any financial discrepancy = Fail (S1).

### TC-P4.4-05 (Metrics): Before/after size documented; reduction confirmed
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | DBA records before/after size in Step 1 ticket | Recorded |
| 2 | SQA confirms reduction | Confirmed |

**Pass/Fail:** Reduction documented and validated.

### TC-P4.4-06 (Linkage & defect flow): Step 2 linked to Step 1; bugs → DBA
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Validation story linked ("relates to"/"validates") | Linked |
| 2 | Issues raised as bugs to DBA | Routed |

**Pass/Fail:** Traceable linkage and defect routing.

### TC-P4.4-07 (Sequential env): Per-env order DEV→QAR→PROD→HFX
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Separate run+validate per env, in order | Honored |

**Pass/Fail:** Order honored.

---

## Completion Checklist Coverage
| Deliverable | Covered by |
|-------------|-----------|
| Payment shrink ticket created/assigned to DBA | TC-HO-01..06 |
| Shrinker executed successfully | TC-P4.4-02, 04 |
| Before/after size documented | TC-P4.4-05 |
| Validation ticket created/assigned to SQA & linked | TC-P4.4-06 |
| Payment size reduction confirmed | TC-P4.4-04, 05 |

## Execution Record
| TC | Date | Tester | Env | Result | Defect | Notes |
|----|------|--------|-----|--------|--------|-------|
| TC-P4.4-01 | | | | | | |
| TC-P4.4-02 | | | | | | |
| TC-P4.4-03 | | | | | | |
| TC-P4.4-04 | | | | | | |
| TC-P4.4-05 | | | | | | |
| TC-P4.4-06 | | | | | | |
| TC-P4.4-07 | | | | | | |

---

## Playbook Reference
This suite validates the playbook item **[Phase04.4_WWShrinkPayment.md](https://dev.azure.com/EnterpriseRepo/Application%20Services/_git/com-client-pilot?path=/Playbook/Phase04.4_WWShrinkPayment.md&version=GBmain)** (`com-client-pilot/Playbook/`).

Related: [Jira ↔ Playbook matrix](../../JiraPlaybookMatrix.md) · [Test Strategy](../../TestStrategy.md) · [Traceability Matrix](../../TraceabilityMatrix.md)
