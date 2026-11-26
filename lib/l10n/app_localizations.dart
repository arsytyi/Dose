import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('uk'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In uk, this message translates to:
  /// **'Dose'**
  String get appTitle;

  /// No description provided for @navToday.
  ///
  /// In uk, this message translates to:
  /// **'Сьогодні'**
  String get navToday;

  /// No description provided for @navMedications.
  ///
  /// In uk, this message translates to:
  /// **'Препарати'**
  String get navMedications;

  /// No description provided for @navSettings.
  ///
  /// In uk, this message translates to:
  /// **'Налаштування'**
  String get navSettings;

  /// No description provided for @todayEmpty.
  ///
  /// In uk, this message translates to:
  /// **'На сьогодні прийомів немає'**
  String get todayEmpty;

  /// No description provided for @todayHint.
  ///
  /// In uk, this message translates to:
  /// **'Додайте препарат і розклад, щоб отримувати нагадування.'**
  String get todayHint;

  /// No description provided for @medicationsEmpty.
  ///
  /// In uk, this message translates to:
  /// **'Препаратів ще немає'**
  String get medicationsEmpty;

  /// No description provided for @addMedication.
  ///
  /// In uk, this message translates to:
  /// **'Додати препарат'**
  String get addMedication;

  /// No description provided for @editMedication.
  ///
  /// In uk, this message translates to:
  /// **'Редагувати препарат'**
  String get editMedication;

  /// No description provided for @fieldName.
  ///
  /// In uk, this message translates to:
  /// **'Назва'**
  String get fieldName;

  /// No description provided for @fieldNameRequired.
  ///
  /// In uk, this message translates to:
  /// **'Введіть назву'**
  String get fieldNameRequired;

  /// No description provided for @kindMedicine.
  ///
  /// In uk, this message translates to:
  /// **'Ліки'**
  String get kindMedicine;

  /// No description provided for @kindSupplement.
  ///
  /// In uk, this message translates to:
  /// **'БАД'**
  String get kindSupplement;

  /// No description provided for @fieldForm.
  ///
  /// In uk, this message translates to:
  /// **'Форма'**
  String get fieldForm;

  /// No description provided for @fieldUnit.
  ///
  /// In uk, this message translates to:
  /// **'Одиниця дози'**
  String get fieldUnit;

  /// No description provided for @fieldUnitHint.
  ///
  /// In uk, this message translates to:
  /// **'табл., капс., мг, мл, крапл.'**
  String get fieldUnitHint;

  /// No description provided for @fieldMeal.
  ///
  /// In uk, this message translates to:
  /// **'Прийом їжі'**
  String get fieldMeal;

  /// No description provided for @fieldNotes.
  ///
  /// In uk, this message translates to:
  /// **'Нотатки'**
  String get fieldNotes;

  /// No description provided for @fieldNotesHint.
  ///
  /// In uk, this message translates to:
  /// **'Від чого, хто призначив, особливості'**
  String get fieldNotesHint;

  /// No description provided for @fieldColor.
  ///
  /// In uk, this message translates to:
  /// **'Колір'**
  String get fieldColor;

  /// No description provided for @save.
  ///
  /// In uk, this message translates to:
  /// **'Зберегти'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In uk, this message translates to:
  /// **'Скасувати'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In uk, this message translates to:
  /// **'Видалити'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In uk, this message translates to:
  /// **'Редагувати'**
  String get edit;

  /// No description provided for @deleteMedicationTitle.
  ///
  /// In uk, this message translates to:
  /// **'Видалити препарат?'**
  String get deleteMedicationTitle;

  /// No description provided for @deleteMedicationBody.
  ///
  /// In uk, this message translates to:
  /// **'Препарат, його розклади та історію буде видалено назавжди.'**
  String get deleteMedicationBody;

  /// No description provided for @deleteScheduleTitle.
  ///
  /// In uk, this message translates to:
  /// **'Видалити розклад?'**
  String get deleteScheduleTitle;

  /// No description provided for @archive.
  ///
  /// In uk, this message translates to:
  /// **'В архів'**
  String get archive;

  /// No description provided for @unarchive.
  ///
  /// In uk, this message translates to:
  /// **'Повернути з архіву'**
  String get unarchive;

  /// No description provided for @archivedSection.
  ///
  /// In uk, this message translates to:
  /// **'Архів'**
  String get archivedSection;

  /// No description provided for @notes.
  ///
  /// In uk, this message translates to:
  /// **'Нотатки'**
  String get notes;

  /// No description provided for @schedules.
  ///
  /// In uk, this message translates to:
  /// **'Розклади'**
  String get schedules;

  /// No description provided for @addSchedule.
  ///
  /// In uk, this message translates to:
  /// **'Додати розклад'**
  String get addSchedule;

  /// No description provided for @noSchedules.
  ///
  /// In uk, this message translates to:
  /// **'Розкладу ще немає. Додайте його, щоб отримувати нагадування.'**
  String get noSchedules;

  /// No description provided for @schedulePaused.
  ///
  /// In uk, this message translates to:
  /// **'Призупинено'**
  String get schedulePaused;

  /// No description provided for @scheduleTitle.
  ///
  /// In uk, this message translates to:
  /// **'Розклад'**
  String get scheduleTitle;

  /// No description provided for @sectionDays.
  ///
  /// In uk, this message translates to:
  /// **'Дні'**
  String get sectionDays;

  /// No description provided for @patternDaily.
  ///
  /// In uk, this message translates to:
  /// **'Щодня'**
  String get patternDaily;

  /// No description provided for @patternWeekdays.
  ///
  /// In uk, this message translates to:
  /// **'Дні тижня'**
  String get patternWeekdays;

  /// No description provided for @patternEveryN.
  ///
  /// In uk, this message translates to:
  /// **'Кожні N днів'**
  String get patternEveryN;

  /// No description provided for @patternCycle.
  ///
  /// In uk, this message translates to:
  /// **'Цикл'**
  String get patternCycle;

  /// No description provided for @patternAsNeeded.
  ///
  /// In uk, this message translates to:
  /// **'За потреби'**
  String get patternAsNeeded;

  /// No description provided for @everyNLabel.
  ///
  /// In uk, this message translates to:
  /// **'Інтервал, днів'**
  String get everyNLabel;

  /// No description provided for @cycleOn.
  ///
  /// In uk, this message translates to:
  /// **'Днів прийому'**
  String get cycleOn;

  /// No description provided for @cycleOff.
  ///
  /// In uk, this message translates to:
  /// **'Днів перерви'**
  String get cycleOff;

  /// No description provided for @asNeededHint.
  ///
  /// In uk, this message translates to:
  /// **'Нагадувань не буде, прийом відмічається вручну.'**
  String get asNeededHint;

  /// No description provided for @sectionTimes.
  ///
  /// In uk, this message translates to:
  /// **'Час і доза'**
  String get sectionTimes;

  /// No description provided for @addTime.
  ///
  /// In uk, this message translates to:
  /// **'Додати час'**
  String get addTime;

  /// No description provided for @generateTimes.
  ///
  /// In uk, this message translates to:
  /// **'Кожні N годин'**
  String get generateTimes;

  /// No description provided for @everyHours.
  ///
  /// In uk, this message translates to:
  /// **'Інтервал, годин'**
  String get everyHours;

  /// No description provided for @fromTime.
  ///
  /// In uk, this message translates to:
  /// **'З'**
  String get fromTime;

  /// No description provided for @untilTime.
  ///
  /// In uk, this message translates to:
  /// **'До'**
  String get untilTime;

  /// No description provided for @dose.
  ///
  /// In uk, this message translates to:
  /// **'Доза'**
  String get dose;

  /// No description provided for @apply.
  ///
  /// In uk, this message translates to:
  /// **'Застосувати'**
  String get apply;

  /// No description provided for @sectionDuration.
  ///
  /// In uk, this message translates to:
  /// **'Тривалість'**
  String get sectionDuration;

  /// No description provided for @startDate.
  ///
  /// In uk, this message translates to:
  /// **'Початок'**
  String get startDate;

  /// No description provided for @durForever.
  ///
  /// In uk, this message translates to:
  /// **'Безстроково'**
  String get durForever;

  /// No description provided for @durDays.
  ///
  /// In uk, this message translates to:
  /// **'Кількість днів'**
  String get durDays;

  /// No description provided for @durUntil.
  ///
  /// In uk, this message translates to:
  /// **'До дати'**
  String get durUntil;

  /// No description provided for @durDoses.
  ///
  /// In uk, this message translates to:
  /// **'Кількість доз'**
  String get durDoses;

  /// No description provided for @endDate.
  ///
  /// In uk, this message translates to:
  /// **'Дата завершення'**
  String get endDate;

  /// No description provided for @preview.
  ///
  /// In uk, this message translates to:
  /// **'Найближчі 7 днів'**
  String get preview;

  /// No description provided for @previewEmpty.
  ///
  /// In uk, this message translates to:
  /// **'У найближчі 7 днів прийомів немає'**
  String get previewEmpty;

  /// No description provided for @problemNoTimes.
  ///
  /// In uk, this message translates to:
  /// **'Додайте хоча б один час прийому'**
  String get problemNoTimes;

  /// No description provided for @problemDuplicateTimes.
  ///
  /// In uk, this message translates to:
  /// **'Час прийому повторюється'**
  String get problemDuplicateTimes;

  /// No description provided for @problemBadDose.
  ///
  /// In uk, this message translates to:
  /// **'Доза має бути більшою за нуль'**
  String get problemBadDose;

  /// No description provided for @problemNoWeekdays.
  ///
  /// In uk, this message translates to:
  /// **'Виберіть хоча б один день тижня'**
  String get problemNoWeekdays;

  /// No description provided for @problemBadEveryN.
  ///
  /// In uk, this message translates to:
  /// **'Інтервал має бути щонайменше 1 день'**
  String get problemBadEveryN;

  /// No description provided for @problemBadCycle.
  ///
  /// In uk, this message translates to:
  /// **'Перевірте кількість днів циклу'**
  String get problemBadCycle;

  /// No description provided for @problemBadDuration.
  ///
  /// In uk, this message translates to:
  /// **'Перевірте тривалість курсу'**
  String get problemBadDuration;

  /// No description provided for @sumDaily.
  ///
  /// In uk, this message translates to:
  /// **'щодня'**
  String get sumDaily;

  /// No description provided for @sumAsNeeded.
  ///
  /// In uk, this message translates to:
  /// **'за потреби'**
  String get sumAsNeeded;

  /// No description provided for @settingsLanguage.
  ///
  /// In uk, this message translates to:
  /// **'Мова'**
  String get settingsLanguage;

  /// No description provided for @langSystem.
  ///
  /// In uk, this message translates to:
  /// **'Як у системі'**
  String get langSystem;

  /// No description provided for @settingsNotifications.
  ///
  /// In uk, this message translates to:
  /// **'Нагадування'**
  String get settingsNotifications;

  /// No description provided for @grantNotifications.
  ///
  /// In uk, this message translates to:
  /// **'Дозволити сповіщення'**
  String get grantNotifications;

  /// No description provided for @grantExactAlarms.
  ///
  /// In uk, this message translates to:
  /// **'Дозволити точні нагадування'**
  String get grantExactAlarms;

  /// No description provided for @grantExactAlarmsHint.
  ///
  /// In uk, this message translates to:
  /// **'Без цього Android може затримувати нагадування на кілька хвилин.'**
  String get grantExactAlarmsHint;

  /// No description provided for @testNotification.
  ///
  /// In uk, this message translates to:
  /// **'Надіслати тестове нагадування'**
  String get testNotification;

  /// No description provided for @testNotificationBody.
  ///
  /// In uk, this message translates to:
  /// **'Нагадування працюють.'**
  String get testNotificationBody;

  /// No description provided for @scheduledCount.
  ///
  /// In uk, this message translates to:
  /// **'Заплановано нагадувань: {count}'**
  String scheduledCount(int count);

  /// No description provided for @about.
  ///
  /// In uk, this message translates to:
  /// **'Про застосунок'**
  String get about;

  /// No description provided for @disclaimer.
  ///
  /// In uk, this message translates to:
  /// **'Dose допомагає не забувати про прийом, але не замінює консультацію лікаря.'**
  String get disclaimer;

  /// No description provided for @notifTitle.
  ///
  /// In uk, this message translates to:
  /// **'Час прийняти ліки'**
  String get notifTitle;

  /// No description provided for @notifChannelName.
  ///
  /// In uk, this message translates to:
  /// **'Нагадування про прийом'**
  String get notifChannelName;

  /// No description provided for @notifChannelDescription.
  ///
  /// In uk, this message translates to:
  /// **'Сповіщення в запланований час прийому'**
  String get notifChannelDescription;

  /// No description provided for @formName.
  ///
  /// In uk, this message translates to:
  /// **'{form, select, tablet{Таблетка} capsule{Капсула} drops{Краплі} liquid{Рідина} powder{Порошок} injection{Ін\'єкція} spray{Спрей} other{Інше}}'**
  String formName(String form);

  /// No description provided for @mealName.
  ///
  /// In uk, this message translates to:
  /// **'{meal, select, any{Неважливо} before{До їжі} during{Під час їжі} after{Після їжі} emptyStomach{Натщесерце} other{}}'**
  String mealName(String meal);

  /// No description provided for @sumEveryN.
  ///
  /// In uk, this message translates to:
  /// **'{n, plural, one{кожен {n} день} few{кожні {n} дні} many{кожні {n} днів} other{кожні {n} дня}}'**
  String sumEveryN(int n);

  /// No description provided for @sumCycle.
  ///
  /// In uk, this message translates to:
  /// **'{on} дн. прийому, {off} дн. перерви'**
  String sumCycle(int on, int off);

  /// No description provided for @sumUntil.
  ///
  /// In uk, this message translates to:
  /// **'до {date}'**
  String sumUntil(String date);

  /// No description provided for @sumFrom.
  ///
  /// In uk, this message translates to:
  /// **'з {date}'**
  String sumFrom(String date);

  /// No description provided for @sumForDays.
  ///
  /// In uk, this message translates to:
  /// **'{n, plural, one{{n} день} few{{n} дні} many{{n} днів} other{{n} дня}}'**
  String sumForDays(int n);

  /// No description provided for @sumForDoses.
  ///
  /// In uk, this message translates to:
  /// **'{n, plural, one{{n} доза} few{{n} дози} many{{n} доз} other{{n} дози}}'**
  String sumForDoses(int n);

  /// No description provided for @daysLeft.
  ///
  /// In uk, this message translates to:
  /// **'{n, plural, one{залишився {n} день} few{залишилось {n} дні} many{залишилось {n} днів} other{залишилось {n} дня}}'**
  String daysLeft(int n);

  /// No description provided for @removeTime.
  ///
  /// In uk, this message translates to:
  /// **'Прибрати час'**
  String get removeTime;

  /// No description provided for @decrease.
  ///
  /// In uk, this message translates to:
  /// **'Зменшити'**
  String get decrease;

  /// No description provided for @increase.
  ///
  /// In uk, this message translates to:
  /// **'Збільшити'**
  String get increase;

  /// No description provided for @colorOption.
  ///
  /// In uk, this message translates to:
  /// **'Колір {n}'**
  String colorOption(int n);

  /// No description provided for @actionTaken.
  ///
  /// In uk, this message translates to:
  /// **'Прийняв'**
  String get actionTaken;

  /// No description provided for @actionSnooze.
  ///
  /// In uk, this message translates to:
  /// **'Відкласти'**
  String get actionSnooze;

  /// No description provided for @actionSkip.
  ///
  /// In uk, this message translates to:
  /// **'Пропустити'**
  String get actionSkip;

  /// No description provided for @notifTitleRepeat.
  ///
  /// In uk, this message translates to:
  /// **'Ще не відмічено'**
  String get notifTitleRepeat;

  /// No description provided for @notifTitleSnoozed.
  ///
  /// In uk, this message translates to:
  /// **'Відкладене нагадування'**
  String get notifTitleSnoozed;

  /// No description provided for @statePlanned.
  ///
  /// In uk, this message translates to:
  /// **'Заплановано'**
  String get statePlanned;

  /// No description provided for @stateOverdue.
  ///
  /// In uk, this message translates to:
  /// **'Прострочено'**
  String get stateOverdue;

  /// No description provided for @stateSkipped.
  ///
  /// In uk, this message translates to:
  /// **'Пропущено'**
  String get stateSkipped;

  /// No description provided for @stateTaken.
  ///
  /// In uk, this message translates to:
  /// **'Прийнято'**
  String get stateTaken;

  /// No description provided for @allDone.
  ///
  /// In uk, this message translates to:
  /// **'Усе прийнято'**
  String get allDone;

  /// No description provided for @partNight.
  ///
  /// In uk, this message translates to:
  /// **'Ніч'**
  String get partNight;

  /// No description provided for @partMorning.
  ///
  /// In uk, this message translates to:
  /// **'Ранок'**
  String get partMorning;

  /// No description provided for @partAfternoon.
  ///
  /// In uk, this message translates to:
  /// **'День'**
  String get partAfternoon;

  /// No description provided for @partEvening.
  ///
  /// In uk, this message translates to:
  /// **'Вечір'**
  String get partEvening;

  /// No description provided for @takeAll.
  ///
  /// In uk, this message translates to:
  /// **'Прийняти все'**
  String get takeAll;

  /// No description provided for @undoMark.
  ///
  /// In uk, this message translates to:
  /// **'Скасувати відмітку'**
  String get undoMark;

  /// No description provided for @undo.
  ///
  /// In uk, this message translates to:
  /// **'Скасувати'**
  String get undo;

  /// No description provided for @asNeededSection.
  ///
  /// In uk, this message translates to:
  /// **'За потреби'**
  String get asNeededSection;

  /// No description provided for @logNow.
  ///
  /// In uk, this message translates to:
  /// **'Прийняв зараз'**
  String get logNow;

  /// No description provided for @prevDay.
  ///
  /// In uk, this message translates to:
  /// **'Попередній день'**
  String get prevDay;

  /// No description provided for @nextDay.
  ///
  /// In uk, this message translates to:
  /// **'Наступний день'**
  String get nextDay;

  /// No description provided for @dayEmpty.
  ///
  /// In uk, this message translates to:
  /// **'На цей день прийомів немає'**
  String get dayEmpty;

  /// No description provided for @snoozeDuration.
  ///
  /// In uk, this message translates to:
  /// **'Відкладати на'**
  String get snoozeDuration;

  /// No description provided for @repeatReminders.
  ///
  /// In uk, this message translates to:
  /// **'Повторювати нагадування'**
  String get repeatReminders;

  /// No description provided for @repeatRemindersHint.
  ///
  /// In uk, this message translates to:
  /// **'Через 15 і 30 хв, якщо прийом не відмічено'**
  String get repeatRemindersHint;

  /// No description provided for @unscheduled.
  ///
  /// In uk, this message translates to:
  /// **'Поза розкладом'**
  String get unscheduled;

  /// No description provided for @stateTakenAt.
  ///
  /// In uk, this message translates to:
  /// **'Прийнято о {time}'**
  String stateTakenAt(String time);

  /// No description provided for @stateSnoozedUntil.
  ///
  /// In uk, this message translates to:
  /// **'Відкладено до {time}'**
  String stateSnoozedUntil(String time);

  /// No description provided for @progressTaken.
  ///
  /// In uk, this message translates to:
  /// **'{taken} з {total} прийнято'**
  String progressTaken(int taken, int total);

  /// No description provided for @progressDetails.
  ///
  /// In uk, this message translates to:
  /// **'Пропущено: {skipped} · Залишилось: {pending}'**
  String progressDetails(int skipped, int pending);

  /// No description provided for @progressPlanned.
  ///
  /// In uk, this message translates to:
  /// **'Заплановано прийомів: {n}'**
  String progressPlanned(int n);

  /// No description provided for @snoozeFor.
  ///
  /// In uk, this message translates to:
  /// **'Відкласти на {n} хв'**
  String snoozeFor(int n);

  /// No description provided for @minutesShort.
  ///
  /// In uk, this message translates to:
  /// **'{n} хв'**
  String minutesShort(int n);

  /// No description provided for @snackSnoozed.
  ///
  /// In uk, this message translates to:
  /// **'Відкладено до {time}'**
  String snackSnoozed(String time);

  /// No description provided for @progressPercent.
  ///
  /// In uk, this message translates to:
  /// **'{n}%'**
  String progressPercent(int n);

  /// No description provided for @unitOther.
  ///
  /// In uk, this message translates to:
  /// **'Інше…'**
  String get unitOther;

  /// No description provided for @unitCustom.
  ///
  /// In uk, this message translates to:
  /// **'Своя одиниця'**
  String get unitCustom;

  /// No description provided for @fieldLook.
  ///
  /// In uk, this message translates to:
  /// **'Вигляд'**
  String get fieldLook;

  /// No description provided for @fieldColor2.
  ///
  /// In uk, this message translates to:
  /// **'Другий колір'**
  String get fieldColor2;

  /// No description provided for @navStats.
  ///
  /// In uk, this message translates to:
  /// **'Статистика'**
  String get navStats;

  /// No description provided for @statsEmpty.
  ///
  /// In uk, this message translates to:
  /// **'Ще немає даних. Відмічайте прийоми, і тут з\'явиться статистика.'**
  String get statsEmpty;

  /// No description provided for @statsAdherence.
  ///
  /// In uk, this message translates to:
  /// **'Виконання'**
  String get statsAdherence;

  /// No description provided for @statsTaken.
  ///
  /// In uk, this message translates to:
  /// **'Прийнято'**
  String get statsTaken;

  /// No description provided for @statsSkipped.
  ///
  /// In uk, this message translates to:
  /// **'Пропущено'**
  String get statsSkipped;

  /// No description provided for @statsMissed.
  ///
  /// In uk, this message translates to:
  /// **'Не відмічено'**
  String get statsMissed;

  /// No description provided for @statsByDay.
  ///
  /// In uk, this message translates to:
  /// **'По днях'**
  String get statsByDay;

  /// No description provided for @statsByMedication.
  ///
  /// In uk, this message translates to:
  /// **'По препаратах'**
  String get statsByMedication;

  /// No description provided for @statsChartHint.
  ///
  /// In uk, this message translates to:
  /// **'Натисніть на стовпчик, щоб вибрати день'**
  String get statsChartHint;

  /// No description provided for @settingsAppearance.
  ///
  /// In uk, this message translates to:
  /// **'Оформлення'**
  String get settingsAppearance;

  /// No description provided for @themeSystem.
  ///
  /// In uk, this message translates to:
  /// **'Як у системі'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In uk, this message translates to:
  /// **'Світла'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In uk, this message translates to:
  /// **'Темна'**
  String get themeDark;

  /// No description provided for @settingsSound.
  ///
  /// In uk, this message translates to:
  /// **'Звук сповіщення'**
  String get settingsSound;

  /// No description provided for @soundDefault.
  ///
  /// In uk, this message translates to:
  /// **'Стандартний звук телефону'**
  String get soundDefault;

  /// No description provided for @soundPickPhone.
  ///
  /// In uk, this message translates to:
  /// **'Вибрати з телефону або свій файл…'**
  String get soundPickPhone;

  /// No description provided for @soundPickPhoneHint.
  ///
  /// In uk, this message translates to:
  /// **'Відкриє список звуків Android, де можна додати свій файл'**
  String get soundPickPhoneHint;

  /// No description provided for @soundPreview.
  ///
  /// In uk, this message translates to:
  /// **'Прослухати'**
  String get soundPreview;

  /// No description provided for @soundChime.
  ///
  /// In uk, this message translates to:
  /// **'Дзвіночок'**
  String get soundChime;

  /// No description provided for @soundBell.
  ///
  /// In uk, this message translates to:
  /// **'Дзвін'**
  String get soundBell;

  /// No description provided for @soundSoft.
  ///
  /// In uk, this message translates to:
  /// **'М\'який'**
  String get soundSoft;

  /// No description provided for @soundPulse.
  ///
  /// In uk, this message translates to:
  /// **'Сигнал'**
  String get soundPulse;

  /// No description provided for @soundCustom.
  ///
  /// In uk, this message translates to:
  /// **'Свій звук'**
  String get soundCustom;

  /// No description provided for @soundBuiltIn.
  ///
  /// In uk, this message translates to:
  /// **'Мелодії Dose'**
  String get soundBuiltIn;

  /// No description provided for @unitShort.
  ///
  /// In uk, this message translates to:
  /// **'{unit, select, tablet{табл.} capsule{капс.} drop{крапл.} ml{мл} mg{мг} g{г} mcg{мкг} iu{МО} units{ОД} sachet{пак.} teaspoon{ч. л.} tablespoon{ст. л.} scoop{мірн. л.} ampoule{амп.} spray{впорск.} dose{доза} piece{шт.} other{}}'**
  String unitShort(String unit);

  /// No description provided for @unitName.
  ///
  /// In uk, this message translates to:
  /// **'{unit, select, tablet{Таблетка (табл.)} capsule{Капсула (капс.)} drop{Крапля (крапл.)} ml{Мілілітр (мл)} mg{Міліграм (мг)} g{Грам (г)} mcg{Мікрограм (мкг)} iu{Міжнародна одиниця (МО)} units{Одиниця дії (ОД)} sachet{Пакетик (пак.)} teaspoon{Чайна ложка} tablespoon{Столова ложка} scoop{Мірна ложка} ampoule{Ампула} spray{Впорскування} dose{Доза} piece{Штука (шт.)} other{}}'**
  String unitName(String unit);

  /// No description provided for @shapeName.
  ///
  /// In uk, this message translates to:
  /// **'{shape, select, roundTablet{Кругла таблетка} ovalTablet{Овальна таблетка} capsule{Капсула} softgel{М\'яка капсула} dropper{Краплі} bottle{Флакон} sachet{Пакетик} syringe{Шприц} spray{Спрей} other{}}'**
  String shapeName(String shape);

  /// No description provided for @statsPeriod.
  ///
  /// In uk, this message translates to:
  /// **'{n, plural, one{{n} день} few{{n} дні} many{{n} днів} other{{n} дня}}'**
  String statsPeriod(int n);

  /// No description provided for @statsStreak.
  ///
  /// In uk, this message translates to:
  /// **'{n, plural, one{{n} день поспіль без пропусків} few{{n} дні поспіль без пропусків} many{{n} днів поспіль без пропусків} other{{n} дня поспіль без пропусків}}'**
  String statsStreak(int n);

  /// No description provided for @statsOfTotal.
  ///
  /// In uk, this message translates to:
  /// **'{taken} з {total}'**
  String statsOfTotal(int taken, int total);

  /// No description provided for @statsSummary.
  ///
  /// In uk, this message translates to:
  /// **'За {days} днів прийнято {taken} з {total} доз ({percent}%).'**
  String statsSummary(int days, int taken, int total, int percent);

  /// No description provided for @stockTitle.
  ///
  /// In uk, this message translates to:
  /// **'Запас'**
  String get stockTitle;

  /// No description provided for @stockNotTracked.
  ///
  /// In uk, this message translates to:
  /// **'Запас не відстежується'**
  String get stockNotTracked;

  /// No description provided for @stockSetUp.
  ///
  /// In uk, this message translates to:
  /// **'Вказати запас'**
  String get stockSetUp;

  /// No description provided for @stockLeft.
  ///
  /// In uk, this message translates to:
  /// **'Залишилось: {amount}'**
  String stockLeft(String amount);

  /// No description provided for @stockDaysLeft.
  ///
  /// In uk, this message translates to:
  /// **'{days, plural, one{Вистачить на {days} день} few{Вистачить на {days} дні} many{Вистачить на {days} днів} other{Вистачить на {days} дня}}'**
  String stockDaysLeft(int days);

  /// No description provided for @stockRunsOut.
  ///
  /// In uk, this message translates to:
  /// **'до {date}'**
  String stockRunsOut(String date);

  /// No description provided for @stockEmpty.
  ///
  /// In uk, this message translates to:
  /// **'Закінчився'**
  String get stockEmpty;

  /// No description provided for @stockLow.
  ///
  /// In uk, this message translates to:
  /// **'Мало запасу'**
  String get stockLow;

  /// No description provided for @stockBought.
  ///
  /// In uk, this message translates to:
  /// **'Докупив'**
  String get stockBought;

  /// No description provided for @stockAddPack.
  ///
  /// In uk, this message translates to:
  /// **'Упаковка: +{amount}'**
  String stockAddPack(String amount);

  /// No description provided for @stockAddAmount.
  ///
  /// In uk, this message translates to:
  /// **'Інша кількість'**
  String get stockAddAmount;

  /// No description provided for @stockAmountToAdd.
  ///
  /// In uk, this message translates to:
  /// **'Скільки додати'**
  String get stockAmountToAdd;

  /// No description provided for @stockCorrect.
  ///
  /// In uk, this message translates to:
  /// **'Виправити залишок'**
  String get stockCorrect;

  /// No description provided for @stockSettings.
  ///
  /// In uk, this message translates to:
  /// **'Налаштування запасу'**
  String get stockSettings;

  /// No description provided for @stockTrack.
  ///
  /// In uk, this message translates to:
  /// **'Відстежувати запас'**
  String get stockTrack;

  /// No description provided for @stockTrackHint.
  ///
  /// In uk, this message translates to:
  /// **'Кожен прийом зменшує залишок'**
  String get stockTrackHint;

  /// No description provided for @stockCurrent.
  ///
  /// In uk, this message translates to:
  /// **'Зараз є'**
  String get stockCurrent;

  /// No description provided for @stockPackSize.
  ///
  /// In uk, this message translates to:
  /// **'В упаковці'**
  String get stockPackSize;

  /// No description provided for @stockPackSizeHint.
  ///
  /// In uk, this message translates to:
  /// **'Для кнопки «Докупив»'**
  String get stockPackSizeHint;

  /// No description provided for @stockWarnDays.
  ///
  /// In uk, this message translates to:
  /// **'Попереджати, коли лишиться днів'**
  String get stockWarnDays;

  /// No description provided for @stockInvalid.
  ///
  /// In uk, this message translates to:
  /// **'Введіть число'**
  String get stockInvalid;

  /// No description provided for @stockBanner.
  ///
  /// In uk, this message translates to:
  /// **'Час докупити'**
  String get stockBanner;

  /// No description provided for @notifStockChannelName.
  ///
  /// In uk, this message translates to:
  /// **'Запас'**
  String get notifStockChannelName;

  /// No description provided for @notifStockChannelDescription.
  ///
  /// In uk, this message translates to:
  /// **'Нагадування докупити препарати'**
  String get notifStockChannelDescription;

  /// No description provided for @settingsData.
  ///
  /// In uk, this message translates to:
  /// **'Дані'**
  String get settingsData;

  /// No description provided for @backupExport.
  ///
  /// In uk, this message translates to:
  /// **'Зберегти резервну копію'**
  String get backupExport;

  /// No description provided for @backupExportHint.
  ///
  /// In uk, this message translates to:
  /// **'Файл з усіма препаратами, розкладами й історією'**
  String get backupExportHint;

  /// No description provided for @backupImport.
  ///
  /// In uk, this message translates to:
  /// **'Відновити з копії'**
  String get backupImport;

  /// No description provided for @backupImportHint.
  ///
  /// In uk, this message translates to:
  /// **'Замінить усі поточні дані'**
  String get backupImportHint;

  /// No description provided for @backupSaved.
  ///
  /// In uk, this message translates to:
  /// **'Копію збережено'**
  String get backupSaved;

  /// No description provided for @backupRestored.
  ///
  /// In uk, this message translates to:
  /// **'Дані відновлено'**
  String get backupRestored;

  /// No description provided for @backupInvalid.
  ///
  /// In uk, this message translates to:
  /// **'Це не резервна копія Dose або файл пошкоджено'**
  String get backupInvalid;

  /// No description provided for @backupFailed.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося: {error}'**
  String backupFailed(String error);

  /// No description provided for @backupConfirmTitle.
  ///
  /// In uk, this message translates to:
  /// **'Відновити дані з копії?'**
  String get backupConfirmTitle;

  /// No description provided for @backupConfirmBody.
  ///
  /// In uk, this message translates to:
  /// **'У копії: препаратів {meds}, розкладів {schedules}, записів про прийом {events}. Усі поточні дані буде замінено.'**
  String backupConfirmBody(int meds, int schedules, int events);

  /// No description provided for @backupRestore.
  ///
  /// In uk, this message translates to:
  /// **'Відновити'**
  String get backupRestore;

  /// No description provided for @fieldIngredients.
  ///
  /// In uk, this message translates to:
  /// **'Діючі речовини'**
  String get fieldIngredients;

  /// No description provided for @ingredientsHint.
  ///
  /// In uk, this message translates to:
  /// **'Для перевірки сумісності. Підібрано за назвою, можна змінити.'**
  String get ingredientsHint;

  /// No description provided for @compatTitle.
  ///
  /// In uk, this message translates to:
  /// **'Сумісність'**
  String get compatTitle;

  /// No description provided for @compatSeparate.
  ///
  /// In uk, this message translates to:
  /// **'З «{other}»: розділяйте щонайменше на {hours} год.'**
  String compatSeparate(String other, int hours);

  /// No description provided for @compatNow.
  ///
  /// In uk, this message translates to:
  /// **'Зараз: {a} і {b}.'**
  String compatNow(String a, String b);

  /// No description provided for @compatSuggest.
  ///
  /// In uk, this message translates to:
  /// **'Порада: перенесіть цей прийом на {time}.'**
  String compatSuggest(String time);

  /// No description provided for @compatAvoid.
  ///
  /// In uk, this message translates to:
  /// **'З «{other}»: обережно.'**
  String compatAvoid(String other);

  /// No description provided for @compatTogether.
  ///
  /// In uk, this message translates to:
  /// **'З «{other}»: добре разом.'**
  String compatTogether(String other);

  /// No description provided for @compatDisclaimer.
  ///
  /// In uk, this message translates to:
  /// **'Це не медична порада. Перед зміною схеми проконсультуйтеся з лікарем.'**
  String get compatDisclaimer;

  /// No description provided for @compatWarningTitle.
  ///
  /// In uk, this message translates to:
  /// **'Можлива несумісність'**
  String get compatWarningTitle;

  /// No description provided for @compatSaveAnyway.
  ///
  /// In uk, this message translates to:
  /// **'Зберегти все одно'**
  String get compatSaveAnyway;

  /// No description provided for @compatChangeTime.
  ///
  /// In uk, this message translates to:
  /// **'Змінити час'**
  String get compatChangeTime;

  /// No description provided for @takenAt.
  ///
  /// In uk, this message translates to:
  /// **'Прийнято о {time}'**
  String takenAt(String time);

  /// No description provided for @changeTakenTime.
  ///
  /// In uk, this message translates to:
  /// **'Змінити час прийому'**
  String get changeTakenTime;

  /// No description provided for @historyTitle.
  ///
  /// In uk, this message translates to:
  /// **'Історія'**
  String get historyTitle;

  /// No description provided for @historyHint.
  ///
  /// In uk, this message translates to:
  /// **'Відсоток прийнятих доз за день. Натисніть день, щоб відкрити його.'**
  String get historyHint;

  /// No description provided for @historyNoDoses.
  ///
  /// In uk, this message translates to:
  /// **'Нічого не заплановано'**
  String get historyNoDoses;

  /// No description provided for @historyDayLabel.
  ///
  /// In uk, this message translates to:
  /// **'{date}: {percent}%'**
  String historyDayLabel(String date, int percent);

  /// No description provided for @prevMonth.
  ///
  /// In uk, this message translates to:
  /// **'Попередній місяць'**
  String get prevMonth;

  /// No description provided for @nextMonth.
  ///
  /// In uk, this message translates to:
  /// **'Наступний місяць'**
  String get nextMonth;

  /// No description provided for @updateCheck.
  ///
  /// In uk, this message translates to:
  /// **'Перевірити оновлення'**
  String get updateCheck;

  /// No description provided for @updateCurrent.
  ///
  /// In uk, this message translates to:
  /// **'Зараз встановлено {version}'**
  String updateCurrent(String version);

  /// No description provided for @updateAuto.
  ///
  /// In uk, this message translates to:
  /// **'Перевіряти оновлення самостійно'**
  String get updateAuto;

  /// No description provided for @updateAutoHint.
  ///
  /// In uk, this message translates to:
  /// **'Раз на день, коли є інтернет'**
  String get updateAutoHint;

  /// No description provided for @updateNone.
  ///
  /// In uk, this message translates to:
  /// **'У вас остання версія'**
  String get updateNone;

  /// No description provided for @updateUnavailable.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося перевірити: немає інтернету або репозиторій закритий'**
  String get updateUnavailable;

  /// No description provided for @updateAvailable.
  ///
  /// In uk, this message translates to:
  /// **'Доступна нова версія {version}'**
  String updateAvailable(String version);

  /// No description provided for @updateDownload.
  ///
  /// In uk, this message translates to:
  /// **'Завантажити'**
  String get updateDownload;

  /// No description provided for @updateHint.
  ///
  /// In uk, this message translates to:
  /// **'Завантажте файл і встановіть його поверх поточної версії. Усі дані збережуться.'**
  String get updateHint;

  /// No description provided for @later.
  ///
  /// In uk, this message translates to:
  /// **'Пізніше'**
  String get later;

  /// No description provided for @guideTitle.
  ///
  /// In uk, this message translates to:
  /// **'Довідка'**
  String get guideTitle;

  /// No description provided for @guideIntake.
  ///
  /// In uk, this message translates to:
  /// **'Як приймати'**
  String get guideIntake;

  /// No description provided for @guideCautions.
  ///
  /// In uk, this message translates to:
  /// **'Обережно'**
  String get guideCautions;

  /// No description provided for @guideSources.
  ///
  /// In uk, this message translates to:
  /// **'Джерела'**
  String get guideSources;

  /// No description provided for @guideProductPage.
  ///
  /// In uk, this message translates to:
  /// **'Сторінка продукту'**
  String get guideProductPage;

  /// No description provided for @guideAll.
  ///
  /// In uk, this message translates to:
  /// **'Довідник добавок і ліків'**
  String get guideAll;

  /// No description provided for @guideAllSubtitle.
  ///
  /// In uk, this message translates to:
  /// **'Як приймати, сумісність, джерела'**
  String get guideAllSubtitle;

  /// No description provided for @productHint.
  ///
  /// In uk, this message translates to:
  /// **'Обов\'язково. Почніть вводити, щоб вибрати готовий продукт'**
  String get productHint;

  /// No description provided for @pickDate.
  ///
  /// In uk, this message translates to:
  /// **'Вибрати дату'**
  String get pickDate;

  /// No description provided for @statsOpenDay.
  ///
  /// In uk, this message translates to:
  /// **'Відкрити день'**
  String get statsOpenDay;

  /// No description provided for @statsCountHint.
  ///
  /// In uk, this message translates to:
  /// **'Натисніть, щоб побачити список'**
  String get statsCountHint;

  /// No description provided for @noDoses.
  ///
  /// In uk, this message translates to:
  /// **'Тут поки порожньо'**
  String get noDoses;

  /// No description provided for @dayUpcoming.
  ///
  /// In uk, this message translates to:
  /// **'Попереду'**
  String get dayUpcoming;

  /// No description provided for @dayDoses.
  ///
  /// In uk, this message translates to:
  /// **'Прийоми'**
  String get dayDoses;

  /// No description provided for @durationMinutes.
  ///
  /// In uk, this message translates to:
  /// **'{m} хв'**
  String durationMinutes(int m);

  /// No description provided for @durationHours.
  ///
  /// In uk, this message translates to:
  /// **'{h} год'**
  String durationHours(int h);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In uk, this message translates to:
  /// **'{h} год {m} хв'**
  String durationHoursMinutes(int h, int m);

  /// No description provided for @delayLate.
  ///
  /// In uk, this message translates to:
  /// **'на {d} пізніше'**
  String delayLate(String d);

  /// No description provided for @delayEarly.
  ///
  /// In uk, this message translates to:
  /// **'на {d} раніше'**
  String delayEarly(String d);

  /// No description provided for @delayOnTime.
  ///
  /// In uk, this message translates to:
  /// **'вчасно'**
  String get delayOnTime;

  /// No description provided for @plannedAt.
  ///
  /// In uk, this message translates to:
  /// **'за планом {time}'**
  String plannedAt(String time);

  /// No description provided for @medStatsTitle.
  ///
  /// In uk, this message translates to:
  /// **'Аналіз прийому'**
  String get medStatsTitle;

  /// No description provided for @medStatsOpenHint.
  ///
  /// In uk, this message translates to:
  /// **'Виконання, серії, графіки, точність часу'**
  String get medStatsOpenHint;

  /// No description provided for @medStatsSince.
  ///
  /// In uk, this message translates to:
  /// **'У додатку з {date}'**
  String medStatsSince(String date);

  /// No description provided for @courseDayOf.
  ///
  /// In uk, this message translates to:
  /// **'День {day} з {total}, курс до {date}'**
  String courseDayOf(int day, int total, String date);

  /// No description provided for @courseOngoing.
  ///
  /// In uk, this message translates to:
  /// **'День {day}, без кінцевої дати'**
  String courseOngoing(int day);

  /// No description provided for @courseNotStarted.
  ///
  /// In uk, this message translates to:
  /// **'Почнеться {date}'**
  String courseNotStarted(String date);

  /// No description provided for @courseFinished.
  ///
  /// In uk, this message translates to:
  /// **'Курс завершено {date}'**
  String courseFinished(String date);

  /// No description provided for @periodAll.
  ///
  /// In uk, this message translates to:
  /// **'Усе'**
  String get periodAll;

  /// No description provided for @trendUp.
  ///
  /// In uk, this message translates to:
  /// **'На {n} п.п. краще, ніж за попередній такий самий період'**
  String trendUp(int n);

  /// No description provided for @trendDown.
  ///
  /// In uk, this message translates to:
  /// **'На {n} п.п. гірше, ніж за попередній такий самий період'**
  String trendDown(int n);

  /// No description provided for @trendSame.
  ///
  /// In uk, this message translates to:
  /// **'Так само, як за попередній такий самий період'**
  String get trendSame;

  /// No description provided for @streakCurrent.
  ///
  /// In uk, this message translates to:
  /// **'Поточна серія'**
  String get streakCurrent;

  /// No description provided for @streakBest.
  ///
  /// In uk, this message translates to:
  /// **'Найдовша серія'**
  String get streakBest;

  /// No description provided for @daysTitle.
  ///
  /// In uk, this message translates to:
  /// **'Дні з прийомами'**
  String get daysTitle;

  /// No description provided for @daysFull.
  ///
  /// In uk, this message translates to:
  /// **'Усе прийнято'**
  String get daysFull;

  /// No description provided for @daysPartial.
  ///
  /// In uk, this message translates to:
  /// **'Частково'**
  String get daysPartial;

  /// No description provided for @daysNone.
  ///
  /// In uk, this message translates to:
  /// **'Жодного'**
  String get daysNone;

  /// No description provided for @chartsTitle.
  ///
  /// In uk, this message translates to:
  /// **'Графіки'**
  String get chartsTitle;

  /// No description provided for @byWeekday.
  ///
  /// In uk, this message translates to:
  /// **'По днях тижня'**
  String get byWeekday;

  /// No description provided for @byDoseTime.
  ///
  /// In uk, this message translates to:
  /// **'По часу прийому'**
  String get byDoseTime;

  /// No description provided for @weekdayWorst.
  ///
  /// In uk, this message translates to:
  /// **'Найчастіше пропускаєте: {day}'**
  String weekdayWorst(String day);

  /// No description provided for @timingTitle.
  ///
  /// In uk, this message translates to:
  /// **'Точність часу'**
  String get timingTitle;

  /// No description provided for @timingAverage.
  ///
  /// In uk, this message translates to:
  /// **'У середньому {delay}'**
  String timingAverage(String delay);

  /// No description provided for @timingOnTime.
  ///
  /// In uk, this message translates to:
  /// **'Вчасно (±15 хв)'**
  String get timingOnTime;

  /// No description provided for @timingEarly.
  ///
  /// In uk, this message translates to:
  /// **'Раніше ніж на 15 хв'**
  String get timingEarly;

  /// No description provided for @timingLate.
  ///
  /// In uk, this message translates to:
  /// **'Пізніше на 15–60 хв'**
  String get timingLate;

  /// No description provided for @timingVeryLate.
  ///
  /// In uk, this message translates to:
  /// **'Пізніше ніж на годину'**
  String get timingVeryLate;

  /// No description provided for @timingMax.
  ///
  /// In uk, this message translates to:
  /// **'Найбільше запізнення: {d}'**
  String timingMax(String d);

  /// No description provided for @timingNone.
  ///
  /// In uk, this message translates to:
  /// **'Ще немає прийомів із відміченим часом'**
  String get timingNone;

  /// No description provided for @amountTitle.
  ///
  /// In uk, this message translates to:
  /// **'Кількість'**
  String get amountTitle;

  /// No description provided for @amountPeriod.
  ///
  /// In uk, this message translates to:
  /// **'За обраний період'**
  String get amountPeriod;

  /// No description provided for @amountAll.
  ///
  /// In uk, this message translates to:
  /// **'За весь час'**
  String get amountAll;

  /// No description provided for @amountPerDay.
  ///
  /// In uk, this message translates to:
  /// **'В середньому на день'**
  String get amountPerDay;

  /// No description provided for @dosesCount.
  ///
  /// In uk, this message translates to:
  /// **'{n, plural, one{{n} прийом} few{{n} прийоми} many{{n} прийомів} other{{n} прийому}}'**
  String dosesCount(int n);

  /// No description provided for @courseRemaining.
  ///
  /// In uk, this message translates to:
  /// **'До кінця курсу ще прийняти: {amount}'**
  String courseRemaining(String amount);

  /// No description provided for @packsToFinish.
  ///
  /// In uk, this message translates to:
  /// **'{n, plural, =0{Запасу вистачить до кінця курсу} one{До кінця курсу треба докупити {n} упаковку} few{До кінця курсу треба докупити {n} упаковки} many{До кінця курсу треба докупити {n} упаковок} other{До кінця курсу треба докупити {n} упаковки}}'**
  String packsToFinish(int n);

  /// No description provided for @listTitle.
  ///
  /// In uk, this message translates to:
  /// **'{status} · {period}'**
  String listTitle(String status, String period);

  /// No description provided for @guideSupplements.
  ///
  /// In uk, this message translates to:
  /// **'Добавки'**
  String get guideSupplements;

  /// No description provided for @guideDrugs.
  ///
  /// In uk, this message translates to:
  /// **'Ліки'**
  String get guideDrugs;

  /// No description provided for @guideSearch.
  ///
  /// In uk, this message translates to:
  /// **'Пошук'**
  String get guideSearch;

  /// No description provided for @guideSearchHint.
  ///
  /// In uk, this message translates to:
  /// **'Назва або бренд, напр. Олідетрим'**
  String get guideSearchHint;

  /// No description provided for @guideNothingFound.
  ///
  /// In uk, this message translates to:
  /// **'Нічого не знайдено'**
  String get guideNothingFound;

  /// No description provided for @guideDrugNote.
  ///
  /// In uk, this message translates to:
  /// **'Для ліків показуємо лише сумісність. Як і скільки приймати — за призначенням лікаря та інструкцією.'**
  String get guideDrugNote;

  /// No description provided for @guideRuleCount.
  ///
  /// In uk, this message translates to:
  /// **'{n, plural, one{{n} правило сумісності} few{{n} правила сумісності} many{{n} правил сумісності} other{{n} правила сумісності}}'**
  String guideRuleCount(int n);

  /// No description provided for @guideRuleAvoid.
  ///
  /// In uk, this message translates to:
  /// **'обережно разом'**
  String get guideRuleAvoid;

  /// No description provided for @guideRuleSeparate.
  ///
  /// In uk, this message translates to:
  /// **'розділяти на {hours} год'**
  String guideRuleSeparate(int hours);

  /// No description provided for @guideRuleTogether.
  ///
  /// In uk, this message translates to:
  /// **'добре разом'**
  String get guideRuleTogether;

  /// No description provided for @ingredientsAdd.
  ///
  /// In uk, this message translates to:
  /// **'Додати речовину'**
  String get ingredientsAdd;

  /// No description provided for @ingredientsPick.
  ///
  /// In uk, this message translates to:
  /// **'Діючі речовини'**
  String get ingredientsPick;

  /// No description provided for @ingredientsDone.
  ///
  /// In uk, this message translates to:
  /// **'Готово'**
  String get ingredientsDone;

  /// No description provided for @ingredientsRemove.
  ///
  /// In uk, this message translates to:
  /// **'Прибрати'**
  String get ingredientsRemove;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
