import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../shared/utils/time_utils.dart';
import 'models/active_alarm.dart';
import 'models/preset.dart';
import 'models/settings.dart';

class PrefsRepository {
  PrefsRepository();

  SharedPreferences? _prefs;

  static const _settingsKey = 'settings';
  static const _activeAlarmKey = 'activeAlarm';
  static const _timezoneKey = 'timezone';

  Future<void> init() async {
    await _ensurePrefs();
  }

  Future<void> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> setTimezone(String timezoneName) async {
    await _ensurePrefs();
    await _prefs?.setString(_timezoneKey, timezoneName);
  }

  String? readTimezone() {
    return _prefs?.getString(_timezoneKey);
  }

  Future<void> saveSettings(Settings settings) async {
    await _ensurePrefs();
    await _prefs?.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  Settings loadSettings() {
    if (_prefs == null) {
      return const Settings.defaults();
    }
    final jsonString = _prefs?.getString(_settingsKey);
    if (jsonString == null) {
      return const Settings.defaults();
    }
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    return Settings.fromJson(map);
  }

  Future<void> saveActiveAlarm(ActiveAlarm? alarm) async {
    await _ensurePrefs();
    if (alarm == null) {
      await _prefs?.remove(_activeAlarmKey);
      return;
    }
    await _prefs?.setString(_activeAlarmKey, jsonEncode(alarm.toJson()));
  }

  ActiveAlarm? loadActiveAlarm() {
    if (_prefs == null) {
      return null;
    }
    final jsonString = _prefs?.getString(_activeAlarmKey);
    if (jsonString == null) {
      return null;
    }
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    return ActiveAlarm.fromJson(map);
  }

  Future<void> clear() async {
    await _ensurePrefs();
    await _prefs?.clear();
  }
}

final timeUtils = TimeUtils();
