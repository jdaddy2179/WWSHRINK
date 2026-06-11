---

## 📋 Modernization & Stabilization Backlog (2026)

This workbook tracks the **Windward platform modernization and stabilization program** — a large-scale initiative to migrate on-prem infrastructure to AWS, consolidate legacy systems, and improve performance/reliability across dental insurance digital channels.

---

### Sheets Overview

| Sheet | Purpose |
|---|---|
| **Original-DoNotUpdate** | Baseline snapshot of the backlog (12 columns, do not modify) |
| **2026 In Progress** | Active working copy with updated statuses, timelines, and team assignments (10 columns) |

### Color Legend
- 🟢 **Green** — Complete
- 🟡 **Yellow** — Committed & In-Progress
- 🟠 **Orange** — Committed, Not Yet Started
- 🟣 **Pink/Purple** — New Scope
- 🔴 **Red** — Needs Clarity/Attention
- ⬜ **No Highlight** — Deferred to later

---

### Workstreams Summary

| Workstream | Focus Area | # Items |
|---|---|---|
| **WS0** | Database optimization & infrastructure (data hygiene, indexing, partitioning, SQL 2022 upgrade) | 10 |
| **WS1** | SQL Always On / High Availability migration | 2 |
| **WS2** | Benefits domain & business services (WS2.1, WS2.2) | 4 |
| **WS3** | Provider domain DataHub migration (WS3.1, WS3.2, WS3.3) | 3 |
| **WS4** | Replatform domain services to serverless AWS (Member, Provider, Group) | 3 |
| **WS5** | DataHub API migrations (WS5.1 Panel Roster, WS5.2 Fee Schedule, WS5.3 PCD, WS5.4 Find-a-Dentist, WS5.5 Alt Auth) | 5 |
| **WS6** | Paperless API / Mobius retirement (WS6.1, WS6.2) | 2 |
| **WS7** | Claims submission domain service | 2 |
| **Interop** | User Preferences Service | 1 |
| **ND1–ND12** | Deferred/future items (BFF replatforms, Org1/Org2 shutdown, server decommissions) | 12 |

---

### Status Breakdown (2026 In Progress sheet)

| Status | Workstream Items |
|---|---|
| ✅ **Complete** | **WS0** — Data Hygiene, Member Domain on AWS, Placekey · **WS2** — Benefits Domain Svc, Member Benefits Business Svc |
| 🔄 **In Progress** | **WS0** — SQL 2022 Upgrade · **WS1** — Always On, DAGs · **WS3.1/3.2/3.3** — Provider Domain DB work · **WS4** — Member/Provider/Group Replatforms · **WS5.1** — Panel Roster · **WS6.1** — NGPP Paperless · **WS7** — Claims Submission · **ND4** — CGA Migration · **ND6** — Org2 Provider Portal to NGPP |
| 📅 **Targeted 2026** | **WS5.5** — Alt Auth (end of April) · **WS5.1** — Panel Roster (mid-April) · **WS5.2** — Fee Schedule (May) · **WS5.3** — PCD Change (July) · **WS7** — Claims (end of Q2 w/o scanning, Q3 w/ scanning) · **WS6.1** — Paperless (Q3) · **WS6.2** — Paperless to AWS (Q4) · **ND5** — Member Portal (2026) · **ND6** — NGPP Migration (Nov 2026) |
| ⏳ **2027 or Later** | **WS5.4** — Find-a-Dentist API · **ND7** — Billed Amounts Service · **ND11** — Support Mirror Shutdown · **ND1** — Product Configuration |
| ❓ **TBD** | **ND2** — Mobile App BFF · **ND3** — Website BFF · **ND8** — Org1 Shutdown · **ND9** — PHWW1SQL22P Shutdown · **ND10** — PHIVRSQL02P Shutdown · **ND12** — API App Server Consolidation |

---

### Detailed Item List by Workstream

#### WS0 — Database Optimization & Infrastructure
| # | Item | Status |
|---|---|---|
| WS0 | Fix Windward Data Hygiene | ✅ Complete |
| WS0 | Create New Member Domain Service Instance on AWS | ✅ Complete |
| WS0 | Introduction of Placekey.io Location Matching | ✅ Complete |
| WS0 | Analyze, Consolidate & Eliminate Indexes on Member Tables | In Progress (serial date 46296) |
| WS0 | Align Partitioning Strategy on Member Tables | In Progress (serial date 46327) |
| WS0 | Implement Foreign Key Updates to Partition Schema | In Progress (serial date 46296) |
| WS0 | Duplicate Entries in Provider Table Archive | In Progress (serial date 46143) |
| WS0 | Archiving Strategy: Production → Archive Tables | In Progress (serial date 46357) |
| WS0 | Upgrade SQL Server to 2022 | In Progress — remaining servers Mar 2026 |

#### WS1 — SQL Always On / High Availability
| # | Item | Status |
|---|---|---|
| WS1 | Migrate Windward Data Tier to SQL Always On Availability Groups | In-Progress — Target Q2/Q3 2026 |
| WS1 | Migrate AWS business units from SQL replication to HA read replica (DAGs) | In-Progress — Target Q2/Q3 2026 |

#### WS2 — Benefits Domain & Business Services
| # | Item | Status |
|---|---|---|
| WS2 | Build New Benefits Domain Service | ✅ Complete (Gov deployment pending) |
| WS2 | Build New Member Benefits Business Service | ✅ Complete (Gov deployment pending) |
| WS2.1 | Create "Group Benefit" Endpoint | Pending — required for NGPP/Texas provider migration |
| WS2.2 | Member Benefit Service Performance (EvolveCX) | Pending — Domain API workaround ETA April |

#### WS3 — Provider Domain DataHub Migration (New in 2026 In Progress)
| # | Item | Status |
|---|---|---|
| WS3.1 | Create New DataHub DBs for Provider Domain | In Progress — Target June |
| WS3.2 | Provider Domain Consume New DH DBs | In Progress — Target April |
| WS3.3 | Refactor Provider Domain to Use Read Replica | In Progress — Target June (depends on WS1) |

#### WS4 — Replatform Domain Services to Serverless AWS
| # | Item | Status |
|---|---|---|
| WS4 | Replatform Member Domain Service | In Progress — Q2/Q3 2026 |
| WS4 | Replatform Provider Domain Service | In Progress 2026 |
| WS4 | Replatform Group/Product Domain Service | In Progress 2026 |

#### WS5 — DataHub API Migrations
| # | Item | Status |
|---|---|---|
| WS5.1 | Migrate Panel Roster Business Service | Mid-April (DH Priority 1) |
| WS5.2 | Migrate Fee Schedule Business Service | May 2026 (DH Priority 2) |
| WS5.3 | Migrate Legacy PCD Change to New API | July 2026 (DH Priority 3) |
| WS5.4 | Create Find-a-Dentist API | 2027 — delayed by FHIR Provider Directory |
| WS5.5 | Replatform Alternate Authentication API | End of April 2026 |

#### WS6 — Paperless API / Mobius Retirement
| # | Item | Status |
|---|---|---|
| WS6.1 | Migrate NGPP to Paperless API | In-Progress — Q3 |
| WS6.2 | Replatform Paperless API to AWS | Q4 |

#### WS7 — Claims Submission
| # | Item | Status |
|---|---|---|
| WS7 | Claims Submission Operation Added to Domain API | End of Q2 (no scanning) / End of Q3 (with scanning) |
| WS7 | Replatform Claim Domain Service | End of Q3 |

#### Interoperability
| # | Item | Status |
|---|---|---|
| Interop | User Preferences Service | Net new — TBD |

#### ND — Needs to be Done (Deferred / Future)
| # | Item | Status |
|---|---|---|
| ND1 | Product Configuration Service | TBD — possibly 2027 / CMS Interop project |
| ND2 | Replatform Mobile App BFF | TBD (depends on ND9) |
| ND3 | Replatform Website BFF | TBD (depends on ND9, WS5.2, WS5.4) |
| — | Replacement IVR to AWS APIs | Part of AWS Connect 2026 |
| ND4 | Migrate CGA (Org2) Integrations to AWS | In Progress 2026 — TBD |
| ND5 | Migrate Member Portal Integrations to AWS | 2026 |
| ND6 | Migrate Clients on Org2 Provider Portal to NGPP | In Progress — Nov 2026 |
| ND7 | Migrate Billed Amounts Service | 2027 |
| ND8 | Shutdown Org1 | TBD |
| ND9 | Shutdown PHWW1SQL22P | TBD |
| ND10 | Shutdown PHIVRSQL02P (IVR) | TBD |
| ND11 | Shutdown PHWW1SQL21P (support mirror) | 2027 or later |
| ND12 | Consolidate & Shutdown API App Servers | TBD |

---

### Key Themes & Value Drivers

1. **On-Prem → AWS Migration** — Eliminate on-prem servers (DataHub, Boomi, IIS, SQL replication) in favor of serverless Lambda and EC2-based services
2. **Reduce MIMS Incidents** — Nearly every item targets reduction in database unresponsiveness events
3. **Cost Reduction** — Healthsparq contract (~$250K/yr), Org2 licensing, EC2 costs, duplicate infrastructure
4. **Architecture Simplification** — Consolidate monolithic domain services into microservices; single source of truth per domain
5. **Data Consistency** — Eliminate latency/sync issues between Windward primary and replication subscribers across IVR, portals, and mobile

---

### Critical Dependencies

| Upstream | Blocks | Detail |
|---|---|---|
| **WS1** (Always On) | **WS3.3, WS4** (all domain replatforms) | Domain services need HA read replica before full AWS migration |
| **WS6.2** (Paperless to AWS) | **WS6.1** (NGPP Paperless), **WS7** (Claims) | Claims submission and NGPP EOB depend on AWS paperless |
| **All API Migrations** | **ND9** (Shutdown PHWW1SQL22P) | Server can't be decommissioned until all APIs are off it |
| **Interop / FHIR Provider Directory** | **WS5.4** (Find-a-Dentist) | FAD API delayed to 2027 waiting on FHIR work |
| **GroupFacts Policy Migration** | **WS0, WS1** | Needs notification of environment changes to avoid overwriting GF changes |
| **WS2.1** (Group Benefit Endpoint) | **NGPP / Texas Provider Migration** | Required before Salesforce Texas provider can migrate to NGPP |
| **ND9** (PHWW1SQL22P Shutdown) | **ND2, ND3** (Mobile/Website BFF) | BFF replatforms depend on server decommission path |

---

### Key Teams & Resources

| Team / Person | Workstream Areas |
|---|---|
| **Eileen's Team** | WS3.1, WS3.2, WS3.3 (Provider Domain), WS4 (Member Domain Replatform) |
| **Codebusters / Arun** | WS7 (Claims), Interop, ND1, ND2, ND3, WS2.1 |
| **FIR / JoeG** | WS5.1, WS5.2, WS5.3, WS5.4 (DataHub migrations), ND4, ND7 |
| **Patrick & Joe** | WS1 (DAG migration) |
| **DBA / Chris Jones** | WS0 (SQL Server 2022 Upgrade) |
| **DataHub Team** | WS3.1, WS5.1, WS5.2 |
| **Arun (Paperless)** | WS6.1, WS6.2 |
| **Fred / Paul / James** | ND8, ND9, ND10, ND11, ND12 (Shutdowns & Decommissions) |
| **James's area** | IVR Replacement, ND5 (Member Portal) |
| **SilentKillers / Fredrik** | ND6 (Org2 Provider Portal to NGPP) |