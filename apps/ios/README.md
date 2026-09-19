# ZEEKR Key for iPhone

A SwiftUI app for iOS 18 or later. Open [Zeekr.xcodeproj](Zeekr.xcodeproj).
There is no watch target in this release.

## Available now

- Vehicle screen with an original vehicle illustration and large access controls.
- Searchable catalog of every control group from the [research](../../docs/research/capabilities.md).
- Clear evidence and blocking reasons for unavailable controls.
- Local command demos with observed state, receipt only, rejection, timeout, and link loss.
- Proximity demo with a filtered synthetic signal, separate thresholds, dwell, and cooldown.
- Read-only BLE service discovery with a 20-second limit. It does not connect or authenticate.
- Local test history and a share action for a report without vehicle identifiers.
- Shortcuts that open the controls or proximity page. They do not execute vehicle commands.

**This version cannot control the car.** The owner selected app-first work and
deferred key enrollment on 2026-09-19. Enrollment, trust validation, the encrypted
session, real commands, and live proximity remain blocked. The app does not claim
that these functions work. AC is unavailable; ventilation is a separate entry.

## Try the interface

1. Open the key button on the vehicle screen.
2. Enable **Demo mode**. The mode returns to off when the process starts again.
3. Select Unlock, Lock, or another mapped control. Choose the test response.
4. Run the demo and inspect **Activity**. A receipt alone never changes lock state.
5. Open **Proximity**. Start the demo, then select **Near**. Wait for the filter and dwell.
6. Select **Far**. Wait for the cooldown, filter, and dwell. A confirmed demo result returns the policy to the approach state.
7. Select **Signal lost**. The state must remain unconfirmed. Stop and restart the demo to recover.

The demo stops when the app becomes inactive. The thresholds are synthetic test
values, not calibration. Real background proximity is not implemented. Bluetooth
permission is requested only when the owner starts discovery.

## Build and install

From the repository root:

```sh
make check
make test
make ios-build
make ios-test
```

`make ios-test` selects an available iPhone simulator with iOS 18 or later. Set
`ZEEKR_SIMULATOR_ID` to select one explicitly. Tests cover the app state and UI.

For signing, create `.local/Signing.xcconfig` with these local values:

```text
DEVELOPMENT_TEAM = your-team-id
ZEEKR_BUNDLE_ID = your.unique.bundle.id
```

Then run `make ios-device-build`. Xcode must have a valid Apple developer account.
The signed app is at `.local/DeviceBuild/Build/Products/Debug-iphoneos/Zeekr.app`.
Use `xcrun devicectl list devices` to find the connected iPhone. To install:

```sh
xcrun devicectl device install app --device YOUR_DEVICE_ID .local/DeviceBuild/Build/Products/Debug-iphoneos/Zeekr.app
```

Alternatively, select the local development team and bundle ID in Xcode, select
the iPhone, and run. Keep local signing changes out of Git. Developer Mode must
be enabled on the phone. Installation and a working interface do not prove a
vehicle command or Bluetooth compatibility.

## Next vehicle step

Complete a supported GCC enrollment route and certificate policy. Resolve the
shared-point derivation, nonce behavior, reconnect path, and response association
before adding authenticated transport. See the [protocol research](../../docs/research/ble-protocol.md).
Then use the [device test plan](../../docs/testing.md). Do not enable controls from
a discovery match, a source constant, or a successful write alone.
