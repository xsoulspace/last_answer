# TODO: rewrite to pubspec exec
fix:
	fvm dart fix --apply
clean:
	fvm flutter clean
get:
	fvm flutter pub get
gen:
	fvm dart run build_runner build
gen-rewrite:
	fvm dart run build_runner build --delete-conflicting-outputs

