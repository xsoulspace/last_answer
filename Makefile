# TODO: rewrite to pubspec exec
fix: 
	fvm dart fix --apply

clean: 
	fvm flutter clean
repair: 
	fvm flutter repair
clean_ios: 
	cd ios && pod deintegrate && pod install
clean_macos: 
	cd macos && pod deintegrate && pod install
clean_android: 
	cd android && gradlew clean

get: 
	fvm flutter pub get

gen: 
	fvm dart run build_runner build
gen-rewrite:
	fvm dart run build_runner build --delete-conflicting-outputs
gen-rewrite-core:
	cd packages/core && make gen-rewrite

gen-icons:
	fvm dart run flutter_launcher_icons

gen-server-types:
	cd apps/core_server_server && serverpod generate
start-server-docker:
	cd apps/core_server_server && docker-compose up --build --detach

start-server-dart:
	cd apps/core_server_server && fvm dart bin/main.dart 

start-server:
	make start-server-docker && make start-server-dart

build-web:
	fvm flutter build web --csp --enable-experiment=inline-class --dart-define-from-file=configs/envs/prod.json --dart-define=STORE=xsoulspaceWebsite
build-google-play:
	fvm flutter build appbundle --enable-experiment=inline-class --dart-define-from-file=configs/envs/prod.json --dart-define=STORE=googlePlay
build-rustore:
	fvm flutter build apk --enable-experiment=inline-class --dart-define-from-file=configs/envs/prod.json 
