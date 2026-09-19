# Repository instructions

- Use ASD-STE100 Simplified Technical English for user reports, documents, code comments, commit messages, and pull requests.
- When a task is complete, run the applicable checks, commit the changes, and push directly to `main`, unless the user specifies another workflow.
- Do not use a feature branch or a pull request by default. Do not force-push. Preserve changes from other contributors.
- This project is in the research and setup phase. Do not implement the iOS app, watchOS app, or vehicle protocol until the user requests implementation.
- Read [README.md](README.md), [the requirements](docs/requirements.md), and [the research findings](docs/research/findings.md) before work on the apps.
- The first target is a 2024 GCC ZEEKR 001. Its official ZEEKR app has a working manual Bluetooth key. Automatic approach unlock and walk-away lock do not work in that app on this car.
- Vehicle commands must use Bluetooth only. Do not add a cloud fallback. Treat online key enrollment as a separate, unresolved setup requirement.
- Keep the watch command path independent of the phone after key setup. Do not claim that a phone relay satisfies this requirement.
- Separate source observations, upstream test reports, and tests on the target car. Never treat a command constant or a transport receipt as proof of vehicle actuation.
- Do not put account data, VINs, private keys, app secrets, raw vehicle captures, or official app binaries in Git. Use `.local/` for private research files.
- Keep unknown capabilities disabled. Do not probe unknown vehicle commands or use a motion command as a connection check.
- Run `make check` before each commit. Add the applicable build and device checks when implementation starts.
