# UI_ROOT_KNOWLEDGE.md

**Owns:** app start-up assembly — `last_answer_app.dart` (root widget +
GlobalStatesProvider), `bootstrap.dart` stays at lib root by convention;
loading/intro chrome, feedback provider (Wiredash body commented — cleanup
pending), update-notification dialog, `la_ui_kit_bridge.dart` (app palette →
LaUiTheme).

**How to extend:** boot order lives in lib/bootstrap.dart; theme glue in
`la_ui_kit_bridge.dart`. No domain logic here.
