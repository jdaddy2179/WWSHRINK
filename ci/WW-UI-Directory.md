# WW UI Test Directory & Databases

A map of the **WW Smoke** UI test suite — how the tests are organized by business
unit, which page-object areas they drive, and the **database name + server** each
one reads from per environment.

- **Repo:** `WW Smoke Tests` (Azure DevOps → `EnterpriseRepo / Application Services`)
- **Tests:** `PlaywrightAutomation/Tests/` · **Page objects:** `PlaywrightAutomation/Pages/`
- **Config per env:** `PlaywrightAutomation/appsettings.<ENV>.json`

---

## Directory layout

```
PlaywrightAutomation/
├─ Tests/                     UI smoke/regression tests (NUnit + Playwright)
│  ├─ Gov*.cs                 Government (GOV)
│  ├─ Com*.cs                 Commercial (COM) + ComDelta
│  ├─ Bcbsm*.cs               BCBSM
│  ├─ MassHealthSearches.cs   MassHealth
│  ├─ WW2ConfigNavigation.cs  WW2 Config app
│  ├─ Ww2PaymentNavigation.cs WW2 Payment app
│  ├─ ClaimImageValidation.cs Claim image checks
│  ├─ WebServerValidation*.cs PROD web-server node checks (WebServer category)
│  └─ Regression/Claims/*.cs  Claims regression (DB-driven)
├─ Pages/                     Page objects (one folder per app)
│  ├─ Windward/               WW 1.0 (main app)
│  ├─ WW2Config/              WW2 configuration UI
│  └─ WW2Payment/             WW2 payment UI
├─ TestData/                  Per-BU JSON test data (incl. "Database": Windward_*)
├─ Helpers/                   ConfigurationHelper, DatabaseHelper, TestCaseIdAttribute
├─ Fixtures/                  PlaywrightFixture (base), BasePlaywrightTests
├─ SqlQueries/                Claims SQL used by the regression tests
└─ appsettings.<ENV>.json     BaseUrl / ConfigUrl / PaymentUrl / DbServer per env
```

---

## Tests by business unit

| Business unit | Test files | Approx. tests | Database (catalog) |
|---|---|---:|---|
| **Government (GOV)** | `GovNavigation.cs`, `GovNavigation1.cs`, `GovNavigation3.cs`, `GovNavigation4.cs`, `GovNavigation5.cs`, `GovSearches.cs` | ~74 | `Windward_Government` |
| **Commercial (COM)** | `ComNavigation.cs`, `ComNavigation1.cs`, `ComSearches.cs` | ~38 | `Windward_Commercial` |
| **ComDelta / Delta** | `ComDeltaSearches.cs` | ~11 | `Windward_Delta` |
| **BCBSM** | `BcbsmNavigation.cs`, `BcbsmNavigation1.cs`, `BcbsmSearches.cs` | ~32 | `Windward_BCBSM` |
| **MassHealth** | `MassHealthSearches.cs` | ~11 | `Windward_MassHealth` |
| **WW2 (Config + Payment)** | `WW2ConfigNavigation.cs`, `Ww2PaymentNavigation.cs` | ~25 | — (UI only) |
| **Claim images** | `ClaimImageValidation.cs` | ~5 | — (UI only) |
| **WebServer (PROD only)** | `WebServerValidation.cs` … `WebServerValidation6.cs`, `WebServerValidationPCD.cs`, `WebServerValidationPCDService.cs` | 117 | — (per-node HTTP checks) |
| **Claims regression** (DB-driven) | `Regression/Claims/{Gov,Com,Bcbsm,Delta,MH}ClaimsTests.cs` | ~27 | `Windward_*` (per BU) |

> The pipeline splits the **smoke run** by BU using the `TestEnv` category filter
> (~173 curated tests); the **WebServer** set runs only on PROD (`WebServer`
> category). Claims regression is DB-driven and not part of the per-BU smoke legs.

---

## Databases

The suite reads reference/claims data from SQL Server. The **server** is chosen by
environment (`DbSettings.DbServer` in `appsettings.<ENV>.json`); the **database
name (Initial Catalog)** is chosen per **business unit** at runtime
(`DatabaseHelper.GetConnectionString(databaseName)` — the `"Database"` field in the
BU's `TestData/*.json`).

### Database names (catalogs) — same across environments

| Business unit | Database name |
|---|---|
| Government | `Windward_Government` |
| Commercial | `Windward_Commercial` |
| BCBSM | `Windward_BCBSM` |
| Delta | `Windward_Delta` |
| MassHealth | `Windward_MassHealth` |

### Database server + app URL per environment

| Env | App BaseUrl | DB server (`DbServer`) |
|---|---|---|
| **DS01** | `https://ds01wwweb.dqdev.ad/` | `DS01WWSQL.DQDEV.AD` |
| **DS10** | `https://ds10wwweb.dqdev.ad/` | `DS10WWSQL.DQDEV.AD` |
| **QAR** | `https://tsslftwwweb.dqtest.ad/` | `TSSLFTWWSQL.DQTEST.AD` |
| **TS06** | `https://ts06wwweb.dqtest.ad/` | `TS06WWSQL.DQTEST.AD` |
| **TSHF** | `https://tshfwwweb.dqtest.ad/` | `TSHFWWSQL.DQTEST.AD` |
| **TSNB5** | `https://tsnb5wwweb.dqtest.ad/` | `TSNB6WWSQL.DQTEST.AD` |
| **TSNB6** | `https://tsnb6wwweb.dqtest.ad/` | `TSNB6WWSQL.DQTEST.AD` |
| **TSNB7** | `https://tsnb7wwweb.dqtest.ad/` | `TSNB7WWSQL.DQTEST.AD` |
| **TSSLADJ** | `https://tssladjwwweb.dqtest.ad/` | `TSSLADJWWSQL.DQTEST.AD` |
| **PROD** | `https://windward.dq.ad/` | `NOTAPPLICABLE` (UI + web-server checks only — no DB reads) |

> Full catalog on a given env = **`DbServer` + database name**, e.g. on TS06 the
> Commercial claims tests read `TS06WWSQL.DQTEST.AD` → `Windward_Commercial`.
> **PROD** runs UI navigation + the 117 WebServer node checks only, so it uses no
> database (`DbServer = NOTAPPLICABLE`). DB credentials come from the
> `PLAYWRIGHT_USERNAME` / `DbSettings__DbUserId` / `DbSettings__DbPassword`
> environment variables — never committed.

### PROD WebServer nodes (from `appsettings.PROD.json`)

`WebServer01–09` → `pswwweb01–09.dq.ad` · `WebServer10–13` →
`phww1web22p–25p.dq.ad`. The `WebServerValidation*` tests hit each node directly to
confirm every PROD web server serves the app.

---

## Related docs
- **Run / results:** `ci/README-Run-Tests-Playbook.md` · **One-pager:** `ci/HOW-TO-RUN.md`
- **Local dev / add tests / troubleshoot:** `ci/README-Local-Dev.md`
- **Test plan:** [WW Smoke (planId 79388)](https://dev.azure.com/EnterpriseRepo/Application%20Services/_testPlans/define?planId=79388) — Env-TS06/DS10/PROD suites (+ **WebServer** under PROD).
