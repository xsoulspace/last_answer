part of 'hooks.dart';

ValueNotifier<bool> useIsBool({final bool initial = false}) =>
    useState(initial);
