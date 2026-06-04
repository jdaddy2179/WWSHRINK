# Traceability Matrix — Full Playbook

Maps every playbook phase to its planned/authored test coverage. `Authored` = detailed cases exist in `test-cases/`. `Pending Content` = phase markdown not yet provided; coverage is drafted against the phase's standard sections and will be authored on content delivery.

Workstream and phase list per `Introduction.md`.

| Phase | Title | WS | Priority | Risk focus | Test Case ID(s) | Status |
|-------|-------|----|----------|-----------|-----------------|--------|
| 1 | Gather Client & AWS Account Info | 1 | P1 | Input accuracy, Tier calc, PHI provenance | `TC-P1-01..11` | **Authored** |
| — | ClientMemCount.sql | — | P1 | Count accuracy → Tier; PROD/PHI safety | `TC-SQL-01..10` | **Authored** |
| 2 | Request AWS Accounts | 1 | P2 | Correct ServiceNow ticket, account spec | `TC-P2-*` | Pending Content |
| 2.1 | Test AWS Accounts | 1 | P2 | Access, region, naming convention | `TC-P2.1-01..10` | **Authored** |
| 3 | Provision Tenant Infrastructure | 1 | P2 | Tier-correct sizing, naming | `TC-P3-*` | Pending Content |
| 3.1 | Kerberos Setup | 1 | P3 | Auth config | `TC-P3.1-*` | Pending Content |
| 3.2 | Load Balancers | 1 | P3 | LB config, DNS CNAME aliases | `TC-P3.2-*` | Pending Content |
| 3.3 | Attach SSL/TLS Certificates | 1 | P2 | Cert validity, expiry, binding | `TC-P3.3-*` | Pending Content |
| 3.4 | Infrastructure-level Security | 1 | P1 | Least privilege, exposure, PHI boundary | `TC-P3.4-*` | Pending Content |
| 4 | Setup SQL Servers & DB Config | 1 | P1 | DB sizing, config, access | `TC-P4-*` | Pending Content |
| 4.1 | Bring COM DB Offline (PROD ONLY) | 1 | **P1** | Irreversible/PROD, rollback, change ctrl | `TC-P4.1-*` | Pending Content |
| 4.2 | Database Backup & Restore | 1 | P1 | Backup integrity, restore verification | `TC-P4.2-*` | Pending Content |
| 4.3 | WW Shrink (WW1.0) & Config | 1 | P1 | Data shrink correctness, no loss | `TC-P4.3-*` | Pending Content |
| 4.4 | WW Shrink (WW Payment) | 2 | P1 | Payment data integrity post-shrink | `TC-P4.4-*` | Pending Content |
| 4.5 | Database Replication | 1 | P2 | Replication consistency/lag | `TC-P4.5-*` | Pending Content |
| 5 | Deploy WW1.0 & Config | 1 | P2 | Deployment correctness | `TC-P5-*` | Pending Content |
| 5.1 | App Security: WW1.0 & Config | 1 | P1 | AuthZ, secrets, PHI access | `TC-P5.1-*` | Pending Content |
| 5.2 | Deploy WW Payments | 2 | P2 | Payment deploy | `TC-P5.2-*` | Pending Content |
| 5.3 | App Security: WW Payments | 2 | P1 | Payment authZ/secrets | `TC-P5.3-*` | Pending Content |
| 6 | Deploy Domain Services | 1 | P2 | Service health | `TC-P6-*` | Pending Content |
| 6.1 | Deploy Business Service | 5 | P2 | Service health | `TC-P6.1-*` | Pending Content |
| 7 | TWS Jobs Setup | 4 | P3 | Job scheduling/run | `TC-P7-*` | Pending Content |
| 7.1 | Correspondence Letter Setup | 4 | P3 | Letter generation | `TC-P7.1-*` | Pending Content |
| 7.2 | EDI Setup | 3 | P2 | Payor/Trading Partner ID routing | `TC-P7.2-*` | Pending Content |
| 7.3 | Eligibility Engine Setup | 3 | P2 | Eligibility responses | `TC-P7.3-*` | Pending Content |
| 7.4 | Member Portal Setup | 5 | P3 | Portal access/PHI | `TC-P7.4-*` | Pending Content |
| 7.5 | Mobile App Setup | 5 | P3 | App access/PHI | `TC-P7.5-*` | Pending Content |
| 8 | Oracle Integration | 2 | P2 | Integration data flow | `TC-P8-*` | Pending Content |
| 9 | Trusted View Setup | 4 | P3 | Reporting/view config | `TC-P9-*` | Pending Content |
| 9.1 | Provider Copy Job | TBD | P3 | Provider data copy | `TC-P9.1-*` | Pending Content |
| 9.2 | Remove Extra Disk & CPUs | TBD | P2 | Right-size, no service impact | `TC-P9.2-*` | Pending Content |
| 10 | Remove SLE Data from COM DB | TBD | **P1** | Irreversible data removal, scope | `TC-P10-*` | Pending Content |
| 11 | Bring COM DB Online (PROD ONLY) | TBD | **P1** | PROD restore, integrity, change ctrl | `TC-P11-*` | Pending Content |
| 12 | Disaster Recovery Setup | TBD | P1 | DR failover/restore drill | `TC-P12-*` | Pending Content |
| X | End-to-End Test & UAT | TBD | P1 | Full onboarding acceptance | `TC-PX-*` | Pending Content |

## Cross-cutting coverage (applies across phases)
| Concern | Where validated |
|---------|-----------------|
| Naming-convention generation/validation | TC-P2.1-07/08; every infra/DB phase |
| Tier-correct sizing propagation | TC-P1-07 → P3, P4, P9.2 |
| PHI/PII handling (DEV none; QAR/PROD/HFX protected) | TC-P1-05; P3.4, P5.1, P5.3, P7.4/7.5 |
| Access prerequisites (Introduction matrix) | Entry criteria of every phase |
| PROD-only / irreversible steps under change control | P4.1, P10, P11 |
| Documentation static review (links, glossary, screenshots) | TC-P1-11, TC-P2.1-10; every phase |
| Repeatability / second-operator | TC-P1-10, TC-SQL-08; sampled per phase |

## Completion-checklist coverage rule
A phase may not be marked COMPLETE until **every** item in its `Completion Checklist` and every `How to validate` step maps to an executed, passing test case (or a formally risk-accepted Gap Register entry).
