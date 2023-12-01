import 'S.dart';

/// The translations for Russian (`ru`).
class SRu extends S {
  SRu([String locale = 'ru']) : super(locale);

  @override
  String get language => 'Язык';

  @override
  String get search => 'Поиск';

  @override
  String get writeAnAnswer => 'Запишите ответ';

  @override
  String get writeANote => 'Запишите заметку';

  @override
  String get subscription => 'Подписка';

  @override
  String get freeSubscription => 'Бесплатно';

  @override
  String get patronSubscription => 'Patron';

  @override
  String get myAccount => 'Мой аккаунт';

  @override
  String get changeLog => 'Change Log';

  @override
  String get username => 'Имя пользователя';

  @override
  String get email => 'E-mail';

  @override
  String get deleteMyAccount => 'Удалить аккаунт';

  @override
  String get danger => 'Опасно';

  @override
  String get loading => 'Загрузка';

  @override
  String get esc => 'ESC';

  @override
  String get generalSettingsFullTitle => 'Общие настройки';

  @override
  String get generalSettingsShortTitle => 'Общие';

  @override
  String get charactersLimit => 'Лимит символов';

  @override
  String get charactersLimitForNewNotesDesription => 'Когда вы устанавливаете лимит, все новые заметки будут иметь это ограничение. А если вам нужно выйти за пределы лимита для одной заметки - просто установите его в настройках заметки.';

  @override
  String get charactersUnlimited => 'Другой';

  @override
  String get madeWithLoveAndFlutter => 'Сделано с Flutter ❤ и Open Source Libraries';

  @override
  String get feedbackTextWithEmail => 'или отправьте сообщение на idea@xsoulspace.dev';

  @override
  String get niceDayWish => 'Спасибо что используете приложение и хорошего дня, полного идей и вдохновения!';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get termsAndConditions => 'Условия использования';

  @override
  String get joinDiscord => 'Присоединяйтесь к Discord';

  @override
  String get pleaseNotice => 'Обратите внимание';

  @override
  String get appInfo => 'Last Answer';

  @override
  String appVersion(Object buildNumber, Object version) {
    return 'Версия: $version, билд: $buildNumber';
  }

  @override
  String get frequentlyUsed => 'Часто используемые';

  @override
  String get theme => 'Тема';

  @override
  String get themeSystem => 'Как в системе';

  @override
  String get themeDark => 'Темная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get projectsDirection => 'Направление заметок';

  @override
  String get settings => 'Настройки';

  @override
  String get noteSettings => 'Настройки заметки';

  @override
  String get wordNew => 'Новое';

  @override
  String get yes => 'ДА';

  @override
  String get noProjectsYet => 'Тут пока пусто';

  @override
  String get createIdeaHelperText => 'Создать туториал';

  @override
  String get whatsYourIdea => 'В чём идея?';

  @override
  String get lastAnswer => 'Последний ответ';

  @override
  String get idea => 'Идея';

  @override
  String get note => 'Заметка';

  @override
  String get answer => 'Ответ';

  @override
  String get cancel => 'Отменить';

  @override
  String get close => 'Закрыть';

  @override
  String get about => 'О приложении';

  @override
  String get aboutAbstractWhatFor => 'Зачем?';

  @override
  String get delete => 'Удалить';

  @override
  String get deleteThisNote => 'Удалить заметку';

  @override
  String get areYouSure => 'Вы уверены?';

  @override
  String willBeLost(Object title) {
    return '$title будет потерян безвозвратно';
  }

  @override
  String get philosophyInspirationTitle => 'Вдохновление';

  @override
  String get philosophyAbstractWhatElse => 'Что ещё?';

  @override
  String get philosophyAbstractFiveWhyesWhat => 'Можно использовать: \"Пять почему\"';

  @override
  String get philosophyAbstractFiveWhyesWhy => 'Потому что благодаря этой технике можно углубить область, изучаемой или создаваемой идеи или проблемы. В качестве метода используется изучение \"причины и эффекта\". Больше об этой технике: https://ru.wikipedia.org/wiki/Пять_почему';

  @override
  String get philosophyAbstractPDSAWhy => 'Потому что это наиболее универсальная техника, не содержащаяя твердых вопросов, как \"Пять почему\", позволяющая реализовать не просто глубинное изучение идеи или проблемы, а изучение области. Больше об этой технике:  https://ru.wikipedia.org/wiki/Цикл_Деминга';

  @override
  String get philosophyAbstractPDSAWhat => 'Ещё можно использовать: \"PDCA/PDSA (Plan-Do-Check(Study)-Act): Цикл Деминга - Шухарта\"';

  @override
  String get philosophyAbstractSixSigmaWhy => 'Если проблема или идея связана с производством - стоит посмотреть этот метод. Он позволяет контролировать процесс улучшения и создания бизнес процессов и продуктов. Больше об этой технике:  https://ru.wikipedia.org/wiki/Шесть_сигм';

  @override
  String get philosophyAbstractSixSigmaWhat => 'Ещё можно использовать: \"Шесть сигм\" ';

  @override
  String get aboutAbstractWhatForDescription => 'Это приложение создано для момента, когда нужно быстро описать свои идеи и мысли; чтобы облегчить решение сложных проблем и обмен идеями между людьми.';

  @override
  String get aboutAbstractHowDescription => 'Можно использовать раздел Вдохновление, чтобы получить пример с какими техниками возможно использовать приложение.';

  @override
  String get aboutAbstractIdeasImprovementsBugs => 'Идеи Улучшения Баги?';
}
