import 'package:flutter/services.dart';

const MethodChannel androidAlarmChannel = MethodChannel('dev.napster/alarm/android');

class AlarmServiceAndroid {
  const AlarmServiceAndroid(this.channel);

  final MethodChannel channel;

  Future<void> createForegroundService({
    required String alarmId,
    required DateTime fireDate,
    required String tone,
    required bool vibration,
  }) async {
    await channel.invokeMethod<void>('createForegroundService', {
      'id': alarmId,
      'fireDate': fireDate.millisecondsSinceEpoch,
      'tone': tone,
      'vibration': vibration,
    });
  }

  Future<void> cancelForegroundService(String alarmId) async {
    await channel.invokeMethod<void>('cancelForegroundService', {'id': alarmId});
  }
}
