# Development setup

## Available now

The iPhone app uses Swift 6, SwiftUI, Core Bluetooth, and a local Swift package.
Its deployment target is iOS 18. There are no external code dependencies and no
watch app target. The watch will follow phone validation.

The owner selected an app-first release on 2026-09-19. This release has a complete
control catalog, local demos, and read-only Bluetooth discovery. It has no
vehicle command transport or key enrollment. See [the app guide](../apps/ios/README.md).

## Checks

```sh
make check
make doctor
make test
make ios-build
make ios-test
```

`make check` uses Python 3.10 or later and Git. It checks links, text format,
research records, and selected private-file patterns. `make test` checks the
shared command gate and proximity policy. `make ios-test` checks the app model
and interface. The local tests include screenshots for visual inspection.

CI runs repository checks on Linux and shared tests plus a simulator build on
macOS. Physical-device and vehicle tests remain local. The setup machine has
Xcode 27.0, build `27A266a`. The detected iPhone 17 Pro runs iOS 27.0 with
Developer Mode enabled. These are environment observations.

## Signing

Shared defaults use a placeholder bundle identifier and no team. Store the real
team and bundle ID in `.local/Signing.xcconfig`. See the app guide for the two
settings. `make ios-device-build` reads this private file. It permits Xcode to
update development provisioning. Do not commit signing profiles or account data.

The Xcode project uses synchronized source groups. Add Swift files under the
app or test directory; Xcode includes them in the corresponding target. The
shared package is in `packages/VehicleCore`.

## Private research workspace

Use `.local/` for build results, screenshots, app packages, captures, signing
settings, and device records. Git ignores this directory. Record only sanitized
conclusions and synthetic fixtures in tracked files. Inspect staged changes
before each push.

The pinned OpenZeekr revision and source links make the research reproducible
without including third-party source or secrets.
