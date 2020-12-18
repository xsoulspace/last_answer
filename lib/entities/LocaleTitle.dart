class LocaleTitle {
  String ru;
  String en;
  LocaleTitle({required this.en, required this.ru});
  String? getProp(String key) => <String, String>{'ru': ru, 'en': en}[key];

  LocaleTitle.fromJson(Map<String, dynamic> json)
      : en = json['en'],
        ru = json['ru'];

  Map<String, dynamic> toJson() => {'en': en, 'ru': ru};
}
