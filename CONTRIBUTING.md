# Contributing

1. Read [AGENTS.md](AGENTS.md) and the documents that apply to the task.
2. Keep research claims tied to a source or a recorded device test.
3. Keep private research data in `.local/`. Use synthetic data for public test fixtures.
4. Run `make check`. For future app changes, also run the applicable build, unit, and device checks.
5. After a significant task, run [selfreview](.agents/skills/selfreview/SKILL.md) in automode before commit or push, as required by [AGENTS.md](AGENTS.md). Wait for the review and its fixes. Resolve material findings and required check failures, then inspect the integrated and staged diff.
6. Commit completed changes directly to `main` and push to `origin main`, unless the user specifies otherwise. Review any later material change before publishing it.
7. If the remote has new commits, fetch and reconcile them without loss of work. Review material integration changes and repeat the affected checks. Do not force-push.
8. Report the change, self-review result, check results, remaining limits, and commit ID.

Do not add app code during the setup phase. Do not add dependencies without a concrete use. Use ASD-STE100 Simplified Technical English in written work.
