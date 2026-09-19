# Apple platform findings

## Direct watch control

[Core Bluetooth](https://developer.apple.com/documentation/corebluetooth) is available on watchOS. A watch can act as a BLE central and communicate directly with the car. It still needs compatible credentials and sufficient radio range.

Plan a watch app that runs independently after setup. Apple describes [independent watchOS apps](https://developer.apple.com/documentation/watchos-apps/creating-independent-watchos-apps). Watch Connectivity can help when the phone is present, but it cannot be the required command transport. Do not claim independent App Store installation until enrollment also works without a required phone setup step.

OpenZeekr's Wear OS app copies a phone credential and controls lock/unlock directly. It does not demonstrate Apple Watch support, watch proximity, or watch AC. Its source reports one vehicle BLE peer at a time. Test this limit on GCC. Phone, watch, and the official app must not compete indefinitely for a connection.

## iOS proximity

Apple's [background guide](https://developer.apple.com/library/archive/documentation/NetworkingInternetWeb/Conceptual/CoreBluetooth_concepts/CoreBluetoothBackgroundProcessingForIOSApps/PerformingTasksWhileYourAppIsInTheBackground.html) supports central-role BLE activity with `bluetooth-central` and state restoration. It also states that background discoveries are combined, duplicate discovery requests are ignored, and scan intervals can increase.

This permits event-driven background work. It does not grant a permanent RSSI polling loop or Android foreground-service behavior. Use restoration identifiers, pending connections, and subscribed events. Rebuild application authentication after reconnect; restored GATT state does not prove a valid digital-key session.

Read the current [TN3115 relaunch rules](https://developer.apple.com/documentation/technotes/tn3115-bluetooth-state-restoration-app-relaunch-rules), not only the older guide. The table covers force quit, Bluetooth switches, Airplane Mode, and reboot. Its note 5 adds an iOS 26 AccessorySetupKit condition for the marked cases. Reboot restoration also needs the first device unlock. Evaluate AccessorySetupKit eligibility for this car; do not assume either unconditional relaunch or unconditional failure on every OS version.

## watchOS proximity

Apple provides a [physical-device background BLE sample](https://developer.apple.com/documentation/watchkit/interacting-with-bluetooth-peripherals-during-background-app-refresh). The [WWDC22 session](https://developer.apple.com/videos/play/wwdc2022/10135/) explains background discovery and characteristic monitoring. Its watchOS 9 behavior requires Series 6 or later for these timely background alerts and applies limits to background connections and runtime grants. It describes a runtime limit of five grants, reset by user interaction or after the stated 24-hour condition.

These are documented historical limits, not a measured budget for every current watchOS release. Test the exact watch and OS. A face complication can help surface an action, but does not grant continuous execution. Do not use periodic widget refresh as a proximity detector.

[Extended runtime sessions](https://developer.apple.com/documentation/watchkit/using-extended-runtime-sessions) have specific purposes and finite durations. A vehicle key does not become a workout, audio, mindfulness, or physical-therapy app to obtain more runtime.

## Shortcuts and watch face actions

Use [App Intents](https://developer.apple.com/documentation/appintents/appintent) for local commands. Include the intent implementation in the watch target so a watch action can run on the watch. A shortcut shown on a watch is not proof that its action executes there.

Use [WidgetKit accessory widgets and complications](https://developer.apple.com/documentation/widgetkit/creating-accessory-widgets-and-watch-complications) for watch face and Lock Screen access. Apple documents [interactive widgets](https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities), but support depends on platform and widget family. Use a deep link to a foreground action where an interactive control is unavailable or the BLE transaction needs more runtime.

The initial AC action is conditional on a verified BLE AC capability. A face tap may need to open the app, connect, authenticate, and then send the command. Do not promise instant background completion. Siri voice handling can have its own connectivity requirements; the BLE command and a local tap must not need internet.

Use explicit actions such as Lock, Unlock, Start AC, and Stop AC. Do not use a toggle when the last state is old. Show a result only after the corresponding evidence exists. Device authentication rules still apply on a locked phone or watch.

## Apple-specific design questions

- Check the current Bluetooth privacy strings and background capabilities for each target. Do not copy an iOS plist into watchOS.
- Core Bluetooth handles notification subscription. Do not directly port Android descriptor writes.
- Use device-only Keychain items. Decide background key access separately from interactive access.
- Verify the required full-point ECDH operation on both targets before selecting a crypto dependency.
- A generic BLE app cannot create a manufacturer-approved Wallet car key. Do not assume UWB, Express Mode, or operation with an empty battery.
- Use physical iPhone and Apple Watch tests for BLE and lifecycle behavior. Simulators can test UI and pure protocol code only.
