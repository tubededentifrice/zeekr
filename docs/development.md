# Development setup

## Available now

- Git rules, text format rules, private-file exclusions, and contribution instructions.
- Research records, requirements, architecture, and device test templates.
- `make check` for repository checks, using Python 3.10 or later without third-party packages.
- `make doctor` for Git, Python, Xcode, Swift, and Apple SDK discovery.
- A read-only GitHub Actions check on pushes to `main` and on pull requests.

The setup machine reported Xcode 27.0, build `27A266a`, on 2026-09-19. This is an environment observation, not a claim that an app build passed.

## Future Apple targets

Create the Xcode project only when implementation is requested. Add iOS and watchOS app targets, their widget extensions, shared Swift modules, and unit tests. Use Swift 6 concurrency checks where the selected toolchain supports them. Use actors or a serial executor for session ownership.

Keep bundle identifiers, development team, signing profiles, and local enrollment configuration out of shared defaults. Document required capabilities next to each target. Add a reviewed project generator only if it removes a concrete maintenance problem.

Add CI in stages: pure protocol tests, unsigned simulator builds, then controlled physical-device tests outside public CI. Do not add a successful placeholder build job when no app exists. Pin dependency revisions when real dependencies are selected.

## Private research workspace

Use `.local/` for app packages, captures, and device records. Git ignores this directory. Record only sanitized conclusions and synthetic fixtures in tracked files. Ignore rules do not remove already tracked files; inspect staged changes before each push.

The OpenZeekr clone used for this review was outside the repository. The pinned commit and source links make the review reproducible without including third-party source or secrets.
