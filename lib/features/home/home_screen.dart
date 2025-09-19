import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/models/preset.dart';
import '../../data/models/active_alarm.dart';
import '../../data/models/settings.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/providers.dart';
import '../../shared/utils/time_utils.dart';
import '../alarm/active_alarm_screen.dart';
import '../alarm/alarm_scheduler.dart';
import '../paywall/paywall_screen.dart';
import '../settings/settings_sheet.dart';
import 'preset_card.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final presets = ref.watch(presetsProvider);
    final alarm = ref.watch(activeAlarmProvider);
    final l10n = AppLocalizations.of(context);
    final pro = ref.watch(proStatusProvider);
    useEffect(() {
      Future.microtask(() async {
        final scheduler = ref.read(alarmSchedulerProvider);
        await scheduler.requestNotificationPermissions();
        await scheduler.requestExactAlarmPermission();
      });
      return null;
    }, const []);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: const [SettingsAction()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _ActiveAlarmBanner(alarm: alarm, settings: settings),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Timezone: \${DateTime.now().timeZoneName}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
                children: presets.map((preset) {
                  final locked = preset.requiresPro && !pro;
                  final isDefault = settings.defaultPreset == preset.type;
                  return PresetCard(
                    preset: preset,
                    isDefault: isDefault,
                    locked: locked,
                    onTap: () => _handlePresetTap(context, ref, preset, locked, settings),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => _showCustomDialog(context, ref),
              icon: const Icon(Icons.timer),
              label: Text(l10n.customTitle()),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePresetTap(
    BuildContext context,
    WidgetRef ref,
    NapPreset preset,
    bool locked,
    Settings settings,
  ) async {
    final l10n = AppLocalizations.of(context);
    if (locked) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PaywallScreen()),
      );
      return;
    }

    final activeAlarm = ref.read(activeAlarmProvider);
    if (activeAlarm != null) {
      final replace = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.homeReplaceAlarm()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.homeCancel()),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.homeReplace()),
            ),
          ],
        ),
      );
      if (replace != true) {
        return;
      }
    }

    final success = await ref.read(activeAlarmProvider.notifier).schedulePreset(preset);
    if (!context.mounted) return;
    if (success) {
      final timeUtils = const TimeUtils();
      final fireAt = DateTime.now().add(Duration(minutes: preset.minutes));
      final timeText = timeUtils.formatClock(fireAt, use24h: settings.use24h);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.homeAlarmSet(timeText))),
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ActiveAlarmScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.toastError())),
      );
    }
  }

  Future<void> _showCustomDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final pro = ref.read(proStatusProvider);
    final minutes = await showModalBottomSheet<int>(
      context: context,
      builder: (context) => _CustomTimerSheet(pro: pro),
    );
    if (minutes == null) return;
    if (!context.mounted) return;
    final success = await ref.read(activeAlarmProvider.notifier).scheduleCustom(minutes);
    if (!context.mounted) return;
    final settings = ref.read(settingsProvider);
    if (success) {
      final fireAt = DateTime.now().add(Duration(minutes: minutes));
      final timeText = const TimeUtils().formatClock(fireAt, use24h: settings.use24h);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.homeAlarmSet(timeText))),
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ActiveAlarmScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.toastError())),
      );
    }
  }
}

class _ActiveAlarmBanner extends ConsumerWidget {
  const _ActiveAlarmBanner({required this.alarm, required this.settings});

  final ActiveAlarm? alarm;
  final Settings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (alarm == null) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    final timeUtils = const TimeUtils();
    final fireAt = timeUtils.fromEpochMillis(alarm!.fireAtEpochMs);
    return Card(
      child: ListTile(
        leading: const Icon(Icons.alarm),
        title: Text(l10n.countdownWakeTime(
          timeUtils.formatClock(fireAt, use24h: settings.use24h),
        )),
        subtitle: Text('${alarm!.totalMinutes} min'),
        trailing: TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ActiveAlarmScreen()),
            );
          },
          child: const Text('View'),
        ),
      ),
    );
  }
}

class _CustomTimerSheet extends StatefulWidget {
  const _CustomTimerSheet({required this.pro});

  final bool pro;

  @override
  State<_CustomTimerSheet> createState() => _CustomTimerSheetState();
}

class _CustomTimerSheetState extends State<_CustomTimerSheet> {
  late double _minutes = widget.pro ? 45 : 10;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final max = widget.pro ? 180.0 : 30.0;
    final min = 5.0;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.customTitle(), style: Theme.of(context).textTheme.titleLarge),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Slider(
            value: _minutes.clamp(min, max),
            min: min,
            max: max,
            divisions: ((max - min) / 5).round(),
            label: '${_minutes.round()} min',
            onChanged: (value) {
              setState(() => _minutes = value);
            },
          ),
          Text('${_minutes.round()} ${l10n.customMinutes()}'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              final minutes = _minutes.round();
              if (!widget.pro && minutes > 30) {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PaywallScreen()),
                );
                return;
              }
              Navigator.pop(context, minutes);
            },
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: Text(l10n.customStart()),
          ),
          if (!widget.pro)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                l10n.customLocked(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}
