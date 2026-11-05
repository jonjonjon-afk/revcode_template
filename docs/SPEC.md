# SPEC — <<FILL: PROJECT NAME>>

Working rules are in `AGENTS.md`. This file says **what** to build, in what order, and how success is judged. The reviewer fills it during intake. The coder reads it and never edits it.

Every `<<FILL: ...>>` must be replaced. Delete sections that do not apply instead of leaving them empty.

## 1. Goal
<<FILL: one paragraph. What it does, for whom, and what "working" means.>>

## 2. Non-goals
<<FILL: things explicitly out of scope.>>

## 3. Environment
<<FILL: platform, terminal/screen sizes (state order: width x height), performance expectations, input methods, offline needs.>>

## 4. Layout / interface
<<FILL: ASCII sketch of the screen or the API surface. Reference screenshots go in `docs/` (gitignore anything private).>>

## 5. Behaviour
<<FILL: per component: what it shows, what each control does, empty/degraded/error states, keyboard equivalents.>>

## 6. Golden examples (exact input -> output pairs)
Source: real data, screenshots or a reference tool. Never invented by an agent. A hand-computed example shows its arithmetic and is marked "hand-computed". Tests assert these exactly. Include edge cases: boundaries, rounding ties, empty, huge.

| ID | Input | Expected output | Source |
|---|---|---|---|
| G1 | <<FILL>> | <<FILL>> | <<FILL>> |

## 7. Data sources and modes
| Source | What it provides | Purpose |
|---|---|---|
| `mock` | Seeded generator, offline, deterministic, optional fake history | Default development and tests |
| `fixture`/`replay` | Recorded, redacted real responses | Contract tests, real-shaped pipeline |
| `live` | The real service | Real use; read-only first |

Fault injection flags: <<FILL: list>>. Separate storage per source.
Reference implementations to read before designing anything: <<FILL: path/URL and what is known from them, to be verified.>>

## 8. Milestones and gates
This list is a menu. Keep, reorder or delete milestones to fit the project, but every gate must be a **runnable command with an expected result**. After each gate the coder stops and the reviewer audits. Proof goes in `docs/evidence/M<n>.md`.

- **M0 Recon and plan (no app code).** Read all references. Fill `docs/api-notes.md` (facts tagged VERIFIED/UNVERIFIED with sources), `docs/PROGRESS.md` (milestone table and plan) and `docs/OPEN_QUESTIONS.md` (each question with a proposed default). List every file, credential or fact needed from the human. *Gate:* the three docs have rows; every external dependency is described or listed as unknown.
- **M1 Skeleton and headless core.** Project, Makefile, domain model, formatting/maths module, injectable clock, mock source, CLI flags, a `--dump` that prints the core results as text. *Gate:* `make check` green; golden tests pass; `--dump` runs.
- **M2 Storage and aggregation.** Persistence with versioned migrations, history, range queries, derived figures. *Gate:* fake-time timeline tests with hand-computed expected values; empty and edge cases; migrations idempotent; mock never touches real storage.
- **M3 Static UI.** Render every panel from mock data, responsive layout, too-small screen. *Gate:* snapshot tests at the listed sizes plus real terminal captures; non-colour markers for all states.
- **M4 Interaction.** Every control by mouse and keyboard, focus modes, scrolling, filters, resize handling, performance at large data sizes (report numbers). *Gate:* input tests per control; real-terminal before/after captures with diffs.
- **M5 Sync, errors and integrity.** Background work, typed errors, fault injection, throttles/backoff, single-flight, state preservation. A failed or partial result never corrupts history. *Gate:* every fault has a test, a snapshot and a capture; the UI stays responsive during slow work.
- **M6 Real integrations (read-only first).** Real clients, redacted fixtures, fake-server tests for each failure, secret-leak tests, explicit flag for any write. *Gate:* contract and failure tests pass; first live run is read-only and the human compares results to a trusted source.
- **M7 Polish and handover.** Optional extras, README, clean-clone run, final evidence. *Gate:* `make check` and `make e2e` green on a clean clone; `docs/EVIDENCE.md` has a row for every acceptance ID.

## 9. Acceptance checklist (IDs referenced in EVIDENCE.md)
- **A1** <<FILL: fits the target size without overlap/truncation.>>
- **A2** <<FILL>>
- **A[n]** `make check` and `make e2e` green; every requirement has evidence.

## 10. Final report format
(1) Filled `docs/EVIDENCE.md`; (2) list of anything unverified or blocked, with reasons; (3) exact steps to move from test data to real use.
