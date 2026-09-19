import CoreBluetooth
import Foundation
import Observation

struct NearbyCandidate: Identifiable {
    let id: UUID
    let label: String
    var rssi: Int
    var lastSeen: Date
    var manufacturerMatches: Bool
}

@MainActor @Observable
final class BluetoothDiscovery: NSObject, CBCentralManagerDelegate {
    private(set) var status = "Not started"
    private(set) var scanning = false
    private(set) var candidates: [NearbyCandidate] = []
    private var central: CBCentralManager?
    private var stopTask: Task<Void, Never>?
    private var wantsScan = false

    func start() {
        wantsScan = true
        if central == nil {
            central = CBCentralManager(delegate: self, queue: .main)
        } else if central?.state == .poweredOn {
            beginScan()
        } else {
            updateState()
        }
    }

    func stop() {
        wantsScan = false
        central?.stopScan()
        stopTask?.cancel()
        stopTask = nil
        scanning = false
        if status == "Scanning" { status = candidates.isEmpty ? "No signals found" : "Scan stopped" }
    }

    private func beginScan() {
        stopTask?.cancel()
        candidates = []
        scanning = true
        status = "Scanning"
        central?.scanForPeripherals(withServices: [CBUUID(string: "FDFD")], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        stopTask = Task { [weak self] in
            do { try await Task.sleep(for: .seconds(20)) } catch { return }
            self?.stop()
        }
    }

    private func updateState() {
        switch central?.state {
        case .poweredOn:
            status = "Bluetooth ready"
            if wantsScan { beginScan() }
        case .poweredOff: status = "Bluetooth is off"
        case .unauthorized: status = "Bluetooth access denied"
        case .unsupported: status = "Bluetooth is not available on this device"
        case .resetting: status = "Bluetooth is restarting"
        default: status = "Waiting for Bluetooth"
        }
        if central?.state != .poweredOn {
            scanning = false
            candidates = []
            stopTask?.cancel()
        }
    }

    nonisolated func centralManagerDidUpdateState(_ central: CBCentralManager) {
        MainActor.assumeIsolated { updateState() }
    }

    nonisolated func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                                   advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let identifier = peripheral.identifier
        let signal = RSSI.intValue
        let data = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data
        let manufacturerMatches = data.map { $0.count >= 2 && $0[$0.startIndex] == 0xFE && $0[$0.startIndex + 1] == 0x06 } ?? false
        MainActor.assumeIsolated {
            guard scanning, (-110 ... -10).contains(signal) else { return }
            if let index = candidates.firstIndex(where: { $0.id == identifier }) {
                candidates[index].rssi = signal
                candidates[index].lastSeen = Date()
                candidates[index].manufacturerMatches = manufacturerMatches
            } else if candidates.count < 20 {
                candidates.append(NearbyCandidate(id: identifier, label: "Nearby signal \(candidates.count + 1)",
                                                  rssi: signal, lastSeen: Date(), manufacturerMatches: manufacturerMatches))
            }
        }
    }
}
