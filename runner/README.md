# WW Smoke Runner (`wwsmoke`)

A small .NET 8 console app testers run to **kick off the WW Smoke pipeline, wait
for it, and see the results right in the console** — no digging around in Azure
DevOps.

It queues the `WW Smoke Tests` pipeline (definition 697) in
`dev.azure.com/EnterpriseRepo`, watches the run to completion, downloads the
consolidated report, and prints the **verdict, pass rate, run link, and any
failing tests** to the terminal.

> **Email is off by default** (so you can just run and read results). To also
> email the report, set `Email.Enabled: true` in `appsettings.json` and fill in
> the SMTP block. See "Optional: email" below.

No external NuGet packages — it uses only the .NET base class library, so it
builds and runs anywhere the **.NET 8 SDK** is installed.

---

## 1. One-time setup

1. **Install the .NET 8 SDK** (if not already): <https://dotnet.microsoft.com/download/dotnet/8.0>.
2. **Create an Azure DevOps PAT** with **Build → Read & execute** scope
   (User settings → Personal access tokens). A shared/service PAT is fine so the
   whole team can use one.
3. **Set the PAT** as an environment variable (don't put it in any file):
   ```powershell
   setx WWSMOKE_ADO_PAT "<your-pat>"      # Windows (new terminals pick it up)
   ```
   ```bash
   export WWSMOKE_ADO_PAT="<your-pat>"    # macOS/Linux
   ```
4. **Edit `appsettings.json`** for your site — especially the `Email` block
   (`SmtpHost`, `From`, `DefaultTo`). Defaults point at the WW Smoke pipeline.
   - If your SMTP relay needs a password, set `WWSMOKE_SMTP_PASSWORD`; otherwise
     it sends as the domain-authenticated machine account.

---

## 1a. Get a single-file `wwsmoke.exe` (no .NET needed to run)

For non-developers, ship a **self-contained single-file exe** — testers just need
the two files `wwsmoke.exe` + `appsettings.json`, no .NET install.

**Option A — build it (needs the .NET 8 SDK on the build machine):**
```powershell
./publish.ps1            # or: publish.cmd     (Windows)
./publish.ps1 -Rid linux-x64   # other platforms
```
Output lands in `runner/publish/` — distribute `wwsmoke.exe` + `appsettings.json`.

**Option B — get it from a pipeline (no local SDK):**
Create a pipeline from `runner/azure-pipelines-runner.yml` (Pipelines → New →
Existing YAML), run it, and download the **`wwsmoke-exe`** artifact.

Then testers just run `wwsmoke.exe` (Section 2 shows the flags); they only need
the PAT env var and to edit `appsettings.json`.

---

## 2. Run it

```bash
# From the runner folder:
dotnet run -- --env TS06 --browser msedge --parallel 3
```

Or build once and run the exe:

```bash
dotnet build -c Release
./bin/Release/net8.0/wwsmoke --env PROD
```

With **no flags** it prompts you for environment and browser:

```bash
dotnet run
```

### What you'll see
```
==================== RESULTS ====================
  TS06: PASS  (98.2% passed, 168 of 171 tests)
  Run: https://dev.azure.com/EnterpriseRepo/.../_build/results?buildId=NNNNNN
  Failing tests (3):
    - [Commercial] Navigate To Member Info
    ...
  Full report: C:\Users\you\AppData\Local\Temp\WW-Smoke-Report-TS06-NNNNNN.html
=================================================
```

### Options
| Flag | Meaning |
|---|---|
| `--env <ENV>` | Target environment (`TS06`, `DS10`, `PROD`, …). Prompted if omitted. |
| `--browser <b>` | `msedge` or `chrome`. Prompted if omitted. |
| `--parallel <n>` | Business-unit legs at once. **PROD is always forced to 1.** |
| `--no-wait` | Queue the run and exit immediately (no waiting). |
| `--timeout <min>` | Max minutes to wait (default 90). |
| `--to <addr>` | Email recipient(s) — only used if email is enabled in `appsettings.json`. |
| `-h`, `--help` | Help. |

---

## 3. What it does

1. Queues the pipeline with your parameters and prints the run URL.
2. Polls until the run completes (or `--timeout`).
3. Downloads the `WW-Smoke-Report-<ENV>` artifact and reads the verdict, pass
   rate, and failing tests.
4. **Prints the results to the console** (verdict, pass rate, run link, failures,
   and the local path to the full HTML report).
5. Exits `0` if the build passed, non-zero otherwise (handy for scheduling).

### Optional: email
Off by default. To also email the report: set `Email.Enabled: true` in
`appsettings.json`, fill in `SmtpHost` / `From` / `DefaultTo` (and
`WWSMOKE_SMTP_PASSWORD` if your relay needs auth), then pass `--to <addr>`.

> **PROD note:** PROD runs as a single leg and takes ~20–25 min; the tool forces
> `--parallel 1`. See the run playbook (`ci/README-Run-Tests-Playbook.md`, §7a)
> for how PROD auth/results work.

---

## 4. Examples

```bash
# Standard smoke on TS06, email the QA lead
dotnet run -- --env TS06 --to qa-lead@company.com

# PROD run, email the release DL (parallel is forced to 1)
dotnet run -- --env PROD --to release-mgmt@company.com

# Just queue a DS10 run and leave (no waiting)
dotnet run -- --env DS10 --no-wait

# Nightly-style: run, don't email, use the exit code
dotnet run -- --env TS06 --no-email
```

---

## 5. Troubleshooting

| Symptom | Fix |
|---|---|
| `set WWSMOKE_ADO_PAT` error | The PAT env var isn't set (or the terminal predates `setx`). |
| `Queue failed (403/401)` | PAT lacks **Build: Read & execute**, or it expired. |
| No email received | Check the `Email` block in `appsettings.json` and that the SMTP host is reachable; set `WWSMOKE_SMTP_PASSWORD` if the relay needs auth. |
| `No consolidated report artifact` | The run failed before producing a report (open the run URL); the email still sends with the build result. |
