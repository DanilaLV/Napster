import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/models/preset.dart';
import '../../data/models/settings.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/providers.dart';
import '../paywall/paywall_screen.dart';
import 'tone_picker_dialog.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final pro = ref.watch(proStatusProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle())),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          _SectionTitle(title: l10n.settingsDefaultPreset()),
          DropdownButtonFormField<PresetType>(
            value: settings.defaultPreset,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: allPresets
                .map(
                  (preset) => DropdownMenuItem<PresetType>(
                    value: preset.type,
                    child: Text(_presetName(context, preset.titleKey)),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                notifier.update(settings.copyWith(defaultPreset: value));
              }
            },
          ),
          const SizedBox(height: 24),
          _SectionTitle(title: l10n.settingsTone()),
          ListTile(
            title: Text(_toneLabel(settings.tone, context)),
            trailing: const Icon(Icons.chevron_right),
            subtitle: Text(l10n.settingsSelectTone()),
            onTap: () async {
              if (!pro && settings.tone != AlarmTone.tone1) {
                _openPaywall(context);
                return;
              }
              final tone = await showDialog<AlarmTone>(
                context: context,
                builder: (context) => TonePickerDialog(selected: settings.tone, pro: pro),
              );
              if (tone != null) {
                await notifier.update(settings.copyWith(tone: tone));
              }
            },
          ),
          SwitchListTile.adaptive(
            title: Text(l10n.settingsVibration()),
            value: settings.vibration,
            onChanged: (value) async {
              await notifier.update(settings.copyWith(vibration: value));
            },
          ),
          const SizedBox(height: 24),
          _SectionTitle(title: l10n.settingsSnoozeLength()),
          ListTile(
            title: Text('${settings.snoozeMinutes} min'),
            subtitle: Text(l10n.countdownSnooze()),
            onTap: () async {
              if (!pro && settings.snoozeMinutes != 5) {
                _openPaywall(context);
                return;
              }
              final value = await showDialog<int>(
                context: context,
                builder: (context) => _SnoozeDialog(
                  initial: settings.snoozeMinutes,
                  pro: pro,
                ),
              );
              if (value != null) {
                await notifier.update(settings.copyWith(snoozeMinutes: value));
              }
            },
          ),
          const SizedBox(height: 24),
          _SectionTitle(title: l10n.settingsLanguage()),
          DropdownButtonFormField<AppLanguage>(
            value: settings.language,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: AppLanguage.values
                .map(
                  (language) => DropdownMenuItem<AppLanguage>(
                    value: language,
                    child: Text(_languageName(language, l10n)),
                  ),
                )
                .toList(),
            onChanged: (value) async {
              if (value != null) {
                await notifier.updateLanguage(value);
              }
            },
          ),
          SwitchListTile.adaptive(
            title: Text(l10n.settingsTwentyFourHour()),
            value: settings.use24h,
            onChanged: (value) async {
              await notifier.updateTwentyFourHour(value);
            },
          ),
          const SizedBox(height: 24),
          ListTile(
            title: Text(l10n.aboutTitle()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

String _presetName(BuildContext context, String key) {
  final l10n = AppLocalizations.of(context);
  switch (key) {
    case 'homeQuickNap':
      return l10n.homeQuickNap();
    case 'homePowerNap':
      return l10n.homePowerNap();
    case 'homeDeepNap':
      return l10n.homeDeepNap();
    case 'homeSleepCycle':
      return l10n.homeSleepCycle();
    default:
      return l10n.homeQuickNap();
  }
}

String _toneLabel(AlarmTone tone, BuildContext context) {
  final l10n = AppLocalizations.of(context);
  switch (tone) {
    case AlarmTone.tone1:
      return '${l10n.settingsTone()} 1';
    case AlarmTone.tone2:
      return '${l10n.settingsTone()} 2';
    case AlarmTone.tone3:
      return '${l10n.settingsTone()} 3';
    case AlarmTone.tone4:
      return '${l10n.settingsTone()} 4';
    case AlarmTone.tone5:
      return '${l10n.settingsTone()} 5';
  }
}

String _languageName(AppLanguage language, AppLocalizations l10n) {
  switch (language) {
    case AppLanguage.en:
      return l10n.languageEnglish();
    case AppLanguage.lv:
      return l10n.languageLatvian();
  }
}

void _openPaywall(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const PaywallScreen()),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _SnoozeDialog extends StatefulWidget {
  const _SnoozeDialog({required this.initial, required this.pro});

  final int initial;
  final bool pro;

  @override
  State<_SnoozeDialog> createState() => _SnoozeDialogState();
}

class _SnoozeDialogState extends State<_SnoozeDialog> {
  late int _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    final options = widget.pro
        ? List<int>.generate(11, (index) => index)
        : <int>[5];
    return AlertDialog(
      title: const Text('Snooze length'),
      content: DropdownButton<int>(
        value: _value,
        items: options
            .map((value) => DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value min'),
                ))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => _value = value);
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _value),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle())),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.aboutPrivacy()),
            const SizedBox(height: 16),
            Text(l10n.aboutMute()),
            const Spacer(),
            Text(l10n.aboutVersion('1.0.0')),
          ],
        ),
      ),
    );
  }
}
