import 'package:flutter_test/flutter_test.dart';
import 'package:napster/data/models/preset.dart';
import 'package:napster/data/models/settings.dart';

void main() {
  test('settings serialization round trip', () {
    const settings = Settings(
      defaultPreset: PresetType.power,
      tone: AlarmTone.tone3,
      vibration: false,
      snoozeMinutes: 7,
      language: AppLanguage.lv,
      use24h: false,
      proUnlocked: true,
    );

    final json = settings.toJson();
    final restored = Settings.fromJson(json);

    expect(restored, settings);
  });
}
