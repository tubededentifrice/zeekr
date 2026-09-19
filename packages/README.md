# Shared Swift code

[VehicleCore](VehicleCore/Package.swift) contains the capability catalog, command
gate, demo result stages, and proximity policy. It has no radio, network, UI, or
credential dependency. Both the future watch target and the phone can use it.

Run `make test` from the repository root. The phone target uses this local package.
The policy takes signal values and monotonic times as inputs. Authentication is
an explicit input. Signal loss or stale data cannot confirm a lock.

The encrypted vehicle protocol is not implemented. See
[the architecture](../docs/architecture.md) and [protocol gaps](../docs/research/ble-protocol.md).
