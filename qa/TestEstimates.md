# Test Time Estimates & Resource Justification — Commercial Client Pilot Playbook

| Field | Value |
|-------|-------|
| Purpose | Estimate SQA testing effort per phase across all four environments (DEV, QAR, PROD, HFX) to justify resourcing |
| Unit | **SQA person-days (PD)** — 1 PD = one tester, one productive day (~6.5 focused hrs) |
| Basis | Derived from authored test suites (case counts, complexity, test types) in `test-cases/` |
| Owner | SQA Team (Joshua Ernstoff, Keerthan Tumuganti); QA Lead Arun Pant |
| Status | Draft v1.1 — 2026-06-04 (added §2.4 +50% complexity uplift for WW Shrink, Payments, WS5) |

> **Milestone (confirmed):** DEV testing to be **completed by end of August 2026**. Effort (person-days) is calendar-independent; the schedule in §6 is anchored to this date.

---

## 1. What this covers (and what it doesn't)
- **Covers:** SQA effort to validate each playbook phase — documentation review, procedure execution, data/functional/security/performance testing, defect logging + retest — **repeated across DEV → QAR → PROD → HFX** where the phase runs in those environments.
- **Now in scope (per stakeholder scope change):** functional testing of Windward and performance/load testing — both add effort, concentrated in deployment phases and Phase X.
- **Excludes:** the *doing* teams' build/deploy effort (Cloud Infra, DBA, InfoSec, App, NextGen). Their **validation-support time** is noted separately in §7 but is not counted in the SQA totals.
- **Placeholder phases** (7.1, 7.2, 7.3, 7.4, 7.5, 8, 12) are unfilled templates → estimates are **ROM (rough order of magnitude), provisional** and flagged; they firm up once content exists.

## 2. Estimation model

### 2.1 Per-environment effort multipliers
Testing each phase repeats per environment, but later environments are faster (cases are known; it becomes regression). PROD carries extra change-control/caution that partly offsets familiarity. Multipliers are applied to the **DEV base** (the full first pass, including environment shake-out and the bulk of defect cycles):

| Environment | Multiplier × DEV base | Rationale |
|-------------|:---------------------:|-----------|
| **DEV** | **1.00** | First pass: full execution + most defects + environment shakeout |
| **QAR** | **0.60** | Cases known; PHI present (COM) so careful, but largely regression |
| **PROD** | **0.70** | Regression, but production caution + change control add overhead |
| **HFX** | **0.50** | Prod-like; mostly confirmatory regression |
| **Full 4-env phase** | **2.80 × base** | Sum of the above |

Phases that run in fewer environments (PROD-only, PROD/HFX-only, or one-time setup) are modeled on their applicable environments only.

### 2.2 DEV-base sizing rubric
| Phase type | DEV base (PD) | Examples |
|-----------|:-------------:|----------|
| One-time setup / ticket QA | 0.5–1.0 | P1, P2, hand-off tickets |
| Hand-off + outcome validation | 0.5–1.0 | Kerberos, Provider Copy |
| Config/infra validation | 1.0–1.5 | LB/DNS, certs, infra naming, DB connectivity |
| Deploy + functional | 2.0–2.5 | WW1.0/Config, Payments, Domain Services |
| Data integrity / security | 2.0–3.0 | Backup/Restore, **WW Shrink**, App Security, Trusted View |
| Destructive / irreversible / PROD cutover | 1.5–3.0 | DB offline, **SLE removal**, bring-online |
| Full E2E + performance + UAT | (modeled separately) | Phase X |

### 2.3 Productivity & contingency
- **1 FTE ≈ 20 productive PD / month** (allows for ceremonies, coordination, environment waits).
- **Contingency: +20%** on base effort for defect re-test cycles, environment-availability delays, and the sequential gating between environments. Applied at the program level (§5).

### 2.4 Complexity uplift (high-difficulty areas)
A **+50% complexity uplift (×1.5 on DEV base)** is applied to the areas confirmed as harder/higher-risk. The uplifted DEV bases are reflected directly in the §3 and §9 tables.

| Area | Phases | Why uplifted |
|------|--------|--------------|
| **WW Shrink** | 4.3, 4.4 | Destructive scope-reduction; correct client scoping (Purchaser/Group IDs) and no-data-loss verification are intricate and unforgiving |
| **Payments** | 5.2, 5.3, 8 | Financial integrity + payment-app security/PHI + Oracle reconciliation; defects carry financial impact |
| **WS5 — Member-Facing** | 6.1, 7.4, 7.5 | Externally exposed surfaces; auth, member-data isolation, and cross-channel (portal/mobile) parity make these the most difficult to validate |

*(4.4 sits in both WW Shrink and Payments; it is uplifted once.)*

## 3. Per-phase estimates (by workstream)

Columns are SQA person-days per environment. "—" = phase does not run in that environment. *(P)* = provisional/ROM placeholder phase. **⬆ = +50% complexity uplift applied (§2.4).** The **Notes** column names the team actually performing the work and SQA's role: **real** = SQA performs hands-on testing; **follow-up** = SQA QAs the ticket and confirms the specialist team's own validation (no independent SQA test). *(TBD)* = team unconfirmed (placeholder/Introduction gap).

### Workstream 1 — Core Infra, DB & Base Deployment
| Phase | DEV | QAR | PROD | HFX | Total | Notes — executing team / SQA role |
|-------|----:|----:|-----:|----:|------:|------|
| 1 Gather Client & Tier (one-time) | 1.0 | — | — | — | **1.0** | Exec: Onboarding lead + stakeholders • SQA: **real** (validate data & Tier calc) |
| `ClientMemCount.sql` (one-time, PROD read) | — | — | 0.5 | — | **0.5** | Exec: DBA / AJ on PROD • SQA: **real** (verify count vs golden) |
| 2 Request AWS Accounts (one-time) | 0.5 | — | — | — | **0.5** | Exec: Onboarding lead (ServiceNow) → Cloud Infra creates • SQA: **follow-up** (ticket QA) |
| 2.1 Test AWS Accounts (per-env, flat) | 0.5 | 0.5 | 0.5 | 0.5 | **2.0** | Exec: **SQA** • SQA: **real** (validate login/naming, all envs) |
| 3 Provision Infrastructure | 1.5 | 0.9 | 1.05 | 0.75 | **4.2** | Exec: Cloud Infra • SQA: **real** (validate servers/naming) + follow-up |
| 3.1 Kerberos | 0.5 | 0.3 | 0.35 | 0.25 | **1.4** | Exec: Kerberos Team (configures + validates) • SQA: **follow-up** |
| 3.2 Load Balancers / DNS | 1.0 | 0.6 | 0.7 | 0.5 | **2.8** | Exec: Cloud Infra + App & Network (validate) • SQA: **follow-up** |
| 3.3 Certificates | 1.0 | 0.6 | 0.7 | 0.5 | **2.8** | Exec: App & Network + Infra (validate) • SQA: **follow-up** |
| 3.4 Infrastructure Security | 1.5 | 0.9 | 1.05 | 0.75 | **4.2** | Exec: InfoSec Team (deploy + validate) • SQA: **follow-up** (IT-intake / story QA) |
| 4 Setup Databases *(→ new 4.1)* | 1.5 | 0.9 | 1.05 | 0.75 | **4.2** | Exec: DBA (create/configure) • SQA: **real** (SSMS connectivity, Step 2) |
| 4.1 Bring COM DB Offline *(→ new 4.1)* | — | — | 2.0 | 1.0 | **3.0** | Exec: DBA • SQA: **follow-up** (confirm offline status) |
| 4.2 Backup & Restore *(→ new 4.1)* | 2.0 | 1.2 | 1.4 | 1.0 | **5.6** | Exec: DBA (backup/restore + integrity) • SQA: **real** (SSMS connectivity) + follow-up |
| 4.3 **WW Shrink (WW1.0/Config)** *(→ new Phase 4)* ⬆ | 4.5 | 2.7 | 3.15 | 2.25 | **12.6** | Exec: WW Shrinker Owner (Nabeel Syed) • SQA: **real** (verify shrink results / scoping / no data loss, Step 2) |
| 4.5 Replication *(→ new 4.2)* | 2.0 | 1.2 | 1.4 | 1.0 | **5.6** | Exec: DBA • SQA: **real** (read-only replica connectivity/consistency) + follow-up |
| 5 Deploy WW1.0 & Config (functional) | 2.5 | 1.5 | 1.75 | 1.25 | **7.0** | Exec: Application Services Team • SQA: **real** (Citrix functional) + follow-up |
| 5.1 App Security WW1.0/Config | 2.0 | 1.2 | 1.4 | 1.0 | **5.6** | Exec: InfoSec + Identity (deploy + validate) • SQA: **follow-up** |
| 6 Deploy Domain Services (4 services) | 2.5 | 1.5 | 1.75 | 1.25 | **7.0** | Exec: NextGen Services Team • SQA: **real** (smoke) + follow-up |
| **WS1 subtotal** | | | | | **≈ 70.0** | |

### Workstream 2 — Payments & Oracle
| Phase | DEV | QAR | PROD | HFX | Total | Notes — executing team / SQA role |
|-------|----:|----:|-----:|----:|------:|------|
| 4.4 **WW Payment Shrink** *(→ new 4.3)* ⬆ | 3.75 | 2.25 | 2.625 | 1.875 | **10.5** | Exec: WW Shrinker Owner (Nabeel Syed) • SQA: **real** (verify payment shrink / scoping / reconcile, Step 2) |
| 5.2 Deploy WW Payments (functional) ⬆ | 3.0 | 1.8 | 2.1 | 1.5 | **8.4** | Exec: Application Services Team • SQA: **real** (Citrix Payment UI) + follow-up |
| 5.3 App Security Payments ⬆ | 2.25 | 1.35 | 1.575 | 1.125 | **6.3** | Exec: InfoSec + Identity • SQA: **follow-up** |
| 8 Oracle Integration *(P)* ⬆ | 3.0 | 1.8 | 2.1 | 1.5 | **8.4** | Exec: Integration / Oracle Team *(TBD)* • SQA: **real** (data-flow reconciliation) — TBD |
| **WS2 subtotal** (25.2 firm + 8.4 ROM) | | | | | **≈ 33.6** | |

### Workstream 3 — EDI & Eligibility *(both placeholder)*
| Phase | DEV | QAR | PROD | HFX | Total | Notes — executing team / SQA role |
|-------|----:|----:|-----:|----:|------:|------|
| 7.2 EDI Setup *(P)* | 3.0 | 1.8 | 2.1 | 1.5 | **8.4** | Exec: EDI / Integration Team *(TBD)* • SQA: **real** (Payor/Trading-Partner routing, PHI in transit) — TBD |
| 7.3 Eligibility Engine *(P)* | 2.5 | 1.5 | 1.75 | 1.25 | **7.0** | Exec: Eligibility Team *(TBD)* • SQA: **real** (eligibility response accuracy) — TBD |
| **WS3 subtotal** (all ROM) | | | | | **≈ 15.4** | |

### Workstream 4 — Jobs, Correspondence & Reporting
| Phase | DEV | QAR | PROD | HFX | Total | Notes — executing team / SQA role |
|-------|----:|----:|-----:|----:|------:|------|
| 7 TWS Jobs | 2.0 | 1.2 | 1.4 | 1.0 | **5.6** | Exec: TWS Team + DBA (configure + validate) • SQA: **follow-up** + functional check (job runs) |
| 7.1 Correspondence Letters *(P)* | 1.5 | 0.9 | 1.05 | 0.75 | **4.2** | Exec: Correspondence Team *(TBD)* • SQA: **real** (letter output / PHI) — TBD |
| 9 Trusted View | 2.0 | 1.2 | 1.4 | 1.0 | **5.6** | Exec: DBA (rebuild) • SQA: **follow-up** + spot-check rebuild integrity |
| **WS4 subtotal** (11.2 firm + 4.2 ROM) | | | | | **≈ 15.4** | |

### Workstream 5 — Member-Facing *(2 of 3 placeholder; external-PHI surfaces)*
| Phase | DEV | QAR | PROD | HFX | Total | Notes — executing team / SQA role |
|-------|----:|----:|-----:|----:|------:|------|
| 6.1 Business Service (smoke) ⬆ | 1.5 | 0.9 | 1.05 | 0.75 | **4.2** | Exec: NextGen Services Team • SQA: **real** (smoke) + follow-up |
| 7.4 Member Portal *(P, security+functional)* ⬆ | 4.5 | 2.7 | 3.15 | 2.25 | **12.6** | Exec: Member Portal Team *(TBD)* • SQA: **real** (auth / member-data isolation / PHI) — TBD |
| 7.5 Mobile App *(P, security+functional)* ⬆ | 4.5 | 2.7 | 3.15 | 2.25 | **12.6** | Exec: Mobile App Team *(TBD)* • SQA: **real** (auth / isolation / PHI) — TBD |
| **WS5 subtotal** (4.2 firm + 25.2 ROM) | | | | | **≈ 29.4** | |

### TBD — Cleanup, PROD Cutover, DR & Acceptance
| Phase | DEV | QAR | PROD | HFX | Total | Notes — executing team / SQA role |
|-------|----:|----:|-----:|----:|------:|------|
| 9.1 Provider Copy Job | 1.0 | 0.6 | 0.7 | 0.5 | **2.8** | Exec: DBA • SQA: **follow-up** (verify provider sync) |
| 9.2 Remove Extra Disk/CPU (perf) | 1.5 | 0.9 | 1.05 | 0.75 | **4.2** | Exec: Infrastructure Team *(TBD)* • SQA: **follow-up** + performance validation |
| 10 **Remove SLE Data** (HFX rehearse + PROD) | — | — | 3.0 | 1.5 | **4.5** | Exec: DBA (runs removal) • SQA: **follow-up** (verify before/after counts, scope) |
| 11 Bring COM DB Online (PROD only) | — | — | 1.5 | — | **1.5** | Exec: DBA • SQA: **real** (application connectivity) + follow-up |
| 12 Disaster Recovery *(P)* | 1.0 | — | 3.0 | 2.0 | **6.0** | Exec: Infra / DBA *(TBD)* • SQA: **real** (failover/restore drill) — TBD |
| **X End-to-End Test & UAT** | 2.0 | 8.0 | 12.0 | 3.0 | **25.0** | Exec: **SQA** (lead) + business UAT • SQA: **real** (full E2E + performance + UAT) |
| **TBD subtotal** (38.0 firm + 6.0 ROM) | | | | | **≈ 44.0** | |

### SQA role summary
- **Hands-on ("real") SQA testing** — SQA independently executes/validates: Phases **1, ClientMemCount.sql, 2.1, 3, 4, 4.2, 4.3, 4.5, 5, 6** (WS1); **4.4, 5.2, 8** (WS2); **7.2, 7.3** (WS3); **7.1** (WS4); **6.1, 7.4, 7.5** (WS5); **11, 12, X** (TBD).
- **"Follow-up" only** — the specialist team executes *and* self-validates; SQA QAs the ticket and confirms completion: Phases **2, 3.1, 3.2, 3.3, 3.4, 4.1, 5.1** (WS1); **5.3** (WS2); **7, 9** (WS4); **9.1, 9.2, 10** (TBD).
- **Implication:** the SQA estimate is **not** pure coordination — the majority of phases (and effort, incl. WW Shrink, Payments, WS5, and Phase X) require independent hands-on testing, which underpins the headcount ask in §7.

## 4. Per-environment rollup (program)
| Environment | Firm phases (PD) | Incl. placeholders (PD) |
|-------------|-----------------:|------------------------:|
| **DEV** | ≈ 44 | ≈ 64 |
| **QAR** | ≈ 33 | ≈ 46 |
| **PROD** | ≈ 46 | ≈ 59 |
| **HFX** | ≈ 27 | ≈ 39 |
| **Program total (base)** | **≈ 149** | **≈ 208** |

*(Increase vs. prior baseline reflects the §2.4 +50% uplift on WW Shrink, Payments, and WS5.)*

## 5. Program totals & contingency
| Line | Firm phases | Incl. placeholders |
|------|------------:|-------------------:|
| Base SQA effort | ≈ 149 PD | ≈ 208 PD |
| + 20% contingency | ≈ 178 PD | ≈ 249 PD |

**Plan against ≈ 249 person-days** for the full pilot once placeholder phases are authored; ≈ 178 PD for the phases that exist today.

## 6. Schedule & DEV-by-August

**DEV environment pass ≈ 64 PD base → ≈ 77 PD with contingency** (raised by the §2.4 uplift — WW Shrink 4.3 and the WS5/Payments DEV work all fall in the DEV pass).

| Scenario | SQA FTE | DEV pass duration | Hits DEV-by-end-Aug-2026? | Full program duration |
|----------|:-------:|-------------------|:-------------------------:|-----------------------|
| Lean | **1 FTE** | ~3.9 months | ⚠️ At-risk (overruns Aug; no buffer; single point of failure) | ~12 months |
| **Recommended** | **2 FTE** | **~1.9 months** | ✅ Yes, but buffer now tighter (~3 wks) | ~6.2 months |
| Accelerated | **3 FTE** | ~1.3 months | ✅ Yes, comfortably | ~4.2 months* |

\*Gains taper above 2 FTE because environments are provisioned **sequentially** (DEV→QAR→PROD→HFX) and SQA cannot validate an environment until the doing teams deliver it — testing is dependency-gated, not freely parallelizable.

**Recommended path to DEV-by-August:** start now (June 2026) with **2 SQA FTE** (the named team: Joshua Ernstoff + Keerthan Tumuganti). DEV testing (~77 PD ÷ 40 PD/month) completes in **~8 weeks → ~late July / early August**, leaving **~3 weeks of buffer before end of August**. The uplift narrows the buffer — if DEV slips, pull in the 0.5 FTE performance/security specialist (§7) to hold the date.

```
2026:  Jun        Jul        Aug        Sep        Oct        Nov
DEV   ▓▓▓▓▓▓▓▓▓▓▓▓░  (done ~late Jul/early Aug; ~3 wk buffer to Aug 31 ✅)
QAR          ░▓▓▓▓▓▓▓▓░░
PROD              ░░▓▓▓▓▓▓▓▓░░   (incl. PROD-only 4.1/10/11 cutover)
HFX                    ░░▓▓▓▓▓░
Phase X (E2E+perf+UAT)        ░░▓▓▓▓▓▓▓▓▓▓░  (QAR/PROD)
```
*(Bars indicate SQA active testing; overlap reflects environments coming online in sequence.)*

## 7. Resource justification (the ask)
| Resource | Quantity | Justification |
|----------|:--------:|---------------|
| **SQA testers (core)** | **2.0 FTE** | Required to complete **DEV by end of Aug 2026** (buffer now tight) and to sustain the ≈ 249 PD full program in ~6.2 months. One tester alone overruns the DEV milestone and creates a single point of failure across PROD/irreversible phases. |
| **Performance/security specialist** | **0.5 FTE** (Phase X-weighted) | Functional + performance testing are now in scope. Phase X (25 PD) plus the security-heavy phases (3.4, 5.1, 5.3, 7.4/7.5) need load-testing and PHI/DLP validation skills beyond baseline SQA. |
| **Supporting-team validation time** *(not in SQA total)* | ~0.25 FTE-equiv across DBA/Infra/InfoSec/App | The doing teams confirm completion on hand-off tickets and pair on PROD/irreversible steps (4.1, 10, 11) and connectivity checks (4, 4.5). Budget their review time even though it's not SQA headcount. |

**Drivers behind the number:**
- **4 environments, not 1:** the program is ≈ 2.8× a single-environment pass. DEV alone is ~30% of total effort; the remaining 70% (QAR/PROD/HFX) still requires the team through the autumn.
- **Highest-effort phases** are the data/irreversible ones, now uplifted: **WW Shrink (4.3/4.4 = 23.1 PD)**, Phase X (25 PD), **Payments (5.2/5.3/8 = 23.1 PD)**, Backup/Restore + Replication (11.2 PD), SLE removal + cutover (6 PD) — these justify experienced testers, not just headcount.
- **WS5 Member-Facing** is uplifted to **≈ 29 PD** (external-PHI portal/mobile + business service) — auth and member-data isolation testing drive the increase.
- **Placeholder phases add ≈ 59 PD** once authored (notably the uplifted external-PHI Member Portal/Mobile App and PHI-routing EDI/EE) — resourcing should reserve for them rather than discover them late.

## 8. Caveats
- Estimates are **ROM** for placeholder phases (7.1–7.5, 8, 12) and will firm up when content exists.
- Assumes environments are delivered roughly on the sequential cadence the playbook describes; **environment-availability slippage is the top schedule risk** (partly covered by the 20% contingency).
- PROD/irreversible phases (4.1, 10, 11) are effort-light but **risk-heavy** — they warrant senior review time disproportionate to their PD.
- Re-baseline after the first real DEV pass: actuals from DEV should be fed back to tune the QAR/PROD/HFX multipliers.

## 9. Hours breakdown (per playbook item & workstream)

**Conversion basis:** 1 person-day (PD) = **6.5 focused hours**. Figures below are SQA test-execution hours per environment; `—` = phase does not run in that environment; *(P)* = provisional/ROM placeholder phase; **⬆ = +50% complexity uplift (§2.4).** Executing-team / SQA-role notes are in **§3** (not repeated here).

### Workstream 1 — Core Infra, DB & Base Deployment
| Phase | DEV h | QAR h | PROD h | HFX h | **Total h** |
|-------|------:|------:|-------:|------:|------------:|
| 1 Gather Client & Tier | 6.5 | — | — | — | **6.5** |
| `ClientMemCount.sql` | — | — | 3.3 | — | **3.3** |
| 2 Request AWS Accounts | 3.3 | — | — | — | **3.3** |
| 2.1 Test AWS Accounts | 3.3 | 3.3 | 3.3 | 3.3 | **13.0** |
| 3 Provision Infrastructure | 9.8 | 5.9 | 6.8 | 4.9 | **27.3** |
| 3.1 Kerberos | 3.3 | 2.0 | 2.3 | 1.6 | **9.1** |
| 3.2 Load Balancers / DNS | 6.5 | 3.9 | 4.6 | 3.3 | **18.2** |
| 3.3 Certificates | 6.5 | 3.9 | 4.6 | 3.3 | **18.2** |
| 3.4 Infrastructure Security | 9.8 | 5.9 | 6.8 | 4.9 | **27.3** |
| 4 Setup Databases *(→ new 4.1)* | 9.8 | 5.9 | 6.8 | 4.9 | **27.3** |
| 4.1 Bring COM DB Offline | — | — | 13.0 | 6.5 | **19.5** |
| 4.2 Backup & Restore *(→ new 4.1)* | 13.0 | 7.8 | 9.1 | 6.5 | **36.4** |
| 4.3 **WW Shrink (WW1.0/Config)** *(→ new Phase 4)* ⬆ | 29.3 | 17.6 | 20.5 | 14.6 | **81.9** |
| 4.5 Replication *(→ new 4.2)* | 13.0 | 7.8 | 9.1 | 6.5 | **36.4** |
| 5 Deploy WW1.0 & Config | 16.3 | 9.8 | 11.4 | 8.1 | **45.5** |
| 5.1 App Security WW1.0/Config | 13.0 | 7.8 | 9.1 | 6.5 | **36.4** |
| 6 Deploy Domain Services | 16.3 | 9.8 | 11.4 | 8.1 | **45.5** |
| **WS1 subtotal** | **159.7** | **97.0** | **123.2** | **75.1** | **≈ 455.0** |

### Workstream 2 — Payments & Oracle
| Phase | DEV h | QAR h | PROD h | HFX h | **Total h** |
|-------|------:|------:|-------:|------:|------------:|
| 4.4 **WW Payment Shrink** *(→ new 4.3)* ⬆ | 24.4 | 14.6 | 17.1 | 12.2 | **68.3** |
| 5.2 Deploy WW Payments ⬆ | 19.5 | 11.7 | 13.7 | 9.8 | **54.6** |
| 5.3 App Security Payments ⬆ | 14.6 | 8.8 | 10.2 | 7.3 | **41.0** |
| 8 Oracle Integration *(P)* ⬆ | 19.5 | 11.7 | 13.7 | 9.8 | **54.6** |
| **WS2 subtotal** | **78.0** | **46.8** | **54.7** | **39.1** | **≈ 218.4** |

### Workstream 3 — EDI & Eligibility *(both placeholder)*
| Phase | DEV h | QAR h | PROD h | HFX h | **Total h** |
|-------|------:|------:|-------:|------:|------------:|
| 7.2 EDI Setup *(P)* | 19.5 | 11.7 | 13.7 | 9.8 | **54.6** |
| 7.3 Eligibility Engine *(P)* | 16.3 | 9.8 | 11.4 | 8.1 | **45.5** |
| **WS3 subtotal** *(all ROM)* | **35.8** | **21.5** | **25.0** | **17.9** | **≈ 100.1** |

### Workstream 4 — Jobs, Correspondence & Reporting
| Phase | DEV h | QAR h | PROD h | HFX h | **Total h** |
|-------|------:|------:|-------:|------:|------------:|
| 7 TWS Jobs | 13.0 | 7.8 | 9.1 | 6.5 | **36.4** |
| 7.1 Correspondence Letters *(P)* | 9.8 | 5.9 | 6.8 | 4.9 | **27.3** |
| 9 Trusted View | 13.0 | 7.8 | 9.1 | 6.5 | **36.4** |
| **WS4 subtotal** | **35.8** | **21.5** | **25.0** | **17.9** | **≈ 100.1** |

### Workstream 5 — Member-Facing
| Phase | DEV h | QAR h | PROD h | HFX h | **Total h** |
|-------|------:|------:|-------:|------:|------------:|
| 6.1 Business Service ⬆ | 9.8 | 5.9 | 6.8 | 4.9 | **27.3** |
| 7.4 Member Portal *(P)* ⬆ | 29.3 | 17.6 | 20.5 | 14.6 | **81.9** |
| 7.5 Mobile App *(P)* ⬆ | 29.3 | 17.6 | 20.5 | 14.6 | **81.9** |
| **WS5 subtotal** | **68.4** | **41.1** | **47.8** | **34.1** | **≈ 191.1** |

### TBD — Cleanup, PROD Cutover, DR & Acceptance
| Phase | DEV h | QAR h | PROD h | HFX h | **Total h** |
|-------|------:|------:|-------:|------:|------------:|
| 9.1 Provider Copy Job | 6.5 | 3.9 | 4.6 | 3.3 | **18.2** |
| 9.2 Remove Extra Disk/CPU | 9.8 | 5.9 | 6.8 | 4.9 | **27.3** |
| 10 **Remove SLE Data** | — | — | 19.5 | 9.8 | **29.3** |
| 11 Bring COM DB Online | — | — | 9.8 | — | **9.8** |
| 12 Disaster Recovery *(P)* | 6.5 | — | 19.5 | 13.0 | **39.0** |
| **X End-to-End Test & UAT** | 13.0 | 52.0 | 78.0 | 19.5 | **162.5** |
| **TBD subtotal** | **35.8** | **61.8** | **138.2** | **50.5** | **≈ 286.1** |

### Workstream rollup (hours)
| Workstream | Firm hours | Incl. placeholders |
|-----------|-----------:|-------------------:|
| WS1 — Core Infra/DB/Deploy | 455.0 | 455.0 |
| WS2 — Payments & Oracle ⬆ | 163.8 | 218.4 |
| WS3 — EDI & Eligibility | 0 | 100.1 |
| WS4 — Jobs/Correspondence/Reporting | 72.8 | 100.1 |
| WS5 — Member-Facing ⬆ | 27.3 | 191.1 |
| TBD — Cleanup/Cutover/DR/UAT | 247.1 | 286.1 |
| **Program (base)** | **≈ 966 h** | **≈ 1,351 h** |

### Program totals (hours)
| Line | Firm phases | Incl. placeholders |
|------|------------:|-------------------:|
| Base SQA effort | ≈ 966 h | ≈ 1,351 h |
| + 20% contingency | ≈ 1,159 h | **≈ 1,621 h** |

### Per-environment totals (hours)
| Environment | Firm | Incl. placeholders |
|-------------|-----:|-------------------:|
| **DEV** | ≈ 286 h | ≈ 416 h |
| **QAR** | ≈ 215 h | ≈ 302 h |
| **PROD** | ≈ 296 h | ≈ 385 h |
| **HFX** | ≈ 172 h | ≈ 250 h |
| **Total (base)** | **≈ 966 h** | **≈ 1,351 h** |

> **FTE reference:** 1 SQA FTE ≈ 130 productive hours/month (20 PD × 6.5 h). DEV pass ≈ 416 h (with placeholders) ≈ 499 h with contingency → **2 FTE ≈ 1.9 months** to DEV-complete by end of Aug 2026.

---
*Effort derived from the authored suites under `test-cases/`; see `TraceabilityMatrix.md` for phase coverage and `TestStrategy.md` §3.4 for the workstream model.*
