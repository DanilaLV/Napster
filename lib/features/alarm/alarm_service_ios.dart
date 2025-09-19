import 'package:flutter/services.dart';

const MethodChannel iosAlarmChannel = MethodChannel('dev.napster/alarm/ios');

class AlarmServiceIos {
  const AlarmServiceIos(this.channel);

  final MethodChannel channel;

  Future<void> ensureCategories() async {
    await channel.invokeMethod<void>('ensureCategories');
  }
}
