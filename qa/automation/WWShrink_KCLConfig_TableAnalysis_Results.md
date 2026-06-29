# WW DataShrink — KCL **Config** Full Table Analysis Results

| Field | Value |
|-------|-------|
| Server | `AWWW2SQLKCL01D` |
| Source DB | `Windward_Config` (full) |
| Target DB | `Windward_Config_KCL` (shrunk) |
| Analysis script | `WWShrink_KCLConfig_FullTableAnalysis.sql` |
| Shrink run (step log) | **RunId 8** — 2026-06-26 21:39:16 → 21:43:12 (236s), **Succeeded**, `LastCompletedOrdinal 999` |
| Requested by | `DQ\E044` |
| Selector | `Purchaser_ID = 400040, 400041, 400042` |
| Supports | TC-P4-04 (data integrity), TC-P4-05 (size reduction) |

> Unlike the WW1.0 analysis, the latest `TrimShrink_Run` (RunId 8) **is** this Config shrink (`SourceDb = Windward_Config_KCL`), so the step-log view in §4 lines up directly with the table changes here.

---

## 1. Executive summary (exact Section 5 roll-up)

| Metric | Source (`Windward_Config`) | Target (`_KCL`) | Reduction |
|--------|---------------------------:|----------------:|----------:|
| **Total rows** | 12,532,294 | 5,229,352 | **−7,302,942 (−58.27%)** |
| **Reserved size** | 1,816.40 MB | 775.85 MB | **−1,040.55 MB (−57.29%)** |
| Overall rows retained | — | — | **41.73%** |
| Tables (user) | 198 | 201 | +3 created |
| **Tables touched** | — | — | **54 of 198 (27.3%)** |
| Tables dropped | — | — | **0** |

The Config DB is small relative to WW1.0 (~1.8 GB vs ~629 GB). Overall retention (41.73%) is dominated by a few large **reference/audit** tables kept whole (`Changeset` 374.77 MB, `Log_Group_Api` 167.68 MB, `GroupIdSuffix` 1.29M rows / 34.07 MB, `BOCP_Mapping` 50.21 MB).

---

## 2. Client-scoping entities — collapse cleanly to KCL

The 3 KCL purchasers drive the trim; group hierarchy reduces consistently across base + settings + archive tables.

| Table | Config | KCL | % retained |
|-------|-------:|----:|-----------:|
| dbo.Purchaser | 47,202 | **3** | 0.01% |
| dbo.Purchaser_Default | 47,202 | 3 | 0.01% |
| dbo.Purchaser_Routing | 47,202 | 3 | 0.01% |
| dbo.Purchaser_Hold | 29,208 | 6 | 0.02% |
| dbo.Parent_Group | 93,768 | 2,783 | 2.97% |
| dbo.Parent_Group_Default | 93,767 | 2,783 | 2.97% |
| dbo.Sub_Group | 231,281 | 3,082 | 1.33% |
| dbo.Sub_Group_Coverage | 559,044 | 3,102 | 0.55% |
| dbo.Sub_Group_TAT_Settings | 778,051 | 12,328 | 1.58% |
| dbo.Parent_Group_Default_TAT_Settings | 289,501 | 11,132 | 3.85% |

The full set of `Sub_Group_*` settings tables (Billing/Claim/EE/Ortho/Prior_Auth) all trim 231,281 → 3,082 (1.33%), matching the parent `Sub_Group` count — internal consistency holds.

---

## 3. Top tables by space reclaimed

| Table | Config (MB) | KCL (MB) | MB reclaimed | Status |
|-------|------------:|---------:|-------------:|--------|
| dbo.Sub_Group | 149.06 | 6.47 | 142.59 | TRIMMED |
| Archive.Sub_Group_Arc | 132.20 | 1.13 | 131.07 | TRIMMED |
| dbo.Sub_Group_Coverage | 128.52 | 1.02 | 127.50 | TRIMMED |
| Archive.Sub_Group_Coverage_Arc | 125.76 | 1.13 | 124.63 | TRIMMED |
| dbo.Sub_Group_TAT_Settings | 71.56 | 1.27 | 70.29 | TRIMMED |
| Archive.Sub_Group_Claim_Settings_Arc | 54.95 | 0.07 | 54.88 | TRIMMED |
| dbo.Parent_Group | 57.74 | 3.99 | 53.75 | TRIMMED |
| dbo.Parent_Group_Default_TAT_Settings | 42.02 | 1.71 | 40.31 | TRIMMED |
| dbo.Purchaser | 27.05 | 0.67 | 26.38 | TRIMMED |
| dbo.Sub_Group_Claim_Settings | 22.08 | 0.58 | 21.50 | TRIMMED |

---

## 4. Status breakdown (54 touched tables)

| Status | Meaning | Notes |
|--------|---------|-------|
| TRIMMED | Reduced to KCL scope | Sub_Group*/Parent_Group*/Purchaser* base + `_Arc` archive |
| EMPTIED | Cleared to 0 | settings/transfer-history `_Arc` logs with no KCL rows |
| TARGET_ONLY | Created by shrink (scaffolding) | `WK_ForeignKey` (419), `WK_Triggers_Windward` (302), `SchemabindingViewBackup` (28) — all working tables, 0 client rows |
| SOURCE_ONLY (dropped) | Removed | **0** |
| GREW (!) | Unexpectedly larger | 0 |

The largest **UNCHANGED** (intentionally retained) tables are reference/audit: `Changeset` (2.86M rows / 374.77 MB), `Log_Group_Api` (167.68 MB), `GroupIdSuffix` (1.29M / 34.07 MB), `BOCP_Mapping` (262K / 50.21 MB), `External_Response_Record_Log` (45.98 MB), `Hold` (182,560 / 15.70 MB), `Bulk_Update`/`Bulk_Update_Command` (~44 MB), plus the full `REF.*` lookup set.

---

## 5. Step log — what the process logged (RunId 8) ✅ matches this DB

- **State:** Succeeded · **Duration:** 236s · **Errors:** 0 · **LastCompletedOrdinal:** 999 (ran to completion incl. file-shrink steps)
- **Trim steps (ordinals 10–29):** `Sub_Group_*` settings (10–20), `Sub_Group` (21), `Parent_Group_Default_TAT_Settings`/`Parent_Group_Default`/`Parent_Group` (22–24), `Purchaser_Hold`/`Default`/`Routing`/`Purchaser` (25–28), `Validation_Report_Result` (29).
- **File shrink (ordinal 999):** `999_01_Shrink_Transaction_Log_File.sql` + `999_02_Shrink_Database_File.sql` both Succeeded → in-DB reclaim flushed to disk.

### Reconciliation of the two "touched" definitions
- **Finding A (17 steps, no matched table):** all infrastructure — TempDB config load, index working-tables create/drop, spIndexes drop/create, disable/enable triggers, drop/recreate FKs & schema bindings, `Archive_Pilot_All` (ordinal 30), `Space_Savings`, and the two `999_*` file-shrink steps. Correct — none trims a single named table. ✅
- **Finding B (table changed, no direct step):** the `*_Arc` **archive** tables (`Sub_Group_*_Arc`, `Parent_Group_*_Arc`, `Purchaser_*_Arc`, etc.) plus `Parent_Group_Hold`, `Sub_Group_Hold`, `Parent_Group_Transfer_History`, and the `WK_*`/`SchemabindingViewBackup` scaffolding. Expected — the archive tables are trimmed by the single `30_Trim_21_Archive_Pilot_All.sql` step (which doesn't name them individually), and the `WK_*` tables are shrink working tables, not data. ✅

This is a **clean reconciliation** — unlike the WW1.0 run, every changed Config table is explained by a logged step or by the archive-pilot/scaffolding mechanism.

---

## 6. Verdict against test cases

| Test case | Result | Evidence |
|-----------|--------|----------|
| **TC-P4-05** (size reduction) | **PASS** | 1,816.40 MB → 775.85 MB (−57.29%); 12.53M → 5.23M rows (−58.27%); per-table before/after captured; file-shrink steps Succeeded |
| **TC-P4-04** (data integrity) | **PASS** | `Purchaser` → 3 (matches 3 Purchaser_IDs); group hierarchy internally consistent; 0 tables dropped; 0 step errors; step log reconciles to table changes |

> Pair with the WW1.0 analysis (`WWShrink_KCL_TableAnalysis_ReRun_Results.md`) for the full Phase-4 evidence package — Config + WW1.0 together cover the complete client-DB shrink.
