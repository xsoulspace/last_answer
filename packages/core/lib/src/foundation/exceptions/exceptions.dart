import 'package:freezed_annotation/freezed_annotation.dart';

part 'exceptions.freezed.dart';

@immutable
@Freezed(
  genericArgumentFactories: true,
)
class AppException with _$AppException implements Exception {
  @Implements<Exception>()
  const factory AppException.cancel() = CancelException;
  const AppException._();
}
