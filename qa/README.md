# QA — Commercial Client Pilot Playbook

Test strategy and test cases validating the AWS onboarding / Windward tenant-creation playbook as an executable operational procedure.

## Contents
| Artifact | Purpose |
|----------|---------|
| [`TestStrategy.md`](TestStrategy.md) | Master strategy: scope, approach, environments, roles, risk, defects, gaps |
| [`TraceabilityMatrix.md`](TraceabilityMatrix.md) | Phase → test-case coverage across the full playbook |
| [`templates/TestCaseTemplate.md`](templates/TestCaseTemplate.md) | Reusable test-case format |
| [`test-cases/`](test-cases/) | Executable, detailed test cases |

## Authored detailed test cases
| File | Covers |
|------|--------|
| [`test-cases/TC_Phase01_GatherClientAndAWSAccountInfo.md`](test-cases/TC_Phase01_GatherClientAndAWSAccountInfo.md) | Phase 1 incl. **Tier boundary** and PHI-provenance cases |
| [`test-cases/TC_Phase02.1_TestAWSAccounts.md`](test-cases/TC_Phase02.1_TestAWSAccounts.md) | Phase 2.1 access + AWS account/naming validation |
| [`test-cases/TC_SQL_ClientMemCount.md`](test-cases/TC_SQL_ClientMemCount.md) | `ClientMemCount.sql` accuracy, safety, definition gaps |

## How to use
1. Read `TestStrategy.md` for approach and quality gates.
2. For a phase under test, open its `TC_*` file (or the matrix to find the ID).
3. Verify entry criteria, execute each TC's steps, record results in the **Execution Record** table.
4. A phase exits only when every `How to validate` item and `Completion Checklist` deliverable maps to a passing TC or a risk-accepted Gap Register entry (`TestStrategy.md` §11).

## Coverage status
Detailed cases exist for the phases whose source content is currently available (Phase 1, Phase 2.1, and the SQL query). All remaining phases are tracked in the traceability matrix as `Pending Content` and will be authored against each phase's standard sections as the markdown is delivered.

## Key risks under test (highest priority first)
- **Member-count accuracy → Tier derivation** (mis-sizes all downstream infrastructure).
- **AWS account naming-convention validation**.
- **PHI/PII handling and US-based authorized access**.
- **PROD-only / irreversible steps** (Phase 4.1 offline, Phase 10 SLE removal, Phase 11 online).

## Open gaps (see `TestStrategy.md` §11)
NBI process for new clients (TBD), total-vs-active member-count definition, 5-year purge applicability in commercial, and several `Target Future State` sections still `To be determined`.
