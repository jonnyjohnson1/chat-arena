clean:
	flutter clean
	flutter build web

web:
	flutter run -d chrome

deploy:
	flutter clean
	flutter build web
	firebase deploy

local:
	firebase serve --only hosting

icons:
	flutter pub run flutter_launcher_icons

iosbundle:
	flutter clean
	flutter build ipa --obfuscate --split-debug-info=build/app/outputs/symbols

appbundle:
	flutter clean
	flutter build appbundle --obfuscate --split-debug-info=build/app/outputs/symbols
