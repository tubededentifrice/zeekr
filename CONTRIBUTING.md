# Contributing

1. Read [AGENTS.md](AGENTS.md) and the documents that apply to the task.
2. Keep research claims tied to a source or a recorded device test.
3. Keep private research data in `.local/`. Use synthetic data for public test fixtures.
4. Run `make check`. For future app changes, also run the applicable build, unit, and device checks.
5. Inspect the staged diff. Commit completed changes directly to `main` and push to `origin main`, unless the user specifies otherwise.
6. If the remote has new commits, fetch and reconcile them without loss of work. Do not force-push.
7. Report the change, check results, remaining limits, and commit ID.

Do not add app code during the setup phase. Do not add dependencies without a concrete use. Use ASD-STE100 Simplified Technical English in written work.
