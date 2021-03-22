import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart';

bool isDesktop() =>
    kIsWeb ||
    Platform.isWindows ||
    Platform.isLinux ||
    Platform.isAndroid ||
    Platform.isIOS ||
    Platform.isMacOS;
