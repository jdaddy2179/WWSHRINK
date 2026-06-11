# High-Level Test Strategy
## Commercial Client Pilot — AWS Onboarding

<br>

## 1. Purpose

This document defines the high-level test strategy for validating each phase of the Commercial Client Pilot onboarding playbook. It provides a structured testing approach that aligns to the playbook phases (Phases 1–9, Phase X), defines what must be tested, who is responsible, and what criteria determine pass or fail for each phase gate.

The playbook phases are operational and delivery steps; this strategy defines how quality is assured at each gate before the next phase begins.

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
- Database setup, restoration, and connectivity (Phases 4, 4.1)
- Application deployment: Windward Web, Core DB, supporting APIs (Phase 5)
- Domain service deployments: Member, Claims, Business Service, Data Publisher (Phase 6 with 4 steps)
- TWS Jobs configuration and execution (Phase 7)
- Correspondence Letter, EDI, EE Portal, Member Portal, Mobile App setup (Phases 7.1, 7.2, 7.3, 7.4, 7.5)
- Oracle integration setup (Phase 8)
- Disaster Recovery planning and validation (Phase 9)
- Test execution and validation coordination (Phase X)
- Multi-environment validation: DEV, QAR, and PROD (sequentially)

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
| 3 | Validate network and security configurations (DNS, load balancers, TLS certificates, InfoSec) |
| 4 | Confirm databases are restored, connected, and sized correctly |
| 5 | Verify all deployed applications and services are accessible, healthy, and connected |
| 6 | Ensure validation is repeatable across all three environments (DEV → QAR → PROD) |
| 7 | Establish a documented test record per tenant onboarding to support future audits |

<br>

## 4. Test Environments

Environments are provisioned sequentially. Validation must be completed and approved in each environment before the next is provisioned.

| Environment | Purpose | Data Sensitivity | Validation Order |
|-------------|---------|-----------------|-----------------|
| **DEV** | Development and initial smoke testing | No PHI | First |
| **QAR** | Quality assurance and integration testing | May contain PHI | Second |
| **PROD** | Production — live tenant traffic | PHI present | Third |

> **Important:** Do not begin QAR validation until DEV validation is signed off. Do not begin PROD validation until QAR is signed off.

<br>

## 5. Automation Approach

The goal is to use existing automated test suites wherever possible. Automation reduces manual effort, provides consistent coverage across DEV / QAR / PROD, and shortens the validation cycle for each new tenant onboarding.

| Phase Scope | Automation Tool | What It Covers | When to Fall Back to Manual |
|-------------|----------------|----------------|----------------------------|
| **Phase 5 — WW Applications** | **Playwright** | URL accessibility, application health endpoints, UI-driven DB connectivity checks | If Playwright suite is not yet configured for the new tenant environment; if a test requires a configuration-level check not covered by existing tests |
| **Phase 6 — Member Domain Service** | **Postman** | Health endpoint, service connectivity to S3 / SQS / OpenSearch | If Postman environment is not yet configured for the tenant; if dependency (OpenSearch, KMS) is not yet available |
| **Phase 6.1 — Claims Domain Service** | **Postman** | Health endpoint, DynamoDB / OpenSearch / SQS connectivity assertions | If Postman environment is not yet configured; if required variables are not yet set |
| **Phase 6.2 — Business Service** | **Postman** | Health endpoint, upstream/downstream service connectivity | If Postman environment is not yet configured for the tenant |
| **Phase 6.3 — Data Publisher** | **Postman** | S3 write/read connectivity, service health | If Postman environment is not yet configured; if CDP credentials are not yet available |
| **Phase 7 — TWS Jobs** | Manual + Jira | Job configuration validation, execution schedule review | N/A — configuration tracked in Jira |
| **Phases 7.1–7.5 — Specialty Services** | Manual + Jira | Service deployment validation per phase specifics | Manual testing required until automation frameworks established |
| **Phase 8 — Oracle Integration** | Manual + Jira | Oracle connectivity and integration validation | Manual testing required; Oracle team provides verification |
| **Phase 9 — Disaster Recovery** | Manual | DR planning documentation, backup/restore validation | Manual testing required; Infrastructure team leads validation |
| **Phases 1–4 (infra/data)** | Manual only | Spreadsheet validation, AWS console checks, DNS lookups, certificate inspection | N/A — no existing automation for these phases |

> **Pre-condition for automation:** Before running Playwright or Postman suites, the tester must configure the environment-specific base URLs and credentials using the values from the Environment Variables spreadsheet. Do not run automation against an environment that has not yet passed its infrastructure and deployment prerequisites.

<br>

## 6. Test Types

| Test Type | Description | Execution | Primary Phases |
|-----------|-------------|-----------|----------------|
| **Data Validation** | Verify completeness and accuracy of Environment Variables spreadsheet inputs | Manual | 1, 2 |
| **Provisioning Validation** | Confirm AWS resources (accounts, servers, load balancers) exist with correct names and configuration | Manual | 2, 2.1, 3, 3.1 |
| **Security & Certificate Validation** | Confirm SSL/TLS certificates are attached, InfoSec controls are in place | Manual | 3.2, 3.3 |
| **Database Validation** | Confirm databases are restored, accessible, and correctly sized | Manual | 4, 4.1 |
| **Deployment Smoke Testing** | Verify each application and service is running and reachable | Playwright (Phase 5) / Postman (Phase 6+) / Manual fallback | 5, 6, 6.1, 6.2, 6.3 |
| **Connectivity & Integration Testing** | Validate app-to-DB, service-to-service, and load balancer routing | Playwright (Phase 5) / Postman (Phase 6+) | 5, 6, 6.1, 6.2, 6.3 |
| **Configuration Validation** | Verify environment-specific settings match expected values from the spreadsheet | Manual (config files) + Postman (runtime assertions) | 5, 6, 6.1, 6.2, 6.3 |

<br>

## 6. Test Strategy by Playbook Phase

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

**What to Test:** Correct IAM roles exist and authorized users can access the new AWS accounts.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| Required IAM roles created (new or existing, per Environment Variables) | AWS console review | SQA / Cloud Infra |
| Authorized team members can log in to each AWS account via Okta SSO | Access test | SQA |
| Role permissions are scoped correctly (not over-privileged) | IAM policy review | InfoSec / Cloud Infra |

**Exit Criteria:** AWS access confirmed for all required roles and team members.

---

### Phase 3 — Provision Tenant Infrastructure

**What to Test:** All expected AWS EC2 servers exist and follow correct naming conventions.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| All expected servers appear in EC2 "Instances (running)" for DEV, QAR, PROD | AWS Console → EC2 | SQA |
| Server names match naming conventions in Environment Variables spreadsheet | Side-by-side comparison | SQA |
| Server counts match expected Tier architecture (Tier 1 / 2 / 3) | Architecture doc vs. AWS | SQA |
| Instance state is "Running" (not stopped, pending, or terminated) | AWS Console status check | SQA |
| System Status Check and Instance Status Check both pass | EC2 status checks tab | SQA |

**Exit Criteria:** All servers running, correctly named, and status checks passed — for each environment validated.

---

### Phase 3.1 — Information Security

**What to Test:** Required InfoSec controls are implemented and evidence is captured.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| Access and permissions reviewed and confirmed per InfoSec requirements | Access review documentation | InfoSec / SQA |
| Required security evidence captured and stored | Evidence package review | InfoSec |
| Security findings documented and remediation tracked | InfoSec review sign-off | InfoSec |

**Exit Criteria:** InfoSec sign-off received; evidence package complete.

---

### Phase 3.2 — Load Balancers and DNS Aliases

**What to Test:** Load balancer details documented and DNS CNAME aliases are correctly configured.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| ALB and NLB physical names and IPs documented in Environment Variables spreadsheet | Spreadsheet review | SQA |
| ServiceNow DNS Change ticket submitted with correct alias-to-server mappings | Ticket review | SQA |
| DNS CNAME aliases resolve to correct load balancer endpoints | `nslookup` / DNS lookup tool | SQA / Network |
| DNS aliases match the expected naming from Environment Variables spreadsheet | DNS lookup vs. spreadsheet | SQA |

**Exit Criteria:** ServiceNow ticket closed; all DNS aliases resolve correctly.

---

### Phase 3.3 — SSL/TLS Certificates

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

### Phase 4 — Setup Databases

**What to Test:** Databases are restored on provisioned servers and accessible.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| All required databases are restored on correct database servers | DBA verification | DBA / SQA |
| Database server connectivity verified (port, hostname, credentials) | Connection test | DBA |
| Database integrity checks pass (no corruption) | DBCC or equivalent | DBA |
| Correct databases are available per environment (DEV, QAR, PROD) | DB instance list review | DBA / SQA |

**Exit Criteria:** All databases restored, accessible, and integrity-verified per environment.

---

### Phase 4.1 — Database Right Sizing

**What to Test:** Database server sizing (compute, storage) matches Tier requirements.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| Database server instance type matches Tier specification in architecture docs | AWS console vs. architecture | DBA / SQA |
| Storage allocation is sufficient for expected data volume | Disk usage check | DBA |
| Sizing confirmed and approved by DBA team | DBA sign-off | DBA |

**Exit Criteria:** Sizing confirmed correct for the tenant's Tier.

---

### Phase 5 — Deploy Windward Applications

**What to Test:** All Windward-related applications (Web, APIs, Core DB connections) are deployed, accessible, and functional.

**Automation:** Use the existing **Playwright** test suite for URL accessibility, health endpoint, and UI-driven connectivity checks. Configure Playwright with the tenant environment URL from the Environment Variables spreadsheet before execution. Fall back to manual steps only if Playwright is not yet configured for the new environment.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| Jira/ADO deployment tickets are resolved | Manual — ticket status | SQA |
| EC2 instances for application servers are in "Running" state | Manual — AWS Console | SQA |
| System and Instance status checks pass on app servers | Manual — EC2 status checks | SQA |
| Application URL loads successfully and health endpoints return healthy status | **Playwright** — existing smoke test suite | SQA |
| Load balancer target group shows all targets as "healthy" | Manual — AWS Console → Target Groups | SQA |
| Application can connect to the database (UI-driven query returns data) | **Playwright** — existing DB connectivity tests | SQA |
| Application is pointing to correct database and service endpoints | Manual — AppSettings review | SQA / App Team |

**Exit Criteria:** All applications running, Playwright suite passes with no failures, LB targets healthy, DB connected.

---

### Phase 6 — Deploy NextGen Services

**Overview:** Phase 6 consists of 4 independent deployment steps for NextGen services: Member Domain Service, Claims Domain Service, Business Service, and Data Publisher. Each step is validated independently, and all must be completed for the Phase 6 gate to close.

---

#### Phase 6 — Step 1: Member Domain Service Deployment

**What to Test:** Member Domain Service is deployed, running, and connected.

**Automation:** Use the existing **Postman** collection for Member Domain Service to validate health and connectivity. Configure the Postman environment with the tenant-specific base URL and credentials before execution.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| Deployment pipeline executed successfully (no failed tasks) | Manual — ADO pipeline status | SQA / Dev |
| Required AWS resources in place (OpenSearch, KMS keys, DynamoDB, SQS) | Manual — AWS Console review | SQA / CE Team |
| Service is running and healthy; S3 / SQS / OpenSearch endpoints reachable | **Postman** — existing Member Domain collection | SQA |
| Service logs show no critical errors on startup | Manual — CloudWatch Logs | SQA |

**Exit Criteria:** Pipeline succeeded; Postman collection passes with no failures; no critical startup errors.

---

#### Phase 6 — Step 2: Claims Domain Service Deployment

**What to Test:** Claims Domain Service pipelines deployed correctly and service is operational.

**Automation:** Use the existing **Postman** collection for Claims Domain Service. Configure the Postman environment with tenant-specific values before execution.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| All 3 Claims Domain Service pipelines executed successfully | Manual — ADO pipeline status | SQA / Dev |
| KMS keys and DynamoDB tables present and accessible | Manual — AWS Console | CE Team / SQA |
| Correct variable values used in deployment (not dummy/placeholder values) | Manual — pipeline vars review | SQA / Dev |
| Service is running and healthy; DynamoDB / OpenSearch / SQS connectivity confirmed | **Postman** — existing Claims Domain collection | SQA |
| Service logs show no critical errors on startup | Manual — CloudWatch Logs | SQA |

**Exit Criteria:** All 3 pipelines deployed with correct values; Postman collection passes with no failures.

---

#### Phase 6 — Step 3: Business Service Deployment

**What to Test:** Business Service is deployed, running, and connected to required dependencies.

**Automation:** Use the existing **Postman** collection for Business Service to validate health and upstream/downstream connectivity.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| Deployment pipeline executed successfully | Manual — ADO pipeline status | SQA / Dev |
| Database connection strings point to the correct tenant servers | Manual — pipeline vars review | SQA / Dev |
| Service health and upstream/downstream service connectivity confirmed | **Postman** — existing Business Service collection | SQA |
| Service logs show no critical errors on startup | Manual — CloudWatch Logs | SQA |

**Exit Criteria:** Pipeline succeeded; Postman collection passes with no failures.

---

#### Phase 6 — Step 4: Data Publisher Deployment

**What to Test:** Data Publisher is deployed with correct S3 bucket, access keys, and connection strings.

**Automation:** Use the existing **Postman** collection for Data Publisher to validate S3 connectivity and service health.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| Deployment pipeline executed successfully | Manual — ADO / TFS pipeline status | SQA / Dev |
| `RouteInfo.json` values correctly injected into `appsettings.json` (Bucket URL, Access Key, Secret Key, DB connection strings) | Manual — AppSettings review | SQA / Dev |
| S3 bucket accessible; CDP credentials functional; service health confirmed | **Postman** — existing Data Publisher collection | SQA / CE Team |
| Service logs show no critical errors on startup | Manual — CloudWatch Logs | SQA |

**Exit Criteria:** Pipeline succeeded; correct config applied; Postman collection passes with no failures.

---

### Phase 7 — TWS Jobs Setup and Configuration

**What to Test:** TWS job configuration is complete, connection strings are correct, and job schedules are validated.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| Jira ticket for TWS job setup created and assigned to TWS Team | Manual — Jira ticket review | SQA |
| All required job scripts configured with correct connection strings | Manual — job config review with TWS Team | TWS Team / SQA |
| Job execution schedule defined and documented | Manual — schedule review | TWS Team |
| Test job execution successful; logs show no critical errors | Manual — execution log review | TWS Team / SQA |

**Exit Criteria:** Jira ticket marked Done; job scripts configured; test execution successful.

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

**What to Test:** EDI (Electronic Data Interchange) configuration is complete and data flows are tested.

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
| Database backups configured and tested | Manual — backup restore test | DBA / Infrastructure Team |
| Backup/restore time objectives (RTO/RPO) documented and validated | Manual — recovery testing | Infrastructure Team |
| Infrastructure team sign-off on DR procedures | Manual — sign-off confirmation | Infrastructure Team |

**Exit Criteria:** DR documentation complete; backups tested; RTO/RPO validated; Infrastructure sign-off received.

---

### Phase X — Testing & Validation

**What to Test:** All onboarding phases are tested end-to-end; test results are documented and all critical issues resolved.

| Validation Check | Method | Owner |
|-----------------|--------|-------|
| Jira ticket for test execution created with links to testing documentation | Manual — Jira ticket review | SQA / Project Manager |
| SQA Team assigned and acknowledged | Manual — ticket assignment | Project Manager |
| All test cases from PlaybookTestCases.csv through Phase 9 executed | Manual — test execution tracking | SQA |
| Test results documented and reported | Manual — report review | SQA |
| All Blocker and High-priority defects resolved | Manual — defect status review | All teams |

**Exit Criteria:** All test cases executed; results documented; critical defects resolved; onboarding sign-off ready.

<br>

## 7. Environment Progression Gate

Each environment must pass validation before the next environment is provisioned. The gate applies across all phases relevant to that environment.

```
DEV Validation Complete → Cloud Infra provisions QAR
QAR Validation Complete → Cloud Infra provisions PROD
PROD Validation Complete → Onboarding sign-off
```

<br>

## 8. Roles & Responsibilities

| Role | Responsibility |
|------|---------------|
| **SQA** | Execute validation steps per phase; document results; log defects; confirm phase exit criteria met |
| **Cloud Infrastructure Team** (Erik, Lindsay) | Provision AWS accounts, servers, load balancers; respond to infrastructure defects |
| **Application Services Team** (Daniel Hobert) | Deploy applications (Phase 5); run sanity tests; respond to application defects |
| **DBA Team** (Vasudha Ramakrishnan) | Database setup, restoration, connectivity, and right-sizing validation (Phases 4, 4.1) |
| **Domain Services Team** (Venkata Nune) | Deploy and validate NextGen services (Phase 6, all 4 steps: Member, Claims, Business, Data Publisher) |
| **TWS Team** | Configure and validate TWS jobs, handle job scheduling (Phase 7) |
| **Specialty Services Team** | Deploy and validate Correspondence Letter, EDI, Portals, Mobile App (Phases 7.1–7.5) |
| **Oracle Team** | Configure and validate Oracle integration (Phase 8) |
| **Infrastructure Team** | Plan, document, and validate Disaster Recovery procedures (Phase 9) |
| **InfoSec** (Jamie Smith) | Security setup and validation (Phase 3.1) |
| **Network Team** | Load balancer and DNS configuration (Phase 3.2), certificate configuration (Phase 3.3) |
| **Project Manager** | Coordinate access requests, stakeholder availability, phase gate approvals, and test execution coordination (Phase X) |

<br>

## 9. Entry & Exit Criteria (Summary)

| Phase | Entry Criteria | Exit Criteria |
|-------|---------------|---------------|
| 1 | Client approved for onboarding; stakeholder contacts identified | Environment Variables complete and stakeholder-validated |
| 2 | Phase 1 complete | AWS accounts created; account details received |
| 2.1 | Phase 2 complete | AWS access confirmed for all required roles |
| 3 | Phases 2, 2.1 complete | All servers provisioned, running, and naming validated |
| 3.1 | Phase 3 complete | InfoSec sign-off received; security evidence captured |
| 3.2 | Phase 3 and 3.1 complete | DNS aliases configured and resolving |
| 3.3 | Phases 3, 3.1, 3.2 complete | SSL/TLS certificates attached and verified |
| 4 | Phases 3, 3.1, 3.2, 3.3 complete | Databases restored, accessible, integrity-verified |
| 4.1 | Phase 4 complete | Database sizing confirmed per Tier |
| 5 | Phase 4 complete | All applications deployed, healthy, DB-connected |
| 6 | Phase 5 complete | All 4 NextGen services deployed (Member, Claims, Business, Data Publisher) healthy |
| 7 | Phase 6 complete | TWS job tickets created and assigned |
| 7.1 | Phase 7 complete | Correspondence Letter configuration complete and validated |
| 7.2 | Phase 7.1 complete | EDI setup complete and validated |
| 7.3 | Phase 7.2 complete | EE Portal deployment complete and accessible |
| 7.4 | Phase 7.3 complete | Member Portal deployment complete and accessible |
| 7.5 | Phase 7.4 complete | Mobile App deployment complete and accessible |
| 8 | Phase 7.5 complete | Oracle integration setup complete and validated |
| 9 | Phase 8 complete | Disaster Recovery planning and validation complete |
| X | Phases 1–9 complete in all environments | Test execution complete, results documented, all critical issues resolved |

<br>

## 10. Defect Management

- Defects found during validation are logged in **Jira** on the client-specific backlog.
- Defects are assigned directly to the team responsible for the failing phase.
- **Severity levels:**

| Severity | Definition | Required Action |
|----------|-----------|----------------|
| **Blocker** | Phase exit criteria cannot be met; onboarding halted | Fix before proceeding to next phase |
| **High** | Core functionality broken but workaround exists | Fix before PROD validation |
| **Medium** | Non-critical issue; does not block phase exit | Fix before onboarding sign-off |
| **Low** | Minor or cosmetic issue | Logged; fix scheduled per team backlog |

<br>

## 11. Tools & Access Required

| Tool | Usage | Required By |
|------|-------|------------|
| SharePoint — Environment Variables spreadsheet | Data collection and validation reference | SQA, all phases |
| AWS Console (via Okta SSO) | Infrastructure and application validation | SQA, Phases 3–6 |
| Jira | Ticket tracking and defect logging | SQA, all phases |
| Azure DevOps (ADO) | Pipeline execution and deployment tracking | SQA, Phases 5–6 |
| ServiceNow | AWS account, DNS, and certificate requests | SQA, Phases 2, 3.1, 3.2 |
| CloudWatch Logs | Application log review and error diagnosis | SQA, Phases 5–6 |
| Browser / curl | URL accessibility and health endpoint testing | SQA, Phases 5–6 |
| DNS lookup tool (nslookup) | DNS alias resolution verification | SQA, Phase 3.1 |

<br>

## 12. Assumptions & Risks

| # | Assumption / Risk | Mitigation |
|---|-------------------|-----------|
| 1 | Infrastructure Team notifies SQA via Jira when provisioning is complete before validation begins | SQA monitors Jira ticket status; does not begin validation until ticket is marked Done |
| 2 | Environment Variables spreadsheet is the single source of truth for all naming and config values | All teams reference the same spreadsheet; any changes must be updated in the spreadsheet first |
| 3 | PHI data handling in QAR requires appropriate access controls and must follow privacy policies | SQA members with QAR access must be authorized; PHI handling procedures must be followed |
| 4 | Some Phase 6 services (Member, Claims, Data Publisher) require dependencies (OpenSearch, KMS keys, DynamoDB) from the CE team before deployment can be validated | CE team dependencies tracked in Jira; SQA flags blockers early |
| 5 | Validation steps for Phase 3.3 (InfoSec) and Phase 6 domain services are not yet fully detailed in the playbook | SQA works with phase owners (Jamie Smith, Venkata Nune) to finalize validation steps as phases are completed |
| 6 | New clients may require operational gap resolution for NBI process (no existing Windward record) | Project Manager to coordinate NBI process completion before Phase 1 can begin |

<br>

## 13. Test Case to Playbook Phase Mapping

The table below maps every test case in [PlaybookTestCases.csv](PlaybookTestCases.csv) to its corresponding playbook phase. Use this to confirm coverage and to identify which test cases must pass before each phase gate closes.

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
| **Phase 3** | Provision Tenant Infrastructure | P3_TC01 | P3_ValidateJiraInfraProvisioningTicket |
| **Phase 3** | Provision Tenant Infrastructure | P3_TC02 | P3_ValidateEC2ServersProvisioned |
| **Phase 3.1** | Information Security Setup | P3.3_TC01 | P3_3_ValidateInfoSecControls |
| **Phase 3.2** | Load Balancers Setup | P3.1_TC01 | P3_1_ValidateInfrastructureInventoryDocumented |
| **Phase 3.2** | Load Balancers Setup | P3.1_TC02 | P3_1_ValidateDNSCNAMETicket |
| **Phase 3.2** | Load Balancers Setup | P3.1_TC03 | P3_1_ValidateDNSAliasResolution |
| **Phase 3.3** | Attach SSL/TLS Certificates | P3.2_TC01 | P3_2_ValidateSSLCertificateTickets |
| **Phase 3.3** | Attach SSL/TLS Certificates | P3.2_TC02 | P3_2_ValidateHTTPSConnectivity |
| **Phase 4** | Setup Database | P4_TC01 | P4_ValidateDatabaseRestoration |
| **Phase 4.1** | Database Right Sizing | P4.1_TC01 | P4_1_ValidateDatabaseRightSizing |
| **Phase 5** | Deploy WW Applications | P5_TC01 | P5_ValidateApplicationDeploymentTickets *(manual)* |
| **Phase 5** | Deploy WW Applications | P5_TC02 | P5_ValidateApplicationServersRunning *(manual)* |
| **Phase 5** | Deploy WW Applications | P5_TC03 | P5_ValidateApplicationURLAccessibility_Playwright *(Playwright)* |
| **Phase 5** | Deploy WW Applications | P5_TC04 | P5_ValidateApplicationHealthEndpoints_Playwright *(Playwright)* |
| **Phase 5** | Deploy WW Applications | P5_TC05 | P5_ValidateLoadBalancerTargetHealth *(manual)* |
| **Phase 5** | Deploy WW Applications | P5_TC06 | P5_ValidateDatabaseConnectivityFromApp *(Playwright + manual)* |
| **Phase 6** | Deploy NextGen Services — Step 1: Member Domain | P6_TC01 | P6_ValidateMemberDomainAWSDependencies *(manual)* |
| **Phase 6** | Deploy NextGen Services — Step 1: Member Domain | P6_TC02 | P6_ValidateMemberDomainServiceDeployment *(manual)* |
| **Phase 6** | Deploy NextGen Services — Step 1: Member Domain | P6_TC03 | P6_ValidateMemberDomainServiceHealth_Postman *(Postman)* |
| **Phase 6** | Deploy NextGen Services — Step 2: Claims Domain | P6.1_TC01 | P6_1_ValidateClaimsDomainAWSDependencies *(manual)* |
| **Phase 6** | Deploy NextGen Services — Step 2: Claims Domain | P6.1_TC02 | P6_1_ValidateClaimsDomainServiceDeployment *(manual)* |
| **Phase 6** | Deploy NextGen Services — Step 2: Claims Domain | P6.1_TC03 | P6_1_ValidateClaimsDomainServiceHealth_Postman *(Postman)* |
| **Phase 6** | Deploy NextGen Services — Step 3: Business Service | P6.2_TC01 | P6_2_ValidateBusinessServiceDeployment *(manual)* |
| **Phase 6** | Deploy NextGen Services — Step 3: Business Service | P6.2_TC02 | P6_2_ValidateBusinessServiceHealth_Postman *(Postman)* |
| **Phase 6** | Deploy NextGen Services — Step 4: Data Publisher | P6.3_TC01 | P6_3_ValidateDataPublisherConfiguration *(manual)* |
| **Phase 6** | Deploy NextGen Services — Step 4: Data Publisher | P6.3_TC02 | P6_3_ValidateDataPublisherDeployment *(manual)* |
| **Phase 6** | Deploy NextGen Services — Step 4: Data Publisher | P6.3_TC03 | P6_3_ValidateDataPublisherS3Connectivity_Postman *(Postman)* |
| **Phase 7** | TWS Jobs Setup | P7_TC01 | P7_ValidateTWSJobConfiguration *(manual)* |
| **Phase 7** | TWS Jobs Setup | P7_TC02 | P7_ValidateTWSJobExecution *(manual)* |
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
| **Phase X** | Testing & Validation | PX_TC01 | PX_ValidateTestExecutionComplete *(manual)* |
| **Phase X** | Testing & Validation | PX_TC02 | PX_ValidateCriticalDefectsResolved *(manual)* |

**Total test cases: 55 across 20 playbook phases**

<br>

## 14. Review History

| Version | Date | Author | Description |
|---------|------|--------|-------------|
| 1.0 | 2026-03-02 | SQA | Initial version — created from Playbook Phases 1–6.3 |
| 2.0 | 2026-03-31 | SQA | Updated scope to include Phases 7–9 and Phase X; added 20 new test case mappings |
