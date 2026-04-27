.PHONY: build run android test web linux web-release web-serve

devices:
	flutter devices

run: run-linux

run-debug:
	flutter run

run-release:
	flutter run --release

run-linux:
	flutter run --device-id linux

run-linux-kickstart:
	flutter run --device-id linux --dart-define=KICKSTART=1

run-chrome:
	flutter run --device-id chrome --web-renderer html

run-web:
	flutter run -d chrome

run-android-debug:
	flutter run --device-id "moto g54 5G" --debug

run-android-release:
	flutter run --device-id "moto g54 5G" --release

release: run-android-release

adb-wireless:
	adb tcpip 5555
	adb connect 192.168.0.23
	adb devices

emulators:
	flutter emulators

emulator:
	flutter emulators --launch Pixel3_API33_T_13_play

dart-fix-dry:
	dart fix --dry-run

dart-fix:
	dart fix --apply

doctor:
	flutter doctor

build-apk:
	flutter build apk --release

build-web:
	flutter build web --release

web-release:
	@echo "Building web app in release mode..."
	flutter build web --release
	@echo ""
	@echo "✓ Build complete!"
	@echo ""
	@echo "GitHub Actions will automatically deploy when you push:"
	@echo "  git push origin master"
	@echo ""
	@echo "Check deployment status at:"
	@echo "  https://github.com/$$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^/]*\/[^.]*\).*/\1/')/actions"

web-serve: build-web
	cd build/web && python3 -m http.server 8080 --bind 0.0.0.0

build-bundle:
	flutter build appbundle --release

icon:
	flutter pub run flutter_launcher_icons

clean:
	flutter clean

upgrade:
	flutter pub upgrade --major-versions
