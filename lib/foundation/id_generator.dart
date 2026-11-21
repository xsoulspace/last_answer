import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Creates a new v4 id for any instance. Never touch [Uuid] directly —
/// id generation stays behind this seam (moved from
/// packages/shared_models foundation, ADR 0038).
String createId() => _uuid.v4();
