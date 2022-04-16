import 'dart:async';

import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';

class ModelBuilder implements Builder {
  @override
  FutureOr<void> build(final BuildStep buildStep) async {
    // Retrieve the currently matched asset
    final inputId = buildStep.inputId;
    final assetName = inputId.pathSegments.last.split('.').first;

    /// Create new target
    final copyAssetId = inputId.changeExtension('.dart');
    final originContentStr = await buildStep.readAsString(inputId);

    Library library = Library();
    void rebuildLibrary(final Iterable<Spec> iterable) =>
        library = library.rebuild((final l) => l.body.addAll(iterable));
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        '.dart': ['.g.dart']
      };
}
