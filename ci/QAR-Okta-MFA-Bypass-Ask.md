# WW Smoke — QAR Okta MFA Bypass (IAM / Okta Admin Ask)

**Purpose:** background + a specific configuration request for the Okta/IAM
admin team, so the WW Smoke automated suite can run against **QAR**. This needs
Okta admin access, which the automation team does not have.

- **Pipeline:** `WW Smoke Tests` — `dev.azure.com/EnterpriseRepo` →
  *Application Services* (definition **697**).
- **Prepared by:** SQA automation. **Needs from IAM/Okta admin:** a scoped MFA
  bypass for the CI agents (Section 4).

---

## 1. TL;DR (the one ask)

QAR sits behind **Okta with Okta Verify (MFA)**. Our headless CI build agents
**cannot answer an MFA challenge** (there is no human to approve an Okta Verify
push), so QAR logins hang and the QAR smoke tests fail on navigation. We are
asking Okta admin to **let the CI agents authenticate to the QAR app without an
MFA prompt** — scoped narrowly to those agents and that app — typically via an
**Okta trusted-network zone + a sign-on policy that does not require a second
factor** for that zone. No change to any user's MFA.

---

## 2. Why QAR is different

| Environment | Login method | Automatable today? |
|---|---|---|
| TS06, DS10 | Internal **forms login** (username → Next) | ✅ Yes |
| **QAR** | **Okta** SSO + **Okta Verify (MFA)** | ❌ No — MFA blocks headless CI |

The suite's existing login helper drives the internal forms login. When QAR
redirects to Okta, there is no forms field to fill and no way to satisfy the
Okta Verify push, so the browser never completes the login and the test times
out on the initial navigation:

```
System.TimeoutException : Timeout 35000ms exceeded.
  - navigating to "https://tsslftwwweb.dqtest.ad/", waiting until "load"
```

This is an **authentication** block, not a test bug.

---

## 3. The fix — scoped MFA bypass for the CI agents

Standard pattern for automating an Okta-protected app in CI. In Okta admin:

1. **Create/identify a network zone** containing the **build agents' egress IP
   addresses** (see "Info to collect", Section 6).
2. On the **QAR application's sign-on policy**, add a rule that, **for that zone
   (and the automation service account only)**, sets the factor requirement to
   **not required** (password-only, or IWA if the app supports it). Leave the
   default rule — MFA required for everyone/everywhere else — unchanged.
3. Provide (or confirm) an **Okta-provisioned service account** the automation
   should log in as, that is authorized for the QAR app.

This keeps the bypass tightly scoped: **specific app + specific network zone +
specific service account.** Everyone else, and any login from outside the agent
IPs, still gets full MFA.

> Alternatives if a zone bypass isn't acceptable (less preferred): a service
> account whose second factor is **TOTP** (seed shared as a secret so the test
> generates the code), or an app-level API/token auth. The trusted-zone bypass
> is the cleanest and needs the least automation code.

---

## 4. What we need from IAM / Okta admin

1. **Confirm the approach** — trusted-zone MFA bypass for the QAR app, scoped to
   the CI agent IPs and the service account.
2. **Create the network zone + sign-on rule** (Section 3, steps 1–2).
3. **Provide the service account** (username) authorized for QAR, and how its
   password/secret is delivered to the pipeline (stored in the pipeline's secret
   variable group, never in code).
4. Confirm whether, after the bypass, QAR login is **username/password** or
   **Integrated Windows Auth** — that determines the small code change we make.

---

## 5. What SQA does once the bypass is in place

- Add a **QAR-aware login path** in the test code (the current forms-login helper
  does not handle Okta). Effort depends on step 4's answer:
  - *Password after bypass:* fill the Okta username/password form.
  - *IWA after bypass:* rely on the agent's Windows identity (allowlist already
    covers `*.dqtest.ad`).
- Store the service-account secret in the pipeline variable group.
- Run QAR and confirm the suite authenticates and passes.

No changes to Okta users, no MFA weakening outside the scoped rule.

---

## 6. Info to collect (fill in before/at the meeting)

| Item | Value |
|---|---|
| Build agent egress IP(s)/CIDR (the pool that runs QAR) | _e.g. AppSvcs-OnPrem-SQA agents — get from network team_ |
| Okta app name/label for QAR | _____ |
| Okta service account for automation | _____ |
| Post-bypass login type (password / IWA) | _____ |
| Secret delivery method | pipeline variable group `PlaywrightAutomation-Secrets` |

---

## 7. Notes / open questions

- Some historical QAR runs showed most tests passing — Okta may have been
  **recently enabled** on QAR, or those runs used cached sessions. Worth a quick
  confirm with the QAR/app owner, but it does not change the ask.
- The agents that run QAR are currently the on-prem-registered
  `AppSvcs-OnPrem-SQA` pool; their egress IPs are what Okta needs to allowlist.
  If QAR later runs from different agents, the zone must include those IPs too.

---

## 8. Reference

- Pipeline: `ci/azure-pipelines.yml` (definition 697)
- How-to-run playbook: `ci/README-Run-Tests-Playbook.md`
- Related infra ask (PROD agents): `ci/PROD-Cloud-Agent-Onboarding.md`
