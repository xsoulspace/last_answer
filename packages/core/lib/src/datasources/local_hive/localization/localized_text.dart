import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../models/common/common.dart';
import '../hive_models.dart';

part 'localized_text.g.dart';

@Deprecated('')

/// Any text, that should be shown to user in different [Languages]
/// should use this class to keep values
@JsonSerializable()
@HiveType(typeId: HiveBoxesIds.localizedText)
class LocalizedText with EquatableMixin {
  @Deprecated('')
  const LocalizedText({
    required this.en,
    required this.ru,
    this.it,
    this.ga,
  });
  @Deprecated('')
  factory LocalizedText.fromJson(final Map<String, dynamic> json) =>
      _$LocalizedTextFromJson(json);
  Map<String, dynamic> toJson() => _$LocalizedTextToJson(this);

  /// Russian
  @HiveField(0)
  final String ru;

  /// English
  @HiveField(1)
  final String en;

  /// Italian
  @HiveField(2)
  final String? it;

  /// Irish
  @HiveField(3)
  final String? ga;

  /// If any new [Languages] added, add this to [values]
  Map<LanguageName, String?> get values => {
        Locales.ru.languageCode: ru,
        Locales.en.languageCode: en,
        Locales.it.languageCode: it,
        Locales.ga.languageCode: ga,
      };
  String getByLanguage(final LanguageName language) {
    final text = values[getLanguageCode(language)];

    return (text == null || text.isEmpty) ? en : text;
  }

  @override
  List<Object?> get props => [ru, en, it, ga];

  LocalizedTextModel toModel() => LocalizedTextModel(
        en: en,
        ru: ru,
        it: it ?? '',
        ga: ga ?? '',
      );
}
