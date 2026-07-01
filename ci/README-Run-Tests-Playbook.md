# WW Smoke Tests — How to Run (Playbook)

A step-by-step guide for testers and release management to run the WW Smoke
Playwright suite in Azure DevOps and read the results.

- **Pipeline:** `WW Smoke Tests` (Azure DevOps → Pipelines, definition **697**)
- **Project:** `EnterpriseRepo / Application Services`
- **What it runs:** ~171 curated Playwright UI smoke tests, split by business
  unit, against the environment you choose.

---

## 1. Quick start — run the tests

You have two ways. Both authenticate with your normal Azure DevOps login — no
tokens or passwords to enter.

### Option A — the Launcher page (easiest for testers)
1. Open the **WW Smoke Launcher** page (the Static Web App URL your team shares).
2. Pick an **environment** (e.g. `TS06`) and a **browser**.
3. Click **“Open Run dialog in Azure DevOps.”**
4. In the dialog that opens, set the values the page shows, then click **Run**.

### Option B — directly in Azure DevOps
1. Go to **Pipelines → WW Smoke Tests**.
2. Click **Run pipeline** (top-right).
3. Set the parameters (below), then **Run**.

---

## 2. Parameters

| Parameter | What it does | Typical value |
|---|---|---|
| **Target environment** | Which `appsettings.<ENV>.json` the tests load (the app/DB they hit). | `TS06` |
| **Browser to run on** | `msedge` or `chrome`. | `msedge` |
| **Business-unit legs at once** (`maxParallel`) | How many business units run in parallel. Higher = faster but more load on the app. **3 is the tested-stable value.** | `3` |

> **Don't raise `maxParallel` past 3 casually.** More browsers hitting the app
> at once caused intermittent timeouts. 3 is the sweet spot.

---

## 3. How it runs (so you know what to expect)

- The suite is split into **5 business-unit legs**, each its own parallel job:
  **Government, Commercial, BCBSM, WW2, MassHealth.**
- Each leg checks out, builds, and runs **only its business unit's tests** with
  `dotnet test`, then publishes results.
- A final **Consolidated test report** job merges everything into one report.
- Typical wall-clock time: **~8–15 minutes** with `maxParallel: 3`.
- **Build status comes from a pass-rate gate**, not individual tests: it's
  **GREEN at ≥ 98% pass** (so 1–3 rotating flaky timeouts don't turn it red) and
  **RED below 98%** (a real regression) or if zero tests ran. Every failure
  still shows in the Tests tab and the report — nothing is hidden.

---

## 4. Read the results

### A) Tests tab (per-test detail) — for testers
Open the run → **Tests** tab. You get every test with:
- Pass/Fail, duration, and the business-unit run title.
- On failure: the **error message + stack trace**, and the **Playwright
  screenshot/trace** attached (download the trace and open it at
  <https://trace.playwright.dev> to replay the failure).

### B) Consolidated HTML report — for management / release
Open the run → **Artifacts** (or the run summary) → download
**`WW-Smoke-Report-<ENV>`** → open `WW-Smoke-Report.html`. It shows:
- **Verdict** (PASS/FAIL) and overall **pass rate**.
- **Results by business unit** (tests / passed / failed / pass-rate per BU).
- **Failed tests** with their reasons.
- A link back to the full ADO run.

### C) Analytics (trends over time)
Pipeline → **Analytics** tab → test pass-rate trend, flaky tests, etc.

---

## 5. Common scenarios

- **Run the standard smoke on TS06:** Environment `TS06`, Browser `msedge`,
  `maxParallel 3` → Run. (These are the defaults — just click Run.)
- **Run on a different environment:** change **Target environment** (e.g.
  `DS10`, `QAR`).
- **Run in Chrome:** set **Browser** to `chrome`.
- **Need it faster and the app can take the load:** raise `maxParallel` to 4–5
  (watch for flaky timeouts).

---

## 6. Known issues / quarantined tests

- **2 provider-search tests** (Commercial, MassHealth `PeformFindAProviderSearch`)
  are **temporarily excluded** — their member/location returns no nearby
  providers in TS06, so the results grid never renders. They’ll be re-added once
  valid TS06 data is available. This is intentional, not a pipeline bug.

---

## 7. Troubleshooting

| Symptom | Likely cause / fix |
|---|---|
| Run is **cancelled at ~20 min** | A leg overran the per-leg timeout (slow agent/app). Re-run; if persistent, lower `maxParallel` or check the environment's health. |
| **“Missing required variable”** error early | The `PlaywrightAutomation-Secrets` variable group isn't linked/authorized for the pipeline (Pipelines → Library). |
| Many tests fail with **timeouts** | The app under test is slow/under load. Lower `maxParallel`, or check the target environment is up. |
| Build is **red** | Pass rate fell below 98% (the gate). Open the report/Tests tab: if it's the usual 1 rotating flaky timeout you'd normally be green — re-run. If several real failures, that's a genuine regression to triage. |
| **No agents / run stuck queued** | The self-hosted pool `AppSvcs-OnPrem-SQA` has no free agents. Wait or check agent health. |
| Agent **low disk / memory** warnings | See `README-Agent-Disk-Maintenance.md` (enable the pool maintenance job). |

---

## 7a. Running against PROD (status: pending prod agents)

PROD (`windward.dq.ad`) uses **IIS Integrated Windows Auth** — there is no
username/password form. The browser authenticates with the **agent's Windows
identity**, which must be a **provisioned Windward PROD app user**. The
`AppSvcs-OnPrem-SQA` agents run as `svc-tfsbuild`, which is *not* a prod app
user, so PROD scheduled on this pool fails app auth
(`ERR_INVALID_AUTH_CREDENTIALS`).

**PROD is therefore not yet runnable from this cloud pipeline.** Non-prod
environments (TS06, DS10, …) run normally today.

**Plan to enable PROD (move off-prem):** the on-prem `SQA Production Agents`
VMs (`Production01…15`) already run the prod smoke on-prem and each run as a
prod-provisioned `DQ\Svc-sqa-p0xx` service account. Register a **second, cloud
agent instance** on each of those VMs against this org, in a cloud pool
`SQA Production Agents`, with the service logged on as the **same**
`DQ\Svc-sqa-p0xx` account. Then PROD points at that pool. Requirements:

- Each VM needs **outbound HTTPS to `dev.azure.com`** (they currently only talk
  to on-prem `tfs.dq.ad`).
- Install a **current v3/v4 agent** (the on-prem ones are v2.x) in a *separate*
  folder from the existing agent so both coexist.
- Keep the VMs **domain-joined** (needed to reach `windward.dq.ad` and
  authenticate).

Once that pool exists, PROD's `pool:` is switched to it (all agents in it are
prod-capable, so no per-agent capability/demand is needed).

---

## 7b. Running against QAR (status: blocked on Okta MFA)

QAR is behind **Okta with Okta Verify (MFA)** — unlike TS06/DS10, which use the
internal forms login. Headless CI agents can't answer an MFA push, so QAR logins
hang and tests fail on the first navigation with a `waiting until "load"`
timeout. **This is an auth block, not a test bug**, and QAR is **not runnable**
until it's resolved.

The chosen fix is a **scoped Okta MFA bypass** for the CI agents (trusted-network
zone + password/IWA for the QAR app), which needs the Okta/IAM admin team. The
full ask is in `ci/QAR-Okta-MFA-Bypass-Ask.md`. Once in place, SQA adds a
QAR-specific login path (the forms-login helper doesn't handle Okta).

---

## 8. Reference

- **Pipeline definition:** `ci/azure-pipelines.yml`
- **Disk/agent maintenance:** `ci/README-Agent-Disk-Maintenance.md`
- **Launcher page:** `launcher/` (deploy steps in `launcher/README.md`)
- **Failure email alerts:** Project Settings → Notifications → *A build completes*
  (status = Failed) → deliver to your distribution list.
- **Self-hosted pool:** `AppSvcs-OnPrem-SQA` (on-prem; required for the internal
  `*.dqtest.ad` hosts, on-prem SQL, and on-prem NuGet feed).
