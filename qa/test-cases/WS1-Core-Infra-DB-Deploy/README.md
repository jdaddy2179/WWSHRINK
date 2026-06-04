# Workstream 1 — Core Infrastructure, Database & Base Deployment

The backbone: gather inputs → stand up AWS accounts/infra/security → build & seed the database (incl. WW Shrink) → deploy core Windward 1.0 + config + domain services. **Highest-risk workstream** — contains every P1 driver. No downstream workstream (WS2–WS5) exits until its WS1 dependencies pass.

| Suite | Phase | Notes |
|-------|-------|-------|
| `TC_Phase01_GatherClientAndAWSAccountInfo.md` | 1 | Tier boundary, PHI provenance |
| `TC_Phase02_RequestAWSAccounts.md` | 2 | ServiceNow request, REF[] substitution |
| `TC_Phase02.1_TestAWSAccounts.md` | 2.1 | AWS access + account/naming validation |
| `TC_Phase03_Infrastructure.md` | 3 | Provisioning + server naming, sequential env |
| `TC_Phase03.1_KerberosSetup.md` | 3.1 | Kerberos (hand-off) |
| `TC_Phase03.2_LoadBalancers.md` | 3.2 | LB + DNS CNAME + rollback |
| `TC_Phase03.3_Certificates.md` | 3.3 | SSL/TLS + 3.2 dependency |
| `TC_Phase03.4_Infrastructure_Security.md` | 3.4 | InfoSec decision table + PHI gate |
| `TC_Phase04_SetupDBs.md` | 4 | DB setup + SSMS connectivity |
| `TC_Phase04.1_BringComDBOfflinePROD.md` | 4.1 | PROD/HFX offline, change control |
| `TC_Phase04.2_BackupRestore.md` | 4.2 | Backup/restore integrity |
| `TC_Phase04.3_WWShrinkWW1.0AndConfig.md` | 4.3 | WW Shrink scoping/no-loss |
| `TC_Phase04.5_Replication.md` | 4.5 | Replication consistency, AG failover |
| `TC_Phase05_DeployWW1.0AndConfig.md` | 5 | Deploy + functional + performance |
| `TC_Phase05.1_AppSecurity_WW1_Config.md` | 5.1 | Okta SSO/auth/ForcePoint DSS PHI |
| `TC_Phase06_DeployDomainServices.md` | 6 | Four NextGen domain services |
| `TC_SQL_ClientMemCount.md` | (Phase 1) | Member-count query accuracy/safety |

Hand-off suites reference `../_shared/TC_PATTERN_JiraHandoffPhase.md`. Full index: [QA README](../../README.md).
