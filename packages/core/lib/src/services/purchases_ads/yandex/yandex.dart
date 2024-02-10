// ignore: lines_longer_than_80_chars
// ignore_for_file: avoid_web_libraries_in_flutter, non_constant_identifier_names, avoid_positional_boolean_parameters

@JS()
library;

import 'dart:html';
import 'dart:js_interop';

extension type Ya._(JSObject _) implements JSObject {
  external static YaContextCb Context;
}

extension type YaContextCb._(JSObject _) implements JSObject {
  external YaContextAdvManager get AdvManager;
  external void push(final void Function() func);
}

extension type YaContextAdvManager._(JSObject _) implements JSObject {
  external String getPlatform();
  external void render(final YaContextAdvManagerRender obj);
}

extension type YaContextAdvManagerRender._(JSObject _) implements JSObject {
  external factory YaContextAdvManagerRender({
    final String platform,
    final String blockId,
    final String type,
    final bool darkTheme,
    final void Function(bool isRewarded) onRewarded,
  });
}

extension WindowX on Window{
  external YaContextCb get yaContextCb;
}
