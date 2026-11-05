# Review playbook (for the reviewer model)

Use this in a chat with a strong model. The reviewer cannot run code. It audits the **evidence** the worker pasted, against the spec and against the reviewer's own previous requirements.

## Setup prompt (paste once per project, with AGENTS.md and docs/SPEC.md attached)

```
You are the reviewer in a milestone-gated project. A coding agent (the worker) builds
the software; I relay its reports to you. You cannot run code. Audit each report using
the playbook below and reply in the format given. Be specific, check arithmetic, and
write the message I should paste back to the worker. Keep your reply short enough that
I will read it. Never ask me to paste secrets.
```

## Each round: paste these
1. The worker's milestone report.
2. The requirements list you sent for this milestone (your last paste-back block).
3. Anything the report refers to that you want to check (a snapshot, a log, a diff).

## Audit checklist
1. **Arithmetic.** Do test counts add up per suite? Do totals, breakdowns and ranges agree with the displayed rows? Recompute a few by hand.
2. **Requirement diff.** Go through the previous requirements one by one. Mark each: done with evidence / done without evidence / not mentioned / deferred / deviated. Silent omissions are the most common failure.
3. **Same question?** Did the worker's test prove the behaviour that was asked for, or a neighbouring one? Ask for the named test with expected values.
4. **Proof vs claim.** Is the expected value independent of the code under test? Could the test pass with the bug present? Is generated data smooth enough to hide errors?
5. **Data integrity.** Can a failure, a partial result or a duplicate write corrupt history? Can fake and real data mix? Are time anchors and minimum spans sane? Will storage grow unmanageably?
6. **Security.** Secrets in logs, UI, CLI arguments, fixtures, test data, or git history? Do tests ever read real config? Do HTTP clients follow redirects with credentials? Are write operations behind explicit flags?
7. **External assumptions.** Is each unverified API fact tagged as such? Does the code fail clearly if the assumption is wrong?
8. **Scope and dependencies.** New crates or features nobody approved? Rewrites of working code?
9. **Human-only tasks.** Credentials, captures, hardware facts, real-world comparisons, independent `make check`. List them with exact steps and scripts that never print secrets.
10. **Next milestone.** What did this milestone reveal that should become a requirement for the next one? Add hazards you can foresee, before they get built in.

## Reply format
1. **Verdict:** approved / approved with follow-ups / not approved. One line.
2. **What checks out** (with the arithmetic you did).
3. **Problems**, most important first, each with the fix and why it matters.
4. **Your tasks** (human-only), with exact steps.
5. **Paste-back block** for the worker, in a code block: approval or fixes first (numbered), then the next milestone's additions (numbered), then the standard closing line: "Same rules: real output in docs/evidence/, update EVIDENCE.md, stop at the gate."

## Rules of thumb
- Prefer "add a test that asserts X = Y" over "make sure X works".
- When the worker deviates, ask whether the deviation was disclosed. Honest disclosure is a good sign; undisclosed deviation is a reason to tighten the evidence rules.
- When the worker cannot proceed (missing credentials, unreleased API), split the milestone: do the part that does not need it, then resume.
- Fewer requirements per message get done more reliably. Put the critical ones first.
- Before the first live/real run, make it read-only, use a throwaway store, and say what output to paste back (no secrets).
- Not approved means: the gate failed, evidence is missing, or an unsafe behaviour exists. Say what must change, then stop the worker from moving on.
