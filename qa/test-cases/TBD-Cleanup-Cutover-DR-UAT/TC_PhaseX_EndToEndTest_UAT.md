# Test Cases — Phase X: End-to-End Test & UAT

| Field | Value |
|-------|-------|
| Playbook reference | `PhaseX_EndtoEndTest_UAT.md` (Step 1) | WS | TBD |
| Priority | **P1 — final go-live acceptance gate across all workstreams** | Type | Jira hand-off (Feature) + master test execution |
| Owner | SQA Team (Joshua Ernstoff; mgr Arun Pant) |

> The joint exit gate. Phase X is where the **functional + performance** scope (now in-scope per `TestStrategy.md` §3.1) is consolidated and where critical/high bugs must be resolved before production go-live. **This QA artifact set (`qa/`) IS the deliverable Phase X references** — the playbook expects a Test Strategy / Testing folder (it links `/Testing/TestStrategy.md` on ADO); `qa/TestStrategy.md`, the suites, and the traceability matrix are that body of work.

**Applies `TC-HO-01,04,06,08,09`** from [`TC_PATTERN_JiraHandoffPhase.md`](../_shared/TC_PATTERN_JiraHandoffPhase.md):
- **Artifact type:** Jira **Feature** (not User Story).
- **Title:** `End to end integration Testing and UAT - REF[Tenant Name]`.
- **AC:** "End-to-end Testing & UAT represented as dedicated feature, where feature covers planning and readiness for end-to-end validation".
- **Links:** Testing folder (ADO), **Test Strategy** (`/Testing/TestStrategy.md`), Env Variables.
- **Assignee:** SQA Team (Joshua Ernstoff; mgr Arun Pant).

### Preconditions
**All preceding phases (1 → 12) COMPLETE** — including any phases currently `Pending Content` / `Not QA-ready` being authored and passed first.

---

### TC-PX-01 (Gate — all phases complete): No E2E start until every prior phase passes
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm every phase 1–12 COMPLETE with its suite executed/passing (or risk-accepted) | All complete |
| 2 | Confirm placeholder phases (7.1–7.5, 8, 12) were authored & passed, not skipped on empty templates | Real coverage |

**Pass/Fail:** E2E begins only when all upstream phases genuinely pass. (Gap G7 placeholders must be resolved first.)

### TC-PX-02 (Feature + backlog built): Testing backlog, strategy, plan, cases in place
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm Jira **Feature** created (not Story) with correct title + Testing/Strategy links | Feature created |
| 2 | Confirm SQA built the testing backlog: strategy, execution plan, cases, automation (if needed) | Built |

**Pass/Fail:** Feature + complete testing backlog exist and link to the strategy.

### TC-PX-03 (Functional E2E — cross-workstream): Full onboarding behaves correctly end-to-end
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Execute end-to-end functional flows spanning WS1–WS5: member enrollment → eligibility (WS3) → claims adjudication → payments (WS2) → correspondence/reporting (WS4) → portal/mobile access (WS5) | Correct end-to-end |
| 2 | Confirm data consistent across Windward, domain services, Trusted View, on-prem replicas | Consistent |

**Pass/Fail:** Onboarded tenant works correctly across all workstreams.

### TC-PX-04 (Performance — acceptance): Tenant meets performance/load targets for its Tier
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Run load representative of the Tier's member/claims volume | Within response-time & resource thresholds |
| 2 | Confirm WW-Shrink-reduced DBs + right-sized infra (Phase 9.2) sustain load | Acceptable |

**Pass/Fail:** Performance acceptance met for the Tier.

### TC-PX-05 (UAT — business acceptance): Business signs off
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Business/UAT participants validate key scenarios | Accepted |
| 2 | UAT results documented | Recorded |

**Pass/Fail:** Business UAT sign-off obtained.

### TC-PX-06 (Exit gate — bug resolution): Critical/High bugs resolved before go-live
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm bugs reported, tracked (dashboards), and **all critical/high resolved** | Resolved |
| 2 | Confirm results documented/reported via Jira | Reported |

**Pass/Fail:** No open Critical/High defects at go-live. This is the hard exit gate.

### TC-PX-07 (DOC DEFECT): "Phase 1 through Phase 13" reference
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Step intro says "Phase 1 through Phase 13" but the playbook ends at Phase 12 / Phase X | No Phase 13 exists |

**Pass/Fail:** Defect D-PX-1 logged (off-by-one phase reference).

---

## Completion Checklist Coverage
| Deliverable | Covered by |
|-------------|-----------|
| Test-execution Feature created/assigned to SQA | TC-PX-02, TC-HO-01/06 |
| All cases executed, results documented | TC-PX-03, 04, 05 |
| Critical/high issues resolved | TC-PX-06 |
| Go-live readiness | TC-PX-01..06 |

## Defects
| ID | Observation | Sev |
|----|-------------|-----|
| D-PX-1 | Prereq says "Phase 1 through Phase 13"; no Phase 13 exists (ends at 12) | S4 |

## Execution Record
| TC | Date | Tester | Env | Result | Defect | Notes |
|----|------|--------|-----|--------|--------|-------|
| TC-PX-01 | | | | | | |
| TC-PX-02 | | | | | | |
| TC-PX-03 | | | | | | |
| TC-PX-04 | | | | | | |
| TC-PX-05 | | | | | | |
| TC-PX-06 | | | | | | |
| TC-PX-07 | | | | | | |

---

## Playbook Reference
This suite validates the playbook item **[PhaseX_EndtoEndTest_UAT.md](https://dev.azure.com/EnterpriseRepo/Application%20Services/_git/com-client-pilot?path=/Playbook/PhaseX_EndtoEndTest_UAT.md&version=GBmain)** (`com-client-pilot/Playbook/`).

Related: [Jira ↔ Playbook matrix](../../JiraPlaybookMatrix.md) · [Test Strategy](../../TestStrategy.md) · [Traceability Matrix](../../TraceabilityMatrix.md)
