// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'Dose';

  @override
  String get navToday => 'Сьогодні';

  @override
  String get navMedications => 'Препарати';

  @override
  String get navSettings => 'Налаштування';

  @override
  String get todayEmpty => 'На сьогодні прийомів немає';

  @override
  String get todayHint =>
      'Додайте препарат і розклад, щоб отримувати нагадування.';

  @override
  String get medicationsEmpty => 'Препаратів ще немає';

  @override
  String get addMedication => 'Додати препарат';

  @override
  String get editMedication => 'Редагувати препарат';

  @override
  String get fieldName => 'Назва';

  @override
  String get fieldNameRequired => 'Введіть назву';

  @override
  String get kindMedicine => 'Ліки';

  @override
  String get kindSupplement => 'БАД';

  @override
  String get fieldForm => 'Форма';

  @override
  String get fieldUnit => 'Одиниця дози';

  @override
  String get fieldUnitHint => 'табл., капс., мг, мл, крапл.';

  @override
  String get fieldMeal => 'Прийом їжі';

  @override
  String get fieldNotes => 'Нотатки';

  @override
  String get fieldNotesHint => 'Від чого, хто призначив, особливості';

  @override
  String get fieldColor => 'Колір';

  @override
  String get save => 'Зберегти';

  @override
  String get cancel => 'Скасувати';

  @override
  String get delete => 'Видалити';

  @override
  String get edit => 'Редагувати';

  @override
  String get deleteMedicationTitle => 'Видалити препарат?';

  @override
  String get deleteMedicationBody =>
      'Препарат, його розклади та історію буде видалено назавжди.';

  @override
  String get deleteScheduleTitle => 'Видалити розклад?';

  @override
  String get archive => 'В архів';

  @override
  String get unarchive => 'Повернути з архіву';

  @override
  String get archivedSection => 'Архів';

  @override
  String get notes => 'Нотатки';

  @override
  String get schedules => 'Розклади';

  @override
  String get addSchedule => 'Додати розклад';

  @override
  String get noSchedules =>
      'Розкладу ще немає. Додайте його, щоб отримувати нагадування.';

  @override
  String get schedulePaused => 'Призупинено';

  @override
  String get scheduleTitle => 'Розклад';

  @override
  String get sectionDays => 'Дні';

  @override
  String get patternDaily => 'Щодня';

  @override
  String get patternWeekdays => 'Дні тижня';

  @override
  String get patternEveryN => 'Кожні N днів';

  @override
  String get patternCycle => 'Цикл';

  @override
  String get patternAsNeeded => 'За потреби';

  @override
  String get everyNLabel => 'Інтервал, днів';

  @override
  String get cycleOn => 'Днів прийому';

  @override
  String get cycleOff => 'Днів перерви';

  @override
  String get asNeededHint => 'Нагадувань не буде, прийом відмічається вручну.';

  @override
  String get sectionTimes => 'Час і доза';

  @override
  String get addTime => 'Додати час';

  @override
  String get generateTimes => 'Кожні N годин';

  @override
  String get everyHours => 'Інтервал, годин';

  @override
  String get fromTime => 'З';

  @override
  String get untilTime => 'До';

  @override
  String get dose => 'Доза';

  @override
  String get apply => 'Застосувати';

  @override
  String get sectionDuration => 'Тривалість';

  @override
  String get startDate => 'Початок';

  @override
  String get durForever => 'Безстроково';

  @override
  String get durDays => 'Кількість днів';

  @override
  String get durUntil => 'До дати';

  @override
  String get durDoses => 'Кількість доз';

  @override
  String get endDate => 'Дата завершення';

  @override
  String get preview => 'Найближчі 7 днів';

  @override
  String get previewEmpty => 'У найближчі 7 днів прийомів немає';

  @override
  String get problemNoTimes => 'Додайте хоча б один час прийому';

  @override
  String get problemDuplicateTimes => 'Час прийому повторюється';

  @override
  String get problemBadDose => 'Доза має бути більшою за нуль';

  @override
  String get problemNoWeekdays => 'Виберіть хоча б один день тижня';

  @override
  String get problemBadEveryN => 'Інтервал має бути щонайменше 1 день';

  @override
  String get problemBadCycle => 'Перевірте кількість днів циклу';

  @override
  String get problemBadDuration => 'Перевірте тривалість курсу';

  @override
  String get sumDaily => 'щодня';

  @override
  String get sumAsNeeded => 'за потреби';

  @override
  String get settingsLanguage => 'Мова';

  @override
  String get langSystem => 'Як у системі';

  @override
  String get settingsNotifications => 'Нагадування';

  @override
  String get grantNotifications => 'Дозволити сповіщення';

  @override
  String get grantExactAlarms => 'Дозволити точні нагадування';

  @override
  String get grantExactAlarmsHint =>
      'Без цього Android може затримувати нагадування на кілька хвилин.';

  @override
  String get testNotification => 'Надіслати тестове нагадування';

  @override
  String get testNotificationBody => 'Нагадування працюють.';

  @override
  String scheduledCount(int count) {
    return 'Заплановано нагадувань: $count';
  }

  @override
  String get about => 'Про застосунок';

  @override
  String get disclaimer =>
      'Dose допомагає не забувати про прийом, але не замінює консультацію лікаря.';

  @override
  String get notifTitle => 'Час прийняти ліки';

  @override
  String get notifChannelName => 'Нагадування про прийом';

  @override
  String get notifChannelDescription => 'Сповіщення в запланований час прийому';

  @override
  String formName(String form) {
    String _temp0 = intl.Intl.selectLogic(form, {
      'tablet': 'Таблетка',
      'capsule': 'Капсула',
      'drops': 'Краплі',
      'liquid': 'Рідина',
      'powder': 'Порошок',
      'injection': 'Ін\'єкція',
      'spray': 'Спрей',
      'other': 'Інше',
    });
    return '$_temp0';
  }

  @override
  String mealName(String meal) {
    String _temp0 = intl.Intl.selectLogic(meal, {
      'any': 'Неважливо',
      'before': 'До їжі',
      'during': 'Під час їжі',
      'after': 'Після їжі',
      'emptyStomach': 'Натщесерце',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String sumEveryN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'кожні $n дня',
      many: 'кожні $n днів',
      few: 'кожні $n дні',
      one: 'кожен $n день',
    );
    return '$_temp0';
  }

  @override
  String sumCycle(int on, int off) {
    return '$on дн. прийому, $off дн. перерви';
  }

  @override
  String sumUntil(String date) {
    return 'до $date';
  }

  @override
  String sumFrom(String date) {
    return 'з $date';
  }

  @override
  String sumForDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n дня',
      many: '$n днів',
      few: '$n дні',
      one: '$n день',
    );
    return '$_temp0';
  }

  @override
  String sumForDoses(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n дози',
      many: '$n доз',
      few: '$n дози',
      one: '$n доза',
    );
    return '$_temp0';
  }

  @override
  String daysLeft(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'залишилось $n дня',
      many: 'залишилось $n днів',
      few: 'залишилось $n дні',
      one: 'залишився $n день',
    );
    return '$_temp0';
  }

  @override
  String get removeTime => 'Прибрати час';

  @override
  String get decrease => 'Зменшити';

  @override
  String get increase => 'Збільшити';

  @override
  String colorOption(int n) {
    return 'Колір $n';
  }

  @override
  String get actionTaken => 'Прийняв';

  @override
  String get actionSnooze => 'Відкласти';

  @override
  String get actionSkip => 'Пропустити';

  @override
  String get notifTitleRepeat => 'Ще не відмічено';

  @override
  String get notifTitleSnoozed => 'Відкладене нагадування';

  @override
  String get statePlanned => 'Заплановано';

  @override
  String get stateOverdue => 'Прострочено';

  @override
  String get stateSkipped => 'Пропущено';

  @override
  String get stateTaken => 'Прийнято';

  @override
  String get allDone => 'Усе прийнято';

  @override
  String get partNight => 'Ніч';

  @override
  String get partMorning => 'Ранок';

  @override
  String get partAfternoon => 'День';

  @override
  String get partEvening => 'Вечір';

  @override
  String get takeAll => 'Прийняти все';

  @override
  String get undoMark => 'Скасувати відмітку';

  @override
  String get undo => 'Скасувати';

  @override
  String get asNeededSection => 'За потреби';

  @override
  String get logNow => 'Прийняв зараз';

  @override
  String get prevDay => 'Попередній день';

  @override
  String get nextDay => 'Наступний день';

  @override
  String get dayEmpty => 'На цей день прийомів немає';

  @override
  String get snoozeDuration => 'Відкладати на';

  @override
  String get repeatReminders => 'Повторювати нагадування';

  @override
  String get repeatRemindersHint =>
      'Через 15 і 30 хв, якщо прийом не відмічено';

  @override
  String get unscheduled => 'Поза розкладом';

  @override
  String stateTakenAt(String time) {
    return 'Прийнято о $time';
  }

  @override
  String stateSnoozedUntil(String time) {
    return 'Відкладено до $time';
  }

  @override
  String progressTaken(int taken, int total) {
    return '$taken з $total прийнято';
  }

  @override
  String progressDetails(int skipped, int pending) {
    return 'Пропущено: $skipped · Залишилось: $pending';
  }

  @override
  String progressPlanned(int n) {
    return 'Заплановано прийомів: $n';
  }

  @override
  String snoozeFor(int n) {
    return 'Відкласти на $n хв';
  }

  @override
  String minutesShort(int n) {
    return '$n хв';
  }

  @override
  String snackSnoozed(String time) {
    return 'Відкладено до $time';
  }

  @override
  String progressPercent(int n) {
    return '$n%';
  }

  @override
  String get unitOther => 'Інше…';

  @override
  String get unitCustom => 'Своя одиниця';

  @override
  String get fieldLook => 'Вигляд';

  @override
  String get fieldColor2 => 'Другий колір';

  @override
  String get navStats => 'Статистика';

  @override
  String get statsEmpty =>
      'Ще немає даних. Відмічайте прийоми, і тут з\'явиться статистика.';

  @override
  String get statsAdherence => 'Виконання';

  @override
  String get statsTaken => 'Прийнято';

  @override
  String get statsSkipped => 'Пропущено';

  @override
  String get statsMissed => 'Не відмічено';

  @override
  String get statsByDay => 'По днях';

  @override
  String get statsByMedication => 'По препаратах';

  @override
  String get statsChartHint => 'Натисніть на стовпчик, щоб вибрати день';

  @override
  String get settingsAppearance => 'Оформлення';

  @override
  String get themeSystem => 'Як у системі';

  @override
  String get themeLight => 'Світла';

  @override
  String get themeDark => 'Темна';

  @override
  String get settingsSound => 'Звук сповіщення';

  @override
  String get soundDefault => 'Стандартний звук телефону';

  @override
  String get soundPickPhone => 'Вибрати з телефону або свій файл…';

  @override
  String get soundPickPhoneHint =>
      'Відкриє список звуків Android, де можна додати свій файл';

  @override
  String get soundPreview => 'Прослухати';

  @override
  String get soundChime => 'Дзвіночок';

  @override
  String get soundBell => 'Дзвін';

  @override
  String get soundSoft => 'М\'який';

  @override
  String get soundPulse => 'Сигнал';

  @override
  String get soundCustom => 'Свій звук';

  @override
  String get soundBuiltIn => 'Мелодії Dose';

  @override
  String unitShort(String unit) {
    String _temp0 = intl.Intl.selectLogic(unit, {
      'tablet': 'табл.',
      'capsule': 'капс.',
      'drop': 'крапл.',
      'ml': 'мл',
      'mg': 'мг',
      'g': 'г',
      'mcg': 'мкг',
      'iu': 'МО',
      'units': 'ОД',
      'sachet': 'пак.',
      'teaspoon': 'ч. л.',
      'tablespoon': 'ст. л.',
      'scoop': 'мірн. л.',
      'ampoule': 'амп.',
      'spray': 'впорск.',
      'dose': 'доза',
      'piece': 'шт.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String unitName(String unit) {
    String _temp0 = intl.Intl.selectLogic(unit, {
      'tablet': 'Таблетка (табл.)',
      'capsule': 'Капсула (капс.)',
      'drop': 'Крапля (крапл.)',
      'ml': 'Мілілітр (мл)',
      'mg': 'Міліграм (мг)',
      'g': 'Грам (г)',
      'mcg': 'Мікрограм (мкг)',
      'iu': 'Міжнародна одиниця (МО)',
      'units': 'Одиниця дії (ОД)',
      'sachet': 'Пакетик (пак.)',
      'teaspoon': 'Чайна ложка',
      'tablespoon': 'Столова ложка',
      'scoop': 'Мірна ложка',
      'ampoule': 'Ампула',
      'spray': 'Впорскування',
      'dose': 'Доза',
      'piece': 'Штука (шт.)',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String shapeName(String shape) {
    String _temp0 = intl.Intl.selectLogic(shape, {
      'roundTablet': 'Кругла таблетка',
      'ovalTablet': 'Овальна таблетка',
      'capsule': 'Капсула',
      'softgel': 'М\'яка капсула',
      'dropper': 'Краплі',
      'bottle': 'Флакон',
      'sachet': 'Пакетик',
      'syringe': 'Шприц',
      'spray': 'Спрей',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String statsPeriod(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n дня',
      many: '$n днів',
      few: '$n дні',
      one: '$n день',
    );
    return '$_temp0';
  }

  @override
  String statsStreak(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n дня поспіль без пропусків',
      many: '$n днів поспіль без пропусків',
      few: '$n дні поспіль без пропусків',
      one: '$n день поспіль без пропусків',
    );
    return '$_temp0';
  }

  @override
  String statsOfTotal(int taken, int total) {
    return '$taken з $total';
  }

  @override
  String statsSummary(int days, int taken, int total, int percent) {
    return 'За $days днів прийнято $taken з $total доз ($percent%).';
  }

  @override
  String get stockTitle => 'Запас';

  @override
  String get stockNotTracked => 'Запас не відстежується';

  @override
  String get stockSetUp => 'Вказати запас';

  @override
  String stockLeft(String amount) {
    return 'Залишилось: $amount';
  }

  @override
  String stockDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Вистачить на $days дня',
      many: 'Вистачить на $days днів',
      few: 'Вистачить на $days дні',
      one: 'Вистачить на $days день',
    );
    return '$_temp0';
  }

  @override
  String stockRunsOut(String date) {
    return 'до $date';
  }

  @override
  String get stockEmpty => 'Закінчився';

  @override
  String get stockLow => 'Мало запасу';

  @override
  String get stockBought => 'Докупив';

  @override
  String stockAddPack(String amount) {
    return 'Упаковка: +$amount';
  }

  @override
  String get stockAddAmount => 'Інша кількість';

  @override
  String get stockAmountToAdd => 'Скільки додати';

  @override
  String get stockCorrect => 'Виправити залишок';

  @override
  String get stockSettings => 'Налаштування запасу';

  @override
  String get stockTrack => 'Відстежувати запас';

  @override
  String get stockTrackHint => 'Кожен прийом зменшує залишок';

  @override
  String get stockCurrent => 'Зараз є';

  @override
  String get stockPackSize => 'В упаковці';

  @override
  String get stockPackSizeHint => 'Для кнопки «Докупив»';

  @override
  String get stockWarnDays => 'Попереджати, коли лишиться днів';

  @override
  String get stockInvalid => 'Введіть число';

  @override
  String get stockBanner => 'Час докупити';

  @override
  String get notifStockChannelName => 'Запас';

  @override
  String get notifStockChannelDescription => 'Нагадування докупити препарати';

  @override
  String get settingsData => 'Дані';

  @override
  String get backupExport => 'Зберегти резервну копію';

  @override
  String get backupExportHint =>
      'Файл з усіма препаратами, розкладами й історією';

  @override
  String get backupImport => 'Відновити з копії';

  @override
  String get backupImportHint => 'Замінить усі поточні дані';

  @override
  String get backupSaved => 'Копію збережено';

  @override
  String get backupRestored => 'Дані відновлено';

  @override
  String get backupInvalid => 'Це не резервна копія Dose або файл пошкоджено';

  @override
  String backupFailed(String error) {
    return 'Не вдалося: $error';
  }

  @override
  String get backupConfirmTitle => 'Відновити дані з копії?';

  @override
  String backupConfirmBody(int meds, int schedules, int events) {
    return 'У копії: препаратів $meds, розкладів $schedules, записів про прийом $events. Усі поточні дані буде замінено.';
  }

  @override
  String get backupRestore => 'Відновити';

  @override
  String get fieldIngredients => 'Діючі речовини';

  @override
  String get ingredientsHint =>
      'Для перевірки сумісності. Підібрано за назвою, можна змінити.';

  @override
  String get compatTitle => 'Сумісність';

  @override
  String compatSeparate(String other, int hours) {
    return 'З «$other»: розділяйте щонайменше на $hours год.';
  }

  @override
  String compatNow(String a, String b) {
    return 'Зараз: $a і $b.';
  }

  @override
  String compatSuggest(String time) {
    return 'Порада: перенесіть цей прийом на $time.';
  }

  @override
  String compatAvoid(String other) {
    return 'З «$other»: обережно.';
  }

  @override
  String compatTogether(String other) {
    return 'З «$other»: добре разом.';
  }

  @override
  String get compatDisclaimer =>
      'Це не медична порада. Перед зміною схеми проконсультуйтеся з лікарем.';

  @override
  String get compatWarningTitle => 'Можлива несумісність';

  @override
  String get compatSaveAnyway => 'Зберегти все одно';

  @override
  String get compatChangeTime => 'Змінити час';

  @override
  String takenAt(String time) {
    return 'Прийнято о $time';
  }

  @override
  String get changeTakenTime => 'Змінити час прийому';

  @override
  String get historyTitle => 'Історія';

  @override
  String get historyHint =>
      'Відсоток прийнятих доз за день. Натисніть день, щоб відкрити його.';

  @override
  String get historyNoDoses => 'Нічого не заплановано';

  @override
  String historyDayLabel(String date, int percent) {
    return '$date: $percent%';
  }

  @override
  String get prevMonth => 'Попередній місяць';

  @override
  String get nextMonth => 'Наступний місяць';

  @override
  String get updateCheck => 'Перевірити оновлення';

  @override
  String updateCurrent(String version) {
    return 'Зараз встановлено $version';
  }

  @override
  String get updateAuto => 'Перевіряти оновлення самостійно';

  @override
  String get updateAutoHint => 'Раз на день, коли є інтернет';

  @override
  String get updateNone => 'У вас остання версія';

  @override
  String get updateUnavailable =>
      'Не вдалося перевірити: немає інтернету або репозиторій закритий';

  @override
  String updateAvailable(String version) {
    return 'Доступна нова версія $version';
  }

  @override
  String get updateDownload => 'Завантажити';

  @override
  String get updateHint =>
      'Завантажте файл і встановіть його поверх поточної версії. Усі дані збережуться.';

  @override
  String get later => 'Пізніше';

  @override
  String get guideTitle => 'Довідка';

  @override
  String get guideIntake => 'Як приймати';

  @override
  String get guideCautions => 'Обережно';

  @override
  String get guideSources => 'Джерела';

  @override
  String get guideProductPage => 'Сторінка продукту';

  @override
  String get guideAll => 'Довідник добавок і ліків';

  @override
  String get guideAllSubtitle => 'Як приймати, сумісність, джерела';

  @override
  String get productHint =>
      'Обов\'язково. Почніть вводити, щоб вибрати готовий продукт';

  @override
  String get pickDate => 'Вибрати дату';

  @override
  String get statsOpenDay => 'Відкрити день';

  @override
  String get statsCountHint => 'Натисніть, щоб побачити список';

  @override
  String get noDoses => 'Тут поки порожньо';

  @override
  String get dayUpcoming => 'Попереду';

  @override
  String get dayDoses => 'Прийоми';

  @override
  String durationMinutes(int m) {
    return '$m хв';
  }

  @override
  String durationHours(int h) {
    return '$h год';
  }

  @override
  String durationHoursMinutes(int h, int m) {
    return '$h год $m хв';
  }

  @override
  String delayLate(String d) {
    return 'на $d пізніше';
  }

  @override
  String delayEarly(String d) {
    return 'на $d раніше';
  }

  @override
  String get delayOnTime => 'вчасно';

  @override
  String plannedAt(String time) {
    return 'за планом $time';
  }

  @override
  String get medStatsTitle => 'Аналіз прийому';

  @override
  String get medStatsOpenHint => 'Виконання, серії, графіки, точність часу';

  @override
  String medStatsSince(String date) {
    return 'У додатку з $date';
  }

  @override
  String courseDayOf(int day, int total, String date) {
    return 'День $day з $total, курс до $date';
  }

  @override
  String courseOngoing(int day) {
    return 'День $day, без кінцевої дати';
  }

  @override
  String courseNotStarted(String date) {
    return 'Почнеться $date';
  }

  @override
  String courseFinished(String date) {
    return 'Курс завершено $date';
  }

  @override
  String get periodAll => 'Усе';

  @override
  String trendUp(int n) {
    return 'На $n п.п. краще, ніж за попередній такий самий період';
  }

  @override
  String trendDown(int n) {
    return 'На $n п.п. гірше, ніж за попередній такий самий період';
  }

  @override
  String get trendSame => 'Так само, як за попередній такий самий період';

  @override
  String get streakCurrent => 'Поточна серія';

  @override
  String get streakBest => 'Найдовша серія';

  @override
  String get daysTitle => 'Дні з прийомами';

  @override
  String get daysFull => 'Усе прийнято';

  @override
  String get daysPartial => 'Частково';

  @override
  String get daysNone => 'Жодного';

  @override
  String get chartsTitle => 'Графіки';

  @override
  String get byWeekday => 'По днях тижня';

  @override
  String get byDoseTime => 'По часу прийому';

  @override
  String weekdayWorst(String day) {
    return 'Найчастіше пропускаєте: $day';
  }

  @override
  String get timingTitle => 'Точність часу';

  @override
  String timingAverage(String delay) {
    return 'У середньому $delay';
  }

  @override
  String get timingOnTime => 'Вчасно (±15 хв)';

  @override
  String get timingEarly => 'Раніше ніж на 15 хв';

  @override
  String get timingLate => 'Пізніше на 15–60 хв';

  @override
  String get timingVeryLate => 'Пізніше ніж на годину';

  @override
  String timingMax(String d) {
    return 'Найбільше запізнення: $d';
  }

  @override
  String get timingNone => 'Ще немає прийомів із відміченим часом';

  @override
  String get amountTitle => 'Кількість';

  @override
  String get amountPeriod => 'За обраний період';

  @override
  String get amountAll => 'За весь час';

  @override
  String get amountPerDay => 'В середньому на день';

  @override
  String dosesCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n прийому',
      many: '$n прийомів',
      few: '$n прийоми',
      one: '$n прийом',
    );
    return '$_temp0';
  }

  @override
  String courseRemaining(String amount) {
    return 'До кінця курсу ще прийняти: $amount';
  }

  @override
  String packsToFinish(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'До кінця курсу треба докупити $n упаковки',
      many: 'До кінця курсу треба докупити $n упаковок',
      few: 'До кінця курсу треба докупити $n упаковки',
      one: 'До кінця курсу треба докупити $n упаковку',
      zero: 'Запасу вистачить до кінця курсу',
    );
    return '$_temp0';
  }

  @override
  String listTitle(String status, String period) {
    return '$status · $period';
  }

  @override
  String get guideSupplements => 'Добавки';

  @override
  String get guideDrugs => 'Ліки';

  @override
  String get guideSearch => 'Пошук';

  @override
  String get guideSearchHint => 'Назва або бренд, напр. Олідетрим';

  @override
  String get guideNothingFound => 'Нічого не знайдено';

  @override
  String get guideDrugNote =>
      'Для ліків показуємо лише сумісність. Як і скільки приймати — за призначенням лікаря та інструкцією.';

  @override
  String guideRuleCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n правила сумісності',
      many: '$n правил сумісності',
      few: '$n правила сумісності',
      one: '$n правило сумісності',
    );
    return '$_temp0';
  }

  @override
  String get guideRuleAvoid => 'обережно разом';

  @override
  String guideRuleSeparate(int hours) {
    return 'розділяти на $hours год';
  }

  @override
  String get guideRuleTogether => 'добре разом';

  @override
  String get ingredientsAdd => 'Додати речовину';

  @override
  String get ingredientsPick => 'Діючі речовини';

  @override
  String get ingredientsDone => 'Готово';

  @override
  String get ingredientsRemove => 'Прибрати';
}
