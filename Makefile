.PHONY: build run android test web linux

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

run-android-1:
	flutter run --device-id "2201117TY" --release

run-android-2:
	flutter run --device-id "moto g54 5G" --release

release: run-android-2

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

build-bundle:
	flutter build appbundle --release

icon:
	flutter pub run flutter_launcher_icons

clean:
	flutter clean

upgrade:
	flutter pub upgrade --major-versions
