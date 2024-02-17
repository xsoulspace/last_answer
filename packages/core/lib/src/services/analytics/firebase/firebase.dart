export 'firebase_initializer.dart';
export 'firebase_noop.dart'
    if (dart.library.io) 'firebase_io.dart'
    if (dart.library.html) 'firebase_io.dart';
