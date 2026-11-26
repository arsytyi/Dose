// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Dose';

  @override
  String get navToday => 'Сегодня';

  @override
  String get navMedications => 'Препараты';

  @override
  String get navSettings => 'Настройки';

  @override
  String get todayEmpty => 'На сегодня приёмов нет';

  @override
  String get todayHint =>
      'Добавьте препарат и расписание, чтобы получать напоминания.';

  @override
  String get medicationsEmpty => 'Препаратов пока нет';

  @override
  String get addMedication => 'Добавить препарат';

  @override
  String get editMedication => 'Изменить препарат';

  @override
  String get fieldName => 'Название';

  @override
  String get fieldNameRequired => 'Введите название';

  @override
  String get kindMedicine => 'Лекарство';

  @override
  String get kindSupplement => 'Добавка';

  @override
  String get fieldForm => 'Форма';

  @override
  String get fieldUnit => 'Единица дозы';

  @override
  String get fieldUnitHint => 'таблетка, капсула, мг, мл, капли';

  @override
  String get fieldMeal => 'Еда';

  @override
  String get fieldNotes => 'Заметки';

  @override
  String get fieldNotesHint => 'Для чего, кто назначил, что важно помнить';

  @override
  String get fieldColor => 'Цвет';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Изменить';

  @override
  String get deleteMedicationTitle => 'Удалить препарат?';

  @override
  String get deleteMedicationBody =>
      'Препарат, его расписания и история будут удалены навсегда.';

  @override
  String get deleteScheduleTitle => 'Удалить расписание?';

  @override
  String get archive => 'В архив';

  @override
  String get unarchive => 'Вернуть';

  @override
  String get archivedSection => 'Архив';

  @override
  String get notes => 'Заметки';

  @override
  String get schedules => 'Расписания';

  @override
  String get addSchedule => 'Добавить расписание';

  @override
  String get noSchedules =>
      'Расписания пока нет. Добавьте его, чтобы получать напоминания.';

  @override
  String get schedulePaused => 'На паузе';

  @override
  String get scheduleTitle => 'Расписание';

  @override
  String get sectionDays => 'Дни';

  @override
  String get patternDaily => 'Каждый день';

  @override
  String get patternWeekdays => 'Дни недели';

  @override
  String get patternEveryN => 'Каждые N дней';

  @override
  String get patternCycle => 'Цикл';

  @override
  String get patternAsNeeded => 'По необходимости';

  @override
  String get everyNLabel => 'Интервал, дней';

  @override
  String get cycleOn => 'Дней приёма';

  @override
  String get cycleOff => 'Дней перерыва';

  @override
  String get asNeededHint => 'Без напоминаний; приёмы отмечаются вручную.';

  @override
  String get sectionTimes => 'Время и доза';

  @override
  String get addTime => 'Добавить время';

  @override
  String get generateTimes => 'Каждые N часов';

  @override
  String get everyHours => 'Интервал, часов';

  @override
  String get fromTime => 'С';

  @override
  String get untilTime => 'До';

  @override
  String get dose => 'Доза';

  @override
  String get apply => 'Применить';

  @override
  String get sectionDuration => 'Длительность';

  @override
  String get startDate => 'Начало';

  @override
  String get durForever => 'Без конца';

  @override
  String get durDays => 'Количество дней';

  @override
  String get durUntil => 'До даты';

  @override
  String get durDoses => 'Количество приёмов';

  @override
  String get endDate => 'Дата окончания';

  @override
  String get preview => 'Ближайшие 7 дней';

  @override
  String get previewEmpty => 'В ближайшие 7 дней приёмов нет';

  @override
  String get problemNoTimes => 'Добавьте хотя бы одно время';

  @override
  String get problemDuplicateTimes => 'Время указано дважды';

  @override
  String get problemBadDose => 'Доза должна быть больше нуля';

  @override
  String get problemNoWeekdays => 'Выберите хотя бы один день недели';

  @override
  String get problemBadEveryN => 'Интервал — минимум 1 день';

  @override
  String get problemBadCycle => 'Проверьте дни цикла';

  @override
  String get problemBadDuration => 'Проверьте длительность';

  @override
  String get sumDaily => 'каждый день';

  @override
  String get sumAsNeeded => 'по необходимости';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get langSystem => 'Как в системе';

  @override
  String get settingsNotifications => 'Напоминания';

  @override
  String get grantNotifications => 'Разрешить уведомления';

  @override
  String get grantExactAlarms => 'Разрешить точные напоминания';

  @override
  String get grantExactAlarmsHint =>
      'Без этого Android может задерживать напоминания на несколько минут.';

  @override
  String get testNotification => 'Отправить тестовое напоминание';

  @override
  String get testNotificationBody => 'Напоминания работают.';

  @override
  String scheduledCount(int count) {
    return 'Запланировано напоминаний: $count';
  }

  @override
  String get about => 'О приложении';

  @override
  String get disclaimer =>
      'Dose помогает не забывать о приёмах, но не заменяет консультацию врача.';

  @override
  String get notifTitle => 'Время принять лекарства';

  @override
  String get notifChannelName => 'Напоминания о приёме';

  @override
  String get notifChannelDescription =>
      'Сигналы в запланированное время приёма';

  @override
  String formName(String form) {
    String _temp0 = intl.Intl.selectLogic(form, {
      'tablet': 'Таблетка',
      'capsule': 'Капсула',
      'drops': 'Капли',
      'liquid': 'Жидкость',
      'powder': 'Порошок',
      'injection': 'Инъекция',
      'spray': 'Спрей',
      'other': 'Другое',
    });
    return '$_temp0';
  }

  @override
  String mealName(String meal) {
    String _temp0 = intl.Intl.selectLogic(meal, {
      'any': 'Неважно',
      'before': 'До еды',
      'during': 'Во время еды',
      'after': 'После еды',
      'emptyStomach': 'Натощак',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String sumEveryN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'каждые $n дня',
      many: 'каждые $n дней',
      few: 'каждые $n дня',
      one: 'каждый $n день',
    );
    return '$_temp0';
  }

  @override
  String sumCycle(int on, int off) {
    return '$on дн. приёма, $off дн. перерыва';
  }

  @override
  String sumUntil(String date) {
    return 'до $date';
  }

  @override
  String sumFrom(String date) {
    return 'с $date';
  }

  @override
  String sumForDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n дня',
      many: '$n дней',
      few: '$n дня',
      one: '$n день',
    );
    return '$_temp0';
  }

  @override
  String sumForDoses(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n приёма',
      many: '$n приёмов',
      few: '$n приёма',
      one: '$n приём',
    );
    return '$_temp0';
  }

  @override
  String daysLeft(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Осталось $n дня',
      many: 'Осталось $n дней',
      few: 'Осталось $n дня',
      one: 'Остался $n день',
    );
    return '$_temp0';
  }

  @override
  String get removeTime => 'Убрать время';

  @override
  String get decrease => 'Меньше';

  @override
  String get increase => 'Больше';

  @override
  String colorOption(int n) {
    return 'Цвет $n';
  }

  @override
  String get actionTaken => 'Принял';

  @override
  String get actionSnooze => 'Отложить';

  @override
  String get actionSkip => 'Пропустить';

  @override
  String get notifTitleRepeat => 'Ещё не отмечено';

  @override
  String get notifTitleSnoozed => 'Отложенное напоминание';

  @override
  String get statePlanned => 'Запланировано';

  @override
  String get stateOverdue => 'Просрочено';

  @override
  String get stateSkipped => 'Пропущено';

  @override
  String get stateTaken => 'Принято';

  @override
  String get allDone => 'Всё принято';

  @override
  String get partNight => 'Ночь';

  @override
  String get partMorning => 'Утро';

  @override
  String get partAfternoon => 'День';

  @override
  String get partEvening => 'Вечер';

  @override
  String get takeAll => 'Принять все';

  @override
  String get undoMark => 'Отменить отметку';

  @override
  String get undo => 'Отменить';

  @override
  String get asNeededSection => 'По необходимости';

  @override
  String get logNow => 'Принял сейчас';

  @override
  String get prevDay => 'Предыдущий день';

  @override
  String get nextDay => 'Следующий день';

  @override
  String get dayEmpty => 'На этот день приёмов нет';

  @override
  String get snoozeDuration => 'Откладывать на';

  @override
  String get repeatReminders => 'Повторять напоминания';

  @override
  String get repeatRemindersHint => 'Через 15 и 30 мин, если приём не отмечен';

  @override
  String get unscheduled => 'Вне расписания';

  @override
  String stateTakenAt(String time) {
    return 'Принято в $time';
  }

  @override
  String stateSnoozedUntil(String time) {
    return 'Отложено до $time';
  }

  @override
  String progressTaken(int taken, int total) {
    return 'Принято $taken из $total';
  }

  @override
  String progressDetails(int skipped, int pending) {
    return 'Пропущено: $skipped · Осталось: $pending';
  }

  @override
  String progressPlanned(int n) {
    return 'Запланировано приёмов: $n';
  }

  @override
  String snoozeFor(int n) {
    return 'Отложить на $n мин';
  }

  @override
  String minutesShort(int n) {
    return '$n мин';
  }

  @override
  String snackSnoozed(String time) {
    return 'Отложено до $time';
  }

  @override
  String progressPercent(int n) {
    return '$n%';
  }

  @override
  String get unitOther => 'Другое…';

  @override
  String get unitCustom => 'Своя единица';

  @override
  String get fieldLook => 'Внешний вид';

  @override
  String get fieldColor2 => 'Второй цвет';

  @override
  String get navStats => 'Статистика';

  @override
  String get statsEmpty =>
      'Данных пока нет. Отмечайте приёмы, и здесь появится статистика.';

  @override
  String get statsAdherence => 'Выполнение';

  @override
  String get statsTaken => 'Принято';

  @override
  String get statsSkipped => 'Пропущено';

  @override
  String get statsMissed => 'Не отмечено';

  @override
  String get statsByDay => 'По дням';

  @override
  String get statsByMedication => 'По препаратам';

  @override
  String get statsChartHint => 'Нажмите на столбик, чтобы выбрать день';

  @override
  String get settingsAppearance => 'Оформление';

  @override
  String get themeSystem => 'Как в системе';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get settingsSound => 'Звук уведомления';

  @override
  String get soundDefault => 'Как в телефоне';

  @override
  String get soundPickPhone => 'Выбрать из телефона или свой файл…';

  @override
  String get soundPickPhoneHint =>
      'Откроется список звуков Android, туда можно добавить свой файл';

  @override
  String get soundPreview => 'Прослушать';

  @override
  String get soundChime => 'Перезвон';

  @override
  String get soundBell => 'Колокольчик';

  @override
  String get soundSoft => 'Мягкий';

  @override
  String get soundPulse => 'Пульс';

  @override
  String get soundCustom => 'Свой звук';

  @override
  String get soundBuiltIn => 'Звуки Dose';

  @override
  String unitShort(String unit) {
    String _temp0 = intl.Intl.selectLogic(unit, {
      'tablet': 'табл.',
      'capsule': 'капс.',
      'drop': 'кап.',
      'ml': 'мл',
      'mg': 'мг',
      'g': 'г',
      'mcg': 'мкг',
      'iu': 'МЕ',
      'units': 'ед.',
      'sachet': 'пак.',
      'teaspoon': 'ч. л.',
      'tablespoon': 'ст. л.',
      'scoop': 'мерн.',
      'ampoule': 'амп.',
      'spray': 'впрыск.',
      'dose': 'доз.',
      'piece': 'шт.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String unitName(String unit) {
    String _temp0 = intl.Intl.selectLogic(unit, {
      'tablet': 'Таблетка',
      'capsule': 'Капсула',
      'drop': 'Капля',
      'ml': 'Миллилитр (мл)',
      'mg': 'Миллиграмм (мг)',
      'g': 'Грамм (г)',
      'mcg': 'Микрограмм (мкг)',
      'iu': 'Международная единица (МЕ)',
      'units': 'Единицы',
      'sachet': 'Пакетик',
      'teaspoon': 'Чайная ложка',
      'tablespoon': 'Столовая ложка',
      'scoop': 'Мерная ложка',
      'ampoule': 'Ампула',
      'spray': 'Впрыскивание',
      'dose': 'Доза',
      'piece': 'Штука',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String shapeName(String shape) {
    String _temp0 = intl.Intl.selectLogic(shape, {
      'roundTablet': 'Круглая таблетка',
      'ovalTablet': 'Овальная таблетка',
      'capsule': 'Капсула',
      'softgel': 'Мягкая капсула',
      'dropper': 'Капли',
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
      many: '$n дней',
      few: '$n дня',
      one: '$n день',
    );
    return '$_temp0';
  }

  @override
  String statsStreak(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n дня подряд без пропусков',
      many: '$n дней подряд без пропусков',
      few: '$n дня подряд без пропусков',
      one: '$n день подряд без пропусков',
    );
    return '$_temp0';
  }

  @override
  String statsOfTotal(int taken, int total) {
    return '$taken из $total';
  }

  @override
  String statsSummary(int days, int taken, int total, int percent) {
    return 'За $days дн. принято $taken из $total доз ($percent%).';
  }

  @override
  String get stockTitle => 'Запас';

  @override
  String get stockNotTracked => 'Запас не отслеживается';

  @override
  String get stockSetUp => 'Настроить запас';

  @override
  String stockLeft(String amount) {
    return 'Осталось: $amount';
  }

  @override
  String stockDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Хватит на $days дня',
      many: 'Хватит на $days дней',
      few: 'Хватит на $days дня',
      one: 'Хватит на $days день',
    );
    return '$_temp0';
  }

  @override
  String stockRunsOut(String date) {
    return 'до $date';
  }

  @override
  String get stockEmpty => 'Закончилось';

  @override
  String get stockLow => 'Мало запаса';

  @override
  String get stockBought => 'Докупил';

  @override
  String stockAddPack(String amount) {
    return 'Одна упаковка: +$amount';
  }

  @override
  String get stockAddAmount => 'Другое количество';

  @override
  String get stockAmountToAdd => 'Сколько добавить';

  @override
  String get stockCorrect => 'Исправить количество';

  @override
  String get stockSettings => 'Настройки запаса';

  @override
  String get stockTrack => 'Отслеживать запас';

  @override
  String get stockTrackHint => 'Каждый принятый приём уменьшает количество';

  @override
  String get stockCurrent => 'Сейчас есть';

  @override
  String get stockPackSize => 'В упаковке';

  @override
  String get stockPackSizeHint => 'Для кнопки «Докупил»';

  @override
  String get stockWarnDays => 'Предупредить, когда останется дней';

  @override
  String get stockInvalid => 'Введите число';

  @override
  String get stockBanner => 'Пора докупить';

  @override
  String get notifStockChannelName => 'Запас';

  @override
  String get notifStockChannelDescription => 'Напоминания докупить';

  @override
  String get settingsData => 'Данные';

  @override
  String get backupExport => 'Сохранить резервную копию';

  @override
  String get backupExportHint =>
      'Файл со всеми препаратами, расписаниями и историей';

  @override
  String get backupImport => 'Восстановить из копии';

  @override
  String get backupImportHint => 'Заменит все текущие данные';

  @override
  String get backupSaved => 'Копия сохранена';

  @override
  String get backupRestored => 'Данные восстановлены';

  @override
  String get backupInvalid => 'Это не копия Dose или файл повреждён';

  @override
  String backupFailed(String error) {
    return 'Не удалось: $error';
  }

  @override
  String get backupConfirmTitle => 'Восстановить данные из копии?';

  @override
  String backupConfirmBody(int meds, int schedules, int events) {
    return 'В копии препаратов: $meds, расписаний: $schedules, записей о приёмах: $events. Все текущие данные будут заменены.';
  }

  @override
  String get backupRestore => 'Восстановить';

  @override
  String get fieldIngredients => 'Действующие вещества';

  @override
  String get ingredientsHint =>
      'Для проверки совместимости. Подобрано по названию, можно изменить.';

  @override
  String get compatTitle => 'Совместимость';

  @override
  String compatSeparate(String other, int hours) {
    return 'С «$other»: разносить минимум на $hours ч.';
  }

  @override
  String compatNow(String a, String b) {
    return 'Сейчас: $a и $b.';
  }

  @override
  String compatSuggest(String time) {
    return 'Совет: перенесите этот приём на $time.';
  }

  @override
  String compatAvoid(String other) {
    return 'С «$other»: осторожно.';
  }

  @override
  String compatTogether(String other) {
    return 'С «$other»: хорошо вместе.';
  }

  @override
  String get compatDisclaimer =>
      'Это не медицинская консультация. Посоветуйтесь с врачом, прежде чем менять схему приёма.';

  @override
  String get compatWarningTitle => 'Возможный конфликт';

  @override
  String get compatSaveAnyway => 'Всё равно сохранить';

  @override
  String get compatChangeTime => 'Изменить время';

  @override
  String takenAt(String time) {
    return 'Принято в $time';
  }

  @override
  String get changeTakenTime => 'Изменить время приёма';

  @override
  String get historyTitle => 'История';

  @override
  String get historyHint =>
      'Доля принятых доз за каждый день. Нажмите на день, чтобы открыть его.';

  @override
  String get historyNoDoses => 'Ничего не запланировано';

  @override
  String historyDayLabel(String date, int percent) {
    return '$date: $percent%';
  }

  @override
  String get prevMonth => 'Предыдущий месяц';

  @override
  String get nextMonth => 'Следующий месяц';

  @override
  String get updateCheck => 'Проверить обновления';

  @override
  String updateCurrent(String version) {
    return 'Установлено: $version';
  }

  @override
  String get updateAuto => 'Проверять обновления самостоятельно';

  @override
  String get updateAutoHint => 'Раз в день, когда есть интернет';

  @override
  String get updateNone => 'У вас последняя версия';

  @override
  String get updateUnavailable =>
      'Не удалось связаться с GitHub. Проверьте интернет и попробуйте позже.';

  @override
  String updateAvailable(String version) {
    return 'Доступна новая версия $version';
  }

  @override
  String get updateDownload => 'Скачать';

  @override
  String get updateHint =>
      'Скачайте файл и установите его поверх текущей версии. Все данные сохранятся.';

  @override
  String get later => 'Позже';

  @override
  String get guideTitle => 'Справка';

  @override
  String get guideIntake => 'Как принимать';

  @override
  String get guideCautions => 'Осторожно';

  @override
  String get guideSources => 'Источники';

  @override
  String get guideProductPage => 'Страница продукта';

  @override
  String get guideAll => 'Справочник добавок и лекарств';

  @override
  String get guideAllSubtitle => 'Как принимать, совместимость, источники';

  @override
  String get productHint =>
      'Обязательно. Начните вводить, чтобы выбрать готовый продукт';

  @override
  String get pickDate => 'Выбрать дату';

  @override
  String get statsOpenDay => 'Открыть день';

  @override
  String get statsCountHint => 'Нажмите, чтобы увидеть список';

  @override
  String get noDoses => 'Здесь пока пусто';

  @override
  String get dayUpcoming => 'Впереди';

  @override
  String get dayDoses => 'Приёмы';

  @override
  String durationMinutes(int m) {
    return '$m мин';
  }

  @override
  String durationHours(int h) {
    return '$h ч';
  }

  @override
  String durationHoursMinutes(int h, int m) {
    return '$h ч $m мин';
  }

  @override
  String delayLate(String d) {
    return 'на $d позже';
  }

  @override
  String delayEarly(String d) {
    return 'на $d раньше';
  }

  @override
  String get delayOnTime => 'вовремя';

  @override
  String plannedAt(String time) {
    return 'по плану $time';
  }

  @override
  String get medStatsTitle => 'Анализ приёма';

  @override
  String get medStatsOpenHint => 'Выполнение, серии, графики, точность времени';

  @override
  String medStatsSince(String date) {
    return 'В приложении с $date';
  }

  @override
  String courseDayOf(int day, int total, String date) {
    return 'День $day из $total, курс до $date';
  }

  @override
  String courseOngoing(int day) {
    return 'День $day, без даты окончания';
  }

  @override
  String courseNotStarted(String date) {
    return 'Начнётся $date';
  }

  @override
  String courseFinished(String date) {
    return 'Курс завершён $date';
  }

  @override
  String get periodAll => 'Всё';

  @override
  String trendUp(int n) {
    return 'На $n п.п. лучше, чем за предыдущий такой же период';
  }

  @override
  String trendDown(int n) {
    return 'На $n п.п. хуже, чем за предыдущий такой же период';
  }

  @override
  String get trendSame => 'Так же, как за предыдущий такой же период';

  @override
  String get streakCurrent => 'Текущая серия';

  @override
  String get streakBest => 'Самая длинная серия';

  @override
  String get daysTitle => 'Дни с приёмами';

  @override
  String get daysFull => 'Всё принято';

  @override
  String get daysPartial => 'Частично';

  @override
  String get daysNone => 'Ни одного';

  @override
  String get chartsTitle => 'Графики';

  @override
  String get byWeekday => 'По дням недели';

  @override
  String get byDoseTime => 'По времени приёма';

  @override
  String weekdayWorst(String day) {
    return 'Чаще всего пропускаете: $day';
  }

  @override
  String get timingTitle => 'Точность времени';

  @override
  String timingAverage(String delay) {
    return 'В среднем $delay';
  }

  @override
  String get timingOnTime => 'Вовремя (±15 мин)';

  @override
  String get timingEarly => 'Раньше более чем на 15 мин';

  @override
  String get timingLate => 'Позже на 15–60 мин';

  @override
  String get timingVeryLate => 'Позже более чем на час';

  @override
  String timingMax(String d) {
    return 'Самое большое опоздание: $d';
  }

  @override
  String get timingNone => 'Пока нет приёмов с отмеченным временем';

  @override
  String get amountTitle => 'Количество';

  @override
  String get amountPeriod => 'За выбранный период';

  @override
  String get amountAll => 'За всё время';

  @override
  String get amountPerDay => 'В среднем в день';

  @override
  String dosesCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n приёма',
      many: '$n приёмов',
      few: '$n приёма',
      one: '$n приём',
    );
    return '$_temp0';
  }

  @override
  String courseRemaining(String amount) {
    return 'До конца курса ещё принять: $amount';
  }

  @override
  String packsToFinish(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'До конца курса нужно докупить $n упаковки',
      many: 'До конца курса нужно докупить $n упаковок',
      few: 'До конца курса нужно докупить $n упаковки',
      one: 'До конца курса нужно докупить $n упаковку',
      zero: 'Запаса хватит до конца курса',
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
  String get guideDrugs => 'Лекарства';

  @override
  String get guideSearch => 'Поиск';

  @override
  String get guideSearchHint => 'Название или бренд, напр. Ксарелто';

  @override
  String get guideNothingFound => 'Ничего не найдено';

  @override
  String get guideDrugNote =>
      'Для лекарств показываем только совместимость. Как и сколько принимать — по назначению врача и инструкции.';

  @override
  String guideRuleCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n правила совместимости',
      many: '$n правил совместимости',
      few: '$n правила совместимости',
      one: '$n правило совместимости',
    );
    return '$_temp0';
  }

  @override
  String get guideRuleAvoid => 'осторожно вместе';

  @override
  String guideRuleSeparate(int hours) {
    return 'разделять на $hours ч';
  }

  @override
  String get guideRuleTogether => 'хорошо вместе';

  @override
  String get ingredientsAdd => 'Добавить вещество';

  @override
  String get ingredientsPick => 'Действующие вещества';

  @override
  String get ingredientsDone => 'Готово';

  @override
  String get ingredientsRemove => 'Убрать';
}
