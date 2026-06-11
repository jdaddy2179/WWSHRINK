# Test Cases — Phase 11: Bring COM Database Back Online (PROD ONLY)

| Field | Value |
|-------|-------|
| Playbook reference | `Phase11_BringComDBOnlinePROD.md` (Step 1) | WS | TBD |
| Priority | **P1 — PRODUCTION cutover (restores COM service)** | Type | Jira hand-off + PROD validation + change control |
| Environment | **PRODUCTION ONLY** |
| Owner | DBA Team executes; SQA validates application connectivity |

> Final cutover: brings the original COM database back online after Phase 10 removals. Until this completes, COM is offline — business-critical. Inverse of Phase 4.1.

**Applies `TC-HO-01..06,08,09`** from [`TC_PATTERN_JiraHandoffPhase.md`](../_shared/TC_PATTERN_JiraHandoffPhase.md):
- **Title:** `Bring COM Database Back Online - REF[Tenant Name] PROD`.
- **AC:** "COM database successfully brought back online in PRODUCTION, connectivity validated, services running properly, and application teams notified".
- **DB:** Windward_Commercial (COM). **Assignee:** DBA Team (Vasudha, Anthony; mgr Chris Jones) + SQA (Joshua, Keerthan; mgr Arun Pant).

### Preconditions
**Phase 10 COMPLETE and validated** (all SLE removals confirmed); DB integrity confirmed. PROD only — never DEV/QAR.

---

### TC-P11-01 (CRITICAL — Gate): Phase 10 fully complete & validated before online
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm all four Phase 10 removals Done & validated by DBA | Confirmed |
| 2 | Confirm DB integrity post-removal | Intact |
| 3 | Block bring-online if any Phase 10 step incomplete | Hard stop |

**Pass/Fail:** COM brought online only after Phase 10 verified complete.

### TC-P11-02 (Environment gating): PROD only
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm ticket targets PRODUCTION only | Correct |
| 2 | No DEV/QAR bring-online performed | None |

**Pass/Fail:** PROD-only scope honored.

### TC-P11-03 (CRITICAL — Online + connectivity): COM online, reachable, services running
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | DBA brings Windward_Commercial online | Online |
| 2 | Verify DB connectivity & accessibility | Reachable |
| 3 | Confirm SQL Server services running properly | Running |
| 4 | Document exact time brought online | Timestamp recorded |

**Pass/Fail:** COM online and healthy.

### TC-P11-04 (SQA — application connectivity): Apps connect & operate against COM
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | SQA validates application connectivity to COM | Apps connect |
| 2 | Confirm no errors post-online (monitor window) | Clean |

**Pass/Fail:** Applications operate normally against the online COM.

### TC-P11-05 (Comms): Application teams & stakeholders notified
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm app teams/stakeholders notified COM is operational | Notified |

**Pass/Fail:** Notifications sent; business resumes.

### TC-P11-06 (Contingency — known issues): Failure paths handled
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | If DB won't come online (corruption/config) → review logs, integrity, **restore from backup** if needed | Recovery path works |
| 2 | App connectivity / service-start / performance issues → documented resolutions applied | Resolved |

**Pass/Fail:** Failure scenarios have working recovery (incl. restore from the Phase 10 backups).

---

## Completion Checklist Coverage
| Deliverable | Covered by |
|-------------|-----------|
| Phase 10 verified complete | TC-P11-01 |
| Ticket created/assigned | TC-HO-01..06 |
| COM online in PROD | TC-P11-02, 03 |
| Online status confirmed/documented | TC-P11-03 |
| Connectivity & services validated | TC-P11-03, 04 |
| App connectivity validated | TC-P11-04 |
| App teams notified | TC-P11-05 |

## Execution Record
| TC | Date | Tester | Env | Result | Defect | Notes |
|----|------|--------|-----|--------|--------|-------|
| TC-P11-01 | | | PROD | | | |
| TC-P11-02 | | | PROD | | | |
| TC-P11-03 | | | PROD | | | |
| TC-P11-04 | | | PROD | | | |
| TC-P11-05 | | | PROD | | | |
| TC-P11-06 | | | PROD | | | |

---

## Playbook Reference
This suite validates the playbook item **[Phase11_BringComDBOnlinePROD.md](https://dev.azure.com/EnterpriseRepo/Application%20Services/_git/com-client-pilot?path=/Playbook/Phase11_BringComDBOnlinePROD.md&version=GBmain)** (`com-client-pilot/Playbook/`).

Related: [Jira ↔ Playbook matrix](../../JiraPlaybookMatrix.md) · [Test Strategy](../../TestStrategy.md) · [Traceability Matrix](../../TraceabilityMatrix.md)
