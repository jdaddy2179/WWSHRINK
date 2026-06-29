# WW DataShrink — KCL Full Table Analysis (Re-run, post Nabeel fix)

| Field | Value |
|-------|-------|
| Server | `AWWW2SQLKCL01D` |
| Source DB | `windward_commercial` (full) |
| Target DB | `windward_KCL` (shrunk, WW1.0) |
| Re-run | post fix for the "large member tables retained in full" defect |
| Supersedes | first run in `WWShrink_KCL_TableAnalysis_Results.md` |

---

## 1. Fix verification — RESOLVED ✅

The defect (Member_Coverage / Subscriber_Coverage / Contact retained in full) is **fixed**. After the re-run all three trim to the KCL scope, and their dependents now clear as well.

| Table | Before fix (kcl) | After fix (kcl) | % retained | Status |
|-------|-----------------:|----------------:|-----------:|--------|
| dbo.Member_Coverage | 7,987,520 | 116,810 | 1.46% | TRIMMED ✅ |
| dbo.Subscriber_Coverage | 4,468,305 | 68,058 | 1.52% | TRIMMED ✅ |
| dbo.Contact | 5,534,651 | 111,386 | 2.01% | TRIMMED ✅ |
| dbo.Member_Coverage_Paid_Through | 389,483 | 0 | — | now EMPTIED |
| dbo.Member_Coverage_Reporting | 24 | 0 | — | now EMPTIED |
| dbo.Contact_Broker_Member_Coverage | 566 | 0 | — | now EMPTIED |
| dbo.member_holds | 5,977 | 0 | — | now EMPTIED |

These three tables + their now-emptied dependents removed an **additional ~19.3M rows / ~9.6 GB** beyond the first run (855.4M → 836.1M rows; 183,473 → 173,664.93 MB).
→ The Jira bug (assigned to Nabeel) can be **closed as Fixed/Verified**. Scoping is now consistent across all member entities; `Member_Coverage` count (116,810) tracks `Member_ID` (65,168) + dependents as expected.

---

## 2. Overall result (post-fix) — EXACT roll-up (Section 5)

| Metric | Source (commercial) | Target (KCL) | Reduction |
|--------|--------------------:|-------------:|----------:|
| Reserved size | 644,146.20 MB (~629 GB) | **173,664.93 MB (~170 GB)** | **470,481.27 MB (~459 GB, −73.04%)** |
| Total rows | 2,342,457,554 | **836,117,922** | −1,506,339,632 (−64.31%) |
| Overall rows retained | — | **35.69%** | — |
| Tables (user) | 1,665 | 1,671 | +6 created |
| **Tables touched** | — | **220 of 1,665 (13.2%)** | — |
| Tables dropped | — | **0** | — |

> These are the **exact** Section 5 figures from the post-fix WW1.0 run (no longer derived). The first run reclaimed to 183,473 MB / 855,420,080 rows; the fix trims an **additional 9,808 MB (~9.6 GB) and ~19.3M rows** (Member_Coverage/Subscriber_Coverage/Contact + their now-emptied dependents), bringing the shrunk DB to **173,664.93 MB / 836,117,922 rows**.

---

## 3. Potential space savings — where the remaining ~170 GB lives

The shrink is working as designed, but **~85–90% of the shrunk KCL DB is NOT KCL data** — it's large shared **reference / provider / fee** tables kept in full (UNCHANGED). These are the real space-savings opportunity.

### Top retained (UNCHANGED) tables in `windward_KCL`

| Table | Retained in KCL (MB) | ~GB | Category |
|-------|---------------------:|----:|----------|
| dbo.Fee_Schedule_Procedure_Code | 65,733.73 | ~64 | Fee schedule |
| dbo.Changeset | 13,254.08 | ~13 | Audit/change history |
| PROV.Provider_Link_SpecialNeed | 11,192.98 | ~11 | Provider directory |
| PROV.Locations | 10,738.86 | ~10 | Provider directory |
| dbo.Fee_Schedule_Scp_Proc_Code | 8,185.97 | ~8 | Fee schedule |
| dbo.Claim_Purge_Result | 7,776.15 | ~7.6 | Purge log/results |
| PROV.Provider_Radius_Network | 7,401.63 | ~7.2 | Provider directory |
| dbo.LKF_Fee_Schedule_Procedure_Code | 6,010.27 | ~6 | Fee schedule |
| PROV.Provider_Network | 5,710.25 | ~5.6 | Provider directory |
| PROV.Provider_Link | 4,123.79 | ~4 | Provider directory |
| dbo.Procedure_Rules | 2,708.57 | ~2.6 | Reference |
| PROV.Provider_Network_Standard_Attribute | 2,581.21 | ~2.5 | Provider directory |
| PROV.network_fee_assignment | 2,579.32 | ~2.5 | Provider/fee |
| **Subtotal (these 13)** | **~148,000** | **~145** | **~85% of the shrunk DB** |

### Savings opportunities (in priority order)

1. **Fee-schedule procedure tables — ~78 GB.** `Fee_Schedule_Procedure_Code` (64 GB) + `Fee_Schedule_Scp_Proc_Code` (8 GB) + `LKF_Fee_Schedule_Procedure_Code` (6 GB) are kept whole and are not client-specific. If these can be **shared/centralized** (one copy serving all client DBs) or scoped to KCL's networks/fee schedules, this is the single biggest lever.
2. **Provider directory — ~47 GB.** Provider_Link*/Provider_Network*/Locations/Radius/Service_Office are full national directory data. Same question: shareable vs. per-client copy, or scope to KCL's networks.
3. **`Claim_Purge_Result` — ~7.6 GB.** Looks like a purge results/log table retained in full; the shrink already EMPTIES the `Data_Hygiene_Audit_*` and `*_Arc` log/archive tables — confirm with SME whether this one can be emptied too.
4. **`Changeset` — ~13 GB.** Global change-history/audit; confirm whether KCL needs the full history or can start fresh.

> If fee-schedule + provider data can be centralized or scoped, the per-client shrunk DB could potentially drop from ~170 GB toward **~25–40 GB** (the actual KCL member/claims footprint + minimal reference). That's an estimated **~110–145 GB additional savings per client DB** — worth confirming with the architect, since it multiplies across every client onboarded.

---

## 4. Important caveat on "space saved"

`mb_reclaimed` is **reserved space freed inside the database**. It only becomes **free disk** after the data/log files are shrunk — handled by the shrinker's `999_01_Shrink_Transaction_Log_File.sql` and `999_02_Shrink_Database_File.sql` steps. Confirm those ran and compare physical file sizes (the script's file-size section / `sys.database_files`) to validate disk-level savings, not just in-DB reclaim.

---

## 5. Verdict

| Test case | Result |
|-----------|--------|
| TC-P4-04 (data integrity) | **PASS** — member-table scoping defect fixed & verified; 0 tables dropped; single-client scoping consistent |
| TC-P4-05 (size reduction) | **PASS** — 644,146.20 MB → 173,664.93 MB (−73.04%); 2.34B → 836.1M rows (−64.31%); exact Section 5 roll-up captured |
| Jira bug (Nabeel) | **Close as Fixed/Verified** |

**Follow-ups:** architect review of centralizing/scoping fee-schedule + provider reference data (~125 GB potential per client DB).
