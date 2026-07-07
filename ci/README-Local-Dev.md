# WW Smoke — Local Dev, Adding Tests (Codegen) & Copilot Troubleshooting

For developers/QA who want to **run the tests locally**, **add new tests with
Playwright codegen**, and **use GitHub Copilot to troubleshoot**.

- Repo: `WW Smoke Tests` (Azure DevOps → `EnterpriseRepo / Application Services`)
- Stack: .NET 8, Playwright + NUnit (C#), page-object pattern
- Solution: `PlaywrightAutomation.sln` · tests in `PlaywrightAutomation/Tests/`

---

## 1. Prerequisites

| Need | Details |
|---|---|
| **.NET 8 SDK** | <https://dotnet.microsoft.com/download/dotnet/8.0> |
| **IDE** | Visual Studio 2022 or VS Code (with C# Dev Kit) |
| **Network** | On the corp network/VPN — tests hit internal `*.dqtest.ad` hosts, and restore uses the on-prem NuGet feed `http://chtfs02pv.dq.ad/nuget/` |
| **Browser** | Microsoft Edge or Chrome installed |
| **Access** | A test-env user id for the app login (`PLAYWRIGHT_USERNAME`) and DB creds |

---

## 2. Get the code

```powershell
git clone "https://dev.azure.com/EnterpriseRepo/Application%20Services/_git/WW%20Smoke%20Tests"
cd "WW Smoke Tests"
```

---

## 3. Configure environment + secrets

The suite picks its config from **`TEST_ENV`** → loads `appsettings.<ENV>.json`
(e.g. `TS06`). Secrets come from **environment variables** (never commit them).

```powershell
# Which environment to target
$env:TEST_ENV = "TS06"

# App login (test-env impersonation) + DB auth
$env:PLAYWRIGHT_USERNAME       = "your-test-user"
$env:DbSettings__DbUserId      = "your-db-user"
$env:DbSettings__DbPassword    = "your-db-password"

# Nice for local: watch the browser + pick the channel
$env:BrowserSettings__Headless = "false"
$env:PLAYWRIGHT_BROWSER_CHANNEL = "msedge"     # or chrome
```

> Prefer .NET user-secrets over env vars? `dotnet user-secrets` works too — set
> `PLAYWRIGHT_USERNAME`, `DbSettings:DbUserId`, `DbSettings:DbPassword`.

---

## 4. Restore, build, install the browser

```powershell
dotnet restore PlaywrightAutomation.sln
dotnet build   PlaywrightAutomation.sln -c Debug

# Install the Playwright browser (one-time; path is created by the build)
pwsh PlaywrightAutomation/bin/Debug/net8.0/playwright.ps1 install msedge
```

---

## 5. Run tests locally

```powershell
# Everything
dotnet test PlaywrightAutomation.sln

# One business unit (same filters the pipeline uses)
dotnet test --filter "FullyQualifiedName~Tests.Gov"
dotnet test --filter "FullyQualifiedName~Tests.Bcbsm"

# A single test by name
dotnet test --filter "FullyQualifiedName~NavigateToClaimsWorkedReportFromOperationsSideMenu"

# The curated smoke set for a BU (mirrors the pipeline)
dotnet test --filter "FullyQualifiedName~Tests.Com&TestCategory=TestEnv"

# See each test as it runs
dotnet test --logger "console;verbosity=detailed"
```

**Watch it run (headed):** set `$env:BrowserSettings__Headless = "false"` (Section 3).

**Debug a failure:**
- Set a breakpoint and run the test under the debugger in VS/VS Code, **or**
- `$env:PWDEBUG = "1"` to launch the **Playwright Inspector** (step through actions), **or**
- Open the failure's **trace** (`trace.zip`, produced on failure) at
  <https://trace.playwright.dev> to replay it click-by-click.

---

## 6. Add a new test with **codegen**

Playwright **codegen** records your clicks/typing and writes the C# for you.

### a) Record
```powershell
# Point at the environment you configured (use that env's BaseUrl)
pwsh PlaywrightAutomation/bin/Debug/net8.0/playwright.ps1 codegen `
  --target csharp -c msedge https://ts06wwweb.dqtest.ad/
```
A browser + **Inspector** open. Do the flow you want to test; the Inspector fills
in with generated C# (`await page.GetByRole(...).ClickAsync();` etc.). Copy it.

### b) Fold it into a test
Codegen emits raw `page.` calls — adapt them to the project's conventions:
1. Put the test in the right BU file under `PlaywrightAutomation/Tests/`
   (e.g. `GovNavigation.cs`), or add a new file.
2. Use the fixture's **`Page`** (not codegen's `page`), and let the base handle
   login/BU selection:
   ```csharp
   [Test, Category("TestEnv")]          // Category("TestEnv") = included in the smoke run
   public async Task NavigateToMyNewThing()
   {
       var baseUrl = ConfigurationHelper.LoadConfiguration().BaseUrl;
       await Page.GotoAsync(baseUrl);
       await basePlaywrightTests.UserIdNeededForTestEnv();   // handles the test-env login
       await basePlaywrightTests.SelectBusinessUnit("GOV");

       // ---- paste your codegen steps here, changing `page` -> `Page` ----
       await Page.GetByRole(AriaRole.Link, new() { Name = "Operations" }).ClickAsync();
       // ...

       // Assert with a web-first assertion (auto-waits; no fixed sleeps)
       await Assertions.Expect(Page.GetByRole(AriaRole.Cell, new() { Name = "Results" }))
                       .ToBeVisibleAsync();
   }
   ```
3. **Categories decide where it runs:** `[Category("TestEnv")]` puts it in the
   smoke set. Match the class namespace to the BU (`...Tests.Gov...`) so the
   pipeline's per-BU filter picks it up.
4. **Prefer role/label locators** (`GetByRole`, `GetByLabel`, `GetByText`) over
   brittle CSS/XPath — codegen usually gives you these; keep them.
5. **No fixed `Task.Delay`/`WaitForTimeout`.** Let `Expect(...)` and the auto-wait
   on clicks handle timing (they return as soon as the app is ready).

### c) Run just your new test
```powershell
dotnet test --filter "FullyQualifiedName~NavigateToMyNewThing"
```
Green locally? Commit and push; it'll flow into the pipeline's smoke run.

---

## 7. Troubleshooting with GitHub Copilot

Copilot Chat (VS 2022: **View → GitHub Copilot Chat**; VS Code: the Chat panel)
is great for test failures. Select the failing code or paste the error, then ask.

### Handy prompts
| Situation | Ask Copilot |
|---|---|
| Cryptic error | Paste it: *"Explain this Playwright error and the most likely cause."* |
| `Timeout 30000ms exceeded … waiting for locator` | *"This locator times out. Suggest a more robust Playwright locator using GetByRole/GetByLabel for this element."* (paste the surrounding HTML if you have it) |
| Flaky test | *"Why might this test be flaky, and how do I make it deterministic with web-first assertions?"* |
| Fixed sleeps | *"Replace these Task.Delay/WaitForTimeout calls with Playwright auto-waiting equivalents."* |
| New assertion | *"Write an NUnit + Playwright `Assertions.Expect` that verifies the results grid shows at least one row."* |
| Selector from HTML | Paste the element's HTML: *"Give me a stable Playwright C# locator for this control."* |
| Understand a helper | Select `UserIdNeededForTestEnv` → **/explain** |
| Quick fix | Select the red squiggle → **/fix** |

### Tips for good answers
- **Give context:** select the test method (and the page object it calls) before
  asking, so Copilot sees the fixture/`Page` conventions.
- **Paste the exact error + stack** — the file/line points Copilot at the spot.
- **Attach the trace insight:** open the failure trace at trace.playwright.dev,
  see where it stalled, and tell Copilot *"it hangs navigating to X"*.
- **Ask it to match the codebase:** *"Follow the existing page-object pattern and
  use the fixture's `Page`, not a new page."*
- **Verify before trusting:** run the test after applying a Copilot suggestion —
  it's a strong assistant, not an oracle. Prefer role/label locators and
  auto-waiting; reject any suggestion that adds `Task.Delay`.

---

## 8. Reference
- **How to run in CI / read results:** `ci/README-Run-Tests-Playbook.md`
- **Run it (one-pager):** `ci/HOW-TO-RUN.md`
- **Pipeline:** `azure-pipelines.yml`
- **Playwright docs:** <https://playwright.dev/dotnet/> · **Trace viewer:** <https://trace.playwright.dev>
