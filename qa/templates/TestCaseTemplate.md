# Test Case Template

Copy this file into `qa/test-cases/` and rename to `TC_<Phase>_<ShortName>.md`. One file may hold multiple related test cases (a suite).

---

## Suite: <Phase / Area Name>

| Field | Value |
|-------|-------|
| Playbook reference | `<PhaseXX_File.md>` — Step N |
| Priority | P1 / P2 / P3 / P4 |
| Type | Documentation / Procedure / Data / Boundary / Negative / Security / Repeatability |
| Environment | DEV / QAR / HFX / PROD |
| Requires PHI access | Yes / No (if Yes: US-based authorized operator) |
| Owner | <name / team> |

### Preconditions
- <prerequisite 1 — map to the phase's `Prerequisites`>
- <required access per Introduction access matrix>

### Test Data
- <input values, client profile, purchaser_gid, expected reference values>

---

### TC-<ID>: <Title>
**Objective:** <what this verifies and why it matters>

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | <action> | <expected> |
| 2 | <action> | <expected> |

**Pass/Fail criteria:** <objective, observable condition tied to the phase's `How to validate`>

**Execution Record**
| Run | Date | Tester | Env | Result (Pass/Fail/Blocked) | Defect ID | Notes |
|-----|------|--------|-----|----------------------------|-----------|-------|
|  |  |  |  |  |  |  |

---

> Repeat the `TC-<ID>` block for each case in the suite.
> Every `How to validate` item and every `Completion Checklist` deliverable in the referenced phase must be covered by at least one TC here (or noted as covered elsewhere).
