# Test Cases — Phase 1: Gather and Document Client & AWS Account Information

| Field | Value |
|-------|-------|
| Playbook reference | `Phase01_GatherClientAndAWSAccountInfo.md` (Steps 1–2) |
| Priority | P1 (inputs propagate to every downstream phase) |
| Environment | N/A (data collection) + PROD read for member count |
| Requires PHI access | Yes — member count must come from a US-based operator with authorized PROD access |
| Owner | SQA Team |

### Preconditions
- Client onboarding formally initiated and approved.
- Operator briefed on client/project scope; has read `Introduction.md`.
- SharePoint access granted (per Introduction access matrix, Phase 1).
- Access to the Environment Variables spreadsheet.

### Test Data — Client Profiles
| Profile | Member Count | Expected Tier | Purpose |
|---------|-------------:|:-------------:|---------|
| C-LOW | 15,172 | Tier 3 | Nominal small (matches playbook example) |
| C-MID | 250,000 | Tier 2 | Nominal medium |
| C-HIGH | 1,500,000 | Tier 1 | Nominal large |
| B-1 | 99,999 | Tier 3 | Boundary just below 100K |
| B-2 | 100,000 | Tier 2 | Boundary at 100K |
| B-3 | 999,999 | Tier 2 | Boundary just below 1M |
| B-4 | 1,000,000 | Tier 1 | Boundary at 1M |
| B-5 | 0 | Tier 3 | Degenerate / empty client |

---

## Step 1 — Collect Client & AWS Account Information

### TC-P1-01: All required Client Information fields collected
**Objective:** Verify every Client Information field is gathered from the correct stakeholder and recorded before Step 2.

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Collect Tenant Name, Tenant ID, Single/Multi-Tenant, Tenant Country Code, Client Member Count | All six fields present and non-empty |
| 2 | Confirm each value's source matches the "Request data from" column | Architect/Coordinator for tenant fields; AJ's SQL or NBI for member count |
| 3 | Confirm values temporarily recorded (notes/email) before Step 2 | Evidence exists |

**Pass/Fail:** All fields collected from the documented source and recorded. Missing any field = Fail.

### TC-P1-02: All required AWS Account Information fields collected
**Objective:** Verify Cost Center, ATG, and New/Existing role are gathered from the correct owners.

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Collect Cost Center (Finance — Kelly Barrero) | 6-digit code obtained |
| 2 | Collect ATG (Architect) | ATG governance ID obtained (e.g., ATG0004932) |
| 3 | Collect New vs Existing IAM role decision (Cloud Infra — Erik/Lindsay) | Decision recorded |

**Pass/Fail:** All three AWS fields obtained from documented owners.

### TC-P1-03 (Format/Negative): Field-format validation
**Objective:** Verify format rules are enforced; malformed inputs are rejected.

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Enter Tenant ID = "KCL" (3 chars) | Accepted |
| 2 | Enter Tenant ID = "KC" or "KCLM" | Rejected — must be exactly 3 chars |
| 3 | Enter Tenant ID equal to an existing tenant's ID | Rejected — must be unique across all tenants |
| 4 | Enter Cost Center = "12AB56" or "1234" | Rejected — must be 6 digits |
| 5 | Enter Country Code = "USA" | Rejected — expected short code "us"/"ca" |

**Pass/Fail:** Each malformed value is caught before Step 2.

### TC-P1-04 (Decision table): Existing vs New client member-count path
**Objective:** Verify the correct member-count source is used per client type.

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Client exists in Windward → run `ClientMemCount.sql` on PROD | Count obtained via SQL (see `TC_SQL_ClientMemCount`) |
| 2 | Client NOT yet in Windward → NBI process | Flagged as gap G1 (NBI = TBD); onboarding blocked until NBI defined |

**Pass/Fail:** Correct path chosen; new-client gap surfaced rather than silently skipped.

### TC-P1-05 (Security): Member count produced by authorized US-based operator
**Objective:** Verify PHI-touching member count is sourced compliantly.

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Identify who ran the PROD count | A US-based team member with authorized PROD/PHI access |
| 2 | Attempt to source count from a non-US / unauthorized operator | Rejected / not permitted |

**Pass/Fail:** Count provenance is compliant; otherwise Fail (S1 security defect).

---

## Step 2 — Document Environment Variables in Spreadsheet

### TC-P1-06: Tab copy & filter procedure
**Objective:** Verify the operator copies `Master_Sheet`, renames to client, and filters to Phase 1 / Manual rows.

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Copy `Master_Sheet` tab in Environment Variables workbook | New tab created |
| 2 | Rename tab to client name (e.g., "Client X") | Tab renamed |
| 3 | Filter Col H = Phase 1, Col G = Manual | Only Phase 1 Manual rows shown |
| 4 | Clear existing Col C values on those rows | Manual cells emptied, ready for input |

**Pass/Fail:** Working tab prepared exactly per instructions; `Master_Sheet` left unmodified.

### TC-P1-07 (Boundary — Tier calculation, CRITICAL): Tier derived correctly at every boundary
**Objective:** Verify Tier logic: `>=1,000,000 → Tier 1`, `>=100,000 → Tier 2`, `<100,000 → Tier 3`. This is the single highest-value computed value in Phase 1.

| Step | Member Count input | Expected Tier |
|------|-------------------:|:-------------:|
| 1 | 0 (B-5) | Tier 3 |
| 2 | 99,999 (B-1) | Tier 3 |
| 3 | 100,000 (B-2) | Tier 2 |
| 4 | 250,000 (C-MID) | Tier 2 |
| 5 | 999,999 (B-3) | Tier 2 |
| 6 | 1,000,000 (B-4) | Tier 1 |
| 7 | 1,500,000 (C-HIGH) | Tier 1 |
| 8 | 15,172 (C-LOW) | Tier 3 |

**Pass/Fail:** Every row yields the expected Tier. Any boundary miss = Fail (S1 — wrong Tier mis-sizes all downstream infrastructure).

### TC-P1-08: All Manual Phase-1 fields entered in Column C
**Objective:** Verify every Manual field is populated: Single/Multi-Tenant, Member Count, Tier, Tenant Name, Tenant ID, Country Code, Cost Center, ATG, New/Existing role.

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Inspect Col C for each Manual row | All nine values present, none left blank |
| 2 | Cross-check each value vs Step 1 collected data | Exact match |

**Pass/Fail:** All Manual fields populated and consistent with Step 1.

### TC-P1-09 (Data validation): Spreadsheet values match stakeholder source exactly
**Objective:** Verify no transcription drift between stakeholder inputs and spreadsheet.

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Compare each Col C value to the recorded stakeholder value | Character-for-character match |
| 2 | Compare formats to Step 1 rules | All formats valid |

**Pass/Fail:** Zero discrepancies.

### TC-P1-10 (Repeatability): Two operators, same client → identical Tier & values
**Objective:** Verify the procedure is deterministic.

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Operator A and Operator B independently complete Phase 1 for C-MID | Same Member Count, same Tier 2, same field values |

**Pass/Fail:** Results identical across operators.

---

## Documentation / Static Review (Phase 1)

### TC-P1-11: Links, references, and glossary consistency
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Follow every `[...](...)` link in Phase 1 | All resolve (Introduction, Glossary, ClientMemCount.sql, Env Variables) |
| 2 | Confirm every defined term (Tenant, Tier, Single/Multi-Tenant, etc.) exists in Glossary | All present and non-contradictory |
| 3 | Confirm Completion Checklist items map to Steps 1–2 outputs | Each deliverable traceable |

**Pass/Fail:** No broken links, no undefined/contradictory terms.

---

## Phase 1 Completion Checklist Coverage
| Deliverable | Covered by |
|-------------|-----------|
| Client & AWS info collected | TC-P1-01, 02, 03, 04, 05 |
| Env Variables documented (Manual) | TC-P1-06, 08, 09 |
| Tier determined & documented | TC-P1-07 |
| Data validated vs stakeholders | TC-P1-09, 10, 11 |

## Execution Record
| TC | Date | Tester | Env | Result | Defect | Notes |
|----|------|--------|-----|--------|--------|-------|
| TC-P1-01 | | | | | | |
| TC-P1-02 | | | | | | |
| TC-P1-03 | | | | | | |
| TC-P1-04 | | | | | | |
| TC-P1-05 | | | | | | |
| TC-P1-06 | | | | | | |
| TC-P1-07 | | | | | | |
| TC-P1-08 | | | | | | |
| TC-P1-09 | | | | | | |
| TC-P1-10 | | | | | | |
| TC-P1-11 | | | | | | |

---

## Playbook Reference
This suite validates the playbook item **[Phase01_GatherClientAndAWSAccountInfo.md](https://dev.azure.com/EnterpriseRepo/Application%20Services/_git/com-client-pilot?path=/Playbook/Phase01_GatherClientAndAWSAccountInfo.md&version=GBmain)** (`com-client-pilot/Playbook/`).

Related: [Jira ↔ Playbook matrix](../../JiraPlaybookMatrix.md) · [Test Strategy](../../TestStrategy.md) · [Traceability Matrix](../../TraceabilityMatrix.md)
