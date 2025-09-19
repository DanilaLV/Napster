import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../shared/providers.dart';
import 'iap_service.dart';

class PaywallScreen extends HookConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final iap = ref.watch(iapServiceProvider);
    final isOwned = iap.isOwned;
    final product = iap.product;

    final benefits = [
      l10n.iapFeatureDeep(),
      l10n.iapFeatureCycle(),
      l10n.iapFeatureCustom(),
      l10n.iapFeatureTones(),
      l10n.iapFeatureSnooze(),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.iapProTitle())),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.iapProDescription(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            ...benefits.map(
              (benefit) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(child: Text(benefit)),
                  ],
                ),
              ),
            ),
            const Spacer(),
            if (isOwned)
              FilledButton.icon(
                onPressed: null,
                icon: const Icon(Icons.star),
                label: Text(l10n.iapOwned()),
              )
            else
              Column(
                children: [
                  FilledButton(
                    onPressed: product == null
                        ? null
                        : () async {
                            await ref.read(iapServiceProvider).buy();
                          },
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                    child: Text(product != null ? l10n.iapPrice(product.price) : l10n.iapBuy()),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () async {
                      await ref.read(iapServiceProvider).restore();
                    },
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                    child: Text(l10n.iapRestore()),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
