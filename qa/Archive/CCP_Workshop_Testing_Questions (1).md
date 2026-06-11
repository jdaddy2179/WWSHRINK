# CCP Workshop — Executive Testing Questions

*Prepared for the week of April 13–19, 2026*

---

## 1. Environments & Release Paths

- What environments (Dev, QA, Staging, Pre-Prod, Prod) are in scope, and is each one provisioned and baselined today?
- How will release promotion work between environments — manual gates, automated pipelines, or a combination?
- Do we have environment parity, or are there known configuration drift issues that could cause "works in QA, fails in Prod" scenarios?
- What is the rollback strategy if a release fails validation in a higher environment?
- How are hotfix and emergency release paths handled differently from standard releases?
- Who owns environment refresh schedules, and how will test data be kept in sync across environments?

---

## 2. Database Migration

- What is the data validation strategy to confirm completeness and accuracy post-migration (row counts, checksums, reconciliation reports)?
- How are we handling schema changes, and have backward-compatibility tests been defined?
- What is the expected downtime window, and have we rehearsed the migration end-to-end in a lower environment?
- Are there data transformation or cleansing rules applied during migration, and how are those independently verified?
- How will referential integrity and foreign key constraints be validated after cutover?
- What is the fallback plan if data corruption is detected post-migration?

---

## 3. Product Support

- How will support teams validate that existing ticket workflows and escalation paths function correctly in the new platform?
- Are there regression tests covering the top 20 most common support scenarios?
- What is the plan for parallel-run testing — will support cases be processed in both old and new systems simultaneously?
- How are SLA timers, notifications, and routing rules being tested?
- Do support tools (knowledge base, chat, telephony integrations) have dedicated integration test suites?

---

## 4. NBI Workflow & UAT Environment

- Is the UAT environment an accurate replica of production in terms of configuration, integrations, and data volume?
- Who are the designated UAT testers, and have they been trained and given documented test scripts?
- What are the formal UAT entry and exit criteria?
- How are UAT defects being triaged — what severity threshold blocks go-live?
- Is there a sign-off process with business stakeholders, and what does the approval chain look like?
- How are NBI workflow edge cases (exceptions, manual overrides, approvals) being tested?

---

## 5. Data Quality Tool & Papercuts

- What data quality rules (completeness, uniqueness, timeliness, validity) are being enforced, and are they automated?
- How are "papercut" issues (minor UX friction, formatting bugs, label mismatches) being cataloged and prioritized?
- Is there a threshold for acceptable data quality scores at go-live?
- Are data quality checks running continuously in lower environments, or only on-demand?
- How do we differentiate between a data quality defect and a migration defect?
- What monitoring or dashboarding will exist in production to catch data quality regressions early?

---

## 6. Testing / Automation, Right-Sizing & Performance

- What percentage of test cases are automated today, and what is the target by go-live?
- Which test automation framework and tools are being used, and are they integrated into the CI/CD pipeline?
- Have performance baselines been established for critical transactions (response time, throughput, concurrency)?
- What load and stress testing scenarios have been defined, and do they reflect realistic production traffic patterns?
- How are we right-sizing test coverage — are we using risk-based testing to focus effort on high-impact areas?
- What is the performance NFR (non-functional requirement) threshold that constitutes a pass vs. fail?
- Are there endurance/soak tests planned to catch memory leaks and degradation over time?

---

## 7. Reporting & Business Intelligence

- Have all critical business reports been identified, and do we have expected-result baselines for comparison testing?
- How are calculated fields, aggregations, and business logic in reports being independently validated?
- Are report performance tests in place for large data sets (month-end, quarter-end, year-end volumes)?
- How will scheduled/automated report generation and distribution be tested?
- Is there a reconciliation process to compare legacy reporting output against new platform output?
- Who is responsible for validating that dashboards and KPIs match executive expectations?

---

## 8. Cost

- How are cost calculations and pricing rules being validated — unit tests, integration tests, or both?
- Is there a reconciliation between the old cost model outputs and the new platform's outputs?
- Have edge cases been tested (zero-quantity, negative adjustments, multi-currency, tax rules)?
- What is the test plan for cost-related integrations (ERP, billing, invoicing)?
- How are rounding rules and decimal precision being verified across the system?

---

## Cross-Cutting Questions for All Tracks

- **Defect Management:** What tool and workflow are we using to track defects, and what is the current open-critical count?
- **Test Data:** Is there a synthetic test data strategy, or are we relying on sanitized production data?
- **Integration Testing:** How are cross-track dependencies being tested (e.g., a database migration that impacts reporting)?
- **Go/No-Go Criteria:** What are the measurable, agreed-upon criteria that must be met before go-live?
- **Risk Register:** What are the top 3 testing risks per track, and what mitigations are in place?
- **Regression Strategy:** After each sprint or release, what is the regression testing approach?

---

*Tip: Use this document as a discussion guide. Flag any question where the answer is "we haven't decided yet" — those are your highest-priority action items.*
