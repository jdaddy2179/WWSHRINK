# Jira ↔ Playbook Traceability Matrix

Maps each playbook **phase × environment** to its Jira "Execute Phase" story in the **CCP** backlog, the story status, the **SQA Sign-off** sub-task (where created), and the QA test-case suite.

| Field | Value |
|-------|-------|
| Source | CCP project ([backlog](https://dentaquest.atlassian.net/jira/software/c/projects/CCP/boards/3794/backlog)) — "Execute Phase" stories |
| Generated | 2026-06-11 |
| Jira link form | `https://dentaquest.atlassian.net/browse/<KEY>` |
| Note | Story statuses are a point-in-time snapshot and will drift — re-pull to refresh |

**Legend:** Env = DEV / QAR / PROD / HFX (Hotfix). **SQA Sign-off** = the "SQA Signed off" sub-task under that story (— = not yet created). Sub-tasks marked 🔗 carry the comment linking to the test-case file.

---

## Workstream 1 — Core Infra, DB & Base Deployment

### Phase 01 — Gather Client & AWS Account Info
| Env | Execute Story | Status | SQA Sign-off | Test Cases |
|-----|---------------|--------|--------------|-----------|
| DEV | [CCP-1511](https://dentaquest.atlassian.net/browse/CCP-1511) | Closed | — | [TC_Phase01](test-cases/WS1-Core-Infra-DB-Deploy/TC_Phase01_GatherClientAndAWSAccountInfo.md) |
| QAR | [CCP-1512](https://dentaquest.atlassian.net/browse/CCP-1512) | Closed | — | ″ |
| PROD | [CCP-1514](https://dentaquest.atlassian.net/browse/CCP-1514) | Closed | — | ″ |
| HFX | [CCP-1513](https://dentaquest.atlassian.net/browse/CCP-1513) | Closed | — | ″ |

### Phase 02 — Request AWS Accounts
| Env | Execute Story | Status | SQA Sign-off | Test Cases |
|-----|---------------|--------|--------------|-----------|
| DEV | [CCP-1516](https://dentaquest.atlassian.net/browse/CCP-1516) | In Progress | [CCP-1728](https://dentaquest.atlassian.net/browse/CCP-1728) 🔗 | [TC_Phase02](test-cases/WS1-Core-Infra-DB-Deploy/TC_Phase02_RequestAWSAccounts.md) |
| QAR | [CCP-1517](https://dentaquest.atlassian.net/browse/CCP-1517) | To Do | [CCP-1732](https://dentaquest.atlassian.net/browse/CCP-1732) 🔗 | ″ |
| PROD | [CCP-1519](https://dentaquest.atlassian.net/browse/CCP-1519) | To Do | [CCP-1740](https://dentaquest.atlassian.net/browse/CCP-1740) 🔗 | ″ |
| HFX | [CCP-1518](https://dentaquest.atlassian.net/browse/CCP-1518) | Blocked Work | [CCP-1736](https://dentaquest.atlassian.net/browse/CCP-1736) 🔗 | ″ |

### Phase 02.1 — Test AWS Accounts
| Env | Execute Story | Status | SQA Sign-off | Test Cases |
|-----|---------------|--------|--------------|-----------|
| DEV | [CCP-1521](https://dentaquest.atlassian.net/browse/CCP-1521) | To Do | [CCP-1744](https://dentaquest.atlassian.net/browse/CCP-1744) 🔗 | [TC_Phase02.1](test-cases/WS1-Core-Infra-DB-Deploy/TC_Phase02.1_TestAWSAccounts.md) |
| QAR | [CCP-1522](https://dentaquest.atlassian.net/browse/CCP-1522) | To Do | [CCP-1748](https://dentaquest.atlassian.net/browse/CCP-1748) 🔗 | ″ |
| PROD | [CCP-1524](https://dentaquest.atlassian.net/browse/CCP-1524) | To Do | [CCP-1756](https://dentaquest.atlassian.net/browse/CCP-1756) 🔗 | ″ |
| HFX | [CCP-1523](https://dentaquest.atlassian.net/browse/CCP-1523) | Blocked Work | [CCP-1752](https://dentaquest.atlassian.net/browse/CCP-1752) 🔗 | ″ |

### Phase 03 — Provision Tenant Infrastructure
| Env | Execute Story | Status | SQA Sign-off | Test Cases |
|-----|---------------|--------|--------------|-----------|
| DEV | [CCP-1526](https://dentaquest.atlassian.net/browse/CCP-1526) | To Do | [CCP-1760](https://dentaquest.atlassian.net/browse/CCP-1760) 🔗 | [TC_Phase03](test-cases/WS1-Core-Infra-DB-Deploy/TC_Phase03_Infrastructure.md) |
| QAR | [CCP-1527](https://dentaquest.atlassian.net/browse/CCP-1527) | To Do | [CCP-1764](https://dentaquest.atlassian.net/browse/CCP-1764) 🔗 | ″ |
| PROD | [CCP-1529](https://dentaquest.atlassian.net/browse/CCP-1529) | To Do | [CCP-1772](https://dentaquest.atlassian.net/browse/CCP-1772) 🔗 | ″ |
| HFX | [CCP-1528](https://dentaquest.atlassian.net/browse/CCP-1528) | Blocked Work | [CCP-1768](https://dentaquest.atlassian.net/browse/CCP-1768) 🔗 | ″ |

### Phase 03.1 — Kerberos
| Env | Execute Story | Status | SQA Sign-off | Test Cases |
|-----|---------------|--------|--------------|-----------|
| DEV | [CCP-1695](https://dentaquest.atlassian.net/browse/CCP-1695) | To Do | [CCP-1788](https://dentaquest.atlassian.net/browse/CCP-1788) 🔗 | [TC_Phase03.1](test-cases/WS1-Core-Infra-DB-Deploy/TC_Phase03.1_KerberosSetup.md) |
| QAR | [CCP-1697](https://dentaquest.atlassian.net/browse/CCP-1697) | To Do | [CCP-1796](https://dentaquest.atlassian.net/browse/CCP-1796) 🔗 | ″ |
| PROD | [CCP-1696](https://dentaquest.atlassian.net/browse/CCP-1696) | To Do | [CCP-1792](https://dentaquest.atlassian.net/browse/CCP-1792) 🔗 | ″ |
| HFX | [CCP-1698](https://dentaquest.atlassian.net/browse/CCP-1698) | To Do | [CCP-1800](https://dentaquest.atlassian.net/browse/CCP-1800) 🔗 | ″ |

### Phase 03.2 — Load Balancers Setup
| Env | Execute Story | Status | SQA Sign-off | Test Cases |
|-----|---------------|--------|--------------|-----------|
| DEV | [CCP-1536](https://dentaquest.atlassian.net/browse/CCP-1536) | To Do | [CCP-1780](https://dentaquest.atlassian.net/browse/CCP-1780) 🔗 | [TC_Phase03.2](test-cases/WS1-Core-Infra-DB-Deploy/TC_Phase03.2_LoadBalancers.md) |
| QAR | [CCP-1537](https://dentaquest.atlassian.net/browse/CCP-1537) | To Do | — | ″ |
| PROD | [CCP-1539](https://dentaquest.atlassian.net/browse/CCP-1539) | To Do | — | ″ |
| HFX | [CCP-1538](https://dentaquest.atlassian.net/browse/CCP-1538) | To Do | — | ″ |

### Phase 03.3 — Certificates
| Env | Execute Story | Status | SQA Sign-off | Test Cases |
|-----|---------------|--------|--------------|-----------|
| DEV | [CCP-1541](https://dentaquest.atlassian.net/browse/CCP-1541) | To Do | [CCP-1784](https://dentaquest.atlassian.net/browse/CCP-1784) 🔗 | [TC_Phase03.3](test-cases/WS1-Core-Infra-DB-Deploy/TC_Phase03.3_Certificates.md) |
| QAR | [CCP-1542](https://dentaquest.atlassian.net/browse/CCP-1542) | To Do | — | ″ |
| PROD | [CCP-1544](https://dentaquest.atlassian.net/browse/CCP-1544) | To Do | — | ″ |
| HFX | [CCP-1543](https://dentaquest.atlassian.net/browse/CCP-1543) | To Do | — | ″ |

### Phase 03.4 — Infrastructure-level Security
*Split into non-ForcePoint and ForcePoint DSS (KCL) stories.*
| Env | Execute Story | Status | SQA Sign-off | Test Cases |
|-----|---------------|--------|--------------|-----------|
| DEV (excl. ForcePoint) | [CCP-1531](https://dentaquest.atlassian.net/browse/CCP-1531) | To Do | [CCP-1776](https://dentaquest.atlassian.net/browse/CCP-1776) 🔗 | [TC_Phase03.4](test-cases/WS1-Core-Infra-DB-Deploy/TC_Phase03.4_Infrastructure_Security.md) |
| QAR (excl. ForcePoint) | [CCP-1532](https://dentaquest.atlassian.net/browse/CCP-1532) | To Do | — | ″ |
| QAR (excl. ForcePoint) | [CCP-1826](https://dentaquest.atlassian.net/browse/CCP-1826) | Closed | — | ″ |
| HFX (ForcePoint DSS KCL) | [CCP-1533](https://dentaquest.atlassian.net/browse/CCP-1533) | To Do | — | ″ |
| PROD (ForcePoint DSS KCL) | [CCP-1534](https://dentaquest.atlassian.net/browse/CCP-1534) | To Do | — | ″ |

> **⚠️ Phase 4 restructured (2026‑06).** The playbook reorganized Phase 4 (6 files → 4): **WW Shrink** is now the main **Phase 4** (was 4.3); **DB Setup & Migration** is **4.1** (consolidates old Setup‑DBs + Bring‑COM‑Offline + Backup/Restore); **Replication** is **4.2** (was 4.5); **WW Payment Shrink** is **4.3** (was 4.4). Test‑case links below now point to the new/consolidated suites. The Jira "Execute Phase" story numbering below still reflects the **old** layout and needs re-aligning (tracked as **D‑P4‑STRUCT** in `DocumentationFixes.md`). The sections below are retained as-is pending that Jira re-numbering.

### Phase 04.1 — Bring COM DB Offline (PROD/HFX)
| Env | Execute Story | Status | SQA Sign-off | Test Cases |
|-----|---------------|--------|--------------|-----------|
| PROD *(marked "HOTFIX??")* | [CCP-1556](https://dentaquest.atlassian.net/browse/CCP-1556) | To Do | — | [TC_Phase04.1](test-cases/WS1-Core-Infra-DB-Deploy/TC_Phase04.1_DatabaseSetup_Migration.md) |

### Phase 04.2 — Database Backup and Restore
| Env | Execute Story | Status | SQA Sign-off | Test Cases |
|-----|---------------|--------|--------------|-----------|
| DEV | [CCP-1558](https://dentaquest.atlassian.net/browse/CCP-1558) | To Do | — | [TC_Phase04.2](test-cases/WS1-Core-Infra-DB-Deploy/TC_Phase04.1_DatabaseSetup_Migration.md) |
| QAR | [CCP-1559](https://dentaquest.atlassian.net/browse/CCP-1559) | To Do | — | ″ |
| PROD | [CCP-1561](https://dentaquest.atlassian.net/browse/CCP-1561) | To Do | — | ″ |
| HFX | [CCP-1560](https://dentaquest.atlassian.net/browse/CCP-1560) | To Do | — | ″ |

### Phase 04.3 — WW Shrink for WW1.0 & Config
| Env | Execute Story | Status | SQA Sign-off | Test Cases |
|-----|---------------|--------|--------------|-----------|
| DEV | [CCP-1563](https://dentaquest.atlassian.net/browse/CCP-1563) | To Do | — | [TC_Phase04.3](test-cases/WS1-Core-Infra-DB-Deploy/TC_Phase04_WWShrinkWW1AndConfig.md) |
| QAR | [CCP-1564](https://dentaquest.atlassian.net/browse/CCP-1564) | To Do | — | ″ |
| PROD | [CCP-1566](https://dentaquest.atlassian.net/browse/CCP-1566) | To Do | — | ″ |
| HFX | [CCP-1565](https://dentaquest.atlassian.net/browse/CCP-1565) | To Do | — | ″ |

### Phase 04.5 — Database Replication Setup
| Env | Execute Story | Status | SQA Sign-off | Test Cases |
|-----|---------------|--------|--------------|-----------|
| DEV | [CCP-1568](https://dentaquest.atlassian.net/browse/CCP-1568) | To Do | — | [TC_Phase04.5](test-cases/WS1-Core-Infra-DB-Deploy/TC_Phase04.2_Replication.md) |
| QAR | [CCP-1569](https://dentaquest.atlassian.net/browse/CCP-1569) | To Do | — | ″ |
| PROD | [CCP-1571](https://dentaquest.atlassian.net/browse/CCP-1571) | To Do | — | ″ |
| HFX | [CCP-1570](https://dentaquest.atlassian.net/browse/CCP-1570) | To Do | — | ″ |

### Phase 05 — Deploy WW1.0 & Config
| Env | Execute Story | Status | SQA Sign-off | Test Cases |
|-----|---------------|--------|--------------|-----------|
| DEV | [CCP-1573](https://dentaquest.atlassian.net/browse/CCP-1573) | To Do | — | [TC_Phase05](test-cases/WS1-Core-Infra-DB-Deploy/TC_Phase05_DeployWW1.0AndConfig.md) |
| QAR | [CCP-1574](https://dentaquest.atlassian.net/browse/CCP-1574) | To Do | — | ″ |
| PROD | [CCP-1576](https://dentaquest.atlassian.net/browse/CCP-1576) | To Do | — | ″ |
| HFX | [CCP-1575](https://dentaquest.atlassian.net/browse/CCP-1575) | To Do | — | ″ |

### Phase 05.1 — Application-level Security: WW1.0 & Config
| Env | Execute Story | Status | SQA Sign-off | Test Cases |
|-----|---------------|--------|--------------|-----------|
| DEV | [CCP-1713](https://dentaquest.atlassian.net/browse/CCP-1713) | To Do | — | [TC_Phase05.1](test-cases/WS1-Core-Infra-DB-Deploy/TC_Phase05.1_AppSecurity_WW1_Config.md) |
| QAR | [CCP-1714](https://dentaquest.atlassian.net/browse/CCP-1714) | To Do | — | ″ |
| PROD | [CCP-1716](https://dentaquest.atlassian.net/browse/CCP-1716) | To Do | — | ″ |
| HFX | [CCP-1715](https://dentaquest.atlassian.net/browse/CCP-1715) | To Do | — | ″ |

### Phase 06 — Deploy Domain Services
| Env | Execute Story | Status | SQA Sign-off | Test Cases |
|-----|---------------|--------|--------------|-----------|
| DEV | [CCP-1578](https://dentaquest.atlassian.net/browse/CCP-1578) | To Do | — | [TC_Phase06](test-cases/WS1-Core-Infra-DB-Deploy/TC_Phase06_DeployDomainServices.md) |
| QAR | [CCP-1579](https://dentaquest.atlassian.net/browse/CCP-1579) | To Do | — | ″ |
| PROD | [CCP-1581](https://dentaquest.atlassian.net/browse/CCP-1581) | To Do | — | ″ |
| HFX | [CCP-1580](https://dentaquest.atlassian.net/browse/CCP-1580) | To Do | — | ″ |

## Workstream 2 — Payments & Oracle

### Phase 05.2 — Deploy WW Payments
| Env | Execute Story | Status | SQA Sign-off | Test Cases |
|-----|---------------|--------|--------------|-----------|
| (all / placeholder) | [CCP-1803](https://dentaquest.atlassian.net/browse/CCP-1803) | To Do | — | [TC_Phase05.2](test-cases/WS2-Payments-Oracle/TC_Phase05.2_DeployWWPayments.md) |

### Phase 05.3 — Application-level Security: WW Payments
| Env | Execute Story | Status | SQA Sign-off | Test Cases |
|-----|---------------|--------|--------------|-----------|
| (all / placeholder, Owner: Jamie) | [CCP-1805](https://dentaquest.atlassian.net/browse/CCP-1805) | To Do | — | [TC_Phase05.3](test-cases/WS2-Payments-Oracle/TC_Phase05.3_AppSecurity_Payments.md) |

---

## Coverage notes
- **60 "Execute Phase" stories** exist in CCP today, spanning Phases **01 → 06** (WS1) plus placeholders for **05.2 / 05.3** (WS2). Most are per-environment (DEV/QAR/PROD/HFX).
- **SQA Sign-off sub-tasks** currently exist for Phases **02, 02.1, 03, 03.1** (all envs) and **03.2 / 03.3 / 03.4** (DEV only) — 19 in total, each carrying the 🔗 comment linking to its test-case file.
- **Not yet ticketed in Jira** (no Execute story found): Phase **04 (Setup DBs)**, **04.4 (WW Payment Shrink)**, and everything from **07 onward** (07.x, 08, 09.x, 10, 11, 12, X). Test-case suites exist for several of these in `qa/test-cases/` and can be linked once stories are created.
- **Anomalies to confirm with the team:** Phase 03.4 has two QAR stories (CCP-1532 open, CCP-1826 closed); Phase 04.1 PROD story (CCP-1556) is tagged "HOTFIX??".

*See `TraceabilityMatrix.md` for phase→test-case coverage and `TestStrategy.md` §8 for the bug/SQA sign-off process.*
