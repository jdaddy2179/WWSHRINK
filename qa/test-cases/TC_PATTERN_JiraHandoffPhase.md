# Reusable Test Pattern — "Jira Hand-off Phase"

Many playbook phases follow an identical shape: **the operator creates one (or more) Jira user story with prescribed Title/Description/Acceptance Criteria and links, assigns it to a specialist team, and the specialist team executes & validates.** Rather than duplicate the same cases in every phase file, those phases reference this pattern and add only their **phase-specific** cases.

**Applies to:** Phase 3.1 (Kerberos), 3.2 (Load Balancers), 3.3 (Certificates), 3 (Provisioning Step 1), 4.1, 4.2, 4.3 Step 1, 4.4 Step 1, 5, 5.1, 5.2, 5.3, 6.1, 7.x, 8, 9.x, 10, 12 — any "create ticket → hand off" step.

## How to use
In a phase suite, write: *"Applies `TC-HO-01..09` from the Hand-off Pattern, instantiated with: backlog=<…>, Title=<…>, links=<…>, assignee=<team>."* Then add phase-specific `TC-<phase>-NN` cases and the completion-checklist mapping.

---

### TC-HO-01: Correct backlog & User Story creation
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Open the **client-specific** Jira backlog (confirm with product owner/PM) | Correct backlog |
| 2 | Create a new User Story (not Task/Bug; not in a generic backlog) | Story created |

**Pass/Fail:** Story created in the correct client backlog.

### TC-HO-02 (CRITICAL — REF substitution): Title formatted with real values, no placeholders
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Apply the phase's Title template | Matches exactly |
| 2 | Replace every `REF[...]` with the value from Env Variables "Key" column | All replaced |
| 3 | Search the story for literal "REF[" | Zero matches |

**Pass/Fail:** No unresolved `REF[]` anywhere in Title/Description/AC.

### TC-HO-03 (Tier correctness): Description references the Tier from Phase 1
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Confirm the Tier cited equals the Phase 1 Env Variables Tier | Identical |
| 2 | Confirm the correct Tier architecture file is the one referenced | Matches Tier |

**Pass/Fail:** Tier in ticket = Phase 1 Tier; correct Tier spec linked. (Skip if phase has no Tier reference.)

### TC-HO-04 (Links resolve): All reference links valid
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Follow every link in the Description (architecture folder, windward-1.0/2.0, Env Variables, phase-specific docs) | All resolve |
| 2 | Confirm linked docs are the intended targets | Correct targets |

**Pass/Fail:** No broken or wrong links.

### TC-HO-05: Acceptance Criteria matches playbook wording
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Enter the phase's prescribed Acceptance Criteria | Present and saved |
| 2 | Confirm it states the measurable done-condition | Yes |

**Pass/Fail:** AC present, accurate, saved.

### TC-HO-06 (CRITICAL — Assignment): Ticket assigned to the correct specialist team
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Assign per the phase Work Assignments | Correct team/owner |
| 2 | Confirm not left unassigned / wrong team | Correct |

**Pass/Fail:** Routed to the documented team.

### TC-HO-07 (Sequential env order, where applicable): One ticket per env, DEV→QAR→PROD→HFX
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | If the phase processes per-environment, create one ticket per env | Separate tickets |
| 2 | Wait for each env to complete before the next | Order honored |

**Pass/Fail:** Sequential order respected. (Skip if single-shot phase.)

### TC-HO-08 (Hand-off / wait-for-Done): Completion confirmed by specialist team
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | After assignment, monitor ticket | Specialist team updates to Done/Resolved or comments completion |
| 2 | Confirm the documented Output/Completion-Checklist deliverables are met | Deliverables evidenced in ticket |

**Pass/Fail:** Specialist team confirms completion with evidence; otherwise follow up.

### TC-HO-09 (Negative — prerequisites): Phase blocked if prior-phase deliverables incomplete
| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Attempt the phase with an unmet prerequisite (e.g., prior phase not COMPLETE, missing access) | Cannot proceed; gap surfaced |

**Pass/Fail:** Unmet prerequisite blocks the phase rather than producing an incomplete ticket.

---

> **Static review (always include):** confirm all images/screenshots referenced by the phase exist, and that the phase's "Next phase" link is correct.
