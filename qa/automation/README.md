# Automation

## WW Shrink — KCL source-vs-target SQL validation

Run on **`AWWW2SQLKCL01D`** (both DBs on one instance) — non-PHI test data,
read-only / least-privilege credentials recommended. Three-part naming means no `USE` switch.

| Script | What it does | Test case |
|--------|--------------|-----------|
| `KCL_Purchasers_discovery.sql` | Distinct KCL **Purchaser** set from `windward_commercial` (the canonical client scope that drives the shrink) | TC-P4-03 |
| `WWShrink_KCL_SourceTarget_Reconciliation.sql` | Reconciles the KCL member set between `windward_commercial` (source) and `windward_KCL` (shrunk target), scoped to that purchaser set. One execution → `PASS`/`FAIL` + row-level diff of any lost/extra members | **TC-P4-04** |
| `WWShrink_KCL_FullTableAnalysis.sql` | Full table-level analysis of every table touched by the datashrink (WW1.0 DB): per-table row-count/size impact `windward_commercial` vs `windward_KCL`, classified UNCHANGED/TRIMMED/EMPTIED/dropped, plus a TrimShrink step-log-driven view that reconciles "what the shrink logged" against "what actually changed" | TC-P4-04 / TC-P4-05 |
| `WWShrink_KCLConfig_FullTableAnalysis.sql` | Same analysis for the **Config** DB: `Windward_Config` vs `Windward_Config_KCL`. Lines up with shrink RunId 6 (Config shrink), so the step-log view matches the config trim steps | TC-P4-04 / TC-P4-05 |
| `KCL_ClientMemCount_validation.sql` | Single-DB KCL member count (TOTAL 97,210 / ACTIVE 81,211 toggle) that drives Tier | TC-SQL-01/03 |

**PASS** = source count == target count **and** both EXCEPT diffs return zero rows
(no member lost by the shrink, no other client's data leaked in). Count parity alone
is insufficient — the set-level diff is what makes it a real reconciliation. Any
discrepancy routes to the WW Shrinker Owner (Nabeel Syed) per TC-P4-07.

> These run against an internal SQL Server (`AWWW2SQLKCL01D`) and are **not** executable
> from CI / this repo — they are operator-run scripts whose output is captured as test evidence.

---

# Environment Variables spreadsheet validation

## Recommendation (why not Playwright)
The Environment Variables workbook lives in **SharePoint behind Okta/M365 SSO + MFA**, and "validating the spreadsheet" means checking **cell values/formulas**, not UI behaviour. Browser automation (Playwright) would have to script a corporate login and scrape Excel‑Online's DOM — fragile and inappropriate for prod/PHI auth. **Validate the data directly** instead: read the `.xlsx` and assert the playbook rules. Deterministic, fast, repeatable, and it maps 1:1 to the Phase 1 / 2.1 test cases.

## `spreadsheet_validator.py`
Data‑level validator (Python + `openpyxl`). Checks a client tab against the rules from the authored suites:

| Rule | Test case |
|------|-----------|
| All Manual Phase‑1 fields present (not blank / not `REF[]`) | TC‑P1‑01, TC‑P1‑08 |
| No unresolved `REF[]` placeholders anywhere | TC‑P1‑11 / TC‑P2 |
| Member count numeric | TC‑SQL / TC‑P1 |
| **Tier matches member count** (≥1M→T1, ≥100k→T2, <100k→T3) | **TC‑P1‑07** |
| Tenant ID is exactly 3 chars | TC‑P1‑03 |
| Cost Center is 6 digits | TC‑P1‑03 |
| Country code is a 2‑letter short code | TC‑P1‑03 |
| Single‑/Multi‑Tenant value valid | TC‑P1‑08 |
| Account ID(s) are 12 digits | TC‑P2.1‑07 |

### Run it
```bash
pip install openpyxl
# 1) download "Environment Variables.xlsx" from SharePoint (your auth)
python spreadsheet_validator.py "Environment Variables.xlsx" "Client X"   # tab = client name
```
Exit code `0` = all pass, `1` = at least one failure. Output lists ✅/❌ per rule with the offending value — usable as test‑execution evidence in the ADO suite.

### Extending
Add rules in `run_checks()` (e.g., naming‑convention regex for generated AWS resource names, IAM role format, Environment Prefix patterns). Keep each rule mapped to a test‑case ID.

## Getting the file without manual download (optional, enterprise path)
For **recurring/automated** validation, pull the workbook via the **Microsoft Graph API** with an Azure AD app registration (Sites.Read.All) instead of manual download — then run the same validator in CI. This needs IT/InfoSec to register the app and grant least‑privilege access; do **not** embed user credentials or use a personal PAT. Until that's set up, the manual‑download path above is the pragmatic option.

> **Note:** this validates the *spreadsheet data*. The other playbook checks (ServiceNow ticket creation, AWS Console account/naming, DB connectivity) remain **manual** — they act on authenticated internal systems and human judgement, and are not automatable here.
