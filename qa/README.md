# QA — Commercial Client Pilot Playbook

Test strategy and test cases validating the AWS onboarding / Windward tenant-creation playbook as an executable operational procedure.

## Contents
| Artifact | Purpose |
|----------|---------|
| [`TestStrategy.md`](TestStrategy.md) | Master strategy: scope, approach, environments, roles, risk, defects, gaps |
| [`TraceabilityMatrix.md`](TraceabilityMatrix.md) | Phase → test-case coverage across the full playbook |
| [`templates/TestCaseTemplate.md`](templates/TestCaseTemplate.md) | Reusable test-case format |
| [`test-cases/`](test-cases/) | Executable, detailed test cases |

## Reusable pattern
| File | Purpose |
|------|---------|
| [`test-cases/TC_PATTERN_JiraHandoffPhase.md`](test-cases/TC_PATTERN_JiraHandoffPhase.md) | Shared cases `TC-HO-01..09` for every "create Jira ticket → hand off to specialist team" phase. Hand-off phase suites reference these instead of duplicating them. |

## Authored detailed test cases
| File | Covers |
|------|--------|
| [`test-cases/TC_Phase01_GatherClientAndAWSAccountInfo.md`](test-cases/TC_Phase01_GatherClientAndAWSAccountInfo.md) | Phase 1 incl. **Tier boundary** and PHI-provenance cases |
| [`test-cases/TC_Phase02_RequestAWSAccounts.md`](test-cases/TC_Phase02_RequestAWSAccounts.md) | Phase 2 ServiceNow request, REF[] substitution |
| [`test-cases/TC_Phase02.1_TestAWSAccounts.md`](test-cases/TC_Phase02.1_TestAWSAccounts.md) | Phase 2.1 access + AWS account/naming validation |
| [`test-cases/TC_Phase03_Infrastructure.md`](test-cases/TC_Phase03_Infrastructure.md) | Phase 3 provisioning + server naming + sequential env |
| [`test-cases/TC_Phase03.1_KerberosSetup.md`](test-cases/TC_Phase03.1_KerberosSetup.md) | Phase 3.1 Kerberos (hand-off) |
| [`test-cases/TC_Phase03.2_LoadBalancers.md`](test-cases/TC_Phase03.2_LoadBalancers.md) | Phase 3.2 LB + DNS CNAME + rollback |
| [`test-cases/TC_Phase03.3_Certificates.md`](test-cases/TC_Phase03.3_Certificates.md) | Phase 3.3 SSL/TLS certs + 3.2 dependency |
| [`test-cases/TC_Phase03.4_Infrastructure_Security.md`](test-cases/TC_Phase03.4_Infrastructure_Security.md) | Phase 3.4 InfoSec **decision table** + PHI gate |
| [`test-cases/TC_Phase04.1_BringComDBOfflinePROD.md`](test-cases/TC_Phase04.1_BringComDBOfflinePROD.md) | Phase 4.1 PROD/HFX offline, change control, env gate |
| [`test-cases/TC_Phase04_SetupDBs.md`](test-cases/TC_Phase04_SetupDBs.md) | Phase 4 DB setup + SSMS connectivity (comma-port) |
| [`test-cases/TC_Phase04.2_BackupRestore.md`](test-cases/TC_Phase04.2_BackupRestore.md) | Phase 4.2 backup/restore integrity, sequential env |
| [`test-cases/TC_Phase04.3_WWShrinkWW1.0AndConfig.md`](test-cases/TC_Phase04.3_WWShrinkWW1.0AndConfig.md) | Phase 4.3 **WW Shrink** scoping/no-loss/backup safety |
| [`test-cases/TC_Phase04.4_WWShrinkPayment.md`](test-cases/TC_Phase04.4_WWShrinkPayment.md) | Phase 4.4 **WW Payment Shrink** integrity/scoping |
| [`test-cases/TC_Phase04.5_Replication.md`](test-cases/TC_Phase04.5_Replication.md) | Phase 4.5 replication consistency, AG failover, on-prem |
| [`test-cases/TC_Phase05_DeployWW1.0AndConfig.md`](test-cases/TC_Phase05_DeployWW1.0AndConfig.md) | Phase 5 deploy + functional (Citrix) + performance |
| [`test-cases/TC_Phase05.1_AppSecurity_WW1_Config.md`](test-cases/TC_Phase05.1_AppSecurity_WW1_Config.md) | Phase 5.1 Okta SSO/auth/ForcePoint DSS PHI |
| [`test-cases/TC_Phase05.2_DeployWWPayments.md`](test-cases/TC_Phase05.2_DeployWWPayments.md) | Phase 5.2 payments deploy + functional + Tier file |
| [`test-cases/TC_Phase05.3_AppSecurity_Payments.md`](test-cases/TC_Phase05.3_AppSecurity_Payments.md) | Phase 5.3 payments security (correct instance) |
| [`test-cases/TC_Phase06_DeployDomainServices.md`](test-cases/TC_Phase06_DeployDomainServices.md) | Phase 6 four NextGen domain services deploy/health |
| [`test-cases/TC_Phase06.1_DeployBusinessService.md`](test-cases/TC_Phase06.1_DeployBusinessService.md) | Phase 6.1 business service (all-env, smoke, rollback) |
| [`test-cases/TC_Phase07_TWSJobs.md`](test-cases/TC_Phase07_TWSJobs.md) | Phase 7 TWS jobs (conn-strings, SSIS, BU, job runs) |
| [`test-cases/TC_Phase09_TrustedView.md`](test-cases/TC_Phase09_TrustedView.md) | Phase 9 Trusted View rebuild integrity |
| [`test-cases/TC_Phase09.1_ProviderCopyJob.md`](test-cases/TC_Phase09.1_ProviderCopyJob.md) | Phase 9.1 provider sync completeness |
| [`test-cases/TC_Phase09.2_RemoveExtraResources.md`](test-cases/TC_Phase09.2_RemoveExtraResources.md) | Phase 9.2 irreversible resize, snapshot, performance |
| [`test-cases/TC_Phase10_RemoveSLEData.md`](test-cases/TC_Phase10_RemoveSLEData.md) | Phase 10 **irreversible SLE removal**: backup/scope/counts |
| [`test-cases/TC_Phase11_BringComDBOnlinePROD.md`](test-cases/TC_Phase11_BringComDBOnlinePROD.md) | Phase 11 PROD cutover, Phase-10 gate, app connectivity |
| [`test-cases/TC_PhaseX_EndToEndTest_UAT.md`](test-cases/TC_PhaseX_EndToEndTest_UAT.md) | Phase X E2E/UAT acceptance gate + bug-resolution exit |
| [`test-cases/TC_SQL_ClientMemCount.md`](test-cases/TC_SQL_ClientMemCount.md) | `ClientMemCount.sql` accuracy, safety, definition gaps |

## How to use
1. Read `TestStrategy.md` for approach and quality gates.
2. For a phase under test, open its `TC_*` file (or the matrix to find the ID).
3. Verify entry criteria, execute each TC's steps, record results in the **Execution Record** table.
4. A phase exits only when every `How to validate` item and `Completion Checklist` deliverable maps to a passing TC or a risk-accepted Gap Register entry (`TestStrategy.md` §11).

## Coverage status
**The full playbook has now been delivered.** Detailed suites are authored for **every content-bearing phase**: 1, 2, 2.1, 3, 3.1–3.4, 4, 4.1–4.5, 5, 5.1–5.3, 6, 6.1, 7, 9, 9.1, 9.2, 10, 11, X, plus `ClientMemCount.sql`. Hand-off phases reuse `TC-HO-01..09` from the pattern file.
- **Not QA-ready (placeholder templates):** Phases 7.1, 7.2, 7.3, 7.4, 7.5, 8, 12 were received as empty templates and are blocked until real content is supplied (Gap Register G7). Phase 12 (DR) and the 7.x/8 phases must be authored and passed before Phase X go-live.
- Workstream-by-workstream coverage status is in `TestStrategy.md` §3.4; phase-by-phase status is in `TraceabilityMatrix.md`.

## Key risks under test (highest priority first)
- **Member-count accuracy → Tier derivation** (mis-sizes all downstream infrastructure).
- **AWS account naming-convention validation**.
- **PHI/PII handling and US-based authorized access**.
- **PROD-only / irreversible steps** (Phase 4.1 offline, Phase 10 SLE removal, Phase 11 online).

## Open gaps (see `TestStrategy.md` §11)
NBI process for new clients (TBD), total-vs-active member-count definition, 5-year purge applicability in commercial, and several `Target Future State` sections still `To be determined`.
