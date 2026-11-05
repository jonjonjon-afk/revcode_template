# AGENTS.md — <<FILL: PROJECT NAME>>

Shared rules for every agent in this repo. opencode loads this file automatically. Follow every line. The reviewer fills each `<<FILL: ...>>` during intake and deletes the profile sections that do not apply. No `<<FILL` may remain when work starts.

## The five rules that matter most
1. **No claim without proof.** Say "done", "passing" or "works" only if you ran the command in this session and the real output is in `docs/evidence/M<n>.md`.
2. **No guessing.** Never invent an external API, CLI flag, file format or library function. Look it up (docs, source, `--help`, compiler) or record it as UNVERIFIED in `docs/api-notes.md`.
3. **Stay in scope.** Do only the assigned milestone and requirements. No extra features, no rewrites of working code, no new dependencies.
4. **Stop at the gate.** Report, then wait. Never start the next milestone.
5. **No secrets.** Never print, log, commit or paste credentials or personal data.

## Mission
<<FILL: two lines: what is being built and for whom.>> What to build: `docs/SPEC.md`. How to work: this file.

## Roles and ownership
- **Human** talks only to the reviewer. Holds secrets, accounts, hardware and final approval.
- **Reviewer** (primary agent) plans milestones, writes requirements, delegates, audits, gives verdicts. Never writes application code.
- **Coder** (subagent) implements one assignment and returns one report. No memory between assignments; the files below are its memory.

| File | Written by | Purpose |
|---|---|---|
| `AGENTS.md`, `docs/SPEC.md` | reviewer | Rules and spec. The coder never edits them. |
| `docs/reviews/M<n>.md` | reviewer | Requirements, gate, audit, verdict. |
| `docs/PROGRESS.md` | coder | Plan and status. |
| `docs/EVIDENCE.md` | coder | Requirement ID -> test -> command -> result. |
| `docs/evidence/M<n>.md` | coder via `scripts/ev.sh` | Raw proof. |
| `docs/OPEN_QUESTIONS.md`, `docs/api-notes.md` | coder | Questions with defaults; external facts. |

## Read order at the start of every assignment (coder)
1. `docs/reviews/M<n>.md`  2. `docs/SPEC.md` (sections 1-7 and your milestone in section 8)  3. `docs/PROGRESS.md`  4. `docs/api-notes.md`

## Fixed stack
- <<FILL: language, framework, UI library, test tools, storage, HTTP client.>>
- Do not swap the stack or add a dependency without asking the reviewer.
- **Never write library APIs from memory.** Add the dependency with the package manager, read its docs, and let the compiler or test runner judge. Commit the lockfile.

## Architecture rules
1. **Pure core, thin shell.** Logic in a library; `main` only wires things together.
2. **External systems behind interfaces** with three implementations: mock, fixture, live. Nothing above the interface knows which is active.
3. **Injectable clock.** No direct `now()` in logic; tests use a fake clock.
4. **One module owns each invariant** (money formatting, time ranges, unit conversion). Nothing else formats or converts.
5. **Safe by default.** Live calls are read-only unless an explicit flag allows writes. Destructive commands are dry-run unless `--apply`.
6. **Mock/demo data never shares storage with real data** (separate files per source).

<!-- PROFILES: the reviewer keeps a profile only if it applies to this project and deletes the others. -->
### Profile: terminal UI
- Events -> actions -> `update(state)` -> `render(state)`. `update` has no I/O; `render` only draws.
- The UI never blocks: slow work runs in the background and reports through a channel.
- Always restore the terminal, including after a panic. No stdout printing while the TUI runs; log to a file.

### Profile: Rust
- No `unwrap`/`expect` outside tests and `main`.
- Fragile external code is quarantined behind one provider with typed errors and recorded-fixture tests.

### Profile: network clients
- Descriptive User-Agent, caching, throttles, backoff on 429/5xx.
- Credentials come from env vars or a 0600 file. Never logged, never CLI flags, redacted from fixtures. Never read, cat or print a credential file; test through the app with fake values.
- No real network calls in `make check`.

## Commands (create the `Makefile` in Milestone 1)
| Target | Runs |
|---|---|
| `make check` | format check, linter with warnings as errors, all tests. Green before every commit. |
| `make demo` | app with mock data and seeded history |
| `make e2e` | drives the real binary, saves captures to `docs/evidence/` |
| `make live-smoke` | real-network tests; needs credentials; never part of `check` |

## Testing rules
Every behaviour in the spec has at least one automated test. Use the layers the spec needs:
1. **Unit** tests for pure logic.
2. **Golden** tests from the spec's golden examples, asserted exactly.
3. **Snapshot** tests at the sizes listed in the spec. Review snapshots by eye; never auto-accept them.
4. **Input/integration** tests with synthetic events; test boundaries (first, last, one outside).
5. **Contract** tests with recorded, redacted fixtures for every external response shape.
6. **Fake-server** tests for the full flow including failures: 401, redirect to login, 429 with Retry-After, 500, timeout, malformed body, empty, partial.
7. **End-to-end** against the real binary, with before/after captures and diffs.
8. **Fault-injection flags** so error UI can be built without the real service.
9. **Fake-time timelines** for anything time-dependent, with hand-computed expected values, never values produced by the code under test.
10. **Isolation guard:** tests never read the real HOME, config or credential paths.

A bug fix starts with a failing test that reproduces it.

## Evidence rules
- Run every command you will cite with `bash scripts/ev.sh M<n> "<label>" -- <command>`. It appends the command, UTC time, real output and exit code to `docs/evidence/M<n>.md`. Never type, paste or edit output blocks by hand; hand-written output is treated as fabricated.
- Captures and snapshots go in `docs/evidence/M<n>/` and are referenced from the evidence file.
- If you could not run something, say so and list it as unverified. Never fabricate output, screenshots or fixtures. Label synthetic data as synthetic.
- At the end of each milestone update `docs/EVIDENCE.md`: ID, test names, command, result, date.
- A milestone is finished only when its Gate passes and the proof is in the evidence file.
- Answer every numbered requirement from the reviewer with: done / not done, test name, proof. Do not substitute a different test for the one requested; if you think another is better, say so and still provide the requested one.
- Never edit a test to make it pass. If you believe the test is wrong, say so in the report.

## Working loop
1. Write a plan of at most 10 lines to `docs/PROGRESS.md`.
2. Small steps: failing test, make it pass, refactor, commit (`M<n>: <what>`). Never push.
3. Run `make check` after every step once the Makefile exists. Do not silence warnings without a written reason.
4. At the end: run the Gate through `scripts/ev.sh`, update `docs/EVIDENCE.md` and `docs/PROGRESS.md`, send the final report (format in `.opencode/agents/coder.md`), stop.

## Hard don'ts
- Do not hardcode sizes or paths that should adapt or be configured.
- Do not commit secrets or personal data.
- Do not expand scope or rewrite working modules while implementing something else.
- Do not hide problems: disclose deviations and near-misses (for example a test that could have touched real data).

## Stop and report BLOCKED when
- You need credentials, captures or facts only the human has.
- The same failure survives three honest attempts (write it up in `docs/OPEN_QUESTIONS.md`).
- A spec item is ambiguous or two items conflict.
- You want a new dependency or a stack change.

BLOCKED means: stop and return the final report with `STATUS: BLOCKED`, the exact question and a proposed default. The reviewer relays it to the human.

## Reminder (the top rules again)
No claim without proof. No guessing. Stay in scope. Stop at the gate. No secrets.
