# Tests

- `make check`: repository text, links, research records, and selected secret patterns.
- `make test`: shared capability gate and proximity policy tests.
- `make ios-build`: unsigned iPhone simulator build.
- `make ios-test`: iPhone model and interface tests on an available simulator.
- `make ios-device-build`: signed iPhone build with private local signing settings.

Shared tests are in `packages/VehicleCore/Tests`. App tests are in
`apps/ios/ZeekrTests`; UI tests are in `apps/ios/ZeekrUITests`. UI tests retain
screenshots in the Xcode test result. Logs and local results belong in `.local/`.

No automated test proves vehicle authentication, physical actuation, or background
proximity. See [the device plan](../docs/testing.md) for those tests. Enrollment
and live command work are deferred until the next vehicle setup step.
