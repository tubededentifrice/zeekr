# Device test plan

No vehicle tests have been run by this project. Use [the observation template](templates/device-observation.md) and [the compatibility template](templates/compatibility-profile.json).

## Test conditions

Use a parked vehicle in a controlled location for access and comfort tests. Keep the physical key available for recovery. For proof of digital-key access or start, keep it and all other enrolled devices outside detection range. Clear people and objects from any panel that will move.

Record model year, market, firmware, app version, device/OS, key type, connection state, network state, starting vehicle state, and physical result. Public records must use a synthetic vehicle reference, not a VIN or location.

## Required cases

| Area | Cases | Required evidence |
| --- | --- | --- |
| Discovery | Awake car, sleeping car, another ZEEKR nearby, stale peripheral ID | Only the selected authenticated car receives commands |
| Enrollment | New key, shared key, second device, interrupted setup | Existing working keys remain understood; new key is synchronized |
| Authentication | First pair, reconnect, wrong certificate, expired key, missing trust store | Invalid sessions never become ready |
| Manual access | Lock and unlock, phone and watch, network off | Vehicle effect matches the result shown |
| Watch independence | Phone powered off; watch Wi-Fi/cellular off | Direct watch BLE operation |
| Drive authorization | Enter, press brake/start, drive-ready state, restart after locking | No physical key or other enrolled device provides authorization |
| AC | Start, stop, setpoint if supported, locked car, low SOC | Actual cooling and state change; record cabin behavior |
| Other controls | Each enabled byte, equipment variants, invalid vehicle state | Exact physical effect and rejection behavior |
| Proximity | Approach, exit, stop near threshold, pass beside car, remain indoors nearby | Counts of correct actions, missed actions, and false actions |
| Background | Screen locked, wrist down, hours idle, Low Power Mode, OS termination | Measured wake and action delay on each supported OS |
| Relaunch | Force quit, Bluetooth off/on, Airplane Mode, reboot before/after first unlock | Behavior matches the exact Apple rules and setup route |
| Link loss | Loss before send, after write, after receipt | No false locked result; uncertain outcomes stay uncertain |
| Device competition | Phone and watch present; official app holds link; handover interruption | Bounded waits and recovery without endless reconnect loops |
| Lock conditions | Open door/trunk, device inside car, other key inside, passenger remains | No unsupported automatic assumption about vehicle state |
| Shortcuts | Phone action, watch action, face tap, locked device, phone absent | Local execution, authentication behavior, accurate completion |
| Recovery | Key expiry, account session displacement, lost watch, revocation offline | Clear limits; local deletion is not reported as vehicle revocation |

## Release evidence

Define numeric limits before the field campaign: maximum action delay, battery use, acceptable missed events, and trial count. Record every false unlock and unconfirmed exit lock as a release blocker. A short successful demonstration does not establish reliable key replacement.

Use repeated sessions over several days, different parking conditions, and device placements. Record median and worst observed latency and the number of trials. Do not invent reliability percentages before measurements exist.

Future automated tests must cover frame fragmentation, invalid lengths and versions, bad CRC/tags, untrusted certificates, sequence boundaries, handshake failures, timeout races, and stale proximity data. They must test behavior, not only mirror constants.
