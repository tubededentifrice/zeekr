PYTHON ?= python3

.PHONY: check doctor test ios-build ios-test ios-device-build

check:
	$(PYTHON) scripts/check_repo.py

doctor:
	$(PYTHON) scripts/doctor.py

test:
	swift test --package-path packages/VehicleCore

ios-build:
	xcodebuild -project apps/ios/Zeekr.xcodeproj -scheme Zeekr -destination 'generic/platform=iOS Simulator' -derivedDataPath .local/DerivedData CODE_SIGNING_ALLOWED=NO build

ios-test:
	$(PYTHON) scripts/test_ios.py

ios-device-build:
	xcodebuild -project apps/ios/Zeekr.xcodeproj -scheme Zeekr -destination 'generic/platform=iOS' -derivedDataPath .local/DeviceBuild -xcconfig .local/Signing.xcconfig -allowProvisioningUpdates build
