# Running WW Smoke from Azure Test Plans (YAML-native)

Replaces the legacy classic release **PlaywrightAutoRelease** with a single YAML
pipeline, `azure-pipelines.yml`, in the **WW Smoke Tests** repo. It runs the
automated tests associated with the test cases in **Plan 79388 / Suite 79389 /
Config 45** and publishes outcomes back onto the test points.

## How it maps to legacy

| Legacy classic release | This pipeline |
|---|---|
| Build artifact `PlaywrightAutomation` (def 1966) | `checkout: self` + `dotnet build` in the pipeline |
| 9 per-env stages | one pipeline; **environment is a run-time parameter** (`testEnv`) |
| File Transform on `appsettings.<ENV>.json` | not needed — app reads `TEST_ENV` and loads the file itself |
| VS Test Platform Installer task | `VisualStudioTestPlatformInstaller@1` |
| `VsTest` task (`testSelector=testRun`) | `VSTest@2` (`testSelector=testPlan`, plan 79388 / suite 79389 / config 45) |
| On-prem queue 12 / 13 | self-hosted pool **AppSvcs-OnPrem-SQA** |

> Legacy bug not carried over: the legacy TSNB5/6/7 and TSSLADJ stages all
> File-Transformed `appsettings.TSHF.json` instead of their own env file. Here
> the env is selected correctly by the `testEnv` parameter.

## One-time setup in ADO Cloud

1. **Create the pipeline.** Pipelines → New pipeline → Azure Repos Git →
   **WW Smoke Tests** → *Existing Azure Pipelines YAML file* → `/azure-pipelines.yml`.
2. **Variable group** `PlaywrightAutomation-Secrets` (Pipelines → Library), ideally
   linked to Key Vault:
   | Variable | Maps to | Secret |
   |---|---|---|
   | `PLAYWRIGHT_USERNAME` | login id | no |
   | `DbSettings__DbUserId` | `DbSettings:DbUserId` | no |
   | `DbSettings__DbPassword` | `DbSettings:DbPassword` | **yes** |
3. **Self-hosted agent** online in pool **AppSvcs-OnPrem-SQA** (Windows, Edge
   installed, can reach `*.dqtest.ad` + on-prem SQL + the on-prem NuGet feed).

## How you run it (and see results in Test Plans)

**Recommended — run from the pipeline (push model):**
Pipelines → *WW Smoke Tests* → **Run pipeline** → choose **testEnv** (e.g. `PROD`,
`QAR`) → Run. `VSTest@2` executes the suite's automated tests and writes pass/fail
back to the test points. Open **Test Plans → Plan 79388 → Progress report / Execute**
to see per-case outcomes. A nightly QAR run is also scheduled (06:00 UTC).

## Important: the "Run" button *inside* Test Plans

The literal *Test Plans → Run → Run automated tests* button is, in stock Azure
DevOps, a **classic-release** feature (it lists release stages, not YAML
pipelines). With this YAML-native approach you drive runs **from the pipeline**
(above), and results still land in Test Plans. If you specifically need the
in-Test-Plans Run button to trigger execution, that requires the classic-release
path (the "Option 1" we discussed) — say the word and I'll generate it.

## Notes

- `testConfiguration: 45` is the plan's default config, which is what every test
  point in suite 79389 currently uses. If you add cases under a different config,
  update this value.
- Plan/suite/config IDs are hard-coded in the YAML for clarity; promote them to
  pipeline variables if you parameterize across plans later.
