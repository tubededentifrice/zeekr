# Requirements

Research date: 2026-09-19. Status: iPhone interface and local test release; enrollment deferred.

## Target and scope

The owner confirmed a 2024 GCC ZEEKR 001 and a working manual Bluetooth key in the official ZEEKR app. Automatic lock and unlock do not work through that app on this car. The development tools detect an iPhone 17 Pro on iOS 27.0 and global app `com.zeekr.global` version `1.6.6`. The owner confirmed a UAE account and an owner Digital Key 1.0. Vehicle firmware remains unknown.

On 2026-09-19, the owner requested the iPhone app first and selected key enrollment as the next step. This release must expose all researched controls with accurate limits, provide local command and proximity tests, and build for the physical phone. Real commands remain blocked until enrollment and protocol work are complete. The watch is deferred until phone validation.

Use this vehicle as the first compatibility profile. Add other models and regions only after evidence supports them.

| ID | Requirement | Acceptance condition |
| --- | --- | --- |
| R01 | Manual lock and unlock on iPhone | Direct BLE operation with phone internet off |
| R02 | Manual lock and unlock on Apple Watch | Direct BLE operation with the phone powered off and watch internet off |
| R03 | Approach unlock | Repeated entry tests on each supported device, including a locked screen and background state |
| R04 | Walk-away lock | Verified lock before loss of range, or a verified vehicle-side lock function; no cloud fallback |
| R05 | All available manual BLE operations | One capability catalog for both apps; each control has evidence and a device test |
| R06 | AC quick action | Actual cooling starts over BLE; fan operation or a receipt alone is insufficient |
| R07 | Local shortcuts | Supported commands can be started through App Intents on each device |
| R08 | Watch face access | A complication opens the selected local action; use direct intent execution only where the platform supports it |
| R09 | Phone absent | Watch commands use credentials on the watch and the watch radio |
| R10 | Replace the physical key | Entry, drive authorization, restart, key expiry, and recovery tests pass on each device |
| R11 | Simple vehicle interface | Vehicle view, connection state, lock state, climate, and quick controls; no unnecessary account or community pages |
| R12 | Accurate feedback | Distinguish sent, received, rejected, timed out, and observed vehicle state |

The phrase “open/close the car” means unlock/lock in the proximity requirement. Automatic movement of doors, windows, or the tailgate is not included. Such movement remains a separate manual capability if the car supports it.

Keep the interface concise. Do not add help cards, repeated explanations, or
development instructions to normal screens. Show only relevant status, errors,
and short reasons for unavailable controls. Put detailed evidence in optional
compatibility details and project documents.

## Bluetooth boundary

Vehicle commands use BLE only. A failed command must not silently use cellular data, Wi-Fi, or a phone relay. Beyond car BLE range, a local command cannot reach the vehicle. A cellular Apple Watch does not extend BLE range.

The reference key enrollment uses the ZEEKR cloud. The proposed boundary is online enrollment and revocation, with offline use after enrollment. This is a research conclusion, not an implemented exception. Confirm a supported route before live enrollment. The current candidate is a separate UAE account with shared vehicle access; Bluetooth permission and regional inputs remain unverified. See [the enrollment study](research/key-enrollment.md). Do not promise that initial setup can be fully offline.

## Priority and unknowns

Manual entry, drive authorization, and AC over BLE are the first feasibility tests. Full AC remains a requirement even though no confirmed BLE route was found. If it is unavailable, report the unmet requirement; do not replace it with a ventilation button.

Proximity must be assessed separately on iPhone and watch. A watch app that works while open does not prove automatic entry with the screen off.

Cloud remote controls, location tracking, camera video, charging schedules, and vehicle motion are outside the first implementation scope. Keep their research records so that a later verified BLE route can be assessed.
