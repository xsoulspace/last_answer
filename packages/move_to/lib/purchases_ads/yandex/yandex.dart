// ignore: lines_longer_than_80_chars
// ignore_for_file: avoid_web_libraries_in_flutter, non_constant_identifier_names, avoid_positional_boolean_parameters, prefer_final_parameters


@JS()
library;


import 'dart:js_interop';

import 'package:web/web.dart';

extension type Ya._(JSObject _) implements JSObject {
  external factory Ya();
  external static YaContextCb Context;
}

extension type YaContextCb._(JSObject _) implements JSObject {
  external factory YaContextCb();
  external YaContextAdvManager get AdvManager;
  external void push(JSExportedDartFunction func);
}

extension type YaContextAdvManager._(JSObject _) implements JSObject {
  external factory YaContextAdvManager();
  external String getPlatform();
  external void render(final YaContextAdvManagerRender obj);
}
extension type YaContextAdvManagerRender._(JSObject _) implements JSObject {
  external factory YaContextAdvManagerRender({
     String? platform,
     String? blockId,
     String? type,
     bool? darkTheme,
     JSFunction? onRewarded,
  });
}

extension WindowX on Window{
  external YaContextCb get yaContextCb;
}
