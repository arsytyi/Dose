// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Dose';

  @override
  String get navToday => 'Hoy';

  @override
  String get navMedications => 'Medicamentos';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get todayEmpty => 'No hay tomas para hoy';

  @override
  String get todayHint =>
      'Añade un medicamento y un horario para recibir recordatorios.';

  @override
  String get medicationsEmpty => 'Aún no hay medicamentos';

  @override
  String get addMedication => 'Añadir medicamento';

  @override
  String get editMedication => 'Editar medicamento';

  @override
  String get fieldName => 'Nombre';

  @override
  String get fieldNameRequired => 'Escribe un nombre';

  @override
  String get kindMedicine => 'Medicamento';

  @override
  String get kindSupplement => 'Suplemento';

  @override
  String get fieldForm => 'Forma';

  @override
  String get fieldUnit => 'Unidad de dosis';

  @override
  String get fieldUnitHint => 'comprimido, cápsula, mg, ml, gotas';

  @override
  String get fieldMeal => 'Comida';

  @override
  String get fieldNotes => 'Notas';

  @override
  String get fieldNotesHint => 'Para qué es, quién lo recetó, qué recordar';

  @override
  String get fieldColor => 'Color';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get deleteMedicationTitle => '¿Eliminar el medicamento?';

  @override
  String get deleteMedicationBody =>
      'El medicamento, sus horarios y su historial se eliminarán para siempre.';

  @override
  String get deleteScheduleTitle => '¿Eliminar el horario?';

  @override
  String get archive => 'Archivar';

  @override
  String get unarchive => 'Restaurar';

  @override
  String get archivedSection => 'Archivados';

  @override
  String get notes => 'Notas';

  @override
  String get schedules => 'Horarios';

  @override
  String get addSchedule => 'Añadir horario';

  @override
  String get noSchedules =>
      'Aún no hay horario. Añade uno para recibir recordatorios.';

  @override
  String get schedulePaused => 'En pausa';

  @override
  String get scheduleTitle => 'Horario';

  @override
  String get sectionDays => 'Días';

  @override
  String get patternDaily => 'Cada día';

  @override
  String get patternWeekdays => 'Días de la semana';

  @override
  String get patternEveryN => 'Cada N días';

  @override
  String get patternCycle => 'Ciclo';

  @override
  String get patternAsNeeded => 'Cuando haga falta';

  @override
  String get everyNLabel => 'Intervalo, días';

  @override
  String get cycleOn => 'Días de toma';

  @override
  String get cycleOff => 'Días de descanso';

  @override
  String get asNeededHint =>
      'Sin recordatorios; las tomas se registran a mano.';

  @override
  String get sectionTimes => 'Hora y dosis';

  @override
  String get addTime => 'Añadir hora';

  @override
  String get generateTimes => 'Cada N horas';

  @override
  String get everyHours => 'Intervalo, horas';

  @override
  String get fromTime => 'Desde';

  @override
  String get untilTime => 'Hasta';

  @override
  String get dose => 'Dosis';

  @override
  String get apply => 'Aplicar';

  @override
  String get sectionDuration => 'Duración';

  @override
  String get startDate => 'Inicio';

  @override
  String get durForever => 'Sin fin';

  @override
  String get durDays => 'Número de días';

  @override
  String get durUntil => 'Hasta una fecha';

  @override
  String get durDoses => 'Número de tomas';

  @override
  String get endDate => 'Fecha de fin';

  @override
  String get preview => 'Próximos 7 días';

  @override
  String get previewEmpty => 'No hay tomas en los próximos 7 días';

  @override
  String get problemNoTimes => 'Añade al menos una hora';

  @override
  String get problemDuplicateTimes => 'Una hora aparece dos veces';

  @override
  String get problemBadDose => 'La dosis debe ser mayor que cero';

  @override
  String get problemNoWeekdays => 'Elige al menos un día de la semana';

  @override
  String get problemBadEveryN => 'El intervalo debe ser de al menos 1 día';

  @override
  String get problemBadCycle => 'Revisa los días del ciclo';

  @override
  String get problemBadDuration => 'Revisa la duración';

  @override
  String get sumDaily => 'cada día';

  @override
  String get sumAsNeeded => 'cuando haga falta';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get langSystem => 'Como el sistema';

  @override
  String get settingsNotifications => 'Recordatorios';

  @override
  String get grantNotifications => 'Permitir notificaciones';

  @override
  String get grantExactAlarms => 'Permitir recordatorios exactos';

  @override
  String get grantExactAlarmsHint =>
      'Sin esto, Android puede retrasar los recordatorios varios minutos.';

  @override
  String get testNotification => 'Enviar un recordatorio de prueba';

  @override
  String get testNotificationBody => 'Los recordatorios funcionan.';

  @override
  String scheduledCount(int count) {
    return 'Recordatorios programados: $count';
  }

  @override
  String get about => 'Acerca de';

  @override
  String get disclaimer =>
      'Dose te ayuda a recordar tus tomas, pero no sustituye el consejo de un médico.';

  @override
  String get notifTitle => 'Hora de tu medicación';

  @override
  String get notifChannelName => 'Recordatorios de tomas';

  @override
  String get notifChannelDescription =>
      'Avisos a la hora prevista de cada toma';

  @override
  String formName(String form) {
    String _temp0 = intl.Intl.selectLogic(form, {
      'tablet': 'Comprimido',
      'capsule': 'Cápsula',
      'drops': 'Gotas',
      'liquid': 'Líquido',
      'powder': 'Polvo',
      'injection': 'Inyección',
      'spray': 'Espray',
      'other': 'Otro',
    });
    return '$_temp0';
  }

  @override
  String mealName(String meal) {
    String _temp0 = intl.Intl.selectLogic(meal, {
      'any': 'Da igual',
      'before': 'Antes de comer',
      'during': 'Con comida',
      'after': 'Después de comer',
      'emptyStomach': 'En ayunas',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String sumEveryN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'cada $n días',
      one: 'cada día',
    );
    return '$_temp0';
  }

  @override
  String sumCycle(int on, int off) {
    return '$on días de toma, $off de descanso';
  }

  @override
  String sumUntil(String date) {
    return 'hasta el $date';
  }

  @override
  String sumFrom(String date) {
    return 'desde el $date';
  }

  @override
  String sumForDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n días',
      one: '$n día',
    );
    return '$_temp0';
  }

  @override
  String sumForDoses(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n tomas',
      one: '$n toma',
    );
    return '$_temp0';
  }

  @override
  String daysLeft(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Quedan $n días',
      one: 'Queda $n día',
    );
    return '$_temp0';
  }

  @override
  String get removeTime => 'Quitar hora';

  @override
  String get decrease => 'Menos';

  @override
  String get increase => 'Más';

  @override
  String colorOption(int n) {
    return 'Color $n';
  }

  @override
  String get actionTaken => 'Tomado';

  @override
  String get actionSnooze => 'Posponer';

  @override
  String get actionSkip => 'Omitir';

  @override
  String get notifTitleRepeat => 'Aún sin marcar';

  @override
  String get notifTitleSnoozed => 'Recordatorio pospuesto';

  @override
  String get statePlanned => 'Previsto';

  @override
  String get stateOverdue => 'Atrasado';

  @override
  String get stateSkipped => 'Omitido';

  @override
  String get stateTaken => 'Tomado';

  @override
  String get allDone => 'Todo tomado';

  @override
  String get partNight => 'Noche';

  @override
  String get partMorning => 'Mañana';

  @override
  String get partAfternoon => 'Tarde';

  @override
  String get partEvening => 'Noche temprana';

  @override
  String get takeAll => 'Tomar todo';

  @override
  String get undoMark => 'Deshacer marca';

  @override
  String get undo => 'Deshacer';

  @override
  String get asNeededSection => 'Cuando haga falta';

  @override
  String get logNow => 'Lo tomé ahora';

  @override
  String get prevDay => 'Día anterior';

  @override
  String get nextDay => 'Día siguiente';

  @override
  String get dayEmpty => 'No hay tomas este día';

  @override
  String get snoozeDuration => 'Posponer durante';

  @override
  String get repeatReminders => 'Repetir recordatorios';

  @override
  String get repeatRemindersHint =>
      'A los 15 y 30 min si la toma no está marcada';

  @override
  String get unscheduled => 'Fuera de horario';

  @override
  String stateTakenAt(String time) {
    return 'Tomado a las $time';
  }

  @override
  String stateSnoozedUntil(String time) {
    return 'Pospuesto hasta las $time';
  }

  @override
  String progressTaken(int taken, int total) {
    return '$taken de $total tomados';
  }

  @override
  String progressDetails(int skipped, int pending) {
    return 'Omitidos: $skipped · Quedan: $pending';
  }

  @override
  String progressPlanned(int n) {
    return 'Tomas previstas: $n';
  }

  @override
  String snoozeFor(int n) {
    return 'Posponer $n min';
  }

  @override
  String minutesShort(int n) {
    return '$n min';
  }

  @override
  String snackSnoozed(String time) {
    return 'Pospuesto hasta las $time';
  }

  @override
  String progressPercent(int n) {
    return '$n %';
  }

  @override
  String get unitOther => 'Otra…';

  @override
  String get unitCustom => 'Unidad propia';

  @override
  String get fieldLook => 'Aspecto';

  @override
  String get fieldColor2 => 'Segundo color';

  @override
  String get navStats => 'Estadísticas';

  @override
  String get statsEmpty =>
      'Aún no hay datos. Marca tus tomas y aquí aparecerán las estadísticas.';

  @override
  String get statsAdherence => 'Cumplimiento';

  @override
  String get statsTaken => 'Tomados';

  @override
  String get statsSkipped => 'Omitidos';

  @override
  String get statsMissed => 'Sin marcar';

  @override
  String get statsByDay => 'Por día';

  @override
  String get statsByMedication => 'Por medicamento';

  @override
  String get statsChartHint => 'Toca una barra para elegir un día';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get settingsSound => 'Sonido de notificación';

  @override
  String get soundDefault => 'El del teléfono';

  @override
  String get soundPickPhone => 'Elegir del teléfono o un archivo propio…';

  @override
  String get soundPickPhoneHint =>
      'Abre la lista de sonidos de Android, donde puedes añadir tu archivo';

  @override
  String get soundPreview => 'Reproducir';

  @override
  String get soundChime => 'Carillón';

  @override
  String get soundBell => 'Campana';

  @override
  String get soundSoft => 'Suave';

  @override
  String get soundPulse => 'Pulso';

  @override
  String get soundCustom => 'Sonido propio';

  @override
  String get soundBuiltIn => 'Sonidos de Dose';

  @override
  String unitShort(String unit) {
    String _temp0 = intl.Intl.selectLogic(unit, {
      'tablet': 'comp.',
      'capsule': 'cáps.',
      'drop': 'gotas',
      'ml': 'ml',
      'mg': 'mg',
      'g': 'g',
      'mcg': 'mcg',
      'iu': 'UI',
      'units': 'unid.',
      'sachet': 'sobre',
      'teaspoon': 'cdta.',
      'tablespoon': 'cda.',
      'scoop': 'cacito',
      'ampoule': 'amp.',
      'spray': 'pulv.',
      'dose': 'dosis',
      'piece': 'uds.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String unitName(String unit) {
    String _temp0 = intl.Intl.selectLogic(unit, {
      'tablet': 'Comprimido',
      'capsule': 'Cápsula',
      'drop': 'Gota',
      'ml': 'Mililitro (ml)',
      'mg': 'Miligramo (mg)',
      'g': 'Gramo (g)',
      'mcg': 'Microgramo (mcg)',
      'iu': 'Unidad internacional (UI)',
      'units': 'Unidades',
      'sachet': 'Sobre',
      'teaspoon': 'Cucharadita',
      'tablespoon': 'Cucharada',
      'scoop': 'Cacito',
      'ampoule': 'Ampolla',
      'spray': 'Pulverización',
      'dose': 'Dosis',
      'piece': 'Unidad',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String shapeName(String shape) {
    String _temp0 = intl.Intl.selectLogic(shape, {
      'roundTablet': 'Comprimido redondo',
      'ovalTablet': 'Comprimido ovalado',
      'capsule': 'Cápsula',
      'softgel': 'Cápsula blanda',
      'dropper': 'Gotas',
      'bottle': 'Frasco',
      'sachet': 'Sobre',
      'syringe': 'Jeringa',
      'spray': 'Espray',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String statsPeriod(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n días',
      one: '$n día',
    );
    return '$_temp0';
  }

  @override
  String statsStreak(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n días seguidos sin olvidos',
      one: '$n día seguido sin olvidos',
    );
    return '$_temp0';
  }

  @override
  String statsOfTotal(int taken, int total) {
    return '$taken de $total';
  }

  @override
  String statsSummary(int days, int taken, int total, int percent) {
    return 'En $days días se tomaron $taken de $total dosis ($percent %).';
  }

  @override
  String get stockTitle => 'Existencias';

  @override
  String get stockNotTracked => 'No se controlan las existencias';

  @override
  String get stockSetUp => 'Configurar existencias';

  @override
  String stockLeft(String amount) {
    return 'Quedan: $amount';
  }

  @override
  String stockDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Alcanza para $days días',
      one: 'Alcanza para $days día',
    );
    return '$_temp0';
  }

  @override
  String stockRunsOut(String date) {
    return 'hasta el $date';
  }

  @override
  String get stockEmpty => 'Agotado';

  @override
  String get stockLow => 'Quedan pocas';

  @override
  String get stockBought => 'He comprado más';

  @override
  String stockAddPack(String amount) {
    return 'Un envase: +$amount';
  }

  @override
  String get stockAddAmount => 'Otra cantidad';

  @override
  String get stockAmountToAdd => 'Cuánto añadir';

  @override
  String get stockCorrect => 'Corregir la cantidad';

  @override
  String get stockSettings => 'Ajustes de existencias';

  @override
  String get stockTrack => 'Controlar existencias';

  @override
  String get stockTrackHint => 'Cada toma marcada reduce la cantidad';

  @override
  String get stockCurrent => 'Disponibles';

  @override
  String get stockPackSize => 'Por envase';

  @override
  String get stockPackSizeHint => 'Lo usa «He comprado más»';

  @override
  String get stockWarnDays => 'Avisar cuando queden estos días';

  @override
  String get stockInvalid => 'Escribe un número';

  @override
  String get stockBanner => 'Hora de reponer';

  @override
  String get notifStockChannelName => 'Existencias';

  @override
  String get notifStockChannelDescription => 'Recordatorios para comprar más';

  @override
  String get settingsData => 'Datos';

  @override
  String get backupExport => 'Guardar una copia';

  @override
  String get backupExportHint =>
      'Un archivo con todos los medicamentos, horarios e historial';

  @override
  String get backupImport => 'Restaurar desde una copia';

  @override
  String get backupImportHint => 'Sustituye todos los datos actuales';

  @override
  String get backupSaved => 'Copia guardada';

  @override
  String get backupRestored => 'Datos restaurados';

  @override
  String get backupInvalid =>
      'No es una copia de Dose o el archivo está dañado';

  @override
  String backupFailed(String error) {
    return 'Error: $error';
  }

  @override
  String get backupConfirmTitle => '¿Restaurar los datos de la copia?';

  @override
  String backupConfirmBody(int meds, int schedules, int events) {
    return 'La copia tiene $meds medicamentos, $schedules horarios y $events registros de tomas. Se sustituirán todos los datos actuales.';
  }

  @override
  String get backupRestore => 'Restaurar';

  @override
  String get fieldIngredients => 'Principios activos';

  @override
  String get ingredientsHint =>
      'Para comprobar la compatibilidad. Elegidos por el nombre; puedes cambiarlos.';

  @override
  String get compatTitle => 'Compatibilidad';

  @override
  String compatSeparate(String other, int hours) {
    return 'Con «$other»: separar al menos $hours h.';
  }

  @override
  String compatNow(String a, String b) {
    return 'Ahora: $a y $b.';
  }

  @override
  String compatSuggest(String time) {
    return 'Consejo: mueve esta toma a las $time.';
  }

  @override
  String compatAvoid(String other) {
    return 'Con «$other»: precaución.';
  }

  @override
  String compatTogether(String other) {
    return 'Con «$other»: bien juntos.';
  }

  @override
  String get compatDisclaimer =>
      'Esto no es consejo médico. Habla con tu médico antes de cambiar tu pauta.';

  @override
  String get compatWarningTitle => 'Posible conflicto';

  @override
  String get compatSaveAnyway => 'Guardar igualmente';

  @override
  String get compatChangeTime => 'Cambiar la hora';

  @override
  String takenAt(String time) {
    return 'Tomado a las $time';
  }

  @override
  String get changeTakenTime => 'Cambiar la hora de la toma';

  @override
  String get historyTitle => 'Historial';

  @override
  String get historyHint =>
      'Parte de las dosis tomadas cada día. Toca un día para abrirlo.';

  @override
  String get historyNoDoses => 'Nada previsto';

  @override
  String historyDayLabel(String date, int percent) {
    return '$date: $percent %';
  }

  @override
  String get prevMonth => 'Mes anterior';

  @override
  String get nextMonth => 'Mes siguiente';

  @override
  String get updateCheck => 'Buscar actualizaciones';

  @override
  String updateCurrent(String version) {
    return 'Instalada: $version';
  }

  @override
  String get updateAuto => 'Buscar actualizaciones automáticamente';

  @override
  String get updateAutoHint => 'Una vez al día, con internet';

  @override
  String get updateNone => 'Tienes la última versión';

  @override
  String get updateUnavailable =>
      'No se pudo conectar con GitHub. Comprueba internet e inténtalo más tarde.';

  @override
  String updateAvailable(String version) {
    return 'Hay una nueva versión: $version';
  }

  @override
  String get updateDownload => 'Descargar';

  @override
  String get updateHint =>
      'Descarga el archivo e instálalo sobre la versión actual. Tus datos se conservan.';

  @override
  String get later => 'Más tarde';

  @override
  String get guideTitle => 'Información';

  @override
  String get guideIntake => 'Cómo tomar';

  @override
  String get guideCautions => 'Precauciones';

  @override
  String get guideSources => 'Fuentes';

  @override
  String get guideProductPage => 'Página del producto';

  @override
  String get guideAll => 'Guía de suplementos';

  @override
  String get guideAllSubtitle => 'Cómo tomar, precauciones, fuentes';

  @override
  String get productHint =>
      'Obligatorio. Empieza a escribir para elegir un producto';

  @override
  String get pickDate => 'Elegir fecha';

  @override
  String get statsOpenDay => 'Abrir día';

  @override
  String get statsCountHint => 'Toca para ver la lista';

  @override
  String get noDoses => 'Aún no hay nada aquí';

  @override
  String get dayUpcoming => 'Pendientes';

  @override
  String get dayDoses => 'Tomas';

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
    return '$d tarde';
  }

  @override
  String delayEarly(String d) {
    return '$d antes';
  }

  @override
  String get delayOnTime => 'a tiempo';

  @override
  String plannedAt(String time) {
    return 'prevista a las $time';
  }

  @override
  String get medStatsTitle => 'Análisis de tomas';

  @override
  String get medStatsOpenHint => 'Cumplimiento, rachas, gráficos, puntualidad';

  @override
  String medStatsSince(String date) {
    return 'En la app desde el $date';
  }

  @override
  String courseDayOf(int day, int total, String date) {
    return 'Día $day de $total, hasta el $date';
  }

  @override
  String courseOngoing(int day) {
    return 'Día $day, sin fecha de fin';
  }

  @override
  String courseNotStarted(String date) {
    return 'Empieza el $date';
  }

  @override
  String courseFinished(String date) {
    return 'Tratamiento terminado el $date';
  }

  @override
  String get periodAll => 'Todo';

  @override
  String trendUp(int n) {
    return '$n puntos mejor que el periodo anterior';
  }

  @override
  String trendDown(int n) {
    return '$n puntos peor que el periodo anterior';
  }

  @override
  String get trendSame => 'Igual que el periodo anterior';

  @override
  String get streakCurrent => 'Racha actual';

  @override
  String get streakBest => 'Mejor racha';

  @override
  String get daysTitle => 'Días con tomas';

  @override
  String get daysFull => 'Todo tomado';

  @override
  String get daysPartial => 'En parte';

  @override
  String get daysNone => 'Ninguna';

  @override
  String get chartsTitle => 'Gráficos';

  @override
  String get byWeekday => 'Por día de la semana';

  @override
  String get byDoseTime => 'Por hora de la toma';

  @override
  String weekdayWorst(String day) {
    return 'Lo que más olvidas: $day';
  }

  @override
  String get timingTitle => 'Puntualidad';

  @override
  String timingAverage(String delay) {
    return 'De media, $delay';
  }

  @override
  String get timingOnTime => 'A tiempo (±15 min)';

  @override
  String get timingEarly => 'Más de 15 min antes';

  @override
  String get timingLate => '15–60 min tarde';

  @override
  String get timingVeryLate => 'Más de una hora tarde';

  @override
  String timingMax(String d) {
    return 'La toma más tardía: $d tarde';
  }

  @override
  String get timingNone => 'Aún no hay tomas con hora registrada';

  @override
  String get amountTitle => 'Cantidad';

  @override
  String get amountPeriod => 'En este periodo';

  @override
  String get amountAll => 'En total';

  @override
  String get amountPerDay => 'Media al día';

  @override
  String dosesCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n tomas',
      one: '$n toma',
    );
    return '$_temp0';
  }

  @override
  String courseRemaining(String amount) {
    return 'Falta por tomar en el tratamiento: $amount';
  }

  @override
  String packsToFinish(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Compra $n envases más para terminar el tratamiento',
      one: 'Compra $n envase más para terminar el tratamiento',
      zero: 'Hay suficiente para terminar el tratamiento',
    );
    return '$_temp0';
  }

  @override
  String listTitle(String status, String period) {
    return '$status · $period';
  }
}
