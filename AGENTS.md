# AGENTS.md — [PROJECT NAME]

Rules for any coding agent working in this repo. Re-read this file at the start of every milestone.

## Mission
[Two lines: what is being built and for whom.] The product spec is `docs/SPEC.md` (what to build). This file is how to work.

## Read order at session start
1. `AGENTS.md`  2. `docs/SPEC.md`  3. `docs/PROGRESS.md` (create in M0; keep current)  4. `docs/api-notes.md`

## Fixed stack
- [Language, framework, UI library, test crates/tools, storage, HTTP client.]
- Do not swap the stack without writing the reason in `docs/PROGRESS.md` and asking the user.
- **Never write library APIs from memory.** Add the dependency with the package manager, read its docs, and let the compiler or test runner be the judge. Commit the lockfile.

## Architecture rules (these keep it testable)
1. **Pure core, thin shell.** Logic in a library; `main` only wires things together.
2. **Events -> actions -> update(state) -> render(state).** `update` has no I/O; `render` has no side effects beyond drawing.
3. **External systems behind interfaces** (providers/traits). Implementations: mock, fixture, live. The UI never knows which is active.
4. **Injectable clock.** No direct `now()` in logic; tests use a fake clock.
5. **The UI never blocks.** Slow work runs in the background and reports through a channel.
6. **One module owns each invariant** (money formatting, time ranges, unit conversion). Nothing else formats or converts.
7. **Terminal/process hygiene.** Always restore the terminal, including after a panic. No printing to stdout while a TUI runs; log to a file. No `unwrap`/`expect` outside tests and `main`.
8. **Fragile external code is quarantined** behind one provider with typed errors and recorded-fixture tests.
9. **Safe by default.** Live calls are read-only unless an explicit flag allows writes. Destructive commands are dry-run unless `--apply`.
10. **Mock/demo data never shares storage with real data** (separate files per source).

## Commands (create a `Makefile` in Milestone 1)
| Target | Runs |
|---|---|
| `make check` | format check, linter with warnings as errors, all tests |
| `make demo` | app with mock data and seeded history |
| `make e2e` | drives the real binary (tmux/PTY), saves captures to `docs/evidence/` |
| `make live-smoke` | real-network tests; needs credentials; never part of `check` |

`make check` must be green before every commit.

## Testing rules
Every behaviour in the spec has at least one automated test. Layers:
1. **Unit tests** for pure logic (formatting, maths, sorting, filtering).
2. **Golden tests** from real examples in the spec, asserted exactly.
3. **Render/snapshot tests** at the sizes listed in the spec; review snapshots by eye, never blindly accept.
4. **Input/integration tests** with synthetic events; test boundaries (first cell, last cell, one outside).
5. **Contract tests** with recorded, redacted fixtures for every external response shape.
6. **Fake-server tests** (wiremock-style) for the full flow including failures: 401, redirect to login, 429 with Retry-After, 500, timeout, malformed body, empty, partial.
7. **End-to-end** against the real binary, with before/after captures and diffs.
8. **Fault injection flags** so error UI can be developed without the real service.
9. **Fake-time timelines** for anything time-dependent; hand-computed expected values, not values produced by the code under test.
10. **Isolation guard:** tests never read the real HOME/config/credential paths.

A bug fix starts with a failing test that reproduces it.

## Evidence rules
- Say "done" or "passing" only if you ran the command **in this session** and pasted the real output into `docs/evidence/<milestone>.md`.
- If you could not run something, say so and list what is unverified. Never fabricate output, screenshots or fixtures. Label synthetic data as synthetic.
- At each milestone end update `docs/EVIDENCE.md`: requirement ID, test name(s), command, result, date.
- A milestone is finished only when its **Gate** passes and the proof is pasted.
- In every report, answer each numbered requirement from the reviewer with: done / not done, test name(s), evidence. Do not substitute a different test for the one requested; if you think a different test is better, say so and still provide the requested one.

## Working loop
1. State the milestone goal in one sentence; write a short plan to `docs/PROGRESS.md`.
2. Small steps: failing test, make it pass, refactor, commit.
3. Run `make check` after every step; do not silence warnings without a written reason.
4. At the end: run the Gate, record evidence, update PROGRESS, then **stop and report** (done, evidence, open questions, deviations). Wait for approval.

## Hard don'ts
- Do not guess external API shapes. Verify against a fixture, reference code or a live response; record in `docs/api-notes.md` as VERIFIED (with source) or UNVERIFIED.
- Do not hardcode sizes/paths that should adapt or be configured.
- Do not commit secrets or personal data. Credentials come from env vars or a 0600 file, are never logged or passed as CLI flags, and are redacted from fixtures. Never read, cat or print a credential file; test through the app with fake values.
- Do not hit real services in `make check`.
- Be a polite client: descriptive User-Agent, caching, throttles, backoff on 429/5xx.
- Do not add dependencies outside the stack list without asking.
- Do not expand scope or rewrite working modules while implementing something else.
- Disclose deviations and near-misses (for example a test that could have touched real data) in the report.

## Stop and ask the user when
- You need credentials, captures or facts only the user has.
- The same bug survives three honest attempts (write it up in `docs/OPEN_QUESTIONS.md`).
- A spec item is ambiguous or two items conflict.
- You want a new dependency.
