import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';

import '../../data/models/preset.dart';
import '../../data/models/settings.dart';
import '../../data/prefs_repository.dart';
import '../../shared/providers.dart';

class AlarmScheduler {
  AlarmScheduler({
    FlutterLocalNotificationsPlugin? plugin,
    MethodChannel? channel,
    required this.prefs,
  })  : _notifications = plugin ?? FlutterLocalNotificationsPlugin(),
        _channel = channel ?? const MethodChannel('dev.napster/alarm'),
        _uuid = const Uuid();

  final FlutterLocalNotificationsPlugin _notifications;
  final MethodChannel _channel;
  final PrefsRepository prefs;
  final Uuid _uuid;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _notifications.initialize(initSettings);
    tz.initializeTimeZones();
    final timezone = prefs.readTimezone();
    if (timezone != null) {
      tz.setLocalLocation(tz.getLocation(timezone));
    } else {
      final localName = await _channel.invokeMethod<String>('getTimeZone');
      if (localName != null) {
        tz.setLocalLocation(tz.getLocation(localName));
        await prefs.setTimezone(localName);
      }
    }
    _initialized = true;
  }

  Future<bool> requestNotificationPermissions() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<bool> requestExactAlarmPermission() async {
    final result = await _channel.invokeMethod<bool>('requestExactAlarm');
    return result ?? true;
  }

  Future<bool> scheduleAlarm({
    required String alarmId,
    required DateTime fireDate,
    required NapPreset preset,
    required Settings settings,
    bool replace = false,
  }) async {
    await initialize();
    final timezone = tz.local;
    final tzDateTime = tz.TZDateTime.from(fireDate, timezone);

    final androidDetails = AndroidNotificationDetails(
      'napster_alarm',
      'Napster Alarm',
      channelDescription: 'Alarm notifications for naps',
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      sound: RawResourceAndroidNotificationSound(_toneName(settings.tone)),
      playSound: true,
      enableVibration: settings.vibration,
      additionalFlags: <int>[4],
      ticker: 'Napster alarm',
    );
    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      sound: '${_toneName(settings.tone)}.caf',
    );
    final notificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

    final payload = AlarmPayload(alarmId: alarmId, presetType: preset.type, totalMinutes: preset.minutes);

    if (!replace) {
      await _notifications.zonedSchedule(
        alarmId.hashCode,
        'Napster',
        'Time to wake up',
        tzDateTime,
        notificationDetails,
        payload: payload.toPayload(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null,
      );
    } else {
      await cancelAlarm(alarmId);
      await _notifications.zonedSchedule(
        alarmId.hashCode,
        'Napster',
        'Snoozed alarm',
        tzDateTime,
        notificationDetails,
        payload: payload.toPayload(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null,
      );
    }

    await _channel.invokeMethod<void>('schedulePlatformAlarm', {
      'id': alarmId,
      'milliseconds': fireDate.millisecondsSinceEpoch,
      'tone': _toneName(settings.tone),
      'vibration': settings.vibration,
      'preset': preset.type.name,
    });
    return true;
  }

  Future<void> cancelAlarm(String alarmId) async {
    await _notifications.cancel(alarmId.hashCode);
    await _channel.invokeMethod<void>('cancelPlatformAlarm', {'id': alarmId});
  }

  String generateAlarmId() => _uuid.v4();
}

String _toneName(AlarmTone tone) {
  switch (tone) {
    case AlarmTone.tone1:
      return 'tone1';
    case AlarmTone.tone2:
      return 'tone2';
    case AlarmTone.tone3:
      return 'tone3';
    case AlarmTone.tone4:
      return 'tone4';
    case AlarmTone.tone5:
      return 'tone5';
  }
}

class AlarmPayload {
  const AlarmPayload({
    required this.alarmId,
    required this.presetType,
    required this.totalMinutes,
  });

  final String alarmId;
  final PresetType presetType;
  final int totalMinutes;

  String toPayload() {
    return '${alarmId}|${presetType.name}|$totalMinutes';
  }

  static AlarmPayload fromPayload(String payload) {
    final parts = payload.split('|');
    return AlarmPayload(
      alarmId: parts[0],
      presetType: PresetType.values.byName(parts[1]),
      totalMinutes: int.parse(parts[2]),
    );
  }
}

final alarmSchedulerProvider = Provider<AlarmScheduler>((ref) {
  final prefs = ref.watch(prefsRepositoryProvider);
  return AlarmScheduler(prefs: prefs);
});
