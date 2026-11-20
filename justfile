# TODO: rewrite to pubspec exec
fix:
    dart fix --apply

# Multiplayer T3 gate as a flutter_mcp_harness scenario: two real app
# instances (macOS host + Chrome web peer), mesh task console end to end.
# Pass --skip-build to reuse existing build artifacts.
gate-multiplayer *ARGS:
    fvm dart tool/gates/multiplayer_harness_gate.dart {{ARGS}}

# CLI chat gate: detect → install if needed → attach a real ACP agent
# (gemini / pi / codex / claude-code-acp) → auth guard → one prompt turn.
# e.g. `just gate-chat --agent pi` (add --install to install the CLI).
gate-chat *ARGS:
    fvm dart tool/gates/chat_cli_gate.dart {{ARGS}}

clean:
    flutter clean
repair:
    flutter repair
clean_ios:
    cd ios && pod deintegrate && pod install
clean_macos:
    cd macos && pod deintegrate && pod install
clean_android:
    cd android && gradlew clean
use-firebase-account:
    firebase login:use
gen:
    dart run build_runner build --enable-experiment=inline-class

# Regenerate the S classes from the arb sources (packages/la_locale).
# The generated files are never hand-edited; edit the arbs instead.
gen-l10n:
    cd packages/la_locale && fvm flutter gen-l10n
gen-rewrite:
    dart run build_runner build --delete-conflicting-outputs --enable-experiment=inline-class
gen-rewrite-core:
    cd packages/core && make gen-rewrite

gen-icons:
    dart run flutter_launcher_icons

gen-server-types:
    cd deployables/server && serverpod generate
start-server-docker:
    cd deployables/server && docker-compose up --build --detach

start-server-dart:
    cd deployables/server && dart bin/main.dart

start-server:
    just start-server-docker && just start-server-dart

build-web-pwa:
    flutter build web --csp --dart-define-from-file=configs/envs/prod.json --dart-define=STORE=xsoulspaceWebsite -t lib/main_prod.dart --pwa-strategy=offline-first && rm -rf release/web && mv build/web release
build-google-play:
    flutter build appbundle --dart-define-from-file=configs/envs/prod.json --dart-define=STORE=googlePlay -t lib/main_prod.dart
build-rustore:
    flutter build apk --dart-define-from-file=configs/envs/prod.json --dart-define=STORE=rustore -t lib/main_prod.dart
# pass
# as argument: make v="3.19." run
# or be defined as environment: wid="" wis="" v="3.19." make run build-snap
deploy-snap:
    snapcraft upload --release=edge last-answer_$(v)_arm64.snap

# Shell redesign acceptance gate: one real macOS binary, keyboard-first
# through the mcp-toolkit VM verbs (edge/inbox oracle, palette flows,
# arm honesty, screenshots). Evidence: $TMPDIR/shell_hgate_evidence/
gate-shell *ARGS:
    fvm dart tool/gates/shell_harness_gate.dart {{ARGS}}

# Endless-chat live smoke: seeded 500-beat room tail/paging/receipts,
# first-run boot, kernel->journal export, daemon roundtrip.
# Evidence: $TMPDIR/chat_smoke_evidence/
smoke-chat *ARGS:
    fvm dart tool/smoke/chat_endless_smoke.dart {{ARGS}}

# DESIGN.md v6 component-carrier law: la_ui_kit stays material-free and lib/
# imports material only via the allowlist (tool/ui_gate_allowlist.txt).
ui-gates:
    fvm dart run tool/check_ui_gates.dart

# ADR 0034 purity law for the headless CLI surface: bin/ runs plain Dart -
# it may not import package:lastanswer or any Flutter library.
bin-gates:
    fvm dart tool/check_bin_gates.dart
