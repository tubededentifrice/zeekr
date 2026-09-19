# Work plan

## Phase 0: repository and research

Complete in this change: requirements, source review, protocol notes, Apple platform assessment, capability catalog, repository checks, and direct-main workflow. App implementation is not part of this phase.

## Phase 1: resolve feasibility

1. Confirm the official regional app, vehicle firmware, phone, and watch.
2. Test all visible official-app controls with phone internet disabled and Bluetooth enabled.
3. Resolve the GCC enrollment route, account session effects, key count, and watch identity support.
4. Establish whether AC start, stop, and temperature control have a BLE route.
5. Verify the GATT advertisement and authentication variant. Resolve reconnect and crypto constraints.

Exit condition: a reviewed protocol profile for the target car, or a clear list of requirements the available protocol cannot satisfy. AC failure must be reported before a UI implies it works.

## Phase 2: protocol and manual key

After the user requests implementation, build pure protocol modules and meaningful fixture tests. Then add a diagnostic phone session for enrollment, authentication, manual lock/unlock, and drive authorization. Require offline device evidence and accurate result handling.

## Phase 3: independent watch

Add watch credentials, direct BLE, and bounded device handover. Repeat manual controls with the phone powered off. Test watch removal, passcode lock, reboot, revocation, and key expiry.

## Phase 4: controls and local shortcuts

Expose every confirmed BLE capability on both apps. Add App Intents, phone widgets, and watch complications. Complete the AC shortcut only after its BLE behavior is proven. Check that the watch executes locally.

## Phase 5: automatic access

Measure foreground and background behavior on each device. Test app-driven proximity and vehicle-side settings separately. Set acceptance thresholds from repeated field results. Enable proximity only on profiles that pass.

## Phase 6: physical-key replacement

Run [the full test plan](testing.md), including entry, start, long offline periods, failure recovery, and loss of a device. Record the exact supported hardware and firmware. Keep any unmet conditions visible in the product.
