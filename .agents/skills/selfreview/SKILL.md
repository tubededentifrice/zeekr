---
name: selfreview
description: Review recent ZEEKR repository changes for defects, missing work, unsupported claims, and unintended effects before commit or push. Use after significant code, research, document, or tooling tasks; automode fixes material findings and runs the applicable checks.
---

# Self-Review

Review the current task against the user request, its requirements, and the
repository rules. This skill is adapted from the selfreview skill in
`labelmaker-universal`. It has no runtime dependency on that repository.

## Modes

- **Interactive** is the default for an explicit invocation without a mode.
  Report material findings and apply fixes that the user has authorized. Ask
  for a decision only when the required fix is outside that authority or needs
  a product choice.
- **Automode** fixes all task-owned `BUGS`, `MISSING`, and `RISKY` findings without
  a user prompt. Use it for `$selfreview automode`, `--automode`, or the automatic
  end-of-task review required by [AGENTS.md](../../../AGENTS.md).

Do not commit or push from the review. Return control to the task owner after
the review and checks finish. A review subagent must not start another automatic
review subagent for its own fixes.

## 1. Establish the scope

Read the user request and [repository rules](../../../AGENTS.md). Read the
documents that govern the changed work. For product or protocol changes, these
include [requirements](../../../docs/requirements.md),
[architecture](../../../docs/architecture.md),
[research findings](../../../docs/research/findings.md), and
[security rules](../../../SECURITY.md).

Inspect the working tree and task history:

```sh
git status --short
git diff --stat
git diff
git diff --cached
git log --oneline -5
```

Use the task's starting status, starting commit, and owned paths to identify its
changes. Inspect task-owned untracked files directly; `git diff` omits them.
If the task already has commits, review the range from its starting commit too.
Do not assume `main...HEAD` has a diff when work occurs directly on `main`.

Do not edit, stage, or report unrelated changes as task findings. If the task
boundary is unclear, establish it before modifying shared files.

## 2. Review the relevant behavior

Trace changed behavior through callers, inputs, failure paths, and user-visible
results. Check the complete task, not only the lines that changed. Apply only
the sections that relate to the task.

### Correctness and evidence

- Compare the result with the request and the applicable requirements. During
  setup, do not add app or protocol implementations unless requested.
- Keep owner reports, source observations, upstream reports, and target tests
  distinct. Check source revisions and links for new protocol claims.
- Do not infer GCC support from EU tests, AC cooling from ventilation, or
  physical-key replacement from successful unlock alone.
- Check frame bounds, byte order, units, sequence handling, response
  association, timeout, cancellation, and reconnect behavior where changed.
- Check callers and stored formats after interface changes. Update the owning
  document when a contract or supported capability changes.
- Require meaningful tests for changed protocol or failure behavior. Use
  synthetic or reviewed sanitized fixtures. Do not require new tests for a
  spelling correction or tests that only repeat implementation constants.

### Vehicle commands and credentials

- Keep vehicle commands on BLE. Do not add a cloud fallback or make a phone
  relay necessary for watch commands. Keep enrollment separate from control.
- Require authentication before control. Check certificate validation, key
  storage, crypto constraints, and failure states where the task changes them.
- Distinguish radio write, command receipt, command result, and vehicle state.
  Link loss must not become a confirmed lock result.
- Keep unknown commands disabled. Do not use motion commands as diagnostics
  or sweep unknown opcodes during review.
- Check that errors, logs, fixtures, and staged files contain no credentials,
  VINs, raw private captures, or official app binaries.

### iPhone, watch, and interface

- Keep protocol and command policy shared where practical. Keep platform
  lifecycle and UI work in the corresponding targets.
- Check local intent execution, competing sessions, phone absence, and stale
  state for changes to watch commands or shortcuts.
- Check actual iOS and watchOS background limits for proximity changes. A
  foreground test or complication does not prove continuous operation.
- Check accessible labels, control size, disabled states, and error feedback
  for UI changes. Do not display unverified capabilities as working controls.
- Inspect current rendered output for material visual changes once app targets
  exist. Do not create app scaffolds or screenshots for a non-visual task.

### Scope and maintenance

- Use `rg` to find stale callers, names, links, and assumptions.
- Check that new dependencies and abstractions have a concrete purpose.
- Exclude generated output and private research files from the task diff.
- Do not turn optional cleanup or a hypothetical risk into a required finding.

## 3. Record findings

Use these groups:

- `BUGS`: wrong behavior caused by the change.
- `MISSING`: required work that is absent.
- `RISKY`: failure under a specific realistic condition.
- `NITPICKS`: optional small improvements.

Each finding must give `file:line`, the trigger, the effect, and a specific fix.
For missing content, cite the nearest owning section. An empty report is valid.

## 4. Fix and check again

In automode, fix every material task-owned finding within the user's authority.
Fix a nitpick only when it is small, safe, and in scope. Review the resulting
diff after fixes. Do not expand a review into unrelated work or vehicle tests.

If a fix needs new authority, unavailable hardware, or a product decision,
report the exact blocker. Do not claim the missing validation passed. Separate
a release-blocking defect from a device test that is explicitly deferred in the
current research task. A known research gap alone does not block a document-only
commit.

## 5. Complete the review

Run `make check`. Run the additional checks required by the changed behavior.
Use [the device test plan](../../../docs/testing.md) to identify hardware checks,
but run them only when they are within the current authorized task. Do not
require app builds while no app targets exist.

If unrelated work causes a check failure, preserve that work, run useful focused
checks, and report the blocker. Report checks not run and their practical limits.

Return a concise summary of scope, findings, fixes, checks, and unresolved
blockers. Use ASD-STE100 Simplified Technical English. State whether the task
changes are ready for the task owner to commit. Any later material change needs
review of the affected part before commit or push.
