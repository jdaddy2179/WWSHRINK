# Documentation Fixes Needed — Commercial Client Pilot Playbook

| Field | Value |
|-------|-------|
| Purpose | Consolidated, actionable list of documentation defects found while authoring the QA test suites, so playbook authors can remediate in one pass |
| Source | Per-suite `D-*` findings under `test-cases/` + Gap Register in `TestStrategy.md` §11 |
| Owner | Playbook authors / Architecture team; raised by SQA |
| Status | Draft v1.0 — 2026-06-04 |

## Severity legend
| Sev | Meaning |
|-----|---------|
| **S1** | Blocks execution / risks data loss or PHI exposure |
| **S2** | Significant — misleads the operator, missing acceptance criteria, or scope ambiguity on a risky phase |
| **S3** | Moderate — incomplete step, unclear ownership, non-authoritative reference |
| **S4** | Cosmetic — typo, rendering glitch, status inconsistency |

## At-a-glance
| Category | Count | Top severity |
|----------|------:|:------------:|
| Systemic / recurring (fix once, applies in many phases) | 7 | S2 |
| Per-phase defects | 22 | S2 |
| Process / operational gaps | 6 | S1 |

> Fix the **systemic** items first (Section A) — they account for the majority of individual broken-link findings.

---

## A. Systemic / recurring issues (fix once → resolves many)

### A1. Broken InfoSec phase reference *(S2, recurring)*
Multiple phases point to InfoSec/IT-Intake setup using the **wrong file/number**. InfoSec is **Phase 3.4 = `Phase03.4_Infrastructure_Security.md`** (Phase 3.1 is Kerberos, 3.3 is Certificates).
- `Phase04_SetupDBs.md` prereq → `Phase03.1_Infosec.md` ❌
- `Phase06_DeployDomainServices.md` prereqs (all 4 steps) → `Phase03.1_Infosec.md` ❌
- `Phase06.1_DeployBusinessService.md` prereq → `Phase03.1_Infosec.md` ❌
- `Phase04.3_WWShrinkWW1.0AndConfig.md` prereq → `Phase03.3_Infosec_IT_Intake.md` ❌
- **Fix:** replace all of the above with `Phase03.4_Infrastructure_Security.md` and the label "Phase 3.4 — Infrastructure-level Security".

### A2. Broken Phase 5 filename link *(S2, recurring)*
Several phases link Phase 5 as **`Phase05_DeployWWApplications.md`**, but the actual file is **`Phase05_DeployWW1.0AndConfig.md`**.
- `Phase04.5_Replication.md` "next phase" link ❌
- `Phase05.2_DeployWWPayments.md` intro + prereqs (appears ~3×) ❌
- **Fix:** repoint all to `Phase05_DeployWW1.0AndConfig.md` (or rename the Phase 5 file and update the Introduction — pick one canonical name).

### A3. Missing Acceptance Criteria *(S2)*
`Phase05.1_AppSecurity_WW1_Config.md` and `Phase05.3_AppSecurity_Payments.md` have **no Acceptance Criteria** (every other phase does). Security phases especially need a measurable done-condition.
- **Fix:** add AC per user story (e.g., "Okta SSO configured and a successful + failed login validated; auth events logged; ForcePoint DSS PHI fingerprinting active on the Government Database for this client ID").

### A4. Completion-checklist status inconsistency *(S4)*
Statuses are mixed/contradictory across sibling phases (e.g., 5 / 5.2 / 6.1 show COMPLETE; 5.1 / 5.3 / 7 show NOT STARTED; 9 / 9.1 / 9.2 show IN PROGRESS; Phase 6 Step 4 IN PROGRESS while Steps 1–3 COMPLETE).
- **Fix:** reset all per-client checklist statuses to a single baseline (e.g., NOT STARTED) in the template so they aren't carried over from the pilot.

### A5. Unassigned owners / managers ("TBD") *(S3)*
Many phases leave Work-Assignment owners and/or Manager/IT-Lead as **TBD** (Phases 7, 9, 9.1, 9.2, 10, 6.1; rollback owner "AJ" has no full name/email in 6 & 6.1).
- **Fix:** populate named owners + managers; expand "AJ" to a full name/email.

### A6. Tasks embedded as numbered "links" *(S3)*
In `Phase09_TrustedView.md` and `Phase09.1_ProviderCopyJob.md`, the Description's numbered "links" list actually contains **task instructions, not links** (items 3–6).
- **Fix:** split into a "Reference links" list and a separate "Tasks" list.

### A7. Empty placeholder phases *(S2 — see Section C/G7)*
`Phase07.1`, `07.2`, `07.3`, `07.4`, `07.5`, `08`, `12` are unfilled templates (no titles, steps, AC, owners, or links).
- **Fix:** author real content. Until then, do not allow these to be marked COMPLETE. (Latent risk is high — EDI/EE carry PHI/claims routing; Member Portal/Mobile App are external PHI surfaces; DR is failover/restore integrity.)

---

## B. Per-phase documentation defects

| Phase | ID | Issue | Location | Sev | Recommended fix |
|-------|----|-------|----------|:---:|-----------------|
| `ClientMemCount.sql` | D-SQL-1 | Returns a **single** count, but Phase 1 asks to record **both total and active** members | header vs Phase 1 | S2 | Add a second query (or column) for active-only, or correct Phase 1 to ask for one figure |
| `ClientMemCount.sql` | D-SQL-2 | Header says replace `'purchaser_gid'`, but value is hardcoded `86319` | line 7 / 42 | S3 | Use a clearly-labeled variable/placeholder and update the instruction |
| `ClientMemCount.sql` | D-SQL-3 | "Inactive members included" intent vs `record_status='A'` joins needs SME confirmation | header vs joins | S2 | Confirm with AJ; document what the count includes |
| `ClientMemCount.sql` | D-SQL-4 | 5-year purge "not clear if running in commercial" | header comment | S3 | Confirm purge status; note impact on count |
| Phase 3 | D-P3-1 | Step 2.3.d "Connect to AWS server" is an unfinished `TODO` | Step 2 | S3 | Author the connect-to-server steps |
| Phase 4.1 | D-P4.1-1 | Scope inconsistency: filename/Intro "PROD ONLY" vs H1 "PROD and HFX" vs AC "PRODUCTION" | title/body/AC | S2 | Decide scope; make title, body, AC, and Intro consistent |
| Phase 4.1 | D-P4.1-2 | No documented rollback/abort if offline fails or window overruns | phase | S3 | Add rollback/abort + reschedule guidance |
| Phase 5 | D-P5-1 | Config module mislabeled "Windward 2.0" in Step 2 prereq | Step 2 | S3 | Call it "Windward Config Module" consistently |
| Phase 5.1 | D-P5.1-2 | Reference links are relative `../architecture/...` — may not resolve from a Jira ticket | Description | S3 | Use absolute ADO URLs like other phases |
| Phase 5.2 | D-P5.2-2 | Description link #4 ("tier file") duplicates link #3 (`applications-deployment-WW`) | Description | S3 | Point to the correct tier-specific file |
| Phase 5.3 | D-P5.3-1 | Near-duplicate of 5.1 (copy-paste risk) + no AC; must target the **Payments** instance | phase | S2 | Add AC; explicitly scope to Payments app/portal |
| Phase 7 | D-P7-2 | Non-authoritative config table name: "`tblClient_BU` **or equivalent**" | Common Issues | S3 | Confirm and state the authoritative table name |
| Phase 9 | D-P9-1 | Mermaid nodes concatenated: `S7[Submit Jira Ticket]S8[Assign to DBA Team]` (renders wrong) | mermaid | S4 | Add the missing line break/connector |
| Phase 9 | D-P9-2 | Typo "checksvalidation" | Step 2 description | S4 | "checks / validation" |
| Phase 9 | D-P9-3 | No distinctive Trusted View reference doc (only generic `/architecture`) | Description | S3 | Link the specific Trusted View spec/scripts |
| Phase 9.2 | D-P9.2-1 | Contradiction: instructions/AC say "**reduce** EBS volume sizes" but AWS can only **increase** EBS size (noted in the same doc's Common Issues) | instructions vs Common Issues | S2 | Reword to delete-and-recreate (snapshot/migrate) approach; EBS cannot shrink in place |
| Phase 10 | D-P10-1 | Unresolved applicability `TODO`: "Double-check with Mel how relevant this is with KCL & Prebuild BU" | phase top | S3 | Resolve and remove the TODO |
| Phase X | D-PX-1 | Prereq says "Phase 1 through **Phase 13**", but the playbook ends at Phase 12 / Phase X | Step 1 prereq | S4 | Change to "Phase 1 through Phase 12" |
| Introduction | D-INT-1 | Workstream column shows **TBD** for Phases 9.1, 9.2, 10, 11, 12, X | phase table | S3 | Assign workstream ownership |
| Multiple | D-GEN-1 | `Target Future State` left "To be determined" in nearly every phase | each phase | S4 | Populate or remove the section |
| Phase 5 / X | D-GEN-2 | Phase X expects the test strategy at `/Testing/TestStrategy.md`; QA artifacts now live in `qa/` | repo layout | S3 | Decide canonical location (move `qa/`→`Testing/` or update Phase X links) |
| Phase 4.3/4.4 | D-GEN-3 | Destructive "replace original DB with reduced version" relies on backup as sole safety net — not stated as a hard precondition | WW Shrink phases | S2 | State "verified restorable backup required before shrink" as a blocking prerequisite |

---

## C. Process / operational gaps (not pure documentation, but block correct use)

| ID | Gap | Phase | Sev | Recommended action |
|----|-----|-------|:---:|--------------------|
| G1 | **NBI process is `TBD`** — new clients (not yet in Windward) have no member-count path → cannot derive Tier | Phase 1 | S1 | Define the NBI process or explicitly block new-client onboarding until defined |
| G7 | **Placeholder phases** 7.1–7.5, 8, 12 are empty templates | those phases | S2 | Author content; block COMPLETE until then |
| G8 | **Workstream ownership TBD** for 9.1, 9.2, 10, 11, 12, X (incl. irreversible PROD 10/11) | Introduction | S3 | Assign owners; confirm QA ownership for 10/11 |
| G-Rollback | **No rollback/abort guidance** on destructive/irreversible phases | 4.1, 10, 11, 9.2 | S2 | Add explicit rollback + restore-from-backup steps |
| G-Backup | Backup-before-destructive **not enforced as a precondition** | 4.3, 4.4, 10 | S2 | Make "verified restorable backup" a blocking prerequisite |
| G-Purge | Windward 5-year purge applicability in commercial unconfirmed | ClientMemCount.sql | S3 | Confirm with AJ; document |

---

## D. Recommended remediation order
1. **Systemic A1 + A2** (broken InfoSec + Phase 5 links) — quick find/replace, removes most broken-link findings.
2. **S1/S2 risk items:** G1 (NBI), G-Backup/G-Rollback on destructive phases, A3 (missing AC), D-P9.2-1 (EBS), D-P4.1-1 (4.1 scope), D-SQL-1/3 (count definition).
3. **Author placeholder phases** (A7 / G7) — 7.1–7.5, 8, 12.
4. **S3 cleanups:** owners/TBD (A5), tasks-as-links (A6), non-authoritative names, applicability TODO.
5. **S4 cosmetics:** statuses (A4), typos, mermaid, "Phase 13", Target Future State.

> Re-run the QA static-review test cases (the `*-static`/links cases in each suite, plus `TC-P1-11`, `TC-P2.1-10`) after fixes to confirm closure.

---
*Compiled from the `D-*` findings embedded in each suite under `test-cases/` and the Gap Register in `TestStrategy.md` §11.*
