import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/models/active_alarm.dart';
import '../../data/models/settings.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/providers.dart';
import '../../shared/utils/time_utils.dart';
import '../settings/settings_sheet.dart';

class ActiveAlarmScreen extends HookConsumerWidget {
  const ActiveAlarmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarm = ref.watch(activeAlarmProvider);
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context);

    if (alarm == null) {
      return const _NoActiveAlarm();
    }

    final timeUtils = const TimeUtils();
    final fireAt = timeUtils.fromEpochMillis(alarm.fireAtEpochMs);
    final countdownStream = useMemoized(() => _countdownStream(fireAt));
    final snapshot = useStream(countdownStream, initialData: timeUtils.remainingUntil(fireAt));

    final remaining = snapshot.data ?? Duration.zero;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.countdownWakeTime(timeUtils.formatClock(
          fireAt,
          use24h: settings.use24h,
        ))),
        actions: const [SettingsAction()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Text(
              l10n.countdownRemaining(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(
              timeUtils.formatDuration(remaining),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () async {
                await ref.read(activeAlarmProvider.notifier).cancelAlarm();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.alarmStopped())),
                );
                Navigator.of(context).maybePop();
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              child: Text(l10n.countdownCancel()),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () async {
                final success = await ref
                    .read(activeAlarmProvider.notifier)
                    .snooze(settings.snoozeMinutes);
                if (!context.mounted) return;
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.snoozeAdded(
                          timeUtils.formatClock(
                            timeUtils.fromEpochMillis(
                              ref.read(activeAlarmProvider)!.fireAtEpochMs,
                            ),
                            use24h: settings.use24h,
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.toastError())),
                  );
                }
              },
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
              child: Text(l10n.countdownSnooze()),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

Stream<Duration> _countdownStream(DateTime fireAt) async* {
  while (true) {
    final diff = fireAt.difference(DateTime.now());
    if (diff.isNegative) {
      yield Duration.zero;
      break;
    }
    yield diff;
    await Future<void>.delayed(const Duration(seconds: 1));
  }
}

class _NoActiveAlarm extends StatelessWidget {
  const _NoActiveAlarm();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Text('No active alarm'),
      ),
    );
  }
}
