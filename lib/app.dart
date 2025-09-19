import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/home/home_screen.dart';
import 'l10n/generated/app_localizations.dart';
import 'data/models/settings.dart';
import 'shared/providers.dart';
import 'shared/theme.dart';

class NapsterApp extends ConsumerWidget {
  const NapsterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final init = ref.watch(initializationProvider);

    return MaterialApp(
      title: 'Napster',
      theme: buildLightTheme(),
      locale: _mapLocale(ref.watch(settingsProvider).language),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: init.when(
        data: (_) => const HomeScreen(),
        loading: () => const _SplashScreen(),
        error: (error, stackTrace) => _ErrorScreen(error: error),
      ),
    );
  }

  Locale _mapLocale(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return const Locale('en');
      case AppLanguage.lv:
        return const Locale('lv');
    }
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Error: $error'),
      ),
    );
  }
}
