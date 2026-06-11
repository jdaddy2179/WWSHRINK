# SQA Overview – Testing Landscape

## NGPP (Next Gen Provider Portal)

### Front End Testing
- **Tool:** Playwright
- **Tests:** 500+ automated Playwright tests
- **Approach:** Automated regression via Playwright test suites
- **Suites:** NGPP GOV Playwright Regression (providerDetailsTest, locationDetailsTest, practiceProfileTest, billedAmountsTest, preAuthorizationsTest, claimsTest, userProfileTest, etc.)

### Back End Testing
- **Tool:** Postman
- **Tests:** Close to 1,000 automated API tests across all 3 layers
- **API Layers (3-tier architecture):**
  1. **Domain** – core data/entity APIs
  2. **Business Service** – business logic/orchestration APIs
  3. **BFF (Backend for Frontend)** – portal-facing aggregation APIs

### Maturity: **Advanced** – Full automation across front end and API layers

---

## WW (Windward / Legacy Platform)

### Front End Testing
- **Smoke Tests:** Playwright (~200 tests)
- **Regression Tests:** Legacy Selenium suite (still in use)

### UAT
- SL Integration test plan (3,170 test cases across 10 suites): NetworkStacking UAT, WW Adjudication Enhancements, Dental Claim Migration, Group & Product Set up, Member Eligibility Integration, Integrated Dental Network, WW Ancillary Systems, Route SL Claims to WW, Reporting and Analytics

### Maturity: **Moderate** – Mix of modern (Playwright smoke) and legacy (Selenium regression)

---

## Front End Portal Testing

- **Tools:** Playwright + Postman
- **Scope:** 1,834 test cases across suites including Registration/Login, Membership, Provider, Prior Auth, ClaimSubmission, Documents/EOB, Case, Portal Admin, and more
- **Maturity:** **Advanced** – Portals are more mature than Data Migration, Oracle Testing, etc.

---

## Finance Testing

- **Approach:** Completely Manual
- **Maturity:** **Low** – No automation in place

---

## Claims Ops

- **Approach:** Leverages automation built by 8West and the Data Quality Tool
- **Maturity:** **High** – Leverages 8West automation and Data Quality Tool

---

## EE (Employee Experience) Testing

- **Owner:** Mike Duhamel's team
- **Maturity:** Managed separately

---

## Internal APIs

- **Tool:** Postman
- **Maturity:** **Medium** – API testing via Postman

---

## SF (Special Functions) Testing

- **Owner:** Jesus Jimenez's team
- **Approach:** Some automated tests in place
- **Maturity:** **Low–Medium** – Some automation, details TBD

---

## Data Migration

- **Approach:** No real automation; no embedded SQA in teams
- **Maturity:** **Low** – Manual processes

---

## Correspondence

- **Approach:** No real automation; no embedded SQA in teams
- **Maturity:** **Low** – Manual processes

---

## UM (Utilization Management)

- **Approach:** No real automation; no embedded SQA in teams
- **Maturity:** **Low** – Manual processes

---

## CDM (Client Data Management)

- **Approach:** No automation
- **Maturity:** **Low** – Manual processes

---

## Maturity Summary

| Area | Automation Level | Primary Tools |
|---|---|---|
| NGPP | High | Playwright, Postman |
| WW Smoke | High | Playwright (~200) |
| WW Regression | Medium (Legacy) | Selenium |
| Portal Front End | High | Playwright, Postman |
| Internal APIs | Medium | Postman |
| SF Testing | Low–Medium | Some automation (Jesus Jimenez) |
| Finance | None | Manual |
| Claims Ops | High | 8West automation, Data Quality Tool |
| Data Migration | None | Manual, no embedded SQA |
| Correspondence | None | Manual, no embedded SQA |
| UM | None | Manual, no embedded SQA |
| EE Testing | Separate team | TBD |
| CDM | None | Manual, no automation |