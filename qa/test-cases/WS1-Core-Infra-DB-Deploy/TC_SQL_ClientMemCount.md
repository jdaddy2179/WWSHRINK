# Test Cases — ClientMemCount.sql (Client Member Count Query)

| Field | Value |
|-------|-------|
| Artifact | `ClientMemCount.sql` |
| Used by | Phase 1, Step 1 (Client Member Count → drives Tier) |
| Priority | P1 (the count determines Tier and thus all infrastructure sizing) |
| Environment | **Production only** (per query header & Phase 1) |
| Requires PHI access | Yes — US-based operator with authorized PROD/PHI access |
| Owner | SQA + DBA; SME: AJ Schmucker |

### What the query does (under test)
Builds `#temp_member_search` of distinct `Contact_Member.contact_relation_gid` for a given `Purchaser.purchaser_gid`, joining the active (`record_status = 'A'`) coverage chain:
`Contact_Member → Member_Coverage → Subscriber_Coverage → (member_coverage) → Member_Coverage_ID → Member_ID (type=1) → Sub_Group_Coverage → Sub_Group → Parent_Group_Coverage → Parent_Group → Purchaser_Coverage → Purchaser`.
Result intent: total members under the client (including termed members whose data still resides in Windward).

### Preconditions
- Run on **Production** by an authorized US-based operator.
- A **golden reference client** exists: a known `purchaser_gid` with an independently verified expected member count (e.g., from NBI or prior audited run).
- Read-only / least-privilege DB credentials.

### Test Data
| Profile | purchaser_gid | Expected count (verified) | Notes |
|---------|--------------:|--------------------------:|-------|
| GOLD | 86319 (header example) | <fill from verified source> | Regression anchor |
| ZERO | <gid with no active coverage> | 0 | Empty-result handling |
| TERMED | <gid with only termed-but-resident members> | >0 | Validates "inactive included" claim |
| INVALID | 999999999 (nonexistent) | 0 rows | Negative |

---

### TC-SQL-01 (CRITICAL — Accuracy): Golden client returns verified count
**Objective:** Query result matches the independently verified member count for the golden client.

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Set `purchaser_gid = <GOLD>`; run on PROD | Executes without error |
| 2 | `SELECT COUNT(*) FROM #temp_member_search` | Equals GOLD expected count |
| 3 | Compare to independent source (NBI/prior audit) | Match within agreed tolerance (ideally exact) |

**Pass/Fail:** Count matches verified figure. Mismatch = Fail (S1).

### TC-SQL-02 (Distinctness): No duplicate members inflate the count
**Objective:** `contact_relation_gid` is distinct despite multiple coverage rows per member.

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | `SELECT COUNT(*) , COUNT(DISTINCT contact_relation_gid) FROM #temp_member_search` | Both equal |
| 2 | Confirm `GROUP BY cm.contact_relation_gid` collapses multi-coverage members | One row per member |

**Pass/Fail:** No duplicates. (The `GROUP BY` should guarantee this — verify it actually does given the multi-join fan-out.)

### TC-SQL-03 (CRITICAL — Definition gap G2): Total vs Active count clarified
**Objective:** Phase 1 asks to record **both total and active** counts, but this query returns ONE number filtered by `record_status='A'` on every join. Verify what the number actually represents.

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Determine semantics of `record_status='A'` | 'A' = row is active/not-deleted, NOT member coverage status |
| 2 | Check whether termed (coverage-ended) members are included | Per header intent, termed-but-resident members SHOULD be counted |
| 3 | Confirm whether a separate "active members" figure exists | If none → **defect**: query provides total only; "active count" undefined |

**Pass/Fail:** Semantics documented; if no active-only query exists, raise defect against Phase 1 / SQL (gap G2). Do not guess the active figure.

### TC-SQL-04 (Inactive inclusion): Termed members are counted
**Objective:** Validate the header claim that inactive/termed members still in Windward are included.

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Run for TERMED profile (members termed but data resident) | Count > 0 |
| 2 | Cross-check a known termed member appears in `#temp_member_search` | Present |

**Pass/Fail:** Termed-but-resident members included as intended. (Note: if `record_status='A'` joins exclude them, this contradicts the header — raise defect.)

### TC-SQL-05 (Boundary → Tier handoff): Count feeds correct Tier
**Objective:** The produced count maps to the Tier rule (link to `TC-P1-07`).

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Take query count and apply Tier rule | >=1M→T1, >=100K→T2, <100K→T3 |
| 2 | Verify count near a Tier boundary classifies correctly | Correct Tier |

**Pass/Fail:** Count → Tier mapping correct.

### TC-SQL-06 (Negative): Nonexistent purchaser_gid
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Set `purchaser_gid = 999999999`; run | 0 rows; no error |
| 2 | Operator interprets 0 correctly | Recognized as "no members / wrong gid", not Tier 3 by default |

**Pass/Fail:** Empty result handled and interpreted, not silently taken as a real count.

### TC-SQL-07 (Safety / non-destructive): Read-only, no side effects
**Objective:** Verify the script only creates a temp table and reads; it must not alter production data.

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Review statements | Only `DROP TABLE IF EXISTS #temp_member_search` (session temp) + `SELECT ... INTO #temp` |
| 2 | Confirm `#temp_member_search` is session-scoped (single `#`) | Yes — no global/permanent table impact |
| 3 | Run with read-only credentials | Succeeds; no write to base tables |

**Pass/Fail:** No production data modified; temp table is session-scoped.

### TC-SQL-08 (Repeatability): Re-run yields identical count
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Run twice in succession for GOLD | Identical counts (barring real-time enrollment changes) |
| 2 | Confirm `DROP TABLE IF EXISTS` makes the script safely re-runnable in one session | No "object exists" error on re-run |

**Pass/Fail:** Deterministic and re-runnable.

### TC-SQL-09 (Usability/Doc): Instructions are followable
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Follow header instructions (replace gid, run on PROD, new-client note) | Clear and sufficient |
| 2 | Note: header says "Replace 'purchaser_gid'" but code hardcodes `p.purchaser_gid = 86319` | **Defect**: instruction/code mismatch — the literal to replace is the numeric value, not a placeholder named `purchaser_gid` |

**Pass/Fail:** Operator can run it unaided; doc/code mismatch logged as minor defect.

### TC-SQL-10 (Performance sanity): Runs within acceptable window on PROD
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Time execution for a large (Tier 1) client | Completes within agreed window; no PROD impact |
| 2 | Confirm no table locks/blocking on base tables | Read-only, minimal footprint |

**Pass/Fail:** Acceptable runtime, no production disruption.

---

## Defects / Observations surfaced by this suite
| ID | Observation | Severity | TC |
|----|-------------|----------|----|
| D-SQL-1 | Single count returned, but Phase 1 wants both total **and** active counts | S2 | TC-SQL-03 |
| D-SQL-2 | Header says replace `'purchaser_gid'` but value is hardcoded `86319` | S4 | TC-SQL-09 |
| D-SQL-3 | "Inactive included" intent vs `record_status='A'` joins needs SME confirmation | S2 | TC-SQL-04 |
| D-SQL-4 | 5-year purge "unclear if running in commercial" → count may include should-be-purged data | S3 | TC-SQL-01 |

## Execution Record
| TC | Date | Tester | Env | Result | Defect | Notes |
|----|------|--------|-----|--------|--------|-------|
| TC-SQL-01 | | | PROD | | | |
| TC-SQL-02 | | | PROD | | | |
| TC-SQL-03 | | | PROD | | | |
| TC-SQL-04 | | | PROD | | | |
| TC-SQL-05 | | | PROD | | | |
| TC-SQL-06 | | | PROD | | | |
| TC-SQL-07 | | | PROD | | | |
| TC-SQL-08 | | | PROD | | | |
| TC-SQL-09 | | | PROD | | | |
| TC-SQL-10 | | | PROD | | | |

---

## Playbook Reference
This suite validates the playbook item **[ClientMemCount.sql](https://dev.azure.com/EnterpriseRepo/Application%20Services/_git/com-client-pilot?path=/Playbook/ClientMemCount.sql&version=GBmain)** (`com-client-pilot/Playbook/`).

Related: [Jira ↔ Playbook matrix](../../JiraPlaybookMatrix.md) · [Test Strategy](../../TestStrategy.md) · [Traceability Matrix](../../TraceabilityMatrix.md)
