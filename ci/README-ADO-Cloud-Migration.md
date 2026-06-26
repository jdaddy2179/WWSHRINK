# Migrating PlaywrightAutomation: On-Prem TFS Release → ADO Cloud Pipeline

Moves the PlaywrightAutomation suite from the on-prem TFS **release** pipeline
to an Azure DevOps **Cloud** YAML pipeline.

| | From (on-prem) | To (cloud) |
|---|---|---|
| Server | `tfs.dq.ad:8080/tfs/WindwardCollection` | `dev.azure.com/EnterpriseRepo` |
| Project | Application Services | Application Services |
| Type | Classic **release** pipeline (releaseId 8471) | **YAML** pipeline (like build def 311) |
| Definition | UI-defined, not in source | [`azure-pipelines.yml`](azure-pipelines.yml), committed to the repo |

## The one thing that must be right: a self-hosted agent

The suite talks to **internal hosts only**:

- App URLs — `https://tsslftwwweb.dqtest.ad/`, `...wwwebpmt...`, `...wwwebcfg...` (`appsettings.*.json`)
- SQL Server — `TSSLFTWWSQL.DQTEST.AD` (`PlaywrightFixture.cs`)
- NuGet feed — `http://CHTFS02PV.DQ.AD/nuget/` (`NuGet.Config`)

Microsoft-hosted ADO Cloud agents live on the public internet and **cannot
resolve or reach `*.dq.ad` / `*.dqtest.ad`**. So even though the *pipeline
control plane* moves to the cloud, the **agent must stay on-prem**:

1. Stand up a **self-hosted agent** (Windows, with Microsoft Edge installed) on
   a host inside the DQ network that can reach the URLs above.
2. Register it in an ADO Cloud **agent pool** (e.g. `DQ-SelfHosted`).
3. Set the pipeline's `agentPool` parameter to that pool name.

This is the standard pattern for cloud ADO driving internal test targets and is
why the old release ran on an on-prem agent in the first place.

## One-time setup in ADO Cloud

1. **Place the YAML.** Copy [`azure-pipelines.yml`](azure-pipelines.yml) to the
   **root of the PlaywrightAutomation repo** (next to `PlaywrightAutomation.sln`).
2. **Create the pipeline.** Pipelines → New pipeline → Azure Repos Git → select
   the repo → *Existing Azure Pipelines YAML file* → `/azure-pipelines.yml`.
3. **Create the variable group** `PlaywrightAutomation-Secrets`
   (Pipelines → Library) with — ideally linked to Azure Key Vault:
   | Variable | Maps to | Used by |
   |---|---|---|
   | `PLAYWRIGHT_USERNAME` | login id | `BasePlaywrightTests.cs` |
   | `DbSettings__DbUserId` | `DbSettings:DbUserId` | `PlaywrightFixture` connection string |
   | `DbSettings__DbPassword` | `DbSettings:DbPassword` | same |
   Mark the password **secret**. The DB creds are intentionally *not* in
   `appsettings.*.json`; the app reads them via `AddEnvironmentVariables()`.
4. **Agent pool.** Confirm the self-hosted pool name and pass it as `agentPool`.

## How the pipeline maps to the code

| Pipeline | Source behavior |
|---|---|
| `TEST_ENV` env var | `ConfigurationHelper` loads `appsettings.<TEST_ENV>.json` (default `DS01`) |
| `testCategory` → `--filter "TestCategory=..."` | NUnit `[Category("TestEnv"/"Prod"/"WebServer"/"Regression")]` |
| `playwright.ps1 install msedge` | `BrowserSettings.Channel = "msedge"` (Chromium) |
| `PublishTestResults@2` (.trx) | NUnit results, replaces release test tab |
| screenshots artifact | `TearDown` screenshots on failure in `PlaywrightFixture.cs` |

## Run it

Pipelines → select pipeline → **Run pipeline**, then choose **Environment**
(`QAR`, `PROD`, …) and **Category** (`TestEnv`, `Prod`, `WebServer`,
`Regression`, or `All`). A nightly QAR schedule (06:00 UTC) is included and can
be adjusted or removed in the YAML.

## Notes / decisions

- `trigger: none` / `pr: none` mirror the release model (run on demand /
  scheduled, not on every commit). Add a `trigger:` block if you want CI on push.
- Restore uses the repo `NuGet.Config` (on-prem feed + nuget.org). It resolves
  only from a self-hosted agent in-network; if you later move to a hosted agent
  you must mirror these packages to Azure Artifacts.
- This guide and the YAML are committed to the **WWSHRINK (qa)** repo for review
  and hand-off. The YAML's runtime home is the **PlaywrightAutomation** repo.
