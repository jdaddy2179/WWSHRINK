# ▶ How to Run the WW Smoke Tests

**[Run pipeline → WW Smoke Tests](https://dev.azure.com/EnterpriseRepo/Application%20Services/_build?definitionId=697)**  ·  no tokens — sign in with your normal ADO account.

## Run it (3 clicks)
1. Open the link above → click **Run pipeline** (top-right).
2. Set the parameters:
   - **Target environment** — e.g. `TS06`, `DS10`, `PROD`
   - **Browser** — `msedge` or `chrome`
   - **Business-unit legs at once** — `3` for non-prod · **`1` for PROD**
3. Click **Run**.

## See results
- **Non-prod (TS06, DS10, …):** open the run → **Tests** tab (per-test pass/fail, error + screenshot) — plus the **`WW-Smoke-Report-<ENV>`** artifact.
- **PROD:** the **`WW-Smoke-Report-PROD`** artifact → `WW-Smoke-Report.html` (PROD has no Tests tab). Live progress is in the **Run Smoke tests** step.
- **Green/Red** = the ≥ 98 % pass-rate gate (1–3 rotating flaky timeouts stay green; a real regression goes red).

## Good to know
- **PROD** takes ~40 min (single agent) and includes the WebServer checks. Non-prod (`maxParallel 3`) is ~8–15 min.
- Prefer a command that also **emails the report**? Use the `wwsmoke` CLI (repo `runner/`).
- Full details, PROD auth, and troubleshooting: **`ci/README-Run-Tests-Playbook.md`**.

_Tip: ⭐ the pipeline (Pipelines list) so it's at the top for everyone._
