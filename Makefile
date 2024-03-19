.PHONY: build run android test web

devices:
	flutter devices

run:
	flutter run

run-mobile:
	flutter run -d 958744f

dart-fix-dry:
	dart fix --dry-run

dart-fix:
	dart fix --apply

doctor:
	flutter doctor
