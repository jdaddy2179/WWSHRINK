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
