import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:murmur3/murmur3.dart';

extension SharedModelsStringExtension on String {
  /// To invoke a callback when this is a non-empty value.
  void onNotEmpty(final void Function(String value) callback) =>
      isEmpty ? null : callback(this);

  /// Use this function to set "default value", which will be used, if
  /// [this.isEmpty]
  String useWhenEmpty(final String value) => isEmpty ? value : this;

  bool get isUrl {
    const uriSchemes = ['http', 'https'];
    final uri = Uri.tryParse(this);

    return uriSchemes.contains(uri?.scheme);
  }

  @useResult
  String? getNullable() => isEmpty ? null : this;

  Future<int> getHashcode() async => murmur3a(this);
}
