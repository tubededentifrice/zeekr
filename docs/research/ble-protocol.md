# BLE protocol reference

These details come from the pinned OpenZeekr source. They are research inputs, not a tested GCC protocol specification. No protocol code is implemented here.

Base source: [OpenZeekr BLE directory](https://github.com/borconi/openzeekr/tree/00661111f77fd613938309b8fb3f691ac79388f7/core/src/main/java/com/openzeekr/app/ble).

## Discovery and GATT

Source: [DkBleManager.kt](https://github.com/borconi/openzeekr/blob/00661111f77fd613938309b8fb3f691ac79388f7/core/src/main/java/com/openzeekr/app/ble/DkBleManager.kt) and [DkProtocol.kt](https://github.com/borconi/openzeekr/blob/00661111f77fd613938309b8fb3f691ac79388f7/core/src/main/java/com/openzeekr/app/ble/DkProtocol.kt).

| Item | Source value |
| --- | --- |
| Advertised service | `0xFDFD` |
| Manufacturer company ID | `0x06FE` |
| GATT service | `02362AFF-CF3A-11E1-EFDE-0002A5D5C51B` |
| Channel 1 write | `02362A10-CF3A-11E1-EFDE-0002A5D5C51B` |
| Channel 1 notify | `02362A11-CF3A-11E1-EFDE-0002A5D5C51B` |
| Channel 2 write | `02362A12-CF3A-11E1-EFDE-0002A5D5C51B` |
| Channel 2 notify | `02362A13-CF3A-11E1-EFDE-0002A5D5C51B` |

The GATT service is not the advertised service in the reference capture. Scan for the advertised UUID. The advertisement parser extracts an eight-byte broadcast random value from bytes `[12:20]` of a 20-byte manufacturer payload. Validate the company ID and payload shape on the GCC car. Apple delivers parsed advertisement data, so do not copy Android raw-packet offsets without checking the representation.

Core Bluetooth does not expose the peripheral MAC address as an application identity. Use its peripheral identifier only as a discovery hint. Authenticate the selected vehicle. Never select a car only because it has the strongest RSSI or a matching name.

OpenZeekr uses writes with response and fragments frames to the negotiated payload size. On Apple platforms, use `maximumWriteValueLength(for:)` and write completion. Do not assume Android's requested MTU of 247. Subscribe to the required notifications before the handshake. Bound receive buffers and assemble partial or combined frames using the declared length.

## Key enrollment

The [UAE enrollment study](key-enrollment.md) adds the target app identity,
shared-account candidate, regional lookup limits, and defects in the existing
owner/shared provisioning paths. Its state and error checks take precedence over
an assumption that the reference flow can be copied unchanged.

Sources: [DkProvisioning.kt](https://github.com/borconi/openzeekr/blob/00661111f77fd613938309b8fb3f691ac79388f7/core/src/main/java/com/openzeekr/app/ble/DkProvisioning.kt), [DkIdentity.kt](https://github.com/borconi/openzeekr/blob/00661111f77fd613938309b8fb3f691ac79388f7/core/src/main/java/com/openzeekr/app/ble/DkIdentity.kt), and [ZeekrConst.kt](https://github.com/borconi/openzeekr/blob/00661111f77fd613938309b8fb3f691ac79388f7/core/src/main/java/com/openzeekr/app/net/ZeekrConst.kt).

The reference generates a P-256 device key pair and CSR. It enrolls the certificate, then creates an owner key or accepts a shared Bluetooth key when the selected branch requires it. The shared binding path polls cloud-to-car synchronization before key download, but can continue after a timeout. The owner path does not perform that poll or rebind an existing key. This is application authentication, not ordinary Bluetooth pairing.

The certificate route starts with `ms-tsp-dkbs-geely/api/v1.0/app/certificatecenter`. The digital-key routes start with `ms-tsp-dkbs-geely/api/v1.0/app/digital-key-center`.

| Method | Suffix | Purpose |
| --- | --- | --- |
| POST | `create-app-certificate` | Enroll the device CSR under certificatecenter |
| POST | `key-list` | Read the account key list; source uses `dkType=2`, `type=2` |
| POST | `create-owner-blu-key` | Create an owner key |
| POST | `share-key` | Accept and bind a shared key |
| GET | `key-info` | Fetch digital key and calibration data |
| POST | `repush-key-to-vechile` | Push a key to the vehicle; spelling is from the API |
| POST | `sync-key-list` | Synchronize the vehicle key list |
| GET | `loop-key-status` | Check synchronization status |
| GET | `phonecoef` | Fetch phone calibration |
| POST | `remove-one-key` | Request key revocation |

The signed digital-key message is UTF-8 `userId + deviceId + vin`, with no separators, signed with ECDSA-SHA256, DER encoded, then Base64 encoded without line breaks. This is in addition to authenticated and signed HTTP transport. The reference also contains a separate ECARX/xchanger account session. Its exact GCC requirement remains unresolved.

Store the device private key, issued app certificate, device ID, VIN, cloud key ID, short `bookId`, digital key blob, and required calibration. The BLE key ID is the short hex `bookId`, not the long cloud `dkId`. Keep all real values out of this repository.

## Frame and handshake

Sources: [DkFrame.kt](https://github.com/borconi/openzeekr/blob/00661111f77fd613938309b8fb3f691ac79388f7/core/src/main/java/com/openzeekr/app/ble/DkFrame.kt), [DkCrypto.kt](https://github.com/borconi/openzeekr/blob/00661111f77fd613938309b8fb3f691ac79388f7/core/src/main/java/com/openzeekr/app/ble/DkCrypto.kt), and [RealDkSession.kt](https://github.com/borconi/openzeekr/blob/00661111f77fd613938309b8fb3f691ac79388f7/core/src/main/java/com/openzeekr/app/ble/RealDkSession.kt).

```text
FE 03 | total length (2, BE) | command ID (2, BE) | instruction (1) | body | CRC (2, BE)
```

Total length includes header and CRC. CRC is CRC-16/ARC, reflected polynomial `0xA001`, initial value zero. The common payload prefix is sequence `(2, BE)` plus Unix timestamp `(4, BE)`. Request instruction is `1`; the source also defines response `2`, confirmable `3`, acknowledgment `4`, non-confirmable `5`, and command `6`.

1. Send `0x0101` connect confirmation. Its body uses AES-128-CBC with PKCS7 padding. The connect key is the first 16 ASCII VIN bytes XOR the uppercase hex encoding of eight broadcast-random bytes. The fixed CBC IV is defined in `DkCrypto.kt`.
2. Read `0x0102`. The source handles busy `0x100C` with bounded retries. State `0x1011` enters certificate exchange. State `0x1012` requires a different reconnect path, which the pinned source explicitly does not implement. `0x1010` indicates failed confirmation.
3. Exchange app and vehicle certificates with `0x0103` / `0x0104`. Validate the car before releasing any digital key.
4. Exchange signed ephemeral P-256 factors with `0x0106` / `0x0108`. Factor content is sequence, timestamp, and the 64-byte X/Y public point, followed by SHA-256 and a DER ECDSA signature.
5. Verify the vehicle factor. Compute the full ECDH shared point. The source takes `X[0:16]` for the AES key and `Y[0:12]` for the GCM nonce.
6. Send the key blob in `0x010B`; require successful `0x010C` verification. Encrypted bodies use AES-128-GCM, a 16-byte tag, and AAD equal to the nonce.
7. Handle calibration if required. Small calibration uses `0x0172` / `0x0173` on channel 2. Big calibration uses `0x0171` on channel 1. Calibration does not prove automatic locking works.

The confirm payload built by the code totals 43 bytes when `bookId` is four bytes. One nearby source comment says 47 bytes. Use the actual fields and captured evidence, not that comment.

## Sending a control

After an authenticated session, a basic control uses command `0x0110` on channel 1. Encrypt `sequence + timestamp + control byte`, then frame it and add the CRC. Examples are unlock `0x01` and lock `0x02`. See [the complete reviewed catalog](capabilities.md).

`0x0111` is a command receipt. `0x0112` is a result. A GATT write result, a receipt, and observed vehicle state are distinct. The source waits 1.5 seconds for the receipt and a further 600 milliseconds for an optional result in its general dispatcher. Those values need measurement on the target car.

Use one command in flight until response association is understood. Validate status lengths and result codes. Keep the result “received; state unknown” if the protocol only supplies a receipt. Do not display a locked vehicle from a successful radio write alone.

The source defines status-related `0x0120` / `0x0121`, but a complete GCC state decoder has not been established. It reports no reply to a bare `0x0120` in its ping experiment. Do not promise BLE battery, range, or climate status from the cloud status screen.

## Proximity commands

`0x0151` is an encrypted custom request on channel 2. After the common prefix, it carries type `0x01` for approach unlock or `0x02` for walk-away lock, then `0x01` to enable or `0x00` to disable. `0x0152` is the reply. The source describes `0x1000` as success for this reply; do not use one global success-code rule for all messages.

`0x0159` is described as a vehicle walk-away lock notification. It is not an approach-unlock notification or a distance measurement. OpenZeekr's vehicle-side controller only arms walk-away lock and uploads calibration. The README still marks this work as unfinished. The presence of a custom type is not proof that GCC firmware enables it.

## Crypto and trust work before a port

CryptoKit's ordinary ECDH shared secret does not expose both affine coordinates. The reference needs X and Y. Select and review an Apple-compatible implementation that exposes the required point operation; do not invent a replacement KDF or custom curve code.

The source keeps the GCM nonce fixed for a session. A changing sequence in plaintext does not satisfy GCM nonce uniqueness. Confirm this behavior against the relevant official version, obtain independent crypto review, and assess session limits and protocol compatibility. A unilateral nonce change can break interoperability. A new session is not automatically a complete remedy for reuse within that session.

The [trust implementation](https://github.com/borconi/openzeekr/blob/00661111f77fd613938309b8fb3f691ac79388f7/core/src/main/java/com/openzeekr/app/ble/DkTrust.kt) must not be copied unchanged. An empty trust store must stop authentication. Add chain and identity validation and strict session state transitions. Test malformed versions, lengths, certificates, factors, and results before any hardware control test.

Remote parking uses more opcodes and CMAC handling. Upstream reports rejection `0x100A` and attributes it to a DK3/Secure Element requirement. This is not verified for all models. Keep motion outside the initial scope and do not use those commands as diagnostics.
