class LocaleTitle {
  String ru;
  String en;
  LocaleTitle(this.en, this.ru);
  String getProp(String key) => <String, String>{'ru': ru, 'en': en}[key];
}
