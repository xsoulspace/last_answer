part of 'utils.dart';

const _uuid = Uuid();

/// Use this function to create new id for any instance
/// Do not access [Uuid] directly!
String createId() => _uuid.v4();
