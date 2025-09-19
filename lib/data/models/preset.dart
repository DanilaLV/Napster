import 'package:equatable/equatable.dart';

enum PresetType { quick, power, deep, cycle, custom }

class NapPreset extends Equatable {
  const NapPreset({
    required this.type,
    required this.minutes,
    required this.titleKey,
    required this.requiresPro,
  });

  final PresetType type;
  final int minutes;
  final String titleKey;
  final bool requiresPro;

  @override
  List<Object?> get props => [type, minutes, titleKey, requiresPro];
}

const quickPreset = NapPreset(
  type: PresetType.quick,
  minutes: 10,
  titleKey: 'homeQuickNap',
  requiresPro: false,
);

const powerPreset = NapPreset(
  type: PresetType.power,
  minutes: 25,
  titleKey: 'homePowerNap',
  requiresPro: false,
);

const deepPreset = NapPreset(
  type: PresetType.deep,
  minutes: 45,
  titleKey: 'homeDeepNap',
  requiresPro: true,
);

const cyclePreset = NapPreset(
  type: PresetType.cycle,
  minutes: 90,
  titleKey: 'homeSleepCycle',
  requiresPro: true,
);

const allPresets = [quickPreset, powerPreset, deepPreset, cyclePreset];
