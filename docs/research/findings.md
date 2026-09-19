# Research findings

Research date: 2026-09-19.

The project has a useful BLE reference, but the complete requested feature set is not yet proven. No commands were sent to the owner's vehicle. No account was used and no key was enrolled.

## Evidence levels

- **Owner report:** behavior reported for the target car.
- **Official publication:** manufacturer or Apple product documentation. It can describe a different region or model.
- **Source observation:** behavior visible in the reviewed source code.
- **Upstream test report:** a result reported by OpenZeekr. It is not a test on the target car.
- **Target test:** a recorded test on this 2024 GCC 001. None exists yet for this project.

Sources and their limits are in [sources.json](../../research/sources.json). OpenZeekr is pinned to commit `00661111f77fd613938309b8fb3f691ac79388f7`.

## Main conclusions

| Need | Finding | Next proof required |
| --- | --- | --- |
| Manual phone key | The owner's official key works. OpenZeekr reports BLE lock/unlock on an EU car. | Enroll a project identity for the GCC car and test it offline |
| Independent watch key | OpenZeekr reports direct Wear OS lock/unlock with a copied phone key. Apple supports direct BLE. | Apple Watch enrollment, direct session, and phone-off tests |
| Automatic entry | OpenZeekr uses Android background services and RSSI. The owner's official app lacks this behavior. | Apple background tests and false-unlock tests |
| Automatic exit lock | OpenZeekr has both BLE logic and a cloud lock fallback. Vehicle-side lock is unfinished research. | Demonstrate a BLE-only result before range is lost |
| Start AC | OpenZeekr sends full climate commands through cloud service `ZAF`. | Identify and test an actual BLE AC command |
| All manual BLE controls | A small control-byte catalog exists. Not all entries are tested. | Test each command and its effect on the exact car |
| Leave the key at home | Official EU material describes passive start with a connected Bluetooth key. | Confirm start and drive authorization on GCC, on phone and watch |

## Source issues that affect a port

The README reports a working key, but the pinned code has limits that a direct translation would retain:

1. `RealDkSession.establish()` throws for reconnect state `0x1012`. Only its `0x1011` path is implemented.
2. Failure in the `0x010B` digital-key exchange is caught. The code can then set `isEstablished = true`. A future implementation must require successful authentication.
3. `DkTrust.requireGeelyVehicleCert()` allows the connection if the trust store is empty. Its non-empty path tests leaf signatures, not a complete certificate and selected-vehicle policy.
4. `RealDkSession.control()` treats a receipt without a later result as confirmed. `DkLockController` returns a write result, and the watch can display “Locked” from that result. Neither proves the physical lock state.
5. `ping()` sends an RPA-start control because the reference car rejects it. This is unsuitable as a general connection check.
6. GCM uses the same key and nonce within a session. The sequence is inside the encrypted plaintext. This does not prevent nonce reuse.
7. Debug paths format session keys and digital key material. Do not copy this logging behavior.
8. Proximity documentation and current defaults differ. The README mentions a large RSSI gap; the current sensitivity presets use an 8 dB gap. Neither is a calibrated value for this car or watch.

These are source observations, not claims that the official app has the same defects. See [the protocol review](ble-protocol.md) for exact files.

## Official app analysis limit

The review directly inspected official store metadata and official ZEEKR product documentation. It also inspected OpenZeekr code that attributes protocol details to Android app analysis. A later read-only device query confirmed the installed global iOS app and version. The owner described its key and sharing pages. The installed iOS binary, live screen capture, and BLE traffic were not inspected. Therefore this is not a completed binary or runtime analysis of that app.

The next research step is a controlled official-app test with network access disabled. Record the visible BLE controls and actual vehicle effects. Capture only the information needed to resolve command and enrollment gaps. See [official app research](official-app.md).

## Enrollment study

The owner confirmed the UAE account and an owner Digital Key 1.0. The official
app has a separate vehicle-share action by email. The preferred candidate is a
secondary UAE account with shared vehicle access and a new app-generated key.
Whether the share includes Bluetooth-key access remains unconfirmed.

The API library has a Middle East TSP host candidate. Request-signing material,
the actual country routing, UAE project ID, and xchanger settings remain open.
An unsigned regional lookup returned a signature-required response. No account
login or key operation was attempted.

The owner branch in the reference does not bind an existing owner key to a new
device before download. It is not a proven way to retain the current owner key
and add our client. Shared binding and synchronization errors can also be ignored
by the reference. See [the detailed study](key-enrollment.md) before a port.
