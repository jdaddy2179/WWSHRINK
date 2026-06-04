# TBD — Cleanup, PROD Cutover, DR & Final Acceptance

Final right-sizing, **irreversible** SLE-data removal, PROD cutover back online, DR readiness, and the joint end-to-end/UAT gate. **P1 — irreversible + production cutover.** Workstream ownership is marked **TBD** in the Introduction (Gap G8) — confirm QA ownership for Phases 10/11 with the QA Lead before execution.

| Suite | Phase | Notes |
|-------|-------|-------|
| `TC_Phase09.1_ProviderCopyJob.md` | 9.1 | Provider sync completeness, cross-tenant safety |
| `TC_Phase09.2_RemoveExtraResources.md` | 9.2 | Irreversible resize, snapshot, performance (EBS-shrink defect) |
| `TC_Phase10_RemoveSLEData.md` | 10 | **Irreversible** SLE removal: backup/scope/before-after counts/sign-off |
| `TC_Phase11_BringComDBOnlinePROD.md` | 11 | PROD cutover, Phase-10 gate, app connectivity |
| `TC_PhaseX_EndToEndTest_UAT.md` | X | E2E/UAT acceptance gate + critical/high bug-resolution exit |

**Not QA-ready (placeholder template):** Phase 12 — Disaster Recovery (P1; failover/restore integrity). Blocked until real content (Gap G7).

Hand-off suites reference `../_shared/TC_PATTERN_JiraHandoffPhase.md`. Full index: [QA README](../../README.md).
