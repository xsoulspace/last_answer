import 'package:uuid/uuid.dart';

class IdCreator {
  IdCreator._();
  static const _uuid = Uuid();
  static String create() => _uuid.v1();
}
