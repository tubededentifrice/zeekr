// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "VehicleCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "VehicleCore", targets: ["VehicleCore"])],
    targets: [
        .target(name: "VehicleCore"),
        .testTarget(name: "VehicleCoreTests", dependencies: ["VehicleCore"])
    ]
)
