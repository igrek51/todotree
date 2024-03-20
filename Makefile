.PHONY: build run android test web

devices:
	flutter devices

run: run-linux

run-flutter:
	flutter run

run-linux:
	flutter run -d linux

run-mobile:
	flutter run -d 958744f

dart-fix-dry:
	dart fix --dry-run

dart-fix:
	dart fix --apply

doctor:
	flutter doctor
