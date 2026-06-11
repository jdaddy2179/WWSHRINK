# High-Level Test Strategy
## Commercial Client Pilot — AWS Onboarding

<br>

## 1. Purpose

This document defines the high-level test strategy for validating each phase of the Commercial Client Pilot onboarding playbook. It provides a structured testing approach that aligns to the playbook phases (Phases 1–9, Phase X), defines what must be tested, who is responsible, and what criteria determine pass or fail for each phase gate.

The playbook phases are operational and delivery steps; this strategy defines how quality is assured at each gate before the next phase begins.

**Pilot tenant:** KCL (Kentucky Children's League / Commercial pilot). All test execution for this iteration is scoped to the KCL tenant across four environments.

<br>

## 2. Scope

This test strategy covers all validation activities required to confirm that a new commercial dental client (Tenant) has been correctly and completely onboarded to AWS, from initial data collection through to full service deployment.

### In Scope
- Environment variable data completeness and accuracy (Phase 1)
- AWS account creation and access validation (Phases 2, 2.1)
- Infrastructure provisioning: servers, naming conventions, network (Phase 3)
- Information security setup and validation (Phase 3.1)
- Load balancers and DNS alias configuration (Phase 3.2)
- SSL/TLS certificate setup (Phase 3.3)
- **Connectivity to provisioned AWS servers (Phase 3.4) — new**
- SQL Server setup and database configuration (Phase 4)
- **Bring COM database offline in production (Phase 4.1) — new, PROD-only**
- **Database backup and restore (Phase 4.2) — new**
- **Windward database shrink (Phase 4.3) — new**
- **Database replication setup (Phase 4.4) — new**
- Application deployment: Windward 1.0 and configuration (Phase 5)
- **Domain Services deployment — consolidated (Phase 6): Member, Claims, Business, Data Publisher, and KCL Group API**
- TWS / IWS Jobs configuration and execution (Phase 7)
- Correspondence Letter, EDI, EE Portal, Member Portal, Mobile App setup (Phases 7.1, 7.2, 7.3, 7.4, 7.5)
- Oracle integration setup (Phase 8)
- Disaster Recovery planning and validation (Phase 9)
- Test execution and validation coordination (Phase X)
- **Multi-environment validation: DEV → QAR → STAGE → PROD (sequentially) — STAGE added**
- **KCL-specific iteration: Modify KCL Windward to show KCL-only data on designated pages (regression and tenant-isolation testing)**

### Out of Scope
- Functional regression testing of the Windward core product (separate test effort)
- End-user acceptance testing (UAT) — covered by client sign-off activities
- Performance and load testing — separate effort, post-onboarding
- Security penetration testing — handled by InfoSec team outside this playbook

<br>

## 3. Test Objectives

| # | Objective |
|---|-----------|
| 1 | Verify each playbook phase output is complete and accurate before the next phase begins |
| 2 | Confirm AWS infrastructure is provisioned correctly per architecture and naming standards |
| 3 | Validate network and security configurations (DNS, load balancers, TLS certificates, InfoSec, server connectivity) |
| 4 | Confirm databases are set up, restored, replicated, and sized correctly |
| 5 | Verify all deployed applications and services are accessible, healthy, and connected |
| 6 | Ensure validation is repeatable across all four environments (DEV → QAR → STAGE → PROD) |
| 7 | Validate tenant isolation — KCL-only data is correctly surfaced on KCL Windward pages while standard Windward continues to show all data |
| 8 | Establish a documented test record per tenant onboarding to support future audits |

<br>

## 4. Test Environments

Environments are provisioned sequentially. Validation must be completed and approved in each environment before the next is provisioned.

| Environment | Purpose | Data Sensitivity | Validation Order |
|-------------|---------|-----------------|-----------------|
| **DEV** | Development and initial smoke testing | No PHI | First |
| **QAR** | Quality assurance and integration testing | May contain PHI | Second |
| **STAGE** | Pre-production staging; release-path rehearsal; final readiness check before PROD | PHI present | Third |
| **PROD** | Production — live tenant traffic | PHI present | Fourth |

> **Important:** Do not begin QAR validation until DEV is signed off. Do not begin STAGE validation until QAR is signed off. Do not begin PROD validation until STAGE is signed off. STAGE is the production-rehearsal environment and is required before any PROD cutover activity (including Phase 4.1 Bring COM DB Offline).

<br>

## 5. Automation Approach

The goal is to use existing automated test suites wherever possible. Automation reduces manual effort, provides consistent coverage across DEV / QAR / STAGE / PROD, and shortens the validation cycle for each new tenant onboarding.

| Phase Scope | Automation Tool | What It Covers | When to Fall Back to Manual |
|-------------|----------------|----------------|----------------------------|
| **Phase 3.4 — Connect to AWS Servers** | Manual + scripted SSH/RDP checks | Server reachability via bastion, port checks, jump-host validation | Manual where scripted access not yet permitted |
| **Phase 5 — Deploy WW1.0 and Config** | **Playwright** | URL accessibility, application health endpoints, UI-driven DB connectivity checks, KCL-only page isolation checks | If Playwright suite is not yet configured for the new tenant environment; if a test requires a configuration-level check not covered by existing tests |
| **Phase 6 — Domain Services (Member, Claims, Business, Data Publisher, KCL Group API)** | **Postman** | Health endpoints, service-to-service connectivity, AWS dependency checks (S3, SQS, OpenSearch, DynamoDB, KMS) | If Postman environment is not yet configured for the tenant; if dependencies (OpenSearch, KMS, Provider Domain) are not yet available |
| **Phase 7 — TWS / IWS Jobs** | Manual + Jira | Job configuration validation, execution schedule review, standardized package validation | N/A — configuration tracked in Jira |
| **Phases 7.1–7.5 — Specialty Services** | Manual + Jira | Service deployment validation per phase specifics | Manual testing required until automation frameworks established |
| **Phase 8 — Oracle Integration** | Manual + Jira | Oracle connectivity and integration validation | Manual testing required; Oracle team provides verification |
| **Phase 9 — Disaster Recovery** | Manual | DR planning documentation, backup/restore validation | Manual testing required; Infrastructure team leads validation |
| **Phases 1–4 (infra/data)** | Manual only | Spreadsheet validation, AWS console checks, DNS lookups, certificate inspection, database integrity and replication checks | N/A — no existing automation for these phases |

> **Pre-condition for automation:** Before running Playwright or Postman suites, the tester must configure the environment-specific base URLs and credentials using the values from the Environment Variables spreadsheet. Do not run automation against an environment that has not yet passed its infrastructure and deployment prerequisites.
>
> **Business Service dependency note:** Of the 17 Business Services in scope, 13 are currently blocked by the Provider Domain. Only Product, User-Management, Provider-Portal-Claim-Number, and Digital-ID-Media are currently testable end-to-end. Postman collections for blocked services should be parked until the Provider Domain dependency clears.

<br>

## 6. Test Types

| Test Type | Description | Execution | Primary Phases |
|-----------|-------------|-----------|----------------|
| **Data Validation** | Verify completeness and accuracy of Environment Variables spreadsheet inputs | Manual | 1, 2 |
| **Provisioning Validation** | Confirm AWS resources (accounts, servers, load balancers) exist with correct names and configuration | Manual | 2, 2.1, 3, 3.1 |
| **Security & Certificate Validation** | Confirm SSL/TLS certificates are attached, InfoSec controls are in place | Manual | 3.1, 3.3 |
| **Connectivity Validation** | Confirm provisioned AWS servers are reachable from approved access paths | Manual / scripted | 3.4 |
| **Database Validation** | Confirm databases are set up, restored, replicated, sized correctly, and (for PROD) brought offline in the correct sequence | Manual | 4, 4.1, 4.2, 4.3, 4.4 |
| **Deployment Smoke Testing** | Verify each application and service is running and reachable | Playwright (Phase 5) / Postman (Phase 6) / Manual fallback | 5, 6 |
| **Connectivity & Integration Testing** | Validate app-to-DB, service-to-service, and load balancer routing | Playwright (Phase 5) / Postman (Phase 6) | 5, 6 |
| **Tenant Isolation Testing** | Verify KCL Windward shows only KCL data on designated pages while WW Standard continues to show all data | Playwright + Manual | 5 (iteration) |
| **Configuration Validation** | Verify environment-specific settings match expected values from the spreadsheet | Manual (config files) + Postman (runtime assertions) | 5, 6 |
| **Replication & Recovery Validation** | Verify DB backup/restore round-trips and replication lag are within tolerance | Manual + DBA tooling | 4.2, 4.4, 9 |

<br>

## 7. Test Strategy by Playbook Phase

---

### Phase 1 — Gather Client Information

**What to Test:** Environment Variables spreadsheet is complete, accurate, and consistent with stakeholder-provided data.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| All Manual fields in Column C are populated (no blank cells) | Spreadsheet review | SQA |
| Tenant Name, Tenant ID, Country Code, Member Count match stakeholder-confirmed values | Cross-reference with stakeholder sign-off | SQA |
| Tier (1, 2, or 3) is correctly calculated from member count thresholds | Formula review + manual check | SQA |
| Tenant ID is unique across all existing tenants | Check against existing tenant list | SQA |

**Exit Criteria:** All Manual fields populated; Tier confirmed; data validated by stakeholders.

---

### Phase 2 — Create & Validate AWS Accounts

**What to Test:** ServiceNow ticket contains correct account details and AWS accounts are created as requested.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| All Phase 2 Manual fields in Environment Variables spreadsheet are populated | Spreadsheet review | SQA |
| ServiceNow ticket data matches Environment Variables spreadsheet (no discrepancies) | Ticket vs. spreadsheet comparison | SQA |
| ServiceNow ticket submitted and assigned to Cloud Infrastructure Team | Ticket status check | SQA |
| AWS accounts created by Cloud Infrastructure Team and account details returned | Account details received confirmation | SQA |

**Exit Criteria:** AWS accounts exist and account details are documented.

---

### Phase 2.1 — Setup AWS Access

**Owner:** Hetal Patel

**What to Test:** Correct IAM roles exist and authorized users can access the new AWS accounts.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| Required IAM roles created (new or existing, per Environment Variables) | AWS console review | SQA / Cloud Infra |
| Authorized team members can log in to each AWS account via Okta SSO | Access test | SQA |
| Role permissions are scoped correctly (not over-privileged) | IAM policy review | InfoSec / Cloud Infra |
| STS AssumeRole pattern works for service-to-service API testing (carry-forward from existing Postman work) | Postman + AWS Signature V4 | SQA |

**Exit Criteria:** AWS access confirmed for all required roles and team members across all four environments.

---

### Phase 3 — Provision Tenant Infrastructure

**Owner:** Erik Rodriguez Vitier

**What to Test:** All expected AWS EC2 servers exist and follow correct naming conventions.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| All expected servers appear in EC2 "Instances (running)" for DEV, QAR, STAGE, PROD | AWS Console → EC2 | SQA |
| Server names match naming conventions in Environment Variables spreadsheet | Side-by-side comparison | SQA |
| Server counts match expected Tier architecture (Tier 1 / 2 / 3) | Architecture doc vs. AWS | SQA |
| Instance state is "Running" (not stopped, pending, or terminated) | AWS Console status check | SQA |
| System Status Check and Instance Status Check both pass | EC2 status checks tab | SQA |
| Utility application server load-balancer design validated (no OAG in front of Utility app, to allow server-to-server API calls) | Architecture review | SQA / Erik |

**Exit Criteria:** All servers running, correctly named, status checks passed, and Utility LB design confirmed — for each environment validated.

---

### Phase 3.1 — Information Security

**Owner:** Jamie Smith

**What to Test:** Required InfoSec controls are implemented and evidence is captured.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| Access and permissions reviewed and confirmed per InfoSec requirements | Access review documentation | InfoSec / SQA |
| Required security evidence captured and stored | Evidence package review | InfoSec |
| Security findings documented and remediation tracked | InfoSec review sign-off | InfoSec |

**Exit Criteria:** InfoSec sign-off received; evidence package complete.

---

### Phase 3.2 — Load Balancers and DNS Aliases

**Owner:** Alex Tang (with Erik Rodriguez Vitier)

**What to Test:** Load balancer details documented and DNS CNAME aliases are correctly configured.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| ALB and NLB physical names and IPs documented in Environment Variables spreadsheet | Spreadsheet review | SQA |
| ServiceNow DNS Change ticket submitted with correct alias-to-server mappings | Ticket review | SQA |
| DNS CNAME aliases resolve to correct load balancer endpoints | `nslookup` / DNS lookup tool | SQA / Network |
| DNS aliases match the expected naming from Environment Variables spreadsheet | DNS lookup vs. spreadsheet | SQA |
| Utility server ALB/NLB configuration matches design (Phase 3 architecture decision) | Manual review | SQA / Erik |

**Exit Criteria:** ServiceNow ticket closed; all DNS aliases resolve correctly; LB topology matches approved design.

---

### Phase 3.3 — SSL/TLS Certificates

**Owner:** Alex Tang

**What to Test:** Certificates are attached to load balancers and servers; HTTPS connections are secure.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| ServiceNow SSL cert ticket(s) submitted and completed | Ticket status | SQA |
| HTTPS connections to each load balancer succeed (no SSL warnings) | Browser test | SQA |
| Certificate domain name matches expected tenant domain | Certificate details in browser | SQA |
| Certificate is not expired and expiry date is documented | Certificate viewer | SQA |
| No mixed-content or TLS version warnings | Browser developer tools | SQA |

**Exit Criteria:** All HTTPS connections succeed; certificate details verified and documented.

---

### Phase 3.4 — Connect to AWS Servers *(NEW)*

**Owner:** Erik Rodriguez Vitier

**What to Test:** Teams can reach the provisioned AWS servers through approved access paths so that downstream phases can proceed.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| Approved access path (bastion / jump host / SSM) is functional for each environment | Manual connectivity test | SQA / Cloud Infra |
| Required ports open per security group and NACL definitions | Port scan / `nc` check | SQA / Cloud Infra |
| Authorized users in each role can connect to required server types (app, DB, utility) | Access test | SQA |
| Connectivity evidence captured per environment (DEV, QAR, STAGE, PROD) | Screenshots / log capture | SQA |
| Documented troubleshooting runbook exists for connection failures | Runbook review | Cloud Infra |

**Exit Criteria:** All required server types reachable from all approved access paths in each environment; evidence stored per environment.

---

### Phase 4 — Setup SQL Servers and Database Configuration

**Owner:** DBA Team (Vasudha Ramakrishnan)

**What to Test:** SQL Server instances and database configuration baselines are established for the tenant.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| SQL Server instances provisioned per architecture (version, edition, instance count) | DBA verification | DBA / SQA |
| Database server connectivity verified (port, hostname, credentials) | Connection test | DBA |
| Server-level configuration (collation, memory, MAXDOP, tempdb) matches standard baseline | DBA review | DBA |
| Required service accounts and DB-level logins created and least-privileged | Manual review | DBA / InfoSec |
| Environment-specific config (DEV, QAR, STAGE, PROD) validated independently | Per-env review | DBA / SQA |

**Exit Criteria:** SQL Server instances available, configured to baseline, accessible from authorized hosts in each environment.

---

### Phase 4.1 — Bring COM Database Offline in Production *(NEW — PROD only)*

**Owner:** DBA Team

**What to Test:** The legacy COM database is taken offline in production according to the cutover sequence, with rollback evidence captured.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| Cutover window communicated and approved by Change Management | Change ticket review | DBA / Project Manager |
| Pre-offline backup captured and verified restorable | Backup/restore test | DBA |
| Application connections to COM DB are drained or rerouted before offline action | Connection monitor | DBA / App Team |
| COM DB transitioned to offline state at the planned timestamp | DBA action log | DBA |
| Rollback runbook tested in STAGE prior to PROD execution | Runbook execution log | DBA / SQA |
| No unexpected connection or job errors observed post-offline | Log review | DBA / SQA |

**Exit Criteria:** COM DB offline in PROD per cutover plan; rollback runbook proven in STAGE; post-cutover monitoring confirms no unexpected errors.

> **Note:** This phase applies only to PROD. DEV/QAR/STAGE iterations validate the runbook itself, not the offline transition of a live customer database.

---

### Phase 4.2 — Database Backup and Restore *(NEW)*

**Owner:** DBA Team (Vasudha Ramakrishnan)

**What to Test:** Backups are produced from source databases and restored cleanly into the tenant SQL Servers, ready for downstream replication and application connectivity.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| Backup files generated per documented procedure (full, log, differential as required) | DBA verification | DBA |
| Backup file checksums validated | Checksum tool | DBA |
| Restore completes cleanly into target DB server with no errors | Restore log review | DBA |
| Post-restore DBCC CHECKDB passes (no corruption) | DBCC output review | DBA |
| Row counts and key business-table totals match expected source values | Spot-check query | DBA / SQA |
| Per-environment restore evidence captured (DEV, QAR, STAGE, PROD) | Evidence package | DBA |

**Exit Criteria:** All required databases restored without error in each environment; integrity verified; spot-check counts match expectations.

---

### Phase 4.3 — Windward Database Shrink *(NEW)*

**Owner:** Nabeel (with DBA support — Vasudha Ramakrishnan)

**What to Test:** The Windward database is shrunk to the appropriate size per tenant Tier so storage costs and performance characteristics match the architecture target.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| Pre-shrink size, file layout, and free-space measurements captured | DBA report | DBA |
| Shrink operation completed per documented procedure (file-level, not DB-level where applicable) | DBA action log | DBA |
| Post-shrink index fragmentation measured and remediated if above threshold | sys.dm_db_index_physical_stats | DBA |
| Post-shrink performance smoke test (query latency for canonical queries) passes | Query timing | DBA / SQA |
| Storage allocation sufficient for projected growth at this tenant Tier | Capacity review | DBA |
| Sizing approved by DBA team | DBA sign-off | DBA |

**Exit Criteria:** Windward DB sized per Tier; fragmentation within tolerance; performance smoke test passes; DBA sign-off captured.

---

### Phase 4.4 — Database Replication Setup *(NEW)*

**Owner:** DBA Team (Vasudha Ramakrishnan)

**What to Test:** Replication is configured between the appropriate source and target databases, replication lag is within tolerance, and downstream consumers can read replicated data.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| Replication topology (publisher, distributor, subscribers / source-target) configured per design | DBA verification | DBA |
| Initial snapshot or seeding completes without error | DBA log review | DBA |
| Replication agents healthy; no error states in the monitor | Replication Monitor | DBA |
| Replication lag is within agreed tolerance (document the SLO) | Lag query | DBA / SQA |
| Test write at source is observable at target within the SLO | End-to-end smoke | DBA / SQA |
| Downstream consumers (reports, domain services) can read from replica/target | Connectivity test | SQA / App Team |

**Exit Criteria:** Replication healthy in each environment; lag within SLO; downstream consumers confirmed reading from target.

---

### Phase 5 — Deploy WW1.0 and Config

**Owner:** Dan Hobert (Application Services Team)

**What to Test:** Windward 1.0 application and configuration are deployed, accessible, and functional. KCL-specific configuration is validated independently.

**Automation:** Use the existing **Playwright** test suite for URL accessibility, health endpoints, UI-driven connectivity checks, and the new KCL-only page isolation checks. Configure Playwright with the tenant environment URL from the Environment Variables spreadsheet before execution. Fall back to manual steps only if Playwright is not yet configured for the new environment.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| Jira/ADO deployment tickets are resolved | Manual — ticket status | SQA |
| EC2 instances for application servers are in "Running" state | Manual — AWS Console | SQA |
| System and Instance status checks pass on app servers | Manual — EC2 status checks | SQA |
| Application URL loads successfully and health endpoints return healthy status | **Playwright** — existing smoke test suite | SQA |
| Load balancer target group shows all targets as "healthy" | Manual — AWS Console → Target Groups | SQA |
| Application can connect to the database (UI-driven query returns data) | **Playwright** — existing DB connectivity tests | SQA |
| Application is pointing to correct database and service endpoints | Manual — AppSettings review | SQA / App Team |
| KCL Windward designated pages show **only** KCL data; WW Standard continues to show all data (tenant isolation regression) | **Playwright** + manual spot-check | SQA |
| 500+ existing Playwright tests on NGPP regression suite pass against this deployment | **Playwright** — full regression run | SQA |

**Exit Criteria:** All applications running, Playwright smoke + regression suites pass with no failures, LB targets healthy, DB connected, KCL-only data isolation verified.

> **Iteration note (CCP backlog):** A specific iteration owned by Maria Gaffney modifies KCL Windward to show only KCL data on designated pages while WW Standard continues to display all data. Tenant-isolation tests for these pages must be run **after** Phase 5 deployment in every environment and before sign-off.

---

### Phase 6 — Deploy Domain Services

**Owner:** Eileen Dillon (Domain Services Team, with Venkata Nune)

**Overview:** Phase 6 deploys the Domain Services that the tenant depends on. The deployment is structured per environment (DEV → QAR → STAGE → PROD) rather than per service. Services in scope: **Member Domain, Claims Domain, Business Service, Data Publisher, and KCL Group API**.

**Automation:** Use the existing **Postman** collections per service. Configure each Postman environment with the tenant-specific base URL and credentials before execution. STS AssumeRole + AWS Signature V4 authentication patterns (already in use for User Management and TPE search) extend to the new services.

#### Phase 6 — Service: Member Domain Service

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| Deployment pipeline executed successfully | Manual — ADO pipeline status | SQA / Dev |
| Required AWS resources in place (OpenSearch, KMS keys, DynamoDB, SQS) | Manual — AWS Console review | SQA / CE Team |
| Service is running and healthy; S3 / SQS / OpenSearch endpoints reachable | **Postman** — existing Member Domain collection | SQA |
| Service logs show no critical errors on startup | Manual — CloudWatch Logs | SQA |

#### Phase 6 — Service: Claims Domain Service

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| All 3 Claims Domain Service pipelines executed successfully | Manual — ADO pipeline status | SQA / Dev |
| KMS keys and DynamoDB tables present and accessible | Manual — AWS Console | CE Team / SQA |
| Correct variable values used in deployment (not dummy/placeholder values) | Manual — pipeline vars review | SQA / Dev |
| Service is running and healthy; DynamoDB / OpenSearch / SQS connectivity confirmed | **Postman** — existing Claims Domain collection | SQA |
| Service logs show no critical errors on startup | Manual — CloudWatch Logs | SQA |

#### Phase 6 — Service: Business Service

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| Deployment pipeline executed successfully | Manual — ADO pipeline status | SQA / Dev |
| Database connection strings point to the correct tenant servers | Manual — pipeline vars review | SQA / Dev |
| Currently testable services (Product, User-Management, Provider-Portal-Claim-Number, Digital-ID-Media) pass health and integration tests | **Postman** — existing Business Service collection | SQA |
| Provider-Domain-blocked services parked with documented blocker (13 of 17) | Manual — blocker registry | SQA |
| Service logs show no critical errors on startup | Manual — CloudWatch Logs | SQA |

#### Phase 6 — Service: Data Publisher

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| Deployment pipeline executed successfully | Manual — ADO / TFS pipeline status | SQA / Dev |
| `RouteInfo.json` values correctly injected into `appsettings.json` (Bucket URL, Access Key, Secret Key, DB connection strings) | Manual — AppSettings review | SQA / Dev |
| S3 bucket accessible; CDP credentials functional; service health confirmed | **Postman** — existing Data Publisher collection | SQA / CE Team |
| Service logs show no critical errors on startup | Manual — CloudWatch Logs | SQA |

#### Phase 6 — Service: KCL Group API *(NEW)*

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| KCL Group API deployment ticket resolved for the environment | Manual — ticket status | SQA |
| Service health endpoint returns healthy | **Postman** — new KCL Group API collection | SQA |
| API authentication via STS AssumeRole + AWS Signature V4 succeeds | **Postman** | SQA |
| Upstream/downstream service connectivity confirmed | **Postman** | SQA |
| Service logs show no critical errors on startup | Manual — CloudWatch Logs | SQA |

**Phase 6 Exit Criteria:** All in-scope services deployed; Postman collections pass with no failures (or blocked services explicitly noted with Provider Domain dependency); no critical startup errors in any environment.

---

### Phase 7 — TWS / IWS Jobs Setup and Configuration

**Owner:** TWS / IWS Team (with engineering design by Nabeel / Zsolt)

**What to Test:** Job configuration is complete, connection strings are correct, job schedules are validated, and standardized packaging is followed where rolled out.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| Jira ticket for IWS job setup created and assigned to TWS Team | Manual — Jira ticket review | SQA |
| All required job scripts configured with correct connection strings | Manual — job config review | TWS Team / SQA |
| Standardized package structure followed (folder layout, docs template, deployment pipeline) — for jobs migrated to new standard | Manual — package inspection | SQA / Engineering |
| Job execution schedule defined and documented | Manual — schedule review | TWS Team |
| Test job execution successful; logs show no critical errors | Manual — execution log review | TWS Team / SQA |
| Production Control standards preserved in standardized deployment model | Manual — Prod Control review | Production Control / SQA |

**Exit Criteria:** Jira ticket marked Done; job scripts configured; test execution successful; standardized package validated where applicable.

> **Forward-looking note:** The CCP T4 workstream is migrating 1,775 scheduled jobs across 13 servers to a new standardized engineering model. Each migration wave will require a re-run of Phase 7 validation against the standardized package. Pilot jobs (basic SQL script, WWCPDPMTGRACEUPD, WWCPDPMTJMTEXPIRE, APPPDBADCLMBPNPIRPT) serve as the proof point.

---

### Phase 7.1 — Correspondence Letter Setup

**What to Test:** Correspondence Letter configuration is deployed and functional.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| Deployment ticket created and assigned | Manual — Jira/ADO ticket review | SQA |
| Correspondence Letter service health confirmed | Manual — service availability check | SQA |
| Template configuration reviewed and validated | Manual — config review | Application Team |

**Exit Criteria:** Service deployed; configuration validated; health check passed.

---

### Phase 7.2 — EDI Setup

**What to Test:** EDI configuration is complete and data flows are tested.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| EDI deployment ticket created and assigned | Manual — Jira/ADO ticket review | SQA |
| EDI service connectivity to source/destination systems verified | Manual — connectivity test | EDI Team / SQA |
| Sample EDI data transmission successful | Manual — test data flow validation | EDI Team |

**Exit Criteria:** Ticket marked Done; connectivity verified; sample data transmitted successfully.

---

### Phase 7.3 — Employer/Employee (EE) Portal Setup

**What to Test:** EE Portal is deployed, accessible, and connected to required services.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| EE Portal deployment ticket marked Done | Manual — ticket status | SQA |
| EE Portal URL loads without errors | Manual — browser test | SQA |
| Application can connect to required backend services | Manual — health check / service integration test | SQA / App Team |
| No critical errors in application startup logs | Manual — CloudWatch logs review | SQA |

**Exit Criteria:** Portal deployed; URL accessible; backend connectivity confirmed; no startup errors.

---

### Phase 7.4 — Member Portal Setup

**What to Test:** Member Portal is deployed, accessible, and integrated with Windward applications.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| Member Portal deployment ticket marked Done | Manual — ticket status | SQA |
| Member Portal URL loads without errors via HTTPS | Manual — browser test | SQA |
| Application can authenticate users and access member data | Manual — login and data retrieval test | SQA / App Team |
| No critical errors in application startup logs | Manual — CloudWatch logs review | SQA |

**Exit Criteria:** Portal deployed; URL accessible over HTTPS; authentication working; no startup errors.

---

### Phase 7.5 — Mobile App Setup

**What to Test:** Mobile App is deployed, accessible, and integrated with backend services.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| Mobile App deployment ticket marked Done | Manual — ticket status | SQA |
| Mobile App endpoints accessible and responding | Manual — REST endpoint testing | SQA |
| App can authenticate and retrieve member/claims data | Manual — functional testing | Mobile App Team / SQA |
| No critical errors in application startup logs | Manual — CloudWatch logs review | SQA |

**Exit Criteria:** Endpoints responding; authentication working; data retrieval successful; no startup errors.

---

### Phase 8 — Oracle Integration Setup

**What to Test:** Oracle integration is configured and data connectivity validated.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| Oracle integration planning ticket marked Done | Manual — Jira ticket review | SQA |
| Oracle connectivity from tenant environment confirmed | Manual — connection test (Oracle team) | Oracle Team / Infrastructure |
| Required data feeds configured and tested | Manual — sample data load test | Oracle Team |
| Oracle team sign-off received | Manual — Oracle team confirmation | Oracle Team |

**Exit Criteria:** Integration ticket complete; connectivity confirmed; sample data successful; Oracle sign-off received.

---

### Phase 9 — Disaster Recovery Setup

**What to Test:** Disaster Recovery plan is documented, backups are tested, and recovery procedures are validated.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| DR plan documentation complete and reviewed | Manual — documentation review | Infrastructure Team / SQA |
| Database backups configured and tested (consistent with Phase 4.2 evidence) | Manual — backup restore test | DBA / Infrastructure Team |
| Replication topology (Phase 4.4) covered in DR plan and failover path documented | Manual — DR doc review | DBA / Infrastructure Team |
| Backup/restore time objectives (RTO/RPO) documented and validated | Manual — recovery testing | Infrastructure Team |
| Infrastructure team sign-off on DR procedures | Manual — sign-off confirmation | Infrastructure Team |

**Exit Criteria:** DR documentation complete; backups tested; replication failover path documented; RTO/RPO validated; Infrastructure sign-off received.

---

### Phase X — Testing & Validation

**What to Test:** All onboarding phases are tested end-to-end; test results are documented and all critical issues resolved.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| Jira ticket for test execution created with links to testing documentation | Manual — Jira ticket review | SQA / Project Manager |
| SQA Team assigned and acknowledged | Manual — ticket assignment | Project Manager |
| All test cases from PlaybookTestCases.csv through Phase 9 executed across DEV, QAR, STAGE, PROD | Manual — test execution tracking | SQA |
| Test results documented and reported | Manual — report review | SQA |
| All Blocker and High-priority defects resolved | Manual — defect status review | All teams |
| Tenant-isolation regression (KCL Windward / KCL Group API) executed and passed in PROD | Playwright + Postman | SQA |

**Exit Criteria:** All test cases executed; results documented; critical defects resolved; tenant-isolation evidence captured; onboarding sign-off ready.

<br>

## 8. Environment Progression Gate

Each environment must pass validation before the next environment is provisioned. The gate applies across all phases relevant to that environment.

```
DEV Validation Complete   → Cloud Infra provisions QAR
QAR Validation Complete   → Cloud Infra provisions STAGE
STAGE Validation Complete → Cloud Infra performs PROD cutover prep
PROD Validation Complete  → Onboarding sign-off
```

> STAGE is the rehearsal environment for any PROD cutover step (especially Phase 4.1 Bring COM DB Offline). The Phase 4.1 runbook must be executed end-to-end against STAGE and approved before PROD execution.

<br>

## 9. Roles & Responsibilities

| Role | Responsibility |
|------|---------------|
| **SQA** (Joshua Greene, team) | Execute validation steps per phase; document results; log defects; confirm phase exit criteria met |
| **Cloud Infrastructure Team** (Erik Rodriguez Vitier, Alex Tang, Lindsay) | Provision AWS accounts, servers, load balancers; respond to infrastructure defects; lead Phases 3, 3.2, 3.3, 3.4 |
| **Application Services Team** (Daniel Hobert) | Deploy applications (Phase 5 Deploy WW1.0 and Config); run sanity tests; respond to application defects |
| **DBA Team** (Vasudha Ramakrishnan, with Nabeel for Windward shrink) | Database setup, backup/restore, replication, sizing, and PROD COM DB offline (Phases 4, 4.1, 4.2, 4.3, 4.4) |
| **Domain Services Team** (Eileen Dillon, Venkata Nune) | Deploy and validate Domain Services (Phase 6: Member, Claims, Business, Data Publisher, KCL Group API) |
| **TWS / IWS Team** (engineering by Nabeel / Zsolt) | Configure and validate jobs, handle job scheduling and standardized packaging (Phase 7) |
| **Specialty Services Team** | Deploy and validate Correspondence Letter, EDI, Portals, Mobile App (Phases 7.1–7.5) |
| **Oracle Team** | Configure and validate Oracle integration (Phase 8) |
| **Infrastructure Team** | Plan, document, and validate Disaster Recovery procedures (Phase 9) |
| **InfoSec** (Jamie Smith) | Security setup and validation (Phase 3.1) |
| **Network Team** | Load balancer and DNS configuration (Phase 3.2), certificate configuration (Phase 3.3) |
| **Production Control** | Standards enforcement for jobs and cutovers (Phases 4.1, 7) |
| **Tenant UI Iteration** (Maria Gaffney) | Owns "Modify KCL Windward to show KCL-only data on designated pages" iteration; partners with SQA on tenant-isolation tests |
| **Project Manager** | Coordinate access requests, stakeholder availability, phase gate approvals, environment progression, and test execution coordination (Phase X) |

<br>

## 10. Entry & Exit Criteria (Summary)

| Phase | Entry Criteria | Exit Criteria |
|-------|---------------|---------------|
| 1 | Client approved for onboarding; stakeholder contacts identified | Environment Variables complete and stakeholder-validated |
| 2 | Phase 1 complete | AWS accounts created; account details received |
| 2.1 | Phase 2 complete | AWS access confirmed for all required roles |
| 3 | Phases 2, 2.1 complete | All servers provisioned, running, naming validated, Utility LB design confirmed |
| 3.1 | Phase 3 complete | InfoSec sign-off received; security evidence captured |
| 3.2 | Phases 3, 3.1 complete | DNS aliases configured and resolving |
| 3.3 | Phases 3, 3.1, 3.2 complete | SSL/TLS certificates attached and verified |
| **3.4** | **Phases 3, 3.1, 3.2, 3.3 complete** | **All server types reachable from approved access paths in each environment** |
| 4 | Phase 3.4 complete | SQL Server instances available, configured to baseline |
| **4.1** | **Phase 4 complete; STAGE rehearsal of runbook passed** | **(PROD only) COM DB offline per cutover plan; rollback runbook proven; no unexpected errors** |
| **4.2** | **Phase 4 complete** | **All required databases restored, integrity verified, spot-checks pass** |
| **4.3** | **Phase 4.2 complete** | **Windward DB sized per Tier; fragmentation within tolerance; performance smoke passes** |
| **4.4** | **Phase 4.2 complete** | **Replication healthy; lag within SLO; downstream consumers confirmed** |
| 5 | Phases 4, 4.2, 4.3, 4.4 complete | All applications deployed; Playwright smoke + regression pass; KCL tenant isolation verified |
| 6 | Phase 5 complete | All in-scope Domain Services deployed (Member, Claims, Business, Data Publisher, KCL Group API); Postman pass; blockers documented |
| 7 | Phase 6 complete | TWS/IWS job tickets created and assigned; standardized packaging validated where applicable |
| 7.1 | Phase 7 complete | Correspondence Letter configuration complete and validated |
| 7.2 | Phase 7.1 complete | EDI setup complete and validated |
| 7.3 | Phase 7.2 complete | EE Portal deployment complete and accessible |
| 7.4 | Phase 7.3 complete | Member Portal deployment complete and accessible |
| 7.5 | Phase 7.4 complete | Mobile App deployment complete and accessible |
| 8 | Phase 7.5 complete | Oracle integration setup complete and validated |
| 9 | Phase 8 complete | DR planning and validation complete; replication failover path documented |
| X | Phases 1–9 complete in all four environments | Test execution complete, results documented, all critical issues resolved, tenant-isolation evidence captured |

<br>

## 11. Defect Management

- Defects found during validation are logged in **Jira** on the CCP backlog.
- Defects are assigned directly to the team responsible for the failing phase.
- **Severity levels:**

| Severity | Definition | Required Action |
|----------|-----------|----------------|
| **Blocker** | Phase exit criteria cannot be met; onboarding halted | Fix before proceeding to next phase |
| **High** | Core functionality broken but workaround exists | Fix before STAGE validation |
| **Medium** | Non-critical issue; does not block phase exit | Fix before onboarding sign-off |
| **Low** | Minor or cosmetic issue | Logged; fix scheduled per team backlog |

<br>

## 12. Tools & Access Required

| Tool | Usage | Required By |
|------|-------|------------|
| SharePoint — Environment Variables spreadsheet | Data collection and validation reference | SQA, all phases |
| AWS Console (via Okta SSO) | Infrastructure and application validation | SQA, Phases 3–6 |
| Jira | Ticket tracking and defect logging | SQA, all phases |
| Azure DevOps (ADO) | Pipeline execution and deployment tracking | SQA, Phases 5–6 |
| ServiceNow | AWS account, DNS, and certificate requests | SQA, Phases 2, 3.2, 3.3 |
| CloudWatch Logs | Application log review and error diagnosis | SQA, Phases 5–6 |
| Browser / curl | URL accessibility and health endpoint testing | SQA, Phases 5–6 |
| DNS lookup tool (nslookup) | DNS alias resolution verification | SQA, Phase 3.2 |
| Bastion / Jump host / SSM | Server connectivity validation | SQA, Phase 3.4 |
| SQL Server Management Studio / DBA tooling | Database setup, backup/restore, shrink, replication validation | DBA, Phases 4, 4.1, 4.2, 4.3, 4.4 |
| Postman (with STS AssumeRole + AWS SigV4) | Domain Service API testing | SQA, Phase 6 |
| Playwright | Windward smoke, regression, and tenant-isolation testing | SQA, Phase 5 |

<br>

## 13. Assumptions & Risks

| # | Assumption / Risk | Mitigation |
|---|-------------------|-----------|
| 1 | Infrastructure Team notifies SQA via Jira when provisioning is complete before validation begins | SQA monitors Jira ticket status; does not begin validation until ticket is marked Done |
| 2 | Environment Variables spreadsheet is the single source of truth for all naming and config values | All teams reference the same spreadsheet; any changes must be updated in the spreadsheet first |
| 3 | PHI data handling in QAR, STAGE, and PROD requires appropriate access controls and must follow privacy policies | SQA members with QAR/STAGE/PROD access must be authorized; PHI handling procedures must be followed |
| 4 | Some Phase 6 services require AWS dependencies (OpenSearch, KMS keys, DynamoDB) from the CE team before deployment can be validated | CE team dependencies tracked in Jira; SQA flags blockers early |
| 5 | 13 of 17 Business Services are currently blocked by the Provider Domain dependency | Only Product, User-Management, Provider-Portal-Claim-Number, and Digital-ID-Media are testable end-to-end; remaining services validated when Provider Domain unblocks |
| 6 | New clients may require operational gap resolution for NBI process (no existing Windward record) | Project Manager to coordinate NBI process completion before Phase 1 can begin |
| 7 | Phase 4.1 (Bring COM DB Offline) is a one-shot, high-blast-radius PROD operation | STAGE rehearsal is mandatory; Change Management approval and rollback runbook required before execution |
| 8 | KCL Windward tenant-isolation page changes may regress existing WW Standard behavior | Run full Playwright NGPP regression suite against both KCL Windward and WW Standard after any iteration deployment |
| 9 | Postman authentication via STS AssumeRole occasionally returns `AccessDenied` mid-test (carry-forward issue from earlier smoke testing, e.g. CCP-1437) | Maintain retry and credential-refresh logic in Postman collections; log recurring failures as bugs |
| 10 | IWS job migration to standardized packaging is in flight (1,775 jobs / 13 servers) and may overlap with onboarding waves | Coordinate Phase 7 validation runs with engineering migration waves; revalidate migrated jobs against new package standard |

<br>

## 14. Test Case to Playbook Phase Mapping

The table below maps every test case in [PlaybookTestCases.csv](PlaybookTestCases.csv) to its corresponding playbook phase. New test cases for added phases are marked **NEW**; existing test cases may need renumbering when the CSV is updated to match this revised structure.

| Playbook Phase | Phase Title | Test Case ID | Test Case Title |
|---------------|-------------|--------------|-----------------|
| **Phase 1** | Gather Client Information | P1_TC01 | P1_ValidateEnvironmentVariablesCompleteness |
| **Phase 1** | Gather Client Information | P1_TC02 | P1_ValidateTierCalculation |
| **Phase 1** | Gather Client Information | P1_TC03 | P1_ValidateStakeholderDataAccuracy |
| **Phase 2** | Create & Request AWS Accounts | P2_TC01 | P2_ValidatePhase2SpreadsheetFields |
| **Phase 2** | Create & Request AWS Accounts | P2_TC02 | P2_ValidateServiceNowAWSAccountTicket |
| **Phase 2** | Create & Request AWS Accounts | P2_TC03 | P2_ValidateAWSAccountsCreated |
| **Phase 2.1** | Setup AWS Access | P2.1_TC01 | P2_1_ValidateAWSIAMRoles |
| **Phase 2.1** | Setup AWS Access | P2.1_TC02 | P2_1_ValidateAWSOktaSSOAccess |
| **Phase 2.1** | Setup AWS Access | P2.1_TC03 *(NEW)* | P2_1_ValidateSTSAssumeRolePattern |
| **Phase 3** | Provision Tenant Infrastructure | P3_TC01 | P3_ValidateJiraInfraProvisioningTicket |
| **Phase 3** | Provision Tenant Infrastructure | P3_TC02 | P3_ValidateEC2ServersProvisioned |
| **Phase 3** | Provision Tenant Infrastructure | P3_TC03 *(NEW)* | P3_ValidateUtilityServerLBDesign |
| **Phase 3.1** | Information Security Setup | P3.1_TC01 | P3_1_ValidateInfoSecControls |
| **Phase 3.2** | Load Balancers Setup | P3.2_TC01 | P3_2_ValidateInfrastructureInventoryDocumented |
| **Phase 3.2** | Load Balancers Setup | P3.2_TC02 | P3_2_ValidateDNSCNAMETicket |
| **Phase 3.2** | Load Balancers Setup | P3.2_TC03 | P3_2_ValidateDNSAliasResolution |
| **Phase 3.3** | Attach SSL/TLS Certificates | P3.3_TC01 | P3_3_ValidateSSLCertificateTickets |
| **Phase 3.3** | Attach SSL/TLS Certificates | P3.3_TC02 | P3_3_ValidateHTTPSConnectivity |
| **Phase 3.4** *(NEW)* | Connect to AWS Servers | P3.4_TC01 *(NEW)* | P3_4_ValidateBastionConnectivity |
| **Phase 3.4** *(NEW)* | Connect to AWS Servers | P3.4_TC02 *(NEW)* | P3_4_ValidatePortAndSecurityGroupAccess |
| **Phase 3.4** *(NEW)* | Connect to AWS Servers | P3.4_TC03 *(NEW)* | P3_4_ValidatePerEnvironmentConnectivityEvidence |
| **Phase 4** | Setup SQL Servers and Database Configuration | P4_TC01 *(revised)* | P4_ValidateSQLServerInstanceProvisioning |
| **Phase 4** | Setup SQL Servers and Database Configuration | P4_TC02 *(NEW)* | P4_ValidateServerBaselineConfiguration |
| **Phase 4.1** *(NEW, PROD-only)* | Bring COM Database Offline in Production | P4.1_TC01 *(NEW)* | P4_1_ValidatePreOfflineBackup |
| **Phase 4.1** *(NEW, PROD-only)* | Bring COM Database Offline in Production | P4.1_TC02 *(NEW)* | P4_1_ValidateRunbookRehearsalInStage |
| **Phase 4.1** *(NEW, PROD-only)* | Bring COM Database Offline in Production | P4.1_TC03 *(NEW)* | P4_1_ValidateProdOfflineCutoverExecution |
| **Phase 4.2** *(NEW)* | Database Backup and Restore | P4.2_TC01 *(NEW)* | P4_2_ValidateBackupGenerationAndChecksum |
| **Phase 4.2** *(NEW)* | Database Backup and Restore | P4.2_TC02 *(NEW)* | P4_2_ValidateRestoreCompletesAndDBCCPasses |
| **Phase 4.2** *(NEW)* | Database Backup and Restore | P4.2_TC03 *(NEW)* | P4_2_ValidatePostRestoreSpotCheckCounts |
| **Phase 4.3** *(NEW)* | Windward Database Shrink | P4.3_TC01 *(NEW)* | P4_3_ValidatePreAndPostShrinkMetrics |
| **Phase 4.3** *(NEW)* | Windward Database Shrink | P4.3_TC02 *(NEW)* | P4_3_ValidatePostShrinkPerformanceSmoke |
| **Phase 4.4** *(NEW)* | Database Replication Setup | P4.4_TC01 *(NEW)* | P4_4_ValidateReplicationTopologyAndSeeding |
| **Phase 4.4** *(NEW)* | Database Replication Setup | P4.4_TC02 *(NEW)* | P4_4_ValidateReplicationLagWithinSLO |
| **Phase 4.4** *(NEW)* | Database Replication Setup | P4.4_TC03 *(NEW)* | P4_4_ValidateDownstreamConsumerReadFromTarget |
| **Phase 5** | Deploy WW1.0 and Config | P5_TC01 | P5_ValidateApplicationDeploymentTickets *(manual)* |
| **Phase 5** | Deploy WW1.0 and Config | P5_TC02 | P5_ValidateApplicationServersRunning *(manual)* |
| **Phase 5** | Deploy WW1.0 and Config | P5_TC03 | P5_ValidateApplicationURLAccessibility_Playwright *(Playwright)* |
| **Phase 5** | Deploy WW1.0 and Config | P5_TC04 | P5_ValidateApplicationHealthEndpoints_Playwright *(Playwright)* |
| **Phase 5** | Deploy WW1.0 and Config | P5_TC05 | P5_ValidateLoadBalancerTargetHealth *(manual)* |
| **Phase 5** | Deploy WW1.0 and Config | P5_TC06 | P5_ValidateDatabaseConnectivityFromApp *(Playwright + manual)* |
| **Phase 5** | Deploy WW1.0 and Config | P5_TC07 *(NEW)* | P5_ValidateKCLTenantIsolation_Playwright *(Playwright)* |
| **Phase 5** | Deploy WW1.0 and Config | P5_TC08 *(NEW)* | P5_ValidateNGPPRegressionSuite_Playwright *(Playwright)* |
| **Phase 6** | Deploy Domain Services — Member Domain | P6_TC01 | P6_ValidateMemberDomainAWSDependencies *(manual)* |
| **Phase 6** | Deploy Domain Services — Member Domain | P6_TC02 | P6_ValidateMemberDomainServiceDeployment *(manual)* |
| **Phase 6** | Deploy Domain Services — Member Domain | P6_TC03 | P6_ValidateMemberDomainServiceHealth_Postman *(Postman)* |
| **Phase 6** | Deploy Domain Services — Claims Domain | P6_TC04 | P6_ValidateClaimsDomainAWSDependencies *(manual)* |
| **Phase 6** | Deploy Domain Services — Claims Domain | P6_TC05 | P6_ValidateClaimsDomainServiceDeployment *(manual)* |
| **Phase 6** | Deploy Domain Services — Claims Domain | P6_TC06 | P6_ValidateClaimsDomainServiceHealth_Postman *(Postman)* |
| **Phase 6** | Deploy Domain Services — Business Service | P6_TC07 | P6_ValidateBusinessServiceDeployment *(manual)* |
| **Phase 6** | Deploy Domain Services — Business Service | P6_TC08 *(revised)* | P6_ValidateBusinessServiceTestableSubset_Postman *(Postman)* |
| **Phase 6** | Deploy Domain Services — Business Service | P6_TC09 *(NEW)* | P6_ValidateProviderDomainBlockerRegistry |
| **Phase 6** | Deploy Domain Services — Data Publisher | P6_TC10 | P6_ValidateDataPublisherConfiguration *(manual)* |
| **Phase 6** | Deploy Domain Services — Data Publisher | P6_TC11 | P6_ValidateDataPublisherDeployment *(manual)* |
| **Phase 6** | Deploy Domain Services — Data Publisher | P6_TC12 | P6_ValidateDataPublisherS3Connectivity_Postman *(Postman)* |
| **Phase 6** | Deploy Domain Services — KCL Group API *(NEW)* | P6_TC13 *(NEW)* | P6_ValidateKCLGroupAPIDeployment *(manual)* |
| **Phase 6** | Deploy Domain Services — KCL Group API *(NEW)* | P6_TC14 *(NEW)* | P6_ValidateKCLGroupAPIHealth_Postman *(Postman)* |
| **Phase 7** | TWS / IWS Jobs Setup | P7_TC01 | P7_ValidateJobConfiguration *(manual)* |
| **Phase 7** | TWS / IWS Jobs Setup | P7_TC02 | P7_ValidateJobExecution *(manual)* |
| **Phase 7** | TWS / IWS Jobs Setup | P7_TC03 *(NEW)* | P7_ValidateStandardizedPackageStructure *(manual)* |
| **Phase 7.1** | Correspondence Letter Setup | P7.1_TC01 | P7_1_ValidateCorrespondenceLetterDeployment *(manual)* |
| **Phase 7.2** | EDI Setup | P7.2_TC01 | P7_2_ValidateEDIConfiguration *(manual)* |
| **Phase 7.2** | EDI Setup | P7.2_TC02 | P7_2_ValidateEDIDataFlow *(manual)* |
| **Phase 7.3** | EE Portal Setup | P7.3_TC01 | P7_3_ValidateEEPortalAccessibility *(manual)* |
| **Phase 7.3** | EE Portal Setup | P7.3_TC02 | P7_3_ValidateEEPortalBackendConnectivity *(manual)* |
| **Phase 7.4** | Member Portal Setup | P7.4_TC01 | P7_4_ValidateMemberPortalAccessibility *(manual)* |
| **Phase 7.4** | Member Portal Setup | P7.4_TC02 | P7_4_ValidateMemberPortalAuthentication *(manual)* |
| **Phase 7.5** | Mobile App Setup | P7.5_TC01 | P7_5_ValidateMobileAppEndpoints *(manual)* |
| **Phase 7.5** | Mobile App Setup | P7.5_TC02 | P7_5_ValidateMobileAppAuthentication *(manual)* |
| **Phase 8** | Oracle Integration | P8_TC01 | P8_ValidateOracleConnectivity *(manual)* |
| **Phase 8** | Oracle Integration | P8_TC02 | P8_ValidateOracleDataFeeds *(manual)* |
| **Phase 9** | Disaster Recovery | P9_TC01 | P9_ValidateDRPlanDocumentation *(manual)* |
| **Phase 9** | Disaster Recovery | P9_TC02 | P9_ValidateDRBackupRestore *(manual)* |
| **Phase 9** | Disaster Recovery | P9_TC03 *(NEW)* | P9_ValidateReplicationFailoverPathDocumented *(manual)* |
| **Phase X** | Testing & Validation | PX_TC01 | PX_ValidateTestExecutionComplete *(manual)* |
| **Phase X** | Testing & Validation | PX_TC02 | PX_ValidateCriticalDefectsResolved *(manual)* |
| **Phase X** | Testing & Validation | PX_TC03 *(NEW)* | PX_ValidateTenantIsolationEvidenceInProd *(Playwright + Postman)* |

**Total test cases: 73 across 22 playbook phases** (was 55 across 20 phases in v2.0)

<br>

## 15. Summary of Changes from v2.0

| # | Change | Reason |
|---|--------|--------|
| 1 | Added **STAGE** environment between QAR and PROD | Aligns with CCP backlog (every Phase 3.x–6 epic now has a STAGE story); STAGE provides PROD-cutover rehearsal |
| 2 | Added **Phase 3.4 — Connect to AWS Servers** (Owner: Erik) | New epic CCP-1545; server reachability was previously implicit |
| 3 | Restructured **Phase 4** from 2 phases to 5 phases (4, 4.1, 4.2, 4.3, 4.4) | Aligns with CCP backlog: Setup SQL Servers, Bring COM DB Offline PROD, Backup/Restore, Windward Shrink, Replication |
| 4 | Renamed **Phase 5** to "Deploy WW1.0 and Config" (Owner: Dan Hobert) | Matches CCP-1572 epic title |
| 5 | Consolidated **Phase 6** to "Deploy Domain Services" (Owner: Eileen Dillon) | Matches CCP-1577 epic structure (per-environment rather than per-service epics) |
| 6 | Added **KCL Group API** as a Phase 6 service | New epics CCP-1618 through CCP-1622 |
| 7 | Added **tenant-isolation testing** for KCL Windward iteration | Maria Gaffney's iteration (CCP-1616) modifies KCL Windward to show only KCL data on designated pages |
| 8 | Renamed **Phase 7** to "TWS / IWS Jobs" and added standardized-package validation | T4 workstream is migrating 1,775 jobs to standardized engineering model |
| 9 | Updated owners throughout (Erik, Alex Tang, Jamie, Vasudha, Nabeel, Dan Hobert, Eileen Dillon, Hetal) | Matches current CCP assignees |
| 10 | Added Provider Domain blocker note to Phase 6 Business Service | 13 of 17 Business Services blocked; only 4 testable end-to-end |
| 11 | Added **STS AssumeRole** test case and credential-refresh risk | Carry-forward from CCP-1437 and ongoing Postman work |
| 12 | Expanded test case count from 55 to 73 across 20 → 22 phases | New phases + new tenant-isolation, replication, and standardization tests |

<br>

## 16. Review History

| Version | Date | Author | Description |
|---------|------|--------|-------------|
| 1.0 | 2026-03-02 | SQA | Initial version — created from Playbook Phases 1–6.3 |
| 2.0 | 2026-03-31 | SQA | Updated scope to include Phases 7–9 and Phase X; added 20 new test case mappings |
| 3.0 | 2026-05-21 | SQA | Aligned to current CCP backlog: added STAGE environment, added Phase 3.4, restructured Phase 4 (5 sub-phases), renamed Phase 5, consolidated Phase 6 with KCL Group API addition, added tenant-isolation testing, refreshed owners, added Provider Domain blocker context |
