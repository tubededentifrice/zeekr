# Security and private data

Digital key credentials give access to a vehicle. Keep private keys, key blobs, account tokens, VINs, and raw captures out of Git and build logs. The file checks are a basic guard, not a complete secret detector.

For future implementation:

- Authenticate the vehicle before sending the digital key. Reject an empty or invalid trust store.
- Check the certificate chain, validity, key usage, and vehicle identity. A valid manufacturer signature alone does not identify the selected car.
- Keep credentials in the device Keychain with device-only storage. Select access rules after tests with a locked screen. Do not assume a key that requires an interactive unlock can serve background proximity.
- Check Secure Enclave support for each key operation. Its presence does not grant ZEEKR Digital Key 3.0 or Apple Wallet access.
- Prefer a separate enrolled identity on each device, if the vehicle permits it. Do not copy a phone private key to a watch by default.
- Treat local key deletion and vehicle key revocation as separate operations. Report revocation as pending until the vehicle has received it.
- Never log key material, decrypted command payloads, account tokens, or complete vehicle identifiers, even in debug builds.
- Serialize commands. Validate frame length, version, CRC, authentication tag, sequence, and command response association.
- Use explicit lock and unlock commands. Do not retry an uncertain toggle or a moving panel command without checking its effect.
- Do not use remote parking as a keep-alive command. An upstream rejection on another vehicle does not make that command harmless.
- Treat RSSI as an uncertain proximity signal. It cannot provide secure distance measurement or prove that the key is outside the car.

The source review found a fixed session GCM nonce in OpenZeekr. Changing plaintext sequence numbers does not make that nonce unique. Resolve this protocol constraint before selecting a production crypto design. See [the protocol review](docs/research/ble-protocol.md).

Keep security reports that contain private data out of public issues. Remove private data before sharing a report with the repository owner.
