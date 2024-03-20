.PHONY: build run android test web

devices:
	flutter devices

run: run-linux

run-flutter:
	flutter run

run-linux:
	flutter run --device-id linux

run-chrome:
	flutter run --device-id chrome --web-renderer html

run-mobile:
	flutter run --device-id 958744f

dart-fix-dry:
	dart fix --dry-run

dart-fix:
	dart fix --apply

doctor:
	flutter doctor
