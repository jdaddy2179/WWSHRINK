# Windward Infrastructure Variables — Kansas City Life (KCL)

**Application (CMDB):** Windward · **Tenant:** Kansas City Life (`KCL`) · **Country:** US · **Account Type:** Single-Tenant · **Tier:** Tier 3

Variables are grouped by **Playbook Phase**. Each value type is marked **Manual** (entered by hand), **Fixed** (constant across clients), or **Generated** (produced by formula or by the Terraform/AWS build).

---

## Phase 1 — Client Info & Fixed Data

### Client Info / AWS Account

| Key | Value | Type | Notes |
|---|---|---|---|
| Single or Multi Tenant | Single-Tenant | Manual | |
| Client Member Count | 97,210 total / 81,211 active | Manual | As of Jan 2026, the SL Employee Plan has 15,172 members on Production (per AJ) |
| Tier | Tier 3 | Manual | 5,100 < 100,000 → Tier 3. Tier 3 chosen for the Pilot project. |
| Tenant Name | Kansas City Life | Manual | Need a way to distinguish Single vs Multi Tenant names; ideally one account per tenant (per AJ) |
| Tenant ID | KCL | Manual | 3 characters |
| Tenant Country Code | US | Manual | |
| Cost Center (2026 only) | 410096 | Manual | Zion to confirm Finance code with Finance team |
| ATG (Application Technology Group) | ATG0004932 | Manual | |
| New or Existing role | Existing | Manual | Use `aws-oktaSSO` as the base to create client roles |

### Fixed Data (constant across environments)

| Key | Value |
|---|---|
| Primary Owner | Paul.Bressi@greatdentalplans.com |
| Secondary Owner | DL-DQ-IT-CloudHostingAll@greatdentalplans.com |
| Support Group | SN-AD&S Production Support Dev |
| Account Type | workload |
| Application (CMDB) | Windward |

| Key | PROD | QAR | DEV |
|---|---|---|---|
| Environment | PROD | QAR | DEV |
| Environment Prefix | P | T | D |
| Server Number | 01, 02, 03, 04 … n | 01, 02, 03, 04 … n | 01, 02, 03, 04 … n |

---

## Phase 2 — AWS Account

| Key | PROD | QAR | DEV | Type |
|---|---|---|---|---|
| AWS Accounts | Dental-KCL-PROD-US | Dental-KCL-QAR-US | Dental-KCL-DEV-US | Generated |
| Account ID | *(TBD)* | *(TBD)* | *(TBD)* | Manual |
| IAM role name | *(TBD)* | *(TBD)* | *(TBD)* | Manual |

**AWS account name formula:** `Dental-[Tenant ID]-[Environment]-[Tenant CountryCode]`
- Alphanumeric only; max 24 characters; `-` is the only permitted delimiter
- Must end in `[Environment]-[Tenant CountryCode]`; Tenant ID ≤ 3 characters
- Validation blocks country codes / environments appearing inside the name (e.g. `something-ca-app-stage` fails on `-ca-` and `-stage`)
- Lindsay (Cloud Infra) confirmed account names can be updated, but it requires a request to SL CCOE

**Deployment variables (DEV) — ⚠️ several pending confirmation:**

| Resource | Value | Status |
|---|---|---|
| S3 Bucket | `dental-sle-dev-us-bucket` | ⚠️ Pending |
| KMS Key | `arn:aws:kms:us-east-1:150411087997:key/e63893cb-0cae-476a-9c2c-2713fa9efe6f` | ⚠️ Pending |
| OpenSearch | `arn:aws:es:us-east-1:150411087997:domain/dq-opensearch-domain-sle-dev` | ✅ Confirmed |
| Subnets | `subnet-01750da7ab47b56ba`, `subnet-0c9c3d254845b024f` | ⚠️ Pending — verify correct subnets |
| VPC Endpoint | `vpce-05342fe8ac2cc92e7` | ⚠️ Pending — shared across all envs; confirm it applies here |
| Security Group | `sg-0620027ab94b078bd` | ⚠️ Pending — verify correct SG |

---

## Phase 3 — Windward Servers & Network

> **Server name formula:** `AWSWW2SQL[Tenant ID][Server Number][Environment Prefix]` — alphanumeric only, max 15 chars, no dashes, Tenant ID ≤ 3 chars. WW1/WW2 are interchangeable depending on Windward config (a technical detail Infra/DBAs can adjust). Most IPs are `tbd` for PROD/QAR until the Terraform build generates them.

### Reporting Server (WW1)

| Key | PROD | QAR | DEV | Type |
|---|---|---|---|---|
| windward-reporting-server-standard | AWRSSQLKCL01P | AWRSSQLKCL01T | AWRSSQLKCL01D | Generated |
| windward-reporting-server-standard-ip | tbd | tbd | 10.222.41.34 | Manual |

### Database Servers (WW1)

| Key | PROD | QAR | DEV | Type |
|---|---|---|---|---|
| windward-database-server | AWWW2SQLKCL01P | AWWW2SQLKCL01T | AWWW2SQLKCL01D | Generated |
| windward-database-server-ip | tbd | tbd | 10.222.37.185 | Manual |
| windward-database-failover-server-passive | AWWW2SQLKCL02P | AWWW2SQLKCL02T | AWWW2SQLKCL02D | Generated |
| windward-database-failover-server-passive-ip | tbd | tbd | 10.222.36.131 | Manual |
| windward-database-read-only-server | AWWW2SQLKCL03P | AWWW2SQLKCL03T | AWWW2SQLKCL03D | Generated |
| windward-database-read-only-server-ip | tbd | tbd | 10.222.37.155 | Manual *(Erik, CCP-96 comments)* |

### Database Listener Aliases

| Key | PROD | QAR | DEV | Type |
|---|---|---|---|---|
| windward-database-server-listener-alias | KCLPRDWWSQL01 | KCLQARWWSQL01 | KCLDS11WWSQL01 | Generated |
| windward-database-read-only-server-alias | KCLPRDWWSQL02 | KCLQARWWSQL02 | KCLDS11WWSQL02 | Generated |

*(Alias pattern: `SLEDS11WWSQL01` for DB servers 1 & 2; `SLEDS11WWSQL02` for DB servers 3 & 4.)*

### Clusters

| Key | PROD | QAR | DEV | Type |
|---|---|---|---|---|
| cluster1 | AWWW2SQLKCLCL01P | AWWW2SQLKCLCL01T | AWWW2SQLKCLCL01D | Generated |
| cluster1-ip-1 | | | 10.222.36.53 | Manual |
| cluster1-ip-2 | | | 10.222.37.137 | Manual |
| cluster1-agip-2 | | | 10.222.36.91 | Manual |
| cluster2 | AWWW2SQLKCLCL02P | AWWW2SQLKCLCL02T | AWWW2SQLKCLCL02D | Generated |
| cluster2-ip-1 | | | 10.222.36.25 | Manual |
| cluster2-ip-2 | | | 10.222.42.23 | Manual |

### Listeners

| Key | PROD | QAR | DEV | Type |
|---|---|---|---|---|
| listener1 | AWW2SQLKCLLS01P | AWW2SQLKCLLS01T | AWW2SQLKCLLS01D | Generated |
| listener1-ip-1 | | | 10.222.43.72 | Manual |
| listener1-ip-2 | | | 10.222.36.91 | Manual |
| listener2 | AWW2SQLKCLLS02P | AWW2SQLKCLLS02T | AWW2SQLKCLLS02D | Generated |
| listener2-ip-1 | | | 10.222.43.185 | Manual |
| listener2-ip-2 | | | 10.222.37.108 | Manual |

### On-Prem Database / Replication (WW1)

| Key | PROD | QAR | DEV | Type |
|---|---|---|---|---|
| windward-onprem-database-distribution-server | tbd | tbd | tbd | Manual |
| windward-onprem-database-distribution-server-ip | | | 10.222.34.126 | Manual |
| windward-onprem-replication-server-existing | tbd | tbd | tbd | |
| windward-onprem-replication-server-existing-ip | | | | |

### Application Servers (WW1)

| Key | PROD | QAR | DEV | Type |
|---|---|---|---|---|
| windward-app-server1 (Utility) | AWWW1APPKCL01P | AWWW1APPKCL01T | AWWW1APPKCL01D | Generated *(confirm app-server names with Dan Hobert)* |
| windward-app-server1Utility-ip | tbd | tbd | 10.222.36.212 | Manual *(Erik, CCP-96)* |
| windward-app-server2 | AWWW1APPKCL02P | AWWW1APPKCL02T | AWWW1APPKCL02D | Generated |
| windward-app-server2-ip | tbd | tbd | 10.222.37.56 | Manual *(Erik, CCP-96)* |
| windward-app-server3 | AWWW1APPKCL03P | AWWW1APPKCL03T | AWWW1APPKCL03D | Generated |
| windward-app-server3-ip | tbd | tbd | 10.222.36.215 | Manual *(Erik, CCP-96)* |

### Web Servers (WW1)

| Key | PROD | QAR | DEV | Type |
|---|---|---|---|---|
| windward-web-server1 | AWWW1WEBKCL01P | AWWW1WEBKCL01T | AWWW1WEBKCL01D | Generated *(Kerberos config)* |
| windward-web-server1-ip | tbd | tbd | 10.222.36.176 | Manual *(Erik, CCP-96)* |
| windward-web-server2 | AWWW1WEBKCL02P | AWWW1WEBKCL02T | AWWW1WEBKCL02D | Generated *(Kerberos config)* |
| windward-web-server2-ip | tbd | tbd | 10.222.36.243 | Manual *(Erik, CCP-96)* |

### Windward 2 Servers (WW2)

| Key | PROD | QAR | DEV | Type |
|---|---|---|---|---|
| windward2-web-server1 | AWWW2WEBKCL02P | AWWW2WEBKCL02T | AWWW2WEBKCL02D | Generated |
| windward2-web-server1-ip | tbd | tbd | 10.222.36.141 | Manual *(Erik, CCP-96)* |
| windward2-app-server1 | AWWW2APPKCL02P | AWWW2APPKCL02T | AWWW2APPKCL02D | Generated |
| windward2-app-server1-ip | tbd | tbd | 10.222.37.27 | Manual *(Erik, CCP-96)* |

### Load Balancers (Physical ALB)

| Key | PROD | QAR | DEV | Type |
|---|---|---|---|---|
| ALB-Physical-LoadBalancer | loadbalancername(P) | loadbalancername(T) | internal-web-alb-dev-1226259626.us-east-1.elb.amazonaws.com | Manual |
| ALB-Physical-LoadBalancer-ip | loadbalancerIP(P) | loadbalancerIP(T) | 203.0.113.47 | Manual |

> ⚠️ **Note:** ALBs stopped functioning for technical reasons, so the Infra team switched to **NLBs** (see Phase 3.2). Load balancer values must be documented after the Terraform build generates them in AWS.

---

## Phase 3.2 — HTTPS Aliases, OAG & NLB

| Key | PROD | QAR | DEV | Type |
|---|---|---|---|---|
| windward1-webserver-https-alias | KCL-windward.dq.ad | KCL-QAR-windward.dqtest.ad | KCL-DS11-windward.dqdev.ad | Generated *(Kerberos config)* |
| okta-and-loadbalancer (OAG_LB) | *(blank)* | *(blank)* | *(blank)* | Manual |
| windward-app-nlb-loadbalancer-tcp-alias | KCL-NLB-windward-app-P | KCL-NLB-windward-app-T | KCL-NLB-windward-app-D | Generated |
| windward-app-utility-https-alias | KCL-windward-app-utility.dqdev.ad | KCL-QAR-windward-app-utility.dqdev.ad | KCL-DS11-windward-app-utility.dqdev.ad | Generated |
| config-webserver-https-alias | KCL-config-windward.dq.ad | KCL-QAR-config-windward.dqtest.ad | KCL-DS11-config-windward.dqdev.ad | Generated |
| payment-webserver-https-alias | KCL-payment-windward.dq.ad | KCL-QAR-payment-windward.dqtest.ad | KCL-DS11-payment-windward.dqdev.ad | Generated |

**windward-app-NLB-loadbalancer listener** (Manual) — PROD: TBD · QAR: TBD · DEV:
- Load balancer: `app-nlb-tls-dev`
- DNS: `app-nlb-tls-dev-e3cda78e760aea79.elb.us-east-1.amazonaws.com`

---

## Phase 4.3 — Windward Database Names & Group Data ("WW Shrink")

| Key | PROD | QAR | DEV | Type |
|---|---|---|---|---|
| WindwardDatabaseName | tbd | tbd | Windward_KCL | Generated |
| ConfigDatabaseName | tbd | tbd | Windward_Config_KCL | Generated |
| PaymentDatabaseName | tbd | tbd | Windward_Payment_KCL | Generated |
| Purchaser_ID | 090033 | 090033 | 090033 | Manual |
| Parent_Group_ID | 0900331001 | 0900331001 | 0900331001 | Manual |

**Sub_Groups** (identical across all environments, Manual):
`0900332001`, `0900332002`, `0900332003`, `0900332004`, `0900332005`, `0900332006`, `0900332007`, `0900332008`, `0900332009`, `0900332010`, `0900332011`, `0900332012`

*Purchaser, parent group, and sub-group values provided by DQ business — Mandy Wills.*

---

## Phase 6 — Domain Services, API Gateways & Secrets

### Domain Services

| Key | PROD | QAR | DEV |
|---|---|---|---|
| Member Domain SQL Authentication Login | TBD | TBD | TBD |
| Member Domain SQL Authentication PW *(Secret)* | TBD | TBD | TBD |
| Member Domain ALB | TBD | TBD | TBD |
| Member Domain URL | TBD | TBD | TBD |
| Claim Domain URL | TBD | TBD | TBD |

### API Gateway IDs (DEV — Generated)

> URL pattern: `https://<API ID>-vpce-05342fe8ac2cc92e7.execute-api.us-east-1.amazonaws.com/<dev|qar>`

| API | DEV API Gateway ID |
|---|---|
| business-services-billed-amounts-api-dev | qrczz0ijyj |
| business-services-digital-id-media-api-dev | r4lhjd5oed |
| slf-aws-dental-claims-foundational-api | 2c1vkicqm5 |
| slfdq-aws-business-services-api | mya9v9kkz1 |
| slfdq-aws-business-services-member-benefits-api | porch1kpt9 |
| slfdq-aws-claim-submission-business-services-api | x2eyrs3pvj |
| slfdq-aws-claim-tpe-business-services-api | pawfvmxkz5 |
| slfdq-aws-document-management-business-services-api | uzj25l1wo7 |
| slfdq-aws-member-eligibility-business-services-api | j6nqqq9i5d |
| slfdq-aws-member-ivr-faxback-business-services-api | fuo2lkx4bc |
| slfdq-aws-user-management-business-services-api | qikx56cqpe |

### Secrets & Connection Strings (DEV)

**WINDWARD_DATABASE_SECRET_ARN_SLE** (domain-member && domain-product):
`arn:aws:secretsmanager:us-east-1:150411087997:secret:ds11/com/foundationalsql-uO6ROx`

**WINDWARD_CONNECTION_SLE** (domain-member && domain-product):
```
Server=SLEDS11WWSQL01.dqdev.ad;Database=Windward_Commercial;Application Name=Foundational - DomainApi - Member;TrustServerCertificate=True;MultiSubnetFailover=True
```

---

### Legend

| Type | Meaning |
|---|---|
| **Manual** | Entered by hand |
| **Fixed** | Constant across all clients |
| **Generated** | Produced by naming formula or by the Terraform / AWS build |

*Status markers:* ✅ Confirmed · ⚠️ Pending confirmation · *tbd / TBD* — value not yet generated or assigned.
