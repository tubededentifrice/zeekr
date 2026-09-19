# Official ZEEKR app

## App identity

The owner reports the app name **ZEEKR**. That name alone does not identify the regional build.

| Store | App ID | iOS bundle ID | Version returned on 2026-09-19 |
| --- | --- | --- | --- |
| UAE | `6504061076` | `com.zeekr.global` | `1.6.6` |
| Sweden / EU | `6448229216` | `com.zeekreu.customer` | `3.0.9` |

The [UAE listing](https://apps.apple.com/ae/app/zeekr/id6504061076) is the initial regional candidate. Its seller is Hangzhou ZEEKR Automobile Sales and Services Co., Ltd. The installed version and account country still need confirmation. Store versions are observations on the research date, not fixed project dependencies.

The [official EU connected-services page](https://www.zeekr.eu/en-se/connected) links the EU iOS listing and Android package `com.zeekr.overseas`. OpenZeekr reports analysis of Android `com.zeekr.overseas` 3.0.7 and `com.zeekr.global` 1.6.3. Do not treat the Android and iOS package versions as equivalent.

## Public features

The UAE listing describes lock/unlock, vehicle status, tire pressure, trunk open/close, AC start, charging controls, maps, and journey records. It does not identify which commands use Bluetooth. Its use of “remote” does not prove an offline path.

The [official UAE 001 page](https://www.zeekrlife.com/en-ae/models/001) describes the vehicle and promotes the ZEEKR app. Vehicle equipment, such as climate control and ventilated seats, does not establish a BLE control API.

The official EU page separates two systems:

- Digital Key 1.0: Bluetooth, selected calibrated phones, and passive start while connected in the app.
- Digital Key 3.0: UWB and Wallet, with passive lock, unlock, and start. The page lists supported 7X, X, and 7GT software combinations. It does not establish DK3 support for the owner's 2024 GCC 001.

The owner's lack of automatic access is therefore an explicit product gap. It is not evidence that manual Bluetooth cannot work.

## Required runtime study

Use the owner's working app as the baseline. Keep the physical key available during tests, but outside detection range when a test must prove digital-key behavior.

1. Record app version, account country, vehicle firmware, phone model, and operating system version. Keep the VIN private.
2. List every control shown for this vehicle. Record disabled controls too.
3. Test once with ordinary connectivity. Then turn phone Wi-Fi and cellular data off while Bluetooth stays on. Restart the app where practical to avoid confusion from cached state.
4. For each action, record the app result and the physical result. Prioritize lock, unlock, start authorization, AC start/stop, target temperature, trunk, windows, and charge flap.
5. Repeat from a locked screen and after a long idle period. Record the time to connect and the time to act.
6. If a BLE capture or lawful local app inspection is available, record its app version, hash, capture method, and relevant GATT writes. Keep the raw material in `.local/`.
7. Compare the capture with the pinned OpenZeekr format. Do not infer unsupported commands by sweeping opcode values.

Use [the observation template](../templates/device-observation.md). An Android app can help explain the protocol, but it cannot prove the iOS app uses the same enrollment, key storage, or background behavior.

## Enrollment questions

Identify the actual account, TSP, and digital-key service region before a login implementation. OpenZeekr has EU hosts, project identifiers, and Android device labels in its source. GCC must not be mapped to EU, SEA, or LA by guesswork.

The working official key cannot be read from another app's iOS Keychain. A new client will need a supported enrollment, transfer, or import route. Determine whether a separate owner/shared key can be issued to each device without replacing the official key. OpenZeekr reports that login can displace another session on the same account.
