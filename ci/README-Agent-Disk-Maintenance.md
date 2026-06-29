# WW Smoke — Agent Disk-Space Maintenance

Self-hosted agents in the **`AppSvcs-OnPrem-SQA`** pool are shared by 30+ build
definitions. Over time each agent's `_work`, `_tool`, and package caches grow
and the agent starts warning about low disk space (and can stop accepting jobs).

The WW Smoke pipeline already minimises **its own** footprint, but only a
**pool-level maintenance job** can reclaim space left by *other* pipelines on the
same agent. This doc covers both.

---

## 1. Enable the pool Maintenance job  ← the real fix (do this once)

Cleans `_work`/`_tool` across **all** pipelines on the pool, automatically, when
agents are idle. Requires **pool administrator** rights.

1. **Organization Settings** → **Pipelines** → **Agent pools**.
2. Open **`AppSvcs-OnPrem-SQA`** → **Settings** tab.
3. Under **Maintenance**, enable it and set:
   - **Maximum number of days to keep `_work` directories**: `2` (or `3`)
   - **Run maintenance every**: e.g. **1 day**, at an off-hours time (e.g. 02:00)
   - **Maximum % of agents run maintenance simultaneously**: `50%` (so the pool
     isn't fully offline during cleanup)
   - **Maintenance job timeout**: `60` minutes
4. **Save.**
5. Verify later under **Maintenance history** — each agent shows a cleanup run,
   how much it freed, and pass/fail.

> Project-scoped alternative (if you only have project admin): **Project
> Settings → Agent pools → AppSvcs-OnPrem-SQA → Settings** exposes the same
> maintenance options for the project's view of the pool.

---

## 2. One-time manual cleanup on an agent (immediate relief)

Use when an agent is critically low *right now* and you can't wait for the
scheduled maintenance. Run in **PowerShell as the agent service account**
(`svc-tfsbuild`) on the agent machine. Prefer running it **between jobs** (or
stop the agent service first) so you don't delete a running job's files.

```powershell
# Go to the agent root (adjust to your install path)
cd D:\cloud-work        # or C:\agent

# 1) NuGet HTTP cache (safe; not the restored packages)
dotnet nuget locals http-cache --clear

# 2) Temp files
Remove-Item "$env:TEMP\*"              -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:LOCALAPPDATA\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

# 3) Old per-pipeline working dirs in _work, keeping the most recent few.
#    (_work\1, _work\2, ... one per pipeline that has run on this agent.)
Get-ChildItem .\_work -Directory |
  Where-Object Name -match '^\d+$' |
  Sort-Object LastWriteTime |
  Select-Object -SkipLast 5 |          # keep the 5 most-recently-used
  Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

# 4) See what's left, largest first
Get-ChildItem .\_work -Directory |
  ForEach-Object { [pscustomobject]@{ Dir=$_.Name
    GB=[math]::Round((Get-ChildItem $_.FullName -Recurse -File -EA SilentlyContinue |
        Measure-Object Length -Sum).Sum/1GB,1) } } |
  Sort-Object GB -Descending | Format-Table -Auto
```

> **Do NOT** delete `_tool` blindly or clear the NuGet **global-packages**
> (`%USERPROFILE%\.nuget\packages`) while other jobs may be running — those are
> shared and clearing them can break concurrent builds. The maintenance job
> handles `_tool` safely on idle agents.

### Check free space on the drive
```powershell
Get-PSDrive -Name C | Select-Object Used,Free
```

---

## 3. What the WW Smoke pipeline already does (no action needed)

These keep our pipeline's own footprint small. They do **not** reclaim space
held by other pipelines — that's what section 1 is for.

| Setting | Effect |
|---|---|
| `workspace: clean: all` | Wipes **our** pipeline's `_work` at the start of every run. |
| `Reclaim disk space` step | Clears `%TEMP%` + NuGet http-cache before the build (best-effort, never fails the run; logs free GB before/after). |
| `checkout: fetchDepth: 1` | Shallow clone — latest commit only, no git history. |
| Video recording **off** | No ffmpeg output; trace + failure screenshots only. |
| Allure **off by default** | No report artifacts unless explicitly enabled. |
| Trace/screenshots kept **on failure only** | Passing tests leave nothing behind. |

> Note: `Reclaim disk space` deliberately does **not** delete
> `%LOCALAPPDATA%\ms-playwright` — the runtime resolves Playwright's ffmpeg from
> there, and wiping it makes every test fail with
> `ffmpeg-win64.exe doesn't exist`.

---

## 4. If agents still run low after all of the above

- Increase the agent VM's data disk, or
- Reduce how many days `_work` is kept (section 1) to `1`, or
- Split heavy pipelines onto a dedicated pool, or
- Add more agents so load (and disk churn) spreads out.
