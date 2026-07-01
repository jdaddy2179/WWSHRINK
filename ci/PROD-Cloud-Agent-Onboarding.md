# WW Smoke — Enabling PROD in the Cloud Pipeline (Release Team Briefing)

**Purpose:** background + specific asks for the Release team, who hold the
access to add build agents. The goal is to run the WW Smoke Playwright suite
against **PROD** from the **cloud** Azure DevOps pipeline. Everything is ready
except one thing only your team can do: **register prod-capable agents to the
cloud org.**

- **Cloud pipeline:** `WW Smoke Tests` — `dev.azure.com/EnterpriseRepo` →
  *Application Services* (definition **697**).
- **Prepared by:** SQA automation. **Needs from Release:** agent + network access
  (Section 5).

---

## 1. TL;DR (the one ask)

Non-prod environments already run green in the cloud pipeline. **PROD does not,
and cannot, until a prod-capable agent is registered to the cloud org.** We are
**not** asking to change any app, credential, or the on-prem prod release. We are
asking to **add a second (cloud) agent instance onto the existing prod agent VMs**
so the cloud pipeline can run PROD on them — the same machines that already run
the prod smoke on-prem today.

---

## 2. Where we are

| Environment | Cloud pipeline status | Runs on |
|---|---|---|
| Non-prod (TS06, DS10, QAR, …) | ✅ Working | `AppSvcs-OnPrem-SQA` (self-hosted, already registered to the cloud org) |
| **PROD** | ❌ **Blocked** | *No prod-capable agent exists in the cloud org* |

The migration goal is **off-prem for the control plane**: the cloud org drives
the pipelines, results, and reports. The *agents* stay self-hosted and
domain-joined (explained in Section 6) — exactly the model non-prod already uses.

---

## 3. Why PROD is blocked (the technical issue)

PROD (`windward.dq.ad`) authenticates with **IIS Integrated Windows
Authentication**. There is **no username/password login form** — the browser is
challenged and answers with **the Windows identity of the account the build
agent runs as**.

- The cloud non-prod pool `AppSvcs-OnPrem-SQA` runs its agent service as
  **`svc-tfsbuild`**, which is **not a provisioned Windward PROD user**.
- So when PROD runs there, the prod app rejects the identity and every test
  fails with **`net::ERR_INVALID_AUTH_CREDENTIALS`** (HTTP 401).

This is **not** a pipeline/code bug and **not** a password problem — it is purely
*which Windows identity hits the prod app*. Passing a username/password into the
browser was tried and returns 401, because prod auth is identity-based, not
form-based.

> We briefly added a pipeline "demand" (`prodAuth=true`) to force PROD onto a
> tagged agent. With no such agent present it blocked PROD from scheduling
> (`No agent found in pool … which satisfies the specified demands`). That demand
> has been **removed** — PROD now schedules but still fails app auth, as above.
> The permanent fix is a real prod-capable agent, below.

---

## 4. The fix — reuse the existing prod agents

Good news: prod-capable agents **already exist and already work** — on-prem.

The on-prem TFS server (`tfs.dq.ad:8080`, *WindwardCollection*) has a pool
**`SQA Production Agents`** with VMs **`Production01…15`** that already run the
**`Prod_Playwright_WW_Smoke`** release successfully. Confirmed from an agent's
capabilities:

- Each runs as a **prod-provisioned domain service account**
  (`USERDOMAIN=DQ`, `USERNAME=Svc-sqa-p0xx`) — the identity prod auth needs.
- They are **domain-joined VMs** (e.g. `VM-WA-…`).
- They authenticate **headless** (`InteractiveSession=False`) — no interactive
  desktop or manual login required; integrated auth already works as a service.

**The plan:** register a **second, cloud agent instance** on each of those same
VMs, pointed at the cloud org, running as the **same** `DQ\Svc-sqa-p0xx`
account, in a **new cloud pool `SQA Production Agents`**. The existing on-prem
agent stays untouched and keeps running the on-prem release; the new instance
just also reports to the cloud org.

Because **every** agent in that pool is prod-capable, the cloud pipeline simply
targets the pool by name — no per-agent tags, no passwords in the pipeline.

---

## 5. What we need from the Release team

Two things, both requiring your access:

1. **Network egress.** Each prod VM currently only reaches on-prem `tfs.dq.ad`.
   The cloud agent connects **outbound over HTTPS (443)** to Azure DevOps.
   Please confirm/allow egress from the prod VMs to:
   - `dev.azure.com`
   - `*.dev.azure.com`
   - `*.vssps.visualstudio.com`
   - `*.vsblob.visualstudio.com`, `*.vstmr.visualstudio.com`
   (Microsoft's published Azure DevOps endpoint list; no inbound ports needed.)

2. **Create the cloud pool + register the agents.** In
   `dev.azure.com/EnterpriseRepo` → **Org Settings → Agent pools**:
   - Create pool **`SQA Production Agents`**.
   - On each prod VM (`Production01…15`), install a **current v3/v4 agent**
     (the on-prem ones are v2.x and can't be reused) into a **separate folder**
     (e.g. `C:\Agents-Cloud`, alongside the existing `C:\Agents`), configured:
     - Server URL: `https://dev.azure.com/EnterpriseRepo`
     - Pool: `SQA Production Agents`
     - Run as a **Windows service, logging on as the same `DQ\Svc-sqa-p0xx`**
       account that box already uses.
   - Keep the VMs **domain-joined** (required for prod app + auth).

> Start with **one** VM as a pilot — that's enough to prove the cloud PROD run
> end-to-end before rolling out the rest.

---

## 6. Why the agents stay self-hosted / domain-joined

"Off-prem" here means the **ADO control plane** (pipelines, runs, results,
reports) lives in the cloud. The **agents cannot be Microsoft-hosted** because
the systems under test are internal:

- `windward.dq.ad` (prod) and `*.dqtest.ad` (test) are **not reachable** from
  Microsoft-hosted cloud runners.
- Prod's **Integrated Windows Auth** requires a **domain identity**, which a
  hosted runner does not have.

So the agents remain self-hosted, domain-joined VMs that phone home to the cloud
org — the standard hybrid model, and exactly what non-prod already does. They can
fully move off-prem once the *application itself* is reachable without the
internal domain.

---

## 7. What SQA does once agents are registered

- Point PROD's pool at the new cloud `SQA Production Agents` pool (a one-line
  pipeline change, already scoped).
- Queue a PROD run and confirm it authenticates and passes.
- Re-enable the PROD-only WebServer validation leg.

**No app changes, no credential changes, no impact to the on-prem prod release.**

---

## 8. Decisions for the meeting

1. **Approve outbound egress** from the prod VMs to Azure DevOps (Section 5.1)?
2. **Who installs the cloud agents** on the VMs, and can we **pilot on one VM**
   first?
3. **Pool name** — use `SQA Production Agents` (mirrors on-prem) or a different
   convention?
4. **Timeline** for the pilot VM.

---

## 9. Reference

- Pipeline: `ci/azure-pipelines.yml` (definition 697)
- How-to-run playbook: `ci/README-Run-Tests-Playbook.md` (§7a covers PROD status)
- On-prem prod release (proof prod agents work): `Prod_Playwright_WW_Smoke`,
  pool `SQA Production Agents` on `tfs.dq.ad`.
