# Register a Self-Hosted Agent to the Cloud Org (per-VM runbook)

Registers one machine as a **v3/v4** Azure Pipelines agent against the **cloud**
org `dev.azure.com/EnterpriseRepo`, running as a Windows **service** under a
domain account. Repeat on each VM. This does **not** touch the machine's
existing on-prem TFS agent — install into a separate folder so both coexist.

> **Prod vs test:** for the **prod** pool, run the service as the box's
> **`DQ\Svc-sqa-p0xx`** account (needed for prod integrated auth). For a
> **test-env** pool, any suitable service account is fine.

---

## 0. Prerequisites (once)

- **Outbound HTTPS (443)** from the VM to `dev.azure.com`, `*.dev.azure.com`,
  `*.vssps.visualstudio.com`, `*.vsblob.visualstudio.com`, `*.vstmr.visualstudio.com`.
- A **cloud PAT** with **Agent Pools → Read & manage** scope (used only during
  config; not stored). Create at `dev.azure.com/EnterpriseRepo` → User settings →
  Personal access tokens.
- The **target pool exists** in the cloud org (Org Settings → Agent pools →
  Add pool), e.g. `SQA Production Agents`.
- Log on to the VM as a **local administrator** (needed to install a service).

---

## 1. Download + unzip the v3/v4 agent

Run in an **elevated PowerShell**. (Version below is an example — use the current
release from the cloud "New agent" dialog or
https://github.com/microsoft/azure-pipelines-agent/releases.)

```powershell
$ver = "4.248.0"                                   # current agent version
$dir = "C:\Agents-Cloud"                           # SEPARATE from the on-prem agent folder
New-Item -ItemType Directory -Force -Path $dir | Out-Null
Set-Location $dir
$zip = "vsts-agent-win-x64-$ver.zip"
Invoke-WebRequest -Uri "https://download.agent.dev.azure.com/agent/$ver/$zip" -OutFile $zip
Expand-Archive -Path $zip -DestinationPath $dir -Force
Remove-Item $zip
```

---

## 2. Configure — unattended, run as a service

Fill in the two placeholders: **`<CLOUD_PAT>`** and the service account
**password**. Nothing here gets committed anywhere.

```powershell
.\config.cmd --unattended `
  --url "https://dev.azure.com/EnterpriseRepo" `
  --auth pat --token "<CLOUD_PAT>" `
  --pool "SQA Production Agents" `
  --agent "$env:COMPUTERNAME-cloud" `
  --replace `
  --work "_work" `
  --runAsService `
  --windowsLogonAccount "DQ\Svc-sqa-p001" `
  --windowsLogonPassword "<SERVICE_ACCOUNT_PASSWORD>"
```

What the flags do:

| Flag | Purpose |
|---|---|
| `--unattended` | No prompts (scriptable). |
| `--url` / `--auth pat` / `--token` | Cloud org + PAT auth (config-time only). |
| `--pool` | Target pool. Change for a test-env pool. |
| `--agent` | Agent display name (append `-cloud` so it's distinct from the on-prem one). |
| `--replace` | If an agent of that name already exists in the pool, replace it. |
| `--runAsService` | Install + start as a **Windows service** (headless, survives reboot). |
| `--windowsLogonAccount` / `--windowsLogonPassword` | Run the service as this domain account — the identity that hits the app. **For prod, this is the box's `DQ\Svc-sqa-p0xx`.** |

> Non-prod pool variant: change `--pool` and, if you don't need a specific
> identity, drop the two `--windowsLogon*` flags to run as the default
> `NT AUTHORITY\NetworkService`.

---

## 2b. Fix git TLS revocation check (locked-down VMs)

Hardened/offline VMs often can't reach the certificate **revocation** servers
(CRL/OCSP), so git-for-windows (schannel) aborts the repo clone with
`CRYPT_E_NO_REVOCATION_CHECK (0x80092012)` and the build fails at checkout.
Run once per VM, **as administrator**:

```powershell
git config --system http.schannelCheckRevoke false
```

`--system` applies to the agent service account and every pipeline on the box.
No restart needed. (The WW Smoke pipeline also disables this per-run as a
safety net, but the VM-level fix is the durable one and helps all pipelines.)

---

## 2c. Pre-provision the VM (behind the TLS-inspecting proxy)

The prod VMs egress through a **TLS-inspecting proxy** whose root CA the machine
doesn't trust, so **runtime HTTPS downloads from the internet fail** (git clone,
the .NET SDK download, any nuget.org package, Playwright browser download). The
WW Smoke pipeline avoids those downloads on PROD by using what's already on the
box, so install these **once per VM**:

1. **.NET 8 SDK** — install system-wide so `dotnet` is on PATH. Verify:
   ```powershell
   dotnet --list-sdks    # must list an 8.0.x SDK
   ```
   (The pipeline no longer downloads the SDK on PROD; it errors if this is
   missing.)
2. **Microsoft Edge** — the tests use the system Edge. Verify it exists at
   `C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe` (or Program
   Files). If present, the pipeline uses it and never downloads a browser.
3. **NuGet packages** — restore comes from the **on-prem `DQ` feed**
   (`http://CHTFS02PV.DQ.AD/nuget/`, plain HTTP, not proxied), so it should work
   as-is. To be safe, warm the cache once by cloning the repo and running
   `dotnet restore PlaywrightAutomation.sln` on the VM.

> **Best fix (removes all of this):** install the corporate proxy's **root CA**
> into the VM's *LocalMachine → Trusted Root Certification Authorities* store and
> set a machine `NODE_EXTRA_CA_CERTS` to it. Then git, .NET, NuGet, and Node
> tasks all trust the inspected chain, runtime downloads work, and the pipeline's
> PROD-specific workarounds (manual clone with `sslVerify=false`, pre-installed
> SDK) can be removed.

---

## 3. Verify

- **On the VM:** `Get-Service vstsagent.*` → Status `Running`.
- **In cloud ADO:** Org Settings → Agent pools → the pool → **Agents** tab →
  the new `<COMPUTERNAME>-cloud` agent shows **Online**.
- Its **Capabilities** should list `Agent.Version` as the v3/v4 you installed and
  `USERDOMAIN=DQ` / the service account under `USERNAME` (confirming the prod
  identity).

---

## 4. Reconfigure or remove

```powershell
Set-Location C:\Agents-Cloud
.\config.cmd remove --auth pat --token "<CLOUD_PAT>"   # deregister + uninstall the service
```
Then re-run step 2 to point at a different pool or change the service account.

---

## Notes

- One zip, installed **once per VM**, each in its own folder.
- Keep VMs **domain-joined** — required to reach `windward.dq.ad` / `*.dqtest.ad`
  and to authenticate.
- The PAT is only used during `config.cmd`; the agent then holds its own
  credential. Rotate/limit the PAT afterward.
- Related: `ci/PROD-Cloud-Agent-Onboarding.md` (why prod needs this) and
  `ci/README-Run-Tests-Playbook.md`.
