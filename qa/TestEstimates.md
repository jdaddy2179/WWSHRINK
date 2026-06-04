# Test Time Estimates & Resource Justification — Commercial Client Pilot Playbook

| Field | Value |
|-------|-------|
| Purpose | Estimate SQA testing effort per phase across all four environments (DEV, QAR, PROD, HFX) to justify resourcing |
| Unit | **SQA person-days (PD)** — 1 PD = one tester, one productive day (~6.5 focused hrs) |
| Basis | Derived from authored test suites (case counts, complexity, test types) in `test-cases/` |
| Owner | SQA Team (Joshua Ernstoff, Keerthan Tumuganti); QA Lead Arun Pant |
| Status | Draft v1.0 — 2026-06-04 |

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

## 3. Per-phase estimates (by workstream)

Columns are SQA person-days per environment. "—" = phase does not run in that environment. *(P)* = provisional/ROM placeholder phase.

### Workstream 1 — Core Infra, DB & Base Deployment
| Phase | DEV | QAR | PROD | HFX | Total |
|-------|----:|----:|-----:|----:|------:|
| 1 Gather Client & Tier (one-time) | 1.0 | — | — | — | **1.0** |
| `ClientMemCount.sql` (one-time, PROD read) | — | — | 0.5 | — | **0.5** |
| 2 Request AWS Accounts (one-time) | 0.5 | — | — | — | **0.5** |
| 2.1 Test AWS Accounts (per-env, flat) | 0.5 | 0.5 | 0.5 | 0.5 | **2.0** |
| 3 Provision Infrastructure | 1.5 | 0.9 | 1.05 | 0.75 | **4.2** |
| 3.1 Kerberos | 0.5 | 0.3 | 0.35 | 0.25 | **1.4** |
| 3.2 Load Balancers / DNS | 1.0 | 0.6 | 0.7 | 0.5 | **2.8** |
| 3.3 Certificates | 1.0 | 0.6 | 0.7 | 0.5 | **2.8** |
| 3.4 Infrastructure Security | 1.5 | 0.9 | 1.05 | 0.75 | **4.2** |
| 4 Setup Databases | 1.5 | 0.9 | 1.05 | 0.75 | **4.2** |
| 4.1 Bring COM DB Offline (PROD/HFX) | — | — | 2.0 | 1.0 | **3.0** |
| 4.2 Backup & Restore | 2.0 | 1.2 | 1.4 | 1.0 | **5.6** |
| 4.3 **WW Shrink (WW1.0/Config)** | 3.0 | 1.8 | 2.1 | 1.5 | **8.4** |
| 4.5 Replication | 2.0 | 1.2 | 1.4 | 1.0 | **5.6** |
| 5 Deploy WW1.0 & Config (functional) | 2.5 | 1.5 | 1.75 | 1.25 | **7.0** |
| 5.1 App Security WW1.0/Config | 2.0 | 1.2 | 1.4 | 1.0 | **5.6** |
| 6 Deploy Domain Services (4 services) | 2.5 | 1.5 | 1.75 | 1.25 | **7.0** |
| **WS1 subtotal** | | | | | **≈ 65.8** |

### Workstream 2 — Payments & Oracle
| Phase | DEV | QAR | PROD | HFX | Total |
|-------|----:|----:|-----:|----:|------:|
| 4.4 **WW Payment Shrink** | 2.5 | 1.5 | 1.75 | 1.25 | **7.0** |
| 5.2 Deploy WW Payments (functional) | 2.0 | 1.2 | 1.4 | 1.0 | **5.6** |
| 5.3 App Security Payments | 1.5 | 0.9 | 1.05 | 0.75 | **4.2** |
| 8 Oracle Integration *(P)* | 2.0 | 1.2 | 1.4 | 1.0 | **5.6** |
| **WS2 subtotal** (16.8 firm + 5.6 ROM) | | | | | **≈ 22.4** |

### Workstream 3 — EDI & Eligibility *(both placeholder)*
| Phase | DEV | QAR | PROD | HFX | Total |
|-------|----:|----:|-----:|----:|------:|
| 7.2 EDI Setup *(P)* | 3.0 | 1.8 | 2.1 | 1.5 | **8.4** |
| 7.3 Eligibility Engine *(P)* | 2.5 | 1.5 | 1.75 | 1.25 | **7.0** |
| **WS3 subtotal** (all ROM) | | | | | **≈ 15.4** |

### Workstream 4 — Jobs, Correspondence & Reporting
| Phase | DEV | QAR | PROD | HFX | Total |
|-------|----:|----:|-----:|----:|------:|
| 7 TWS Jobs | 2.0 | 1.2 | 1.4 | 1.0 | **5.6** |
| 7.1 Correspondence Letters *(P)* | 1.5 | 0.9 | 1.05 | 0.75 | **4.2** |
| 9 Trusted View | 2.0 | 1.2 | 1.4 | 1.0 | **5.6** |
| **WS4 subtotal** (11.2 firm + 4.2 ROM) | | | | | **≈ 15.4** |

### Workstream 5 — Member-Facing *(2 of 3 placeholder; external-PHI surfaces)*
| Phase | DEV | QAR | PROD | HFX | Total |
|-------|----:|----:|-----:|----:|------:|
| 6.1 Business Service (smoke) | 1.0 | 0.6 | 0.7 | 0.5 | **2.8** |
| 7.4 Member Portal *(P, security+functional)* | 3.0 | 1.8 | 2.1 | 1.5 | **8.4** |
| 7.5 Mobile App *(P, security+functional)* | 3.0 | 1.8 | 2.1 | 1.5 | **8.4** |
| **WS5 subtotal** (2.8 firm + 16.8 ROM) | | | | | **≈ 19.6** |

### TBD — Cleanup, PROD Cutover, DR & Acceptance
| Phase | DEV | QAR | PROD | HFX | Total |
|-------|----:|----:|-----:|----:|------:|
| 9.1 Provider Copy Job | 1.0 | 0.6 | 0.7 | 0.5 | **2.8** |
| 9.2 Remove Extra Disk/CPU (perf) | 1.5 | 0.9 | 1.05 | 0.75 | **4.2** |
| 10 **Remove SLE Data** (HFX rehearse + PROD) | — | — | 3.0 | 1.5 | **4.5** |
| 11 Bring COM DB Online (PROD only) | — | — | 1.5 | — | **1.5** |
| 12 Disaster Recovery *(P)* | 1.0 | — | 3.0 | 2.0 | **6.0** |
| **X End-to-End Test & UAT** | 2.0 | 8.0 | 12.0 | 3.0 | **25.0** |
| **TBD subtotal** (38.0 firm + 6.0 ROM) | | | | | **≈ 44.0** |

## 4. Per-environment rollup (program)
| Environment | Firm phases (PD) | Incl. placeholders (PD) |
|-------------|-----------------:|------------------------:|
| **DEV** | ≈ 39 | ≈ 55 |
| **QAR** | ≈ 30 | ≈ 41 |
| **PROD** | ≈ 42 | ≈ 53 |
| **HFX** | ≈ 24 | ≈ 34 |
| **Program total (base)** | **≈ 135** | **≈ 183** |

## 5. Program totals & contingency
| Line | Firm phases | Incl. placeholders |
|------|------------:|-------------------:|
| Base SQA effort | ≈ 135 PD | ≈ 183 PD |
| + 20% contingency | ≈ 162 PD | ≈ 220 PD |

**Plan against ≈ 220 person-days** for the full pilot once placeholder phases are authored; ≈ 162 PD for the phases that exist today.

## 6. Schedule & DEV-by-August

**DEV environment pass ≈ 55 PD base → ≈ 66 PD with contingency.**

| Scenario | SQA FTE | DEV pass duration | Hits DEV-by-end-Aug-2026? | Full program duration |
|----------|:-------:|-------------------|:-------------------------:|-----------------------|
| Lean | **1 FTE** | ~3.3 months | ⚠️ Tight / at-risk (no buffer, single point of failure) | ~9–11 months |
| **Recommended** | **2 FTE** | **~1.6 months** | ✅ Yes — with buffer, can start QAR early | ~5.5 months |
| Accelerated | **3 FTE** | ~1.1 months | ✅ Yes, comfortably | ~3.7 months* |

\*Gains taper above 2 FTE because environments are provisioned **sequentially** (DEV→QAR→PROD→HFX) and SQA cannot validate an environment until the doing teams deliver it — testing is dependency-gated, not freely parallelizable.

**Recommended path to DEV-by-August:** start now (June 2026) with **2 SQA FTE** (the named team: Joshua Ernstoff + Keerthan Tumuganti). DEV testing (~66 PD ÷ 40 PD/month) completes in **~6–7 weeks → ~mid/late July**, leaving **3–5 weeks of buffer before end of August** to absorb defect cycles and environment delays, and to begin the QAR pass.

```
2026:  Jun        Jul        Aug        Sep        Oct        Nov
DEV   ▓▓▓▓▓▓▓▓▓▓░░  (done ~mid/late Jul; buffer to Aug 31 ✅)
QAR        ░▓▓▓▓▓▓▓▓░░
PROD            ░░▓▓▓▓▓▓▓▓░░   (incl. PROD-only 4.1/10/11 cutover)
HFX                  ░░▓▓▓▓▓░
Phase X (E2E+perf+UAT)        ░░▓▓▓▓▓▓▓▓▓▓░  (QAR/PROD)
```
*(Bars indicate SQA active testing; overlap reflects environments coming online in sequence.)*

## 7. Resource justification (the ask)
| Resource | Quantity | Justification |
|----------|:--------:|---------------|
| **SQA testers (core)** | **2.0 FTE** | Required to complete **DEV by end of Aug 2026 with buffer** and to sustain the ≈ 220 PD full program in ~5.5 months. One tester alone puts the DEV milestone at risk and creates a single point of failure across PROD/irreversible phases. |
| **Performance/security specialist** | **0.5 FTE** (Phase X-weighted) | Functional + performance testing are now in scope. Phase X (25 PD) plus the security-heavy phases (3.4, 5.1, 5.3, 7.4/7.5) need load-testing and PHI/DLP validation skills beyond baseline SQA. |
| **Supporting-team validation time** *(not in SQA total)* | ~0.25 FTE-equiv across DBA/Infra/InfoSec/App | The doing teams confirm completion on hand-off tickets and pair on PROD/irreversible steps (4.1, 10, 11) and connectivity checks (4, 4.5). Budget their review time even though it's not SQA headcount. |

**Drivers behind the number:**
- **4 environments, not 1:** the program is ≈ 2.8× a single-environment pass. DEV alone is ~30% of total effort; the remaining 70% (QAR/PROD/HFX) still requires the team through the autumn.
- **Highest-effort phases** are the data/irreversible ones: WW Shrink (4.3/4.4 = 15.4 PD), Phase X (25 PD), Backup/Restore + Replication (11.2 PD), SLE removal + cutover (6 PD) — these justify experienced testers, not just headcount.
- **Placeholder phases add ≈ 48 PD** once authored (notably the external-PHI Member Portal/Mobile App and PHI-routing EDI/EE) — resourcing should reserve for them rather than discover them late.

## 8. Caveats
- Estimates are **ROM** for placeholder phases (7.1–7.5, 8, 12) and will firm up when content exists.
- Assumes environments are delivered roughly on the sequential cadence the playbook describes; **environment-availability slippage is the top schedule risk** (partly covered by the 20% contingency).
- PROD/irreversible phases (4.1, 10, 11) are effort-light but **risk-heavy** — they warrant senior review time disproportionate to their PD.
- Re-baseline after the first real DEV pass: actuals from DEV should be fed back to tune the QAR/PROD/HFX multipliers.

## 9. Hours breakdown (per playbook item & workstream)

**Conversion basis:** 1 person-day (PD) = **6.5 focused hours**. Figures below are SQA test-execution hours per environment; `—` = phase does not run in that environment; *(P)* = provisional/ROM placeholder phase.

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
| 4 Setup Databases | 9.8 | 5.9 | 6.8 | 4.9 | **27.3** |
| 4.1 Bring COM DB Offline | — | — | 13.0 | 6.5 | **19.5** |
| 4.2 Backup & Restore | 13.0 | 7.8 | 9.1 | 6.5 | **36.4** |
| 4.3 **WW Shrink (WW1.0/Config)** | 19.5 | 11.7 | 13.7 | 9.8 | **54.6** |
| 4.5 Replication | 13.0 | 7.8 | 9.1 | 6.5 | **36.4** |
| 5 Deploy WW1.0 & Config | 16.3 | 9.8 | 11.4 | 8.1 | **45.5** |
| 5.1 App Security WW1.0/Config | 13.0 | 7.8 | 9.1 | 6.5 | **36.4** |
| 6 Deploy Domain Services | 16.3 | 9.8 | 11.4 | 8.1 | **45.5** |
| **WS1 subtotal** | **149.9** | **91.1** | **116.4** | **70.3** | **≈ 427.7** |

### Workstream 2 — Payments & Oracle
| Phase | DEV h | QAR h | PROD h | HFX h | **Total h** |
|-------|------:|------:|-------:|------:|------------:|
| 4.4 **WW Payment Shrink** | 16.3 | 9.8 | 11.4 | 8.1 | **45.5** |
| 5.2 Deploy WW Payments | 13.0 | 7.8 | 9.1 | 6.5 | **36.4** |
| 5.3 App Security Payments | 9.8 | 5.9 | 6.8 | 4.9 | **27.3** |
| 8 Oracle Integration *(P)* | 13.0 | 7.8 | 9.1 | 6.5 | **36.4** |
| **WS2 subtotal** | **52.1** | **31.3** | **36.4** | **26.0** | **≈ 145.6** |

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
| 6.1 Business Service | 6.5 | 3.9 | 4.6 | 3.3 | **18.2** |
| 7.4 Member Portal *(P)* | 19.5 | 11.7 | 13.7 | 9.8 | **54.6** |
| 7.5 Mobile App *(P)* | 19.5 | 11.7 | 13.7 | 9.8 | **54.6** |
| **WS5 subtotal** | **45.5** | **27.3** | **32.0** | **22.9** | **≈ 127.4** |

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
| WS1 — Core Infra/DB/Deploy | 427.7 | 427.7 |
| WS2 — Payments & Oracle | 109.2 | 145.6 |
| WS3 — EDI & Eligibility | 0 | 100.1 |
| WS4 — Jobs/Correspondence/Reporting | 72.8 | 100.1 |
| WS5 — Member-Facing | 18.2 | 127.4 |
| TBD — Cleanup/Cutover/DR/UAT | 247.1 | 286.1 |
| **Program (base)** | **≈ 875 h** | **≈ 1,187 h** |

### Program totals (hours)
| Line | Firm phases | Incl. placeholders |
|------|------------:|-------------------:|
| Base SQA effort | ≈ 875 h | ≈ 1,187 h |
| + 20% contingency | ≈ 1,050 h | **≈ 1,425 h** |

### Per-environment totals (hours)
| Environment | Firm | Incl. placeholders |
|-------------|-----:|-------------------:|
| **DEV** | ≈ 254 h | ≈ 358 h |
| **QAR** | ≈ 195 h | ≈ 267 h |
| **PROD** | ≈ 273 h | ≈ 345 h |
| **HFX** | ≈ 156 h | ≈ 221 h |
| **Total (base)** | **≈ 875 h** | **≈ 1,187 h** |

> **FTE reference:** 1 SQA FTE ≈ 130 productive hours/month (20 PD × 6.5 h). DEV pass ≈ 358 h (with placeholders) ≈ 430 h with contingency → **2 FTE ≈ 1.6 months** to DEV-complete by end of Aug 2026.

---
*Effort derived from the authored suites under `test-cases/`; see `TraceabilityMatrix.md` for phase coverage and `TestStrategy.md` §3.4 for the workstream model.*
