import 'package:equatable/equatable.dart';

import 'preset.dart';

enum AppLanguage { en, lv }

enum AlarmTone { tone1, tone2, tone3, tone4, tone5 }

class Settings extends Equatable {
  const Settings({
    required this.defaultPreset,
    required this.tone,
    required this.vibration,
    required this.snoozeMinutes,
    required this.language,
    required this.use24h,
    required this.proUnlocked,
  });

  const Settings.defaults()
      : defaultPreset = PresetType.power,
        tone = AlarmTone.tone1,
        vibration = true,
        snoozeMinutes = 5,
        language = AppLanguage.en,
        use24h = true,
        proUnlocked = false;

  final PresetType defaultPreset;
  final AlarmTone tone;
  final bool vibration;
  final int snoozeMinutes;
  final AppLanguage language;
  final bool use24h;
  final bool proUnlocked;

  Settings copyWith({
    PresetType? defaultPreset,
    AlarmTone? tone,
    bool? vibration,
    int? snoozeMinutes,
    AppLanguage? language,
    bool? use24h,
    bool? proUnlocked,
  }) {
    return Settings(
      defaultPreset: defaultPreset ?? this.defaultPreset,
      tone: tone ?? this.tone,
      vibration: vibration ?? this.vibration,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      language: language ?? this.language,
      use24h: use24h ?? this.use24h,
      proUnlocked: proUnlocked ?? this.proUnlocked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultPreset': defaultPreset.name,
      'tone': tone.name,
      'vibration': vibration,
      'snoozeMinutes': snoozeMinutes,
      'language': language.name,
      'use24h': use24h,
      'proUnlocked': proUnlocked,
    };
  }

  static Settings fromJson(Map<String, dynamic> json) {
    return Settings(
      defaultPreset: PresetType.values.byName(json['defaultPreset'] as String),
      tone: AlarmTone.values.byName(json['tone'] as String),
      vibration: json['vibration'] as bool? ?? true,
      snoozeMinutes: json['snoozeMinutes'] as int? ?? 5,
      language: AppLanguage.values.byName(json['language'] as String),
      use24h: json['use24h'] as bool? ?? true,
      proUnlocked: json['proUnlocked'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        defaultPreset,
        tone,
        vibration,
        snoozeMinutes,
        language,
        use24h,
        proUnlocked,
      ];
}
