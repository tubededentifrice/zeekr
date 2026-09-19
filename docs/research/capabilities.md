# Capability matrix

This is a research catalog. **No project command is enabled or tested on the GCC car.** “Source” means a code mapping exists. “Upstream report” means OpenZeekr reports a test on its vehicle. A missing BLE mapping means “not found in this review,” not proof that the car can never support it.

Main sources: [DkProtocol.kt](https://github.com/borconi/openzeekr/blob/00661111f77fd613938309b8fb3f691ac79388f7/core/src/main/java/com/openzeekr/app/ble/DkProtocol.kt), [VehicleControl.kt](https://github.com/borconi/openzeekr/blob/00661111f77fd613938309b8fb3f691ac79388f7/core/src/main/java/com/openzeekr/app/remote/VehicleControl.kt), and [Command.kt](https://github.com/borconi/openzeekr/blob/00661111f77fd613938309b8fb3f691ac79388f7/core/src/main/java/com/openzeekr/app/remote/Command.kt).

## Basic BLE control catalog

These bytes are the control value inside `0x0110`, not complete frames.

| Control | Byte | Evidence and limit |
| --- | --- | --- |
| Unlock | `0x01` | Upstream reports working BLE actuation; target project test pending |
| Lock | `0x02` | Upstream reports working BLE actuation; target project test pending |
| Locate car with lights/horn | `0x03` | Source maps the combined action; physical pattern needs a test |
| Hood/frunk release | `0x04` | Source mapping; hardware and exact movement are unknown |
| Panic search | `0x05` | Constant only; not exposed by the general dispatcher |
| Trunk unlock/release | `0x06` | Source mapping; release is not proof of powered opening |
| Trunk lock | `0x07` | Source mapping; lock is not proof of powered closing |
| Remote engine start | `0x08` | Constant only; do not label it AC or drive authorization |
| Key inside | `0x09` | Protocol constant; not a normal user action |
| RPA start | `0x0A` | Upstream reports rejection; excluded from initial implementation |
| Key outside | `0x0B` | Protocol constant; not a normal user action |
| Windows up | `0x0C` | Source mapping; extent and anti-pinch behavior need tests |
| Windows down | `0x0D` | Source mapping; extent needs a test |
| Cabin ventilation | `0x12` | Upstream comment reports a receipt and no window movement; actual cooling is not established |
| Charge flap | `0x13` | Source maps open; no separate close mapping found |

The source also defines null `0x00` and undefined `0xFF`. They are not product controls.

## Proximity and key functions

| Function | Reference path | Evidence and limit |
| --- | --- | --- |
| App-driven approach unlock | RSSI policy, then `0x0110 / 0x01` | Android upstream report; Apple background proof required |
| App-driven walk-away lock | RSSI policy, then `0x0110 / 0x02` | Reference can use cloud fallback; BLE-only reliability unproven |
| Vehicle approach setting | `0x0151`, type `0x01`, enable/disable | Source constant; not armed by the current car-side controller |
| Vehicle walk-away setting | `0x0151`, type `0x02`, enable/disable | Experimental source path with calibration |
| Vehicle auto-lock event | `0x0159` | Source event; needs a target capture |
| Passive start / drive authorization | Authenticated key presence | Official EU description and upstream key claim; GCC phone/watch test required |
| Enrollment, sharing, revocation | Online account and DK services | Source flow; GCC endpoints and device rules unknown |
| BLE vehicle state | `0x0120` / `0x0121` family | Partial source definitions; no complete target decoder |

## Other app controls

These controls appear in the official product description or the reference cloud catalog. No verified BLE path was found for them.

| Control group | Reference cloud service | BLE status |
| --- | --- | --- |
| AC start, stop, temperature, duration | `ZAF`, `AC`, `AC.temp`, `AC.duration` | Unresolved; first-priority research |
| Cabin ventilation on/off | `RCC`, `rcc.conditioner`, `rcc.ventilation` | BLE `0x12` is a lead only; no paired stop or parameters confirmed |
| Defrost | `ZAF`, `DF` | No mapping found |
| Seat heat and ventilation | `ZAF`, `SH.<position>`, `SV.<position>` | No mapping found |
| Steering wheel heat | `ZAF`, `SW` | No mapping found |
| Fragrance and fridge | `RFD`, `ZAE` | No mapping found; equipment dependent |
| Powered tailgate open/close | `RDU_2`, `RDL_2` | Do not infer from BLE latch/lock bytes |
| Charge flap close | `RDC` | No mapping found |
| Window vent position | `RWS`, target `ventilate` | Source explicitly rejects mapping this to `0x12` |
| Sunroof and sunshade | `RWS` | No mapping found; equipment dependent |
| Charge start/stop and target SOC | `RCS` | No mapping found |
| Battery preheat | `ZAN` | No mapping found |
| Separate light flash or horn | `RHL` | Combined locator byte exists; separate controls unproven |
| Sentry mode | `RSM` | No mapping found |
| Private locker | `RDL` / `RDU` | No mapping found |
| Glovebox lock and visitor mode | `ZAD`, `ZAG` | No mapping found |
| Remote engine stop | `RES` | No mapping found |
| Battery, range, tire pressure, location, journeys | Cloud status and other APIs | BLE data availability unresolved |
| Charging/departure schedules | Cloud scheduling | No mapping found; upstream saving is also reported broken |
| Camera footage / live view | Sentinel service | No BLE route found; regional cloud limits do not establish a GCC result |
| Remote parking motion | RPA BLE protocol family | Upstream rejection; outside initial scope |

Keep one shared capability definition for the phone, watch, and shortcuts. A later target test must record firmware, device, action, response, and physical effect before an entry becomes supported. Keep unsupported controls visible in the setup capability report with a reason; do not present them as working action buttons.
