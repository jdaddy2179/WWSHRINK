# Workstream 5 — Member-Facing Services

Services/apps members and providers use directly — the externally exposed surface. **Highest external PHI exposure**: authN/authZ, member data isolation, session security must be airtight. Entry depends on WS1 core app (and business service for portal/mobile).

| Suite | Phase | Notes |
|-------|-------|-------|
| `TC_Phase06.1_DeployBusinessService.md` | 6.1 | Business service (all-env deploy, smoke, rollback) |

**Not QA-ready (placeholder templates) — will be P1 for exposure once authored (Gap G7):**

| Phase | Status | Latent risk |
|-------|--------|-------------|
| 7.4 — Member Portal Setup | Not QA-ready (placeholder) | External member-PHI access; isolation |
| 7.5 — Mobile App Setup | Not QA-ready (placeholder) | External member-PHI access; isolation |

Hand-off suites reference `../_shared/TC_PATTERN_JiraHandoffPhase.md`. Full index: [QA README](../../README.md).
