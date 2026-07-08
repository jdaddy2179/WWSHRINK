# WW Smoke Tests

Automated Playwright UI smoke tests for Windward, run from the **WW Smoke Tests**
pipeline in Azure DevOps (~170 curated tests across Government, Commercial,
BCBSM, WW2, MassHealth, plus PROD WebServer checks).

> This repo holds the CI/tooling/docs. The **test source** lives in the Azure
> DevOps repo: [`WW Smoke Tests` → `PlaywrightAutomation/Tests`](https://dev.azure.com/EnterpriseRepo/Application%20Services/_git/WW%20Smoke%20Tests?path=/PlaywrightAutomation/Tests).

---

## ▶ Run the tests & get results emailed

**Run it (3 clicks):** open **[Run pipeline → WW Smoke Tests](https://dev.azure.com/EnterpriseRepo/Application%20Services/_build?definitionId=697)** → **Run pipeline** → set:
- **Target environment** (TS06, DS10, PROD, …) · **Browser** (msedge / chrome) · **legs at once** (3 non-prod, **1 for PROD**)

→ **Run**. Sign in with your normal ADO account — no tokens.

**Get results emailed to you** — either:
- **Subscribe in ADO (no tooling):** [Notification settings](https://dev.azure.com/EnterpriseRepo/_settings/notifications) → **New subscription** → **Build → A build completes** → filter **Build pipeline = WW Smoke Tests** → your email.
- **`wwsmoke` CLI:** `wwsmoke --env TS06` — queues the run, waits, and prints the verdict, pass rate, and failing tests **in the console** (email optional, off by default; see [`runner/`](runner/README.md)).

**See results:** non-prod → the run's **Tests** tab + the `WW-Smoke-Report-<ENV>` artifact. PROD → the `WW-Smoke-Report-PROD` artifact (no Tests tab). Green/red = the **≥ 98 % pass-rate gate**.

---

## Docs
| Doc | What it covers |
|---|---|
| [`ci/HOW-TO-RUN.md`](ci/HOW-TO-RUN.md) | One-page run + email + test-plan links (paste into a dashboard/wiki) |
| [`ci/WW-UI-Directory.md`](ci/WW-UI-Directory.md) | UI test directory by business unit + **database names/servers** per env |
| [`ci/README-Run-Tests-Playbook.md`](ci/README-Run-Tests-Playbook.md) | Full guide: parameters, results, **PROD**, troubleshooting |
| [`ci/README-Local-Dev.md`](ci/README-Local-Dev.md) | Run locally, add tests via **codegen**, **Copilot** troubleshooting |
| [`runner/README.md`](runner/README.md) | `wwsmoke` CLI (queue + wait + console results; optional email) and single-file exe |
| [`launcher/README.md`](launcher/README.md) | Optional static self-service launcher page |
| [`ci/PROD-Cloud-Agent-Onboarding.md`](ci/PROD-Cloud-Agent-Onboarding.md) | Register prod agents (to parallelize PROD) |
| [`ci/agent-register-cloud.md`](ci/agent-register-cloud.md) | Per-VM agent registration + proxy notes |
| [`ci/QAR-Okta-MFA-Bypass-Ask.md`](ci/QAR-Okta-MFA-Bypass-Ask.md) | Enable QAR (Okta MFA bypass ask) |
| [`ci/README-Agent-Disk-Maintenance.md`](ci/README-Agent-Disk-Maintenance.md) | Agent disk/memory upkeep |

## Test cases & scenarios
- **Source:** [`PlaywrightAutomation/Tests`](https://dev.azure.com/EnterpriseRepo/Application%20Services/_git/WW%20Smoke%20Tests?path=/PlaywrightAutomation/Tests)
- **Test Plan:** [WW Smoke (planId 79388)](https://dev.azure.com/EnterpriseRepo/Application%20Services/_testPlans/define?planId=79388) — Env-TS06/DS10/PROD suites.

## Pipeline
`ci/azure-pipelines.yml` (definition 697). Non-prod runs on `AppSvcs-OnPrem-SQA`; PROD on `Production SQA Agents`.
