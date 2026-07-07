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

## Test cases & scenarios (for reference)
- **Test Plan — [WW Smoke](https://dev.azure.com/EnterpriseRepo/Application%20Services/_testPlans/define?planId=79388)** (scenarios by environment):
  [Env – TS06](https://dev.azure.com/EnterpriseRepo/Application%20Services/_testPlans/define?planId=79388&suiteId=79808) ·
  [Env – DS10](https://dev.azure.com/EnterpriseRepo/Application%20Services/_testPlans/define?planId=79388&suiteId=79807) ·
  [Env – PROD](https://dev.azure.com/EnterpriseRepo/Application%20Services/_testPlans/define?planId=79388&suiteId=79809)
- **Browse the tests (source):** [WW Smoke Tests repo → `PlaywrightAutomation/Tests`](https://dev.azure.com/EnterpriseRepo/Application%20Services/_git/WW%20Smoke%20Tests?path=/PlaywrightAutomation/Tests)
- **Executed cases from a run:** open a non-prod run → **Tests** tab (every test with pass/fail, duration, error + screenshot).

> The automated smoke run is driven by the `TestEnv` **category filter** (~170 curated tests), not by the Test Plan suites — the plan above is the scenario reference.

## Good to know
- **PROD** takes ~40 min (single agent) and includes the WebServer checks. Non-prod (`maxParallel 3`) is ~8–15 min.
- Prefer a command that also **emails the report**? Use the `wwsmoke` CLI (repo `runner/`).
- Full details, PROD auth, and troubleshooting: **`ci/README-Run-Tests-Playbook.md`**.

_Tip: ⭐ the pipeline (Pipelines list) so it's at the top for everyone._
