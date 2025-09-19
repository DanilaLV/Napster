import 'package:equatable/equatable.dart';

import '../../shared/utils/time_utils.dart';
import 'preset.dart';

enum AlarmStatus { scheduled, ringing }

class ActiveAlarm extends Equatable {
  const ActiveAlarm({
    required this.id,
    required this.fireAtEpochMs,
    required this.presetType,
    required this.totalMinutes,
    required this.status,
  });

  final String id;
  final EpochMillis fireAtEpochMs;
  final PresetType presetType;
  final int totalMinutes;
  final AlarmStatus status;

  ActiveAlarm copyWith({
    EpochMillis? fireAtEpochMs,
    AlarmStatus? status,
  }) {
    return ActiveAlarm(
      id: id,
      fireAtEpochMs: fireAtEpochMs ?? this.fireAtEpochMs,
      presetType: presetType,
      totalMinutes: totalMinutes,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fireAtEpochMs': fireAtEpochMs,
      'presetType': presetType.name,
      'totalMinutes': totalMinutes,
      'status': status.name,
    };
  }

  static ActiveAlarm fromJson(Map<String, dynamic> json) {
    return ActiveAlarm(
      id: json['id'] as String,
      fireAtEpochMs: json['fireAtEpochMs'] as int,
      presetType: PresetType.values.byName(json['presetType'] as String),
      totalMinutes: json['totalMinutes'] as int,
      status: AlarmStatus.values.byName(json['status'] as String),
    );
  }

  @override
  List<Object?> get props => [id, fireAtEpochMs, presetType, totalMinutes, status];
}
