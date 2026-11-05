# Milestone-gated AI project template

A way to build software with a cheaper coding agent (the **worker**) while a stronger model (the **reviewer**) and you (the **human**) keep it honest.

## The three roles

| Role | Does | Never does |
|---|---|---|
| Worker (coding agent in a harness with a shell) | Writes code and tests, runs commands, pastes real output, stops at gates | Declares success without pasted output; guesses APIs; widens scope |
| Reviewer (a strong chat model, new chat per project is fine) | Reads the worker's report, audits it against the spec, writes the next message | Runs code. It can only judge evidence you paste |
| Human (you) | Holds secrets, real accounts, real hardware facts; runs `make check` yourself now and then; approves each milestone | Pastes secrets into chat |

## Files

| File | Goes where | Purpose |
|---|---|---|
| `AGENTS.template.md` | repo root as `AGENTS.md` | How the worker must behave (rules, testing layers, evidence) |
| `SPEC.template.md` | `docs/SPEC.md` | What to build, golden examples, milestones with gates, acceptance IDs |
| `REVIEW_PLAYBOOK.md` | give to the reviewer | The audit checklist and the reply format |

The worker also keeps these (created in Milestone 0): `docs/PROGRESS.md` (plan and status), `docs/EVIDENCE.md` (requirement ID, test, command, result), `docs/api-notes.md` (each external fact tagged VERIFIED or UNVERIFIED with its source), `docs/OPEN_QUESTIONS.md` (questions with proposed defaults), `docs/evidence/` (pasted outputs per milestone).

## Starting a new project (about 45 minutes)

1. Copy the templates in. Fill every `[BRACKET]`. The golden examples in the spec matter most: real input and output pairs, taken from screenshots, real data or a reference tool.
2. Write the milestones. Keep the standard order (see the spec template) and make each gate a command with an expected result.
3. Before the worker starts, handle the human-only tasks: clone reference repos into `reference/`, gitignore them, install the tools the e2e tests need (tmux, a browser driver), and capture any logged-in fixtures with a script that never prints secrets.
4. Open the worker with the kickoff prompt below. Always start with Milestone 0 and stop.
5. After each report: paste the report and the previous requirements list to the reviewer using `REVIEW_PLAYBOOK.md`. Send the worker the reviewer's paste-back block. Repeat.

## Kickoff prompt for the worker

```
You are building [PROJECT]. Read AGENTS.md and docs/SPEC.md in full and follow them
exactly. Reference material is in reference/ (read-only).

Start with Milestone 0 only (recon and planning, no app code). Then STOP and report:
what you learned, what is still unknown, and which files or facts you need from me.
Wait for my approval before Milestone 1.

Rules that matter most: never claim something works without pasting real command
output into docs/evidence/; never guess external API shapes; never write library APIs
from memory; keep docs/PROGRESS.md current.
```

## Lessons from the first project

- **Put human-only tasks first.** Credentials, real captures and hardware facts blocked a milestone late. Ask for them in Milestone 0.
- **Never send a message with unfilled placeholders.** The worker will stop, correctly.
- **Say which order dimensions come in** (rows x cols, width x height).
- **Ask for named tests.** "Add a test that X" gets a different test unless you name the behaviour and its expected value.
- **Keep paste-backs short.** Approval, numbered fixes, next-milestone additions. Long messages get partly skipped.
- **Safe by default.** Read-only first, destructive actions behind explicit flags, dry-run for anything that deletes.
- **Run `make check` yourself** every few milestones. Evidence is only as honest as its source.
- **Mock data must never touch real data:** separate files per source.
