# Milestone-gated AI project template (opencode)

Build software with a cheaper model while a **reviewer** agent keeps it honest. You talk to one agent; it manages the other.

```
 you  <->  reviewer (primary agent)  ->  coder (subagent)
           writes plan + rules           writes code, runs commands
           audits the evidence      <-   returns a short report + raw proof
```

## Roles
| Role | Does | Never does |
|---|---|---|
| **You** | Describe the project, give real examples, hold secrets/accounts/hardware facts, approve each milestone, run `make check` yourself now and then | Paste secrets into chat |
| **Reviewer** (`.opencode/agents/reviewer.md`) | Interviews you, fills `AGENTS.md` and `docs/SPEC.md`, writes requirements per milestone, delegates, audits evidence, gives a verdict | Writes application code; edits evidence; approves without proof |
| **Coder** (`.opencode/agents/coder.md`) | Implements one assignment, runs commands through `scripts/ev.sh`, returns a short report | Declares success without proof; guesses APIs; widens scope; edits the spec or the reviewer's files |

## Files
| File | Written by | Purpose |
|---|---|---|
| `AGENTS.md` | reviewer (intake) | Rules for both agents. Loaded automatically by opencode. |
| `docs/SPEC.md` | reviewer (intake) | What to build, golden examples, milestones with gates |
| `docs/REVIEW_PLAYBOOK.md` | template | The reviewer's audit checklist and red flags |
| `docs/reviews/M<n>.md` | reviewer | Requirements, gate, audit table, verdict, fixes (copy of `_TEMPLATE.md`) |
| `docs/PROGRESS.md` | coder | Plan and status. The coder's memory between assignments |
| `docs/EVIDENCE.md` | coder | Requirement ID -> test -> command -> result |
| `docs/evidence/M<n>.md` | coder via `scripts/ev.sh` | Raw command output with exit codes |
| `docs/OPEN_QUESTIONS.md`, `docs/api-notes.md` | coder | Questions with defaults; external facts tagged VERIFIED/UNVERIFIED |
| `scripts/ev.sh` | template | Runs a command and appends its real output to the evidence file |
| `opencode.json` | template | Makes the reviewer the default agent |

## Start a new project
1. Copy these files into your project, keeping the paths. Run `opencode` in the repo. The reviewer opens by default.
2. Pick the model in opencode. Leave `model:` unset in both agent files and the coder inherits the reviewer's model. To use different models, uncomment `model:` in an agent file (`opencode models` lists the ids).
3. Tell the reviewer what you want, for example: *"I want to build X for Y. Start intake."* It asks up to 5 questions at a time. The most valuable thing you can give it is **real examples** (input and expected output, from real data, screenshots or a reference tool).
4. The reviewer fills `AGENTS.md` and `docs/SPEC.md`, shows you a summary and waits. Read it. Check nothing is left: `grep -rn "<<FILL" AGENTS.md docs/SPEC.md` must print nothing.
5. Do the human-only tasks it lists (credentials, reference repos in a gitignored `reference/`, tools to install, captures). Never paste secrets into chat.
6. Say "go". The reviewer writes `docs/reviews/M0.md`, delegates to the coder, audits, and reports. Approve each milestone before it starts the next. After approval, a fresh session (`/new`) per milestone keeps context clean; the files carry all state.

## Running on DeepSeek V4.1 Flash 1017
- The 1M-token context is not the bottleneck. Instruction drift is. That is why the formats are fixed and short, requirements are capped at 8 per round, and the files (not chat history) hold the state.
- Keep `AGENTS.md` and the agent files unchanged during a session: a stable prompt prefix is what prompt caching rewards.
- The model has several reasoning levels (High is the default). If your provider exposes them as variants in opencode, use High or Max for the reviewer, where the audit happens, and Medium for the coder if you want to save cost.
- `steps: 80` caps each agent run. If a milestone gets cut off, the coder reports `INCOMPLETE`; raise `steps` in the agent file.
- Watch for loops, hand-typed evidence, and tests edited to pass. The red-flag list in `docs/REVIEW_PLAYBOOK.md` covers these.

## What the reviewer can and cannot do
It can read the repo and git history, edit `AGENTS.md`, `docs/SPEC.md` and `docs/reviews/*`, and run `make check` itself to compare against the coder's evidence. It cannot run anything else. Live runs, `make e2e` and comparisons with a trusted source stay with you. If you want a stricter reviewer, delete the `"make check*": allow` line in `reviewer.md`.

## Lessons from the first project
- **Put human-only tasks first.** Credentials, real captures and hardware facts blocked a milestone late. Ask for them in M0.
- **Never delegate with unfilled placeholders.** The coder will stop, correctly.
- **Say which order dimensions come in** (rows x cols, width x height).
- **Ask for named tests.** "Add a test that X" gets a different test unless you name the behaviour and its expected value.
- **Keep messages short.** Approval, numbered fixes, next-milestone additions. Long messages get partly skipped.
- **Safe by default.** Read-only first, destructive actions behind explicit flags, dry-run for anything that deletes.
- **Run `make check` yourself** every few milestones. Evidence is only as honest as its source.
- **Mock data must never touch real data:** separate files per source.
