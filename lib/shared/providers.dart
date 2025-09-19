import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/active_alarm.dart';
import '../data/models/preset.dart';
import '../data/models/settings.dart';
import '../data/prefs_repository.dart';
import '../features/alarm/alarm_scheduler.dart';
import '../features/paywall/iap_service.dart';

final prefsRepositoryProvider = Provider<PrefsRepository>((ref) {
  return PrefsRepository();
});

final initializationProvider = FutureProvider<void>((ref) async {
  final prefs = ref.read(prefsRepositoryProvider);
  await prefs.init();
  final storedSettings = prefs.loadSettings();
  ref.read(settingsProvider.notifier).hydrate(storedSettings);
  final storedAlarm = prefs.loadActiveAlarm();
  if (storedAlarm != null) {
    ref.read(activeAlarmProvider.notifier).restore(storedAlarm);
  }
  final alarmScheduler = ref.read(alarmSchedulerProvider);
  await alarmScheduler.initialize();
  final iap = ref.read(iapServiceProvider);
  await iap.initialize();
});

final settingsProvider = StateNotifierProvider<SettingsController, Settings>((ref) {
  final prefs = ref.watch(prefsRepositoryProvider);
  final controller = SettingsController(prefs: prefs, initial: const Settings.defaults());
  ref.onDispose(controller.dispose);
  return controller;
});

final activeAlarmProvider = StateNotifierProvider<ActiveAlarmController, ActiveAlarm?>((ref) {
  final prefs = ref.watch(prefsRepositoryProvider);
  final scheduler = ref.watch(alarmSchedulerProvider);
  final settings = ref.watch(settingsProvider);
  final controller = ActiveAlarmController(
    scheduler: scheduler,
    prefs: prefs,
    settings: settings,
  );
  ref.listen<Settings>(settingsProvider, (_, next) {
    controller.updateSettings(next);
  });
  return controller;
});

final proStatusProvider = Provider<bool>((ref) {
  final settings = ref.watch(settingsProvider);
  final iap = ref.watch(iapServiceProvider);
  return settings.proUnlocked || iap.isOwned;
});

final presetsProvider = Provider<List<NapPreset>>((ref) {
  final pro = ref.watch(proStatusProvider);
  return allPresets.map((preset) {
    return NapPreset(
      type: preset.type,
      minutes: preset.minutes,
      titleKey: preset.titleKey,
      requiresPro: preset.requiresPro && !pro ? true : false,
    );
  }).toList();
});

class SettingsController extends StateNotifier<Settings> {
  SettingsController({required this.prefs, required Settings initial})
      : super(initial);

  final PrefsRepository prefs;
  bool _disposed = false;

  void hydrate(Settings value) {
    if (_disposed) return;
    state = value;
  }

  Future<void> update(Settings value) async {
    if (_disposed) return;
    state = value;
    await prefs.saveSettings(value);
  }

  Future<void> updateLanguage(AppLanguage language) async {
    await update(state.copyWith(language: language));
  }

  Future<void> updateTwentyFourHour(bool use24h) async {
    await update(state.copyWith(use24h: use24h));
  }

  Future<void> setProUnlocked(bool unlocked) async {
    await update(state.copyWith(proUnlocked: unlocked));
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class ActiveAlarmController extends StateNotifier<ActiveAlarm?> {
  ActiveAlarmController({
    required this.scheduler,
    required this.prefs,
    required Settings settings,
  })  : _settings = settings,
        super(null);

  final AlarmScheduler scheduler;
  final PrefsRepository prefs;
  Settings _settings;

  void updateSettings(Settings settings) {
    _settings = settings;
  }

  void restore(ActiveAlarm? alarm) {
    if (alarm == null) {
      state = null;
      return;
    }
    final fireAt = DateTime.fromMillisecondsSinceEpoch(alarm.fireAtEpochMs, isUtc: true).toLocal();
    if (fireAt.isBefore(DateTime.now())) {
      state = null;
      return;
    }
    state = alarm;
    final preset = _presetForRestore(alarm);
    if (preset != null) {
      scheduler.scheduleAlarm(
        alarmId: alarm.id,
        fireDate: fireAt,
        preset: preset,
        settings: _settings,
        replace: true,
      );
    }
  }

  NapPreset? _presetForRestore(ActiveAlarm alarm) {
    switch (alarm.presetType) {
      case PresetType.quick:
        return quickPreset;
      case PresetType.power:
        return powerPreset;
      case PresetType.deep:
        return deepPreset;
      case PresetType.cycle:
        return cyclePreset;
      case PresetType.custom:
        return NapPreset(
          type: PresetType.custom,
          minutes: alarm.totalMinutes,
          titleKey: 'customTitle',
          requiresPro: false,
        );
    }
  }

  Future<bool> schedulePreset(NapPreset preset) async {
    final now = DateTime.now();
    final fireAt = now.add(Duration(minutes: preset.minutes));
    final alarm = ActiveAlarm(
      id: scheduler.generateAlarmId(),
      fireAtEpochMs: fireAt.toUtc().millisecondsSinceEpoch,
      presetType: preset.type,
      totalMinutes: preset.minutes,
      status: AlarmStatus.scheduled,
    );
    final success = await scheduler.scheduleAlarm(
      alarmId: alarm.id,
      fireDate: fireAt,
      preset: preset,
      settings: _settings,
    );
    if (!success) {
      return false;
    }
    state = alarm;
    await prefs.saveActiveAlarm(alarm);
    return true;
  }

  Future<bool> scheduleCustom(int minutes) async {
    final customPreset = NapPreset(
      type: PresetType.custom,
      minutes: minutes,
      titleKey: 'customTitle',
      requiresPro: false,
    );
    return schedulePreset(customPreset);
  }

  Future<void> cancelAlarm() async {
    final alarm = state;
    if (alarm == null) {
      return;
    }
    await scheduler.cancelAlarm(alarm.id);
    state = null;
    await prefs.saveActiveAlarm(null);
  }

  Future<bool> snooze(int minutes) async {
    final alarm = state;
    if (alarm == null) {
      return false;
    }
    final newFireAt =
        DateTime.fromMillisecondsSinceEpoch(alarm.fireAtEpochMs, isUtc: true)
            .add(Duration(minutes: minutes));
    final success = await scheduler.scheduleAlarm(
      alarmId: alarm.id,
      fireDate: newFireAt,
      preset: NapPreset(
        type: alarm.presetType,
        minutes: alarm.totalMinutes + minutes,
        titleKey: 'countdownSnooze',
        requiresPro: false,
      ),
      settings: _settings,
      replace: true,
    );
    if (!success) {
      return false;
    }
    final updated = alarm.copyWith(
      fireAtEpochMs: newFireAt.toUtc().millisecondsSinceEpoch,
    );
    state = updated;
    await prefs.saveActiveAlarm(updated);
    return true;
  }
}
