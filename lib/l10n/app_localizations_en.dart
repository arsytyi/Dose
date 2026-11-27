// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Dose';

  @override
  String get navToday => 'Today';

  @override
  String get navMedications => 'Medications';

  @override
  String get navSettings => 'Settings';

  @override
  String get todayEmpty => 'No doses planned for today';

  @override
  String get todayHint => 'Add a medication and a schedule to get reminders.';

  @override
  String get medicationsEmpty => 'No medications yet';

  @override
  String get addMedication => 'Add medication';

  @override
  String get editMedication => 'Edit medication';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldNameRequired => 'Enter a name';

  @override
  String get kindMedicine => 'Medicine';

  @override
  String get kindSupplement => 'Supplement';

  @override
  String get fieldForm => 'Form';

  @override
  String get fieldUnit => 'Dose unit';

  @override
  String get fieldUnitHint => 'tablet, capsule, mg, ml, drops';

  @override
  String get fieldMeal => 'Food';

  @override
  String get fieldNotes => 'Notes';

  @override
  String get fieldNotesHint =>
      'What it\'s for, who prescribed it, anything to remember';

  @override
  String get fieldColor => 'Color';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get deleteMedicationTitle => 'Delete medication?';

  @override
  String get deleteMedicationBody =>
      'The medication, its schedules and history will be deleted permanently.';

  @override
  String get deleteScheduleTitle => 'Delete schedule?';

  @override
  String get archive => 'Archive';

  @override
  String get unarchive => 'Restore';

  @override
  String get archivedSection => 'Archived';

  @override
  String get notes => 'Notes';

  @override
  String get schedules => 'Schedules';

  @override
  String get addSchedule => 'Add schedule';

  @override
  String get noSchedules => 'No schedule yet. Add one to get reminders.';

  @override
  String get schedulePaused => 'Paused';

  @override
  String get scheduleTitle => 'Schedule';

  @override
  String get sectionDays => 'Days';

  @override
  String get patternDaily => 'Every day';

  @override
  String get patternWeekdays => 'Weekdays';

  @override
  String get patternEveryN => 'Every N days';

  @override
  String get patternCycle => 'Cycle';

  @override
  String get patternAsNeeded => 'As needed';

  @override
  String get everyNLabel => 'Interval, days';

  @override
  String get cycleOn => 'Days on';

  @override
  String get cycleOff => 'Days off';

  @override
  String get asNeededHint => 'No reminders; log doses manually.';

  @override
  String get sectionTimes => 'Time and dose';

  @override
  String get addTime => 'Add time';

  @override
  String get generateTimes => 'Every N hours';

  @override
  String get everyHours => 'Interval, hours';

  @override
  String get fromTime => 'From';

  @override
  String get untilTime => 'Until';

  @override
  String get dose => 'Dose';

  @override
  String get apply => 'Apply';

  @override
  String get sectionDuration => 'Duration';

  @override
  String get startDate => 'Start';

  @override
  String get durForever => 'No end';

  @override
  String get durDays => 'Number of days';

  @override
  String get durUntil => 'Until date';

  @override
  String get durDoses => 'Number of doses';

  @override
  String get endDate => 'End date';

  @override
  String get preview => 'Next 7 days';

  @override
  String get previewEmpty => 'No doses in the next 7 days';

  @override
  String get problemNoTimes => 'Add at least one time';

  @override
  String get problemDuplicateTimes => 'A time is listed twice';

  @override
  String get problemBadDose => 'Dose must be greater than zero';

  @override
  String get problemNoWeekdays => 'Pick at least one weekday';

  @override
  String get problemBadEveryN => 'Interval must be at least 1 day';

  @override
  String get problemBadCycle => 'Check the cycle days';

  @override
  String get problemBadDuration => 'Check the duration';

  @override
  String get sumDaily => 'every day';

  @override
  String get sumAsNeeded => 'as needed';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get langSystem => 'System default';

  @override
  String get settingsNotifications => 'Reminders';

  @override
  String get grantNotifications => 'Allow notifications';

  @override
  String get grantExactAlarms => 'Allow exact reminders';

  @override
  String get grantExactAlarmsHint =>
      'Without this Android may delay reminders by several minutes.';

  @override
  String get testNotification => 'Send a test reminder';

  @override
  String get testNotificationBody => 'Reminders are working.';

  @override
  String scheduledCount(int count) {
    return 'Reminders scheduled: $count';
  }

  @override
  String get about => 'About';

  @override
  String get disclaimer =>
      'Dose helps you remember your doses but does not replace advice from a doctor.';

  @override
  String get notifTitle => 'Time for your medication';

  @override
  String get notifChannelName => 'Dose reminders';

  @override
  String get notifChannelDescription => 'Alerts at planned dose times';

  @override
  String formName(String form) {
    String _temp0 = intl.Intl.selectLogic(form, {
      'tablet': 'Tablet',
      'capsule': 'Capsule',
      'drops': 'Drops',
      'liquid': 'Liquid',
      'powder': 'Powder',
      'injection': 'Injection',
      'spray': 'Spray',
      'other': 'Other',
    });
    return '$_temp0';
  }

  @override
  String mealName(String meal) {
    String _temp0 = intl.Intl.selectLogic(meal, {
      'any': 'Doesn\'t matter',
      'before': 'Before food',
      'during': 'With food',
      'after': 'After food',
      'emptyStomach': 'On an empty stomach',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String sumEveryN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'every $n days',
      one: 'every day',
    );
    return '$_temp0';
  }

  @override
  String sumCycle(int on, int off) {
    return '$on days on, $off days off';
  }

  @override
  String sumUntil(String date) {
    return 'until $date';
  }

  @override
  String sumFrom(String date) {
    return 'from $date';
  }

  @override
  String sumForDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days',
      one: '$n day',
    );
    return '$_temp0';
  }

  @override
  String sumForDoses(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n doses',
      one: '$n dose',
    );
    return '$_temp0';
  }

  @override
  String daysLeft(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days left',
      one: '$n day left',
    );
    return '$_temp0';
  }

  @override
  String get removeTime => 'Remove time';

  @override
  String get decrease => 'Decrease';

  @override
  String get increase => 'Increase';

  @override
  String colorOption(int n) {
    return 'Color $n';
  }

  @override
  String get actionTaken => 'Taken';

  @override
  String get actionSnooze => 'Snooze';

  @override
  String get actionSkip => 'Skip';

  @override
  String get notifTitleRepeat => 'Not marked yet';

  @override
  String get notifTitleSnoozed => 'Snoozed reminder';

  @override
  String get statePlanned => 'Planned';

  @override
  String get stateOverdue => 'Overdue';

  @override
  String get stateSkipped => 'Skipped';

  @override
  String get stateTaken => 'Taken';

  @override
  String get allDone => 'All done';

  @override
  String get partNight => 'Night';

  @override
  String get partMorning => 'Morning';

  @override
  String get partAfternoon => 'Afternoon';

  @override
  String get partEvening => 'Evening';

  @override
  String get takeAll => 'Take all';

  @override
  String get undoMark => 'Undo';

  @override
  String get undo => 'Undo';

  @override
  String get asNeededSection => 'As needed';

  @override
  String get logNow => 'Took it now';

  @override
  String get prevDay => 'Previous day';

  @override
  String get nextDay => 'Next day';

  @override
  String get dayEmpty => 'No doses on this day';

  @override
  String get snoozeDuration => 'Snooze for';

  @override
  String get repeatReminders => 'Repeat reminders';

  @override
  String get repeatRemindersHint =>
      'After 15 and 30 min if the dose isn\'t marked';

  @override
  String get unscheduled => 'Unscheduled';

  @override
  String stateTakenAt(String time) {
    return 'Taken at $time';
  }

  @override
  String stateSnoozedUntil(String time) {
    return 'Snoozed until $time';
  }

  @override
  String progressTaken(int taken, int total) {
    return '$taken of $total taken';
  }

  @override
  String progressDetails(int skipped, int pending) {
    return 'Skipped: $skipped · Left: $pending';
  }

  @override
  String progressPlanned(int n) {
    return 'Doses planned: $n';
  }

  @override
  String snoozeFor(int n) {
    return 'Snooze $n min';
  }

  @override
  String minutesShort(int n) {
    return '$n min';
  }

  @override
  String snackSnoozed(String time) {
    return 'Snoozed until $time';
  }

  @override
  String progressPercent(int n) {
    return '$n%';
  }

  @override
  String get unitOther => 'Other…';

  @override
  String get unitCustom => 'Custom unit';

  @override
  String get fieldLook => 'Look';

  @override
  String get fieldColor2 => 'Second color';

  @override
  String get navStats => 'Statistics';

  @override
  String get statsEmpty =>
      'No data yet. Mark your doses and statistics will appear here.';

  @override
  String get statsAdherence => 'Adherence';

  @override
  String get statsTaken => 'Taken';

  @override
  String get statsSkipped => 'Skipped';

  @override
  String get statsMissed => 'Not marked';

  @override
  String get statsByDay => 'By day';

  @override
  String get statsByMedication => 'By medication';

  @override
  String get statsChartHint => 'Tap a bar to select a day';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsSound => 'Notification sound';

  @override
  String get soundDefault => 'Phone default';

  @override
  String get soundPickPhone => 'Choose from phone or your own file…';

  @override
  String get soundPickPhoneHint =>
      'Opens Android\'s sound list, where you can add your own file';

  @override
  String get soundPreview => 'Play';

  @override
  String get soundChime => 'Chime';

  @override
  String get soundBell => 'Bell';

  @override
  String get soundSoft => 'Soft';

  @override
  String get soundPulse => 'Pulse';

  @override
  String get soundCustom => 'Custom sound';

  @override
  String get soundBuiltIn => 'Dose sounds';

  @override
  String unitShort(String unit) {
    String _temp0 = intl.Intl.selectLogic(unit, {
      'tablet': 'tab',
      'capsule': 'caps',
      'drop': 'drops',
      'ml': 'ml',
      'mg': 'mg',
      'g': 'g',
      'mcg': 'mcg',
      'iu': 'IU',
      'units': 'units',
      'sachet': 'sachet',
      'teaspoon': 'tsp',
      'tablespoon': 'tbsp',
      'scoop': 'scoop',
      'ampoule': 'amp',
      'spray': 'spray',
      'dose': 'dose',
      'piece': 'pcs',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String unitName(String unit) {
    String _temp0 = intl.Intl.selectLogic(unit, {
      'tablet': 'Tablet',
      'capsule': 'Capsule',
      'drop': 'Drop',
      'ml': 'Millilitre (ml)',
      'mg': 'Milligram (mg)',
      'g': 'Gram (g)',
      'mcg': 'Microgram (mcg)',
      'iu': 'International unit (IU)',
      'units': 'Units',
      'sachet': 'Sachet',
      'teaspoon': 'Teaspoon',
      'tablespoon': 'Tablespoon',
      'scoop': 'Scoop',
      'ampoule': 'Ampoule',
      'spray': 'Spray',
      'dose': 'Dose',
      'piece': 'Piece',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String shapeName(String shape) {
    String _temp0 = intl.Intl.selectLogic(shape, {
      'roundTablet': 'Round tablet',
      'ovalTablet': 'Oval tablet',
      'capsule': 'Capsule',
      'softgel': 'Softgel',
      'dropper': 'Drops',
      'bottle': 'Bottle',
      'sachet': 'Sachet',
      'syringe': 'Syringe',
      'spray': 'Spray',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String statsPeriod(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days',
      one: '$n day',
    );
    return '$_temp0';
  }

  @override
  String statsStreak(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days in a row with nothing missed',
      one: '$n day in a row with nothing missed',
    );
    return '$_temp0';
  }

  @override
  String statsOfTotal(int taken, int total) {
    return '$taken of $total';
  }

  @override
  String statsSummary(int days, int taken, int total, int percent) {
    return 'Over $days days $taken of $total doses were taken ($percent%).';
  }

  @override
  String get stockTitle => 'Stock';

  @override
  String get stockNotTracked => 'Stock isn\'t tracked';

  @override
  String get stockSetUp => 'Set up stock';

  @override
  String stockLeft(String amount) {
    return 'Left: $amount';
  }

  @override
  String stockDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Lasts $days days',
      one: 'Lasts $days day',
    );
    return '$_temp0';
  }

  @override
  String stockRunsOut(String date) {
    return 'until $date';
  }

  @override
  String get stockEmpty => 'Out of stock';

  @override
  String get stockLow => 'Running low';

  @override
  String get stockBought => 'Bought more';

  @override
  String stockAddPack(String amount) {
    return 'One pack: +$amount';
  }

  @override
  String get stockAddAmount => 'Another amount';

  @override
  String get stockAmountToAdd => 'How much to add';

  @override
  String get stockCorrect => 'Correct the count';

  @override
  String get stockSettings => 'Stock settings';

  @override
  String get stockTrack => 'Track stock';

  @override
  String get stockTrackHint => 'Each dose taken lowers the count';

  @override
  String get stockCurrent => 'On hand';

  @override
  String get stockPackSize => 'Per pack';

  @override
  String get stockPackSizeHint => 'Used by \"Bought more\"';

  @override
  String get stockWarnDays => 'Warn when this many days are left';

  @override
  String get stockInvalid => 'Enter a number';

  @override
  String get stockBanner => 'Time to restock';

  @override
  String get notifStockChannelName => 'Stock';

  @override
  String get notifStockChannelDescription => 'Reminders to buy more';

  @override
  String get settingsData => 'Data';

  @override
  String get backupExport => 'Save a backup';

  @override
  String get backupExportHint =>
      'A file with all medications, schedules and history';

  @override
  String get backupImport => 'Restore from a backup';

  @override
  String get backupImportHint => 'Replaces all current data';

  @override
  String get backupSaved => 'Backup saved';

  @override
  String get backupRestored => 'Data restored';

  @override
  String get backupInvalid =>
      'This isn\'t a Dose backup, or the file is damaged';

  @override
  String backupFailed(String error) {
    return 'Failed: $error';
  }

  @override
  String get backupConfirmTitle => 'Restore data from the backup?';

  @override
  String backupConfirmBody(int meds, int schedules, int events) {
    return 'The backup has $meds medications, $schedules schedules and $events dose records. All current data will be replaced.';
  }

  @override
  String get backupRestore => 'Restore';

  @override
  String get fieldIngredients => 'Active substances';

  @override
  String get ingredientsHint =>
      'Used for the compatibility check. Picked from the name; you can change them.';

  @override
  String get compatTitle => 'Compatibility';

  @override
  String compatSeparate(String other, int hours) {
    return 'With “$other”: keep at least $hours h apart.';
  }

  @override
  String compatNow(String a, String b) {
    return 'Now: $a and $b.';
  }

  @override
  String compatSuggest(String time) {
    return 'Tip: move this dose to $time.';
  }

  @override
  String compatAvoid(String other) {
    return 'With “$other”: be careful.';
  }

  @override
  String compatTogether(String other) {
    return 'With “$other”: good together.';
  }

  @override
  String get compatDisclaimer =>
      'This is not medical advice. Talk to your doctor before changing your regimen.';

  @override
  String get compatWarningTitle => 'Possible conflict';

  @override
  String get compatSaveAnyway => 'Save anyway';

  @override
  String get compatChangeTime => 'Change the time';

  @override
  String takenAt(String time) {
    return 'Taken at $time';
  }

  @override
  String get changeTakenTime => 'Change the time taken';

  @override
  String get historyTitle => 'History';

  @override
  String get historyHint =>
      'Share of doses taken each day. Tap a day to open it.';

  @override
  String get historyNoDoses => 'Nothing planned';

  @override
  String historyDayLabel(String date, int percent) {
    return '$date: $percent%';
  }

  @override
  String get prevMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get updateCheck => 'Check for updates';

  @override
  String updateCurrent(String version) {
    return 'Installed: $version';
  }

  @override
  String get updateAuto => 'Check for updates automatically';

  @override
  String get updateAutoHint => 'Once a day when online';

  @override
  String get updateNone => 'You have the latest version';

  @override
  String get updateUnavailable =>
      'Couldn\'t reach GitHub. Check your internet and try again later.';

  @override
  String updateAvailable(String version) {
    return 'Version $version is available';
  }

  @override
  String get updateDownload => 'Download';

  @override
  String get updateHint =>
      'Download the file and install it over the current version. Your data stays.';

  @override
  String get later => 'Later';

  @override
  String get guideTitle => 'Reference';

  @override
  String get guideIntake => 'How to take';

  @override
  String get guideCautions => 'Cautions';

  @override
  String get guideSources => 'Sources';

  @override
  String get guideProductPage => 'Product page';

  @override
  String get guideAll => 'Supplement and medicine guide';

  @override
  String get guideAllSubtitle => 'How to take, compatibility, sources';

  @override
  String get productHint =>
      'Required. Start typing to pick a ready-made product';

  @override
  String get pickDate => 'Choose date';

  @override
  String get statsOpenDay => 'Open day';

  @override
  String get statsCountHint => 'Tap to see the list';

  @override
  String get noDoses => 'Nothing here yet';

  @override
  String get dayUpcoming => 'Upcoming';

  @override
  String get dayDoses => 'Doses';

  @override
  String durationMinutes(int m) {
    return '$m min';
  }

  @override
  String durationHours(int h) {
    return '$h h';
  }

  @override
  String durationHoursMinutes(int h, int m) {
    return '$h h $m min';
  }

  @override
  String delayLate(String d) {
    return '$d late';
  }

  @override
  String delayEarly(String d) {
    return '$d early';
  }

  @override
  String get delayOnTime => 'on time';

  @override
  String plannedAt(String time) {
    return 'planned $time';
  }

  @override
  String get medStatsTitle => 'Intake analysis';

  @override
  String get medStatsOpenHint => 'Adherence, streaks, charts, timing';

  @override
  String medStatsSince(String date) {
    return 'In the app since $date';
  }

  @override
  String courseDayOf(int day, int total, String date) {
    return 'Day $day of $total, until $date';
  }

  @override
  String courseOngoing(int day) {
    return 'Day $day, no end date';
  }

  @override
  String courseNotStarted(String date) {
    return 'Starts $date';
  }

  @override
  String courseFinished(String date) {
    return 'Course finished $date';
  }

  @override
  String get periodAll => 'All';

  @override
  String trendUp(int n) {
    return '$n points better than the period before';
  }

  @override
  String trendDown(int n) {
    return '$n points worse than the period before';
  }

  @override
  String get trendSame => 'Same as the period before';

  @override
  String get streakCurrent => 'Current streak';

  @override
  String get streakBest => 'Best streak';

  @override
  String get daysTitle => 'Days with doses';

  @override
  String get daysFull => 'All taken';

  @override
  String get daysPartial => 'Partly';

  @override
  String get daysNone => 'None taken';

  @override
  String get chartsTitle => 'Charts';

  @override
  String get byWeekday => 'By weekday';

  @override
  String get byDoseTime => 'By dose time';

  @override
  String weekdayWorst(String day) {
    return 'Most often missed: $day';
  }

  @override
  String get timingTitle => 'Timing';

  @override
  String timingAverage(String delay) {
    return 'On average $delay';
  }

  @override
  String get timingOnTime => 'On time (±15 min)';

  @override
  String get timingEarly => 'Over 15 min early';

  @override
  String get timingLate => '15–60 min late';

  @override
  String get timingVeryLate => 'Over an hour late';

  @override
  String timingMax(String d) {
    return 'Latest dose: $d late';
  }

  @override
  String get timingNone => 'No doses with a recorded time yet';

  @override
  String get amountTitle => 'Amount';

  @override
  String get amountPeriod => 'In this period';

  @override
  String get amountAll => 'All time';

  @override
  String get amountPerDay => 'Average per day';

  @override
  String dosesCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n doses',
      one: '$n dose',
    );
    return '$_temp0';
  }

  @override
  String courseRemaining(String amount) {
    return 'Left to take in the course: $amount';
  }

  @override
  String packsToFinish(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Buy $n more packs to finish the course',
      one: 'Buy $n more pack to finish the course',
      zero: 'Enough stock to finish the course',
    );
    return '$_temp0';
  }

  @override
  String listTitle(String status, String period) {
    return '$status · $period';
  }

  @override
  String get guideSupplements => 'Supplements';

  @override
  String get guideDrugs => 'Medicines';

  @override
  String get guideSearch => 'Search';

  @override
  String get guideSearchHint => 'Name or brand, e.g. Xarelto';

  @override
  String get guideNothingFound => 'Nothing found';

  @override
  String get guideDrugNote =>
      'For medicines we only show compatibility. How and how much to take is up to your doctor and the leaflet.';

  @override
  String guideRuleCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n compatibility rules',
      one: '$n compatibility rule',
    );
    return '$_temp0';
  }

  @override
  String get guideRuleAvoid => 'careful together';

  @override
  String guideRuleSeparate(int hours) {
    return 'keep $hours h apart';
  }

  @override
  String get guideRuleTogether => 'good together';

  @override
  String get ingredientsAdd => 'Add substance';

  @override
  String get ingredientsPick => 'Active substances';

  @override
  String get ingredientsDone => 'Done';

  @override
  String get ingredientsRemove => 'Remove';

  @override
  String get exactAlarmPromptTitle => 'Reminders on time';

  @override
  String get exactAlarmPromptBody =>
      'Android may delay reminders by several minutes unless Dose is allowed to set exact alarms. On the next screen, turn on “Allow setting alarms and reminders”.';

  @override
  String get exactAlarmPromptAllow => 'Allow';

  @override
  String get proTitle => 'Dose Pro';

  @override
  String get proTagline => 'One payment. No subscription, no ads.';

  @override
  String get proFeatureAnalytics => 'Detailed analytics';

  @override
  String get proFeatureAnalyticsHint =>
      'Each medication and each day in depth: streaks, timing, trends.';

  @override
  String get proFeatureStock => 'Stock and refill reminders';

  @override
  String get proFeatureStockHint =>
      'See how many days are left and get reminded before you run out.';

  @override
  String get proFeatureGuide => 'Full substance guide';

  @override
  String get proFeatureGuideHint =>
      'How to take each supplement, with sources and ready-made products.';

  @override
  String get proFeatureSounds => 'Your own reminder sound';

  @override
  String get proFeatureSoundsHint => 'Dose sounds or any sound on your phone.';

  @override
  String get proFreeNote =>
      'Free forever: reminders, the dose log, statistics, compatibility warnings and backups.';

  @override
  String proBuy(String price) {
    return 'Buy for $price';
  }

  @override
  String get proBuyNoPrice => 'Buy Dose Pro';

  @override
  String get proRestore => 'Restore purchase';

  @override
  String get proUnlockedThanks => 'Dose Pro is active. Thank you!';

  @override
  String get proPending =>
      'The purchase is waiting for payment. Pro opens as soon as Google Play confirms it.';

  @override
  String get proError =>
      'Couldn\'t reach Google Play. Check that you\'re signed in to Play and try again.';

  @override
  String get proLocked => 'Available in Dose Pro';

  @override
  String get proLearnMore => 'About Dose Pro';

  @override
  String get proSettingsActive => 'Active. Thank you!';

  @override
  String get proSettingsInactive => 'Analytics, stock, guide and sounds';
}
