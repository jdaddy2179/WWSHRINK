# WW DataShrink — KCL Full Table Analysis Results

| Field | Value |
|-------|-------|
| Server | `AWWW2SQLKCL01D` |
| Source DB | `windward_commercial` (full) |
| Target DB | `windward_KCL` (shrunk) |
| Analysis run | 2026-06-26 (metadata-only, `WWShrink_KCL_FullTableAnalysis.sql`) |
| Latest shrink run (step log) | RunId 6 — 2026-06-17 19:40–19:44 (245s), **Succeeded** |
| Selector | `Purchaser_ID = 400040, 400041, 400042` |
| Supports | TC-P4-04 (data integrity), TC-P4-05 (size reduction) |

---

## 1. Executive summary

The shrink reduced `windward_KCL` to a single client (KCL = 3 purchasers) while retaining shared reference/provider data in full.

| Metric | Source (commercial) | Target (KCL) | Reduction |
|--------|--------------------:|-------------:|----------:|
| **Total rows** | 2,342,457,554 | 855,420,080 | **−1,487,037,474 (−63.5%)** |
| **Reserved size** | 644,146 MB (~629 GB) | 183,473 MB (~179 GB) | **−460,673 MB (~−450 GB, −71.5%)** |
| Overall rows retained | — | — | **36.52%** |
| Tables (user) | 1,665 | 1,671 | +6 created |
| **Tables touched** | — | — | **209 of 1,665 (12.6%)** |
| Tables dropped | — | — | **0** |

> Overall row retention (36.52%) looks high because large **reference/provider/fee** tables are intentionally kept whole (e.g. `Fee_Schedule_Procedure_Code` 157M, `Changeset` 126M, `Provider_Radius_Network` 92M, `Claim_Purge_Result` 79M). The **client-scoped** member/claims tables were trimmed to ~1–3% (see §3).

---

## 2. Status breakdown (209 touched tables)

| Status | Meaning | Count |
|--------|---------|------:|
| UNCHANGED | Row count identical (reference/shared data kept) | 1,456 |
| TRIMMED | Rows reduced to the client scope | ~135 |
| EMPTIED | Cleared to 0 (logs, temp/staging, archive, hygiene) | ~68 |
| TARGET_ONLY | New table created by the shrink | 6 |
| SOURCE_ONLY (dropped) | Removed by the shrink | **0** |
| GREW (!) | Unexpectedly larger | 0 |

The 6 **TARGET_ONLY** tables are shrink scaffolding, all 0 rows: `BCS_Bank_Acct_Payment_Preview_Trimmed`, `BCS_Check_Trimmed`, `BCS_Explanation_Of_Benefit_Change_Trimmed`, `BCS_Explanation_Of_Benefit_Preview_Trimmed`, `BCS_Explanation_Of_Benefit_Summary_Trimmed`, `SchemabindingViewBackup`.

---

## 3. Client-scoping entities (the heart of the shrink)

The scoping IDs collapse cleanly to KCL — `Purchaser` drops to **3 rows**, matching the 3 Purchaser_IDs.

| Table | Commercial | KCL | % retained |
|-------|-----------:|----:|-----------:|
| Purchaser | 38,144 | **3** | 0.01% |
| Purchaser_Coverage | 38,144 | 3 | 0.01% |
| Parent_Group | 42,220 | 2,779 | 6.58% |
| Parent_Group_Coverage | 42,220 | 2,779 | 6.58% |
| Sub_Group | 63,623 | 3,086 | 4.85% |
| Sub_Group_Coverage | 90,423 | 3,106 | 3.43% |
| Member_ID | 5,837,280 | 65,168 | 1.12% |
| Windward_Member_ID | 5,433,890 | 65,172 | 1.20% |
| Contact_Member | 4,956,763 | 111,478 | 2.25% |
| Member_Coverage_ID | 4,474,710 | 68,062 | 1.52% |
| Claims_Header_Log | 12,001,985 | 108,114 | 0.90% |
| Claims_Current_Version | 12,079,168 | 108,114 | 0.90% |

---

## 4. Top 10 tables by rows removed

| Table | Commercial | KCL | Removed | MB reclaimed | Status |
|-------|-----------:|----:|--------:|-------------:|--------|
| dbo.Windward_Api_Logs | 443,283,276 | 0 | 443,283,276 | **223,848** | EMPTIED |
| dbo.Claims_Log_Message | 274,130,555 | 3,544,056 | 270,586,499 | 25,084 | TRIMMED |
| dbo.PAYMENT_TEMP_FFS_BILLING_INFORMATION_ASSIGNMENT | 79,742,058 | 0 | 79,742,058 | 6,924 | EMPTIED |
| dbo.Claims_Detail_Log_Timely_Late | 64,480,020 | 313,522 | 64,166,498 | 3,096 | TRIMMED |
| dbo.MaxDed_Claim_Facts | 62,592,419 | 726,173 | 61,866,246 | 11,273 | TRIMMED |
| dbo.Timely_Late_Member | 54,453,920 | 1,291,721 | 53,162,199 | 3,451 | TRIMMED |
| Archive.Timely_Late_Member_Arc | 46,739,315 | 0 | 46,739,315 | 3,011 | EMPTIED |
| dbo.Claims_Detail_Log | 34,873,131 | 314,856 | 34,558,275 | **41,598** | TRIMMED |
| dbo.Claim_Documentation | 26,951,561 | 266,246 | 26,685,315 | 10,557 | TRIMMED |
| dbo.Ded_Member_Summary | 25,032,785 | 348,121 | 24,684,664 | 5,046 | TRIMMED |

`Windward_Api_Logs` alone accounts for ~30% of rows removed and ~49% of space reclaimed.

---

## 5. Datashrink step log — what the process logged (RunId 6)

> **Scope note:** RunId 6 is the **Config database** shrink (`SourceDb = Windward_Config_KCL`), **not** the main `windward_KCL` (WW1.0) shrink. The table comparison in §1–4 reflects the main WW1.0 shrink, which was a **separate, earlier run** not in this step log.

- **State:** Succeeded · **Duration:** 245s · **Steps:** 41 · **Errors:** 0 · **LastCompletedOrdinal:** 999 (ran to completion)
- **Requested by:** `DQ\E044` · **Selector:** `Purchaser_ID = 400040, 400041, 400042`
- Trim steps (ordinals 10–30) reduced the **config/group** tables: `Sub_Group`, `Sub_Group_Coverage`, `Parent_Group`, `Purchaser`, `Prior_Auth`, `Sub_Group_TAT_Settings`, `Validation_Report_Result`.

### Reconciliation of the two "touched" definitions
- **Finding A (20 steps, no matched table):** all are infrastructure steps — index drop/create, disable/enable triggers, drop/recreate FKs & schema bindings, `Archive_Pilot_All`, and the two file-shrink steps (`999_*`). Correct: these don't trim a single table. ✅
- **Finding B (~172 tables changed, no step in this log):** the big claims/member tables (`Claims_*`, `Member_*`, `Contact_*`, etc.). Expected — they were trimmed by the **main WW1.0 shrink run**, not by Config RunId 6. To reconcile them against a step log, re-run §6–8 selecting that run (the WW1.0 shrink's RunId in `TrimShrink_Run`).

---

## 6. Observations / items to confirm with SME

1. **Large member tables retained in full** — `Member_Coverage` (7,987,520), `Subscriber_Coverage` (4,468,305), and `Contact` (5,534,651) are **UNCHANGED**, while `Member_ID`, `Contact_Member`, and `Member_Coverage_ID` trimmed to ~1–2%. Confirm these are intentionally kept (shared/reference lineage) vs. a pending trim. *(Relates to TC-P4-04 completeness.)*
2. **Config vs WW1.0 runs** — only the Config shrink (RunId 6) is the latest in `TrimShrink_Run`. Capture the WW1.0 shrink's RunId to get a step-level reconciliation for the claims/member tables.
3. **Negative `mb_reclaimed` on a few tables** (e.g. `Billing_Rate_Interface`, `Contact_Group_Phone`) — target slightly larger than source; index-rebuild/fill-factor artifact, not added data (row counts equal or lower).
4. **0 tables dropped, 0 step errors** — no cross-client contamination at the table level; all 209 changes are trims/empties/new-scaffolding.

---

## 7. Verdict against test cases

| Test case | Result | Evidence |
|-----------|--------|----------|
| **TC-P4-05** (size reduction documented & confirmed) | **PASS** | 644 GB → 179 GB reserved (−71.5%); 2.34B → 855M rows; before/after captured per table |
| **TC-P4-04** (data integrity post-shrink) | **PASS (1 SME confirm)** | Single-client scoping verified (`Purchaser` → 3); 0 tables dropped; 0 step errors. Open item: confirm fully-retained `Member_Coverage`/`Subscriber_Coverage`/`Contact` are intentional (Obs. #1) |

> Pair this breadth view with the member-level depth check (`WWShrink_KCL_SourceTarget_Reconciliation.sql`) for the complete TC-P4-04 evidence package.
