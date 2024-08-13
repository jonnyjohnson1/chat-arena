clean:
	flutter clean
	flutter build web

web:
	flutter run -d chrome

local:
	firebase serve --only hosting
	
deploy:
	flutter clean
	flutter build web
	firebase deploy

icons:
	flutter pub run flutter_launcher_icons

iosbundle:
	flutter clean
	flutter build ipa --obfuscate --split-debug-info=build/app/outputs/symbols

appbundle:
	flutter clean
	flutter build appbundle --obfuscate --split-debug-info=build/app/outputs/symbols
