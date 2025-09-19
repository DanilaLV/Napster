import 'package:flutter/material.dart';

import '../../data/models/preset.dart';
import '../../l10n/generated/app_localizations.dart';

class PresetCard extends StatelessWidget {
  const PresetCard({
    required this.preset,
    required this.onTap,
    required this.isDefault,
    required this.locked,
    super.key,
  });

  final NapPreset preset;
  final VoidCallback onTap;
  final bool isDefault;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = _resolveTitle(l10n, preset.titleKey);
    final minutes = preset.minutes;

    return GestureDetector(
      onTap: locked ? null : onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: isDefault ? 1.05 : 1.0,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      locked ? Icons.lock_outline : Icons.bedtime,
                      color: locked
                          ? Theme.of(context).colorScheme.outline
                          : Theme.of(context).colorScheme.primary,
                    ),
                    const Spacer(),
                    if (isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Default',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$minutes min',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _resolveTitle(AppLocalizations l10n, String key) {
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
