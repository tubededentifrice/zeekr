# ZEEKR Bluetooth key for iPhone and Apple Watch

This repository contains an iPhone app, shared Swift policy code, and vehicle protocol research. The app has a vehicle interface, a complete control catalog, local command and proximity demos, and read-only Bluetooth discovery. Key enrollment and real vehicle commands are not implemented.

The first target is a **2024 GCC ZEEKR 001**. The owner uses the official **ZEEKR** app. Its manual Bluetooth key works. It does not automatically lock or unlock this car.

The owner selected app-first work and deferred key enrollment on 2026-09-19. The phone comes first; the watch follows phone validation. The later watch must operate directly with the car when the phone is absent. The iPhone interface uses a simple vehicle view and quick controls, with a dark appearance.

## Current findings

- OpenZeekr reports working BLE lock and unlock on an EU vehicle. GCC support is not confirmed.
- Its source lists more BLE controls, but most need tests on this car.
- Full AC control is sent through the cloud in OpenZeekr. Its BLE ventilation byte does not prove cooling, temperature control, or an AC stop command.
- A watch can use Core Bluetooth directly. Background operation has limits. Automatic access needs separate tests on both Apple platforms.
- OpenZeekr obtains digital key credentials through online enrollment. A fully offline enrollment method has not been established.
- The owner has a UAE account and Digital Key 1.0. A separate shared account is the preferred enrollment candidate; regional signing and Bluetooth permissions still need proof. See [the enrollment study](docs/research/key-enrollment.md).
- Replacing the physical key also requires drive authorization, restart, offline, key expiry, and recovery tests. Unlock alone is not enough.

Read [the findings](docs/research/findings.md) first. They include the source limits and the problems found in the reference implementation.

## Development setup

Run these commands from the repository root:

```sh
make check
make doctor
make test
make ios-build
make ios-test
```

`make check` uses Python 3.10 or later and Git. It checks document links, text format, research records, and selected secret file patterns. It makes no vehicle or network requests. `make doctor` checks the local Apple development tools.

Open [the iPhone project](apps/ios/Zeekr.xcodeproj). See [the app guide](apps/ios/README.md) for demo tests, signing, and installation. The app needs iOS 18 or later. Simulator tests and a signed build do not prove car support. The target structure is in [development](docs/development.md).

## Documents

| Document | Purpose |
| --- | --- |
| [Requirements](docs/requirements.md) | Product scope and acceptance conditions |
| [Research findings](docs/research/findings.md) | Main conclusions and limits |
| [Official app](docs/research/official-app.md) | App identity, public features, and evidence gaps |
| [Key enrollment](docs/research/key-enrollment.md) | UAE routing, shared account, key binding, and work possible away from the car |
| [BLE protocol](docs/research/ble-protocol.md) | Discovery, enrollment, session, and command details |
| [Capability matrix](docs/research/capabilities.md) | Every control group found in the review |
| [Apple platform limits](docs/research/apple-platforms.md) | iPhone, watch, shortcuts, and background operation |
| [Architecture](docs/architecture.md) | Shared core and independent device command paths |
| [Device test plan](docs/testing.md) | Tests needed before key replacement |
| [Work plan](docs/roadmap.md) | Ordered research and implementation steps |
| [Source records](research/sources.json) | URLs, source types, and pinned upstream revision |
| [Security](SECURITY.md) | Credential and vehicle command rules |
| [Contributing](CONTRIBUTING.md) | Checks and direct commits to main |

This project is independent of ZEEKR, Geely, ECARX, Tesla, and Apple. See [third-party sources](THIRD_PARTY_NOTICES.md).
