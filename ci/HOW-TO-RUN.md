# ▶ How to Run the WW Smoke Tests

**[Run pipeline → WW Smoke Tests](https://dev.azure.com/EnterpriseRepo/Application%20Services/_build?definitionId=697)**  ·  no tokens — sign in with your normal ADO account.

## Run it (3 clicks)
1. Open the link above → click **Run pipeline** (top-right).
2. Set the parameters:
   - **Target environment** — e.g. `TS06`, `DS10`, `PROD`
   - **Browser** — `msedge` or `chrome`
   - **Business-unit legs at once** — `3` for non-prod · **`1` for PROD**
3. Click **Run**.

## View results (after the run completes)
1. **Find the run:** Pipelines → **WW Smoke Tests** → click your run (top of the list). The header shows **green** (passed the ≥ 98 % pass-rate gate) or **red** (a real regression, or 0 tests).
2. **Per-test detail — non-prod (TS06, DS10, …):** open the **Tests** tab → every test with pass/fail, duration, and on failure the **error message + attached screenshot/trace**. Download a trace and open it at <https://trace.playwright.dev> to replay the failure click-by-click.
3. **Consolidated report — any env (best for sharing):** run → **Artifacts** (or the run summary) → **`WW-Smoke-Report-<ENV>`** → open `WW-Smoke-Report.html` — **verdict, pass rate, per-business-unit breakdown, and each failure with its reason**.
4. **PROD** has **no Tests tab** → use the report artifact above. Failures also print in the **Consolidated test report** step log, and live per-test output streams in the **Run Smoke tests** step while it runs.

> **Green/Red** = the ≥ 98 % pass-rate gate — 1–3 rotating flaky timeouts stay green; a real regression (or zero tests) goes red. Every failure still shows in the Tests tab / report regardless.

## 📧 Get results emailed to you
**Option A — subscribe yourself in Azure DevOps (no tooling):**
1. Go to **[Notification settings](https://dev.azure.com/EnterpriseRepo/_settings/notifications)** (avatar → **User settings → Notifications**).
2. **New subscription** → **Build** → **A build completes**.
3. Filter: **Build pipeline = WW Smoke Tests** (optionally **Status = Failed** only).
4. Deliver to your email → **Save**. You'll get an email each time a run finishes.

**Option B — run it and read results in the console (`wwsmoke` CLI, repo `runner/`):**
```
wwsmoke --env TS06
```
Queues the run, waits, and prints the verdict, pass rate, run link, and failing tests. (Email is optional — off by default; enable it in `appsettings.json`.) See `runner/README.md`.

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
