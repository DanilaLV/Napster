import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' as intl;

class AppLocalizations {
  AppLocalizations(this.localeName);

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('lv'),
  ];

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static Future<AppLocalizations> load(Locale locale) async {
    final name = locale.countryCode?.isEmpty ?? true
        ? locale.languageCode
        : locale.toString();
    final localeName = intl.Intl.canonicalizedLocale(name);
    return AppLocalizations(localeName);
  }

  String get appTitle {
    switch (localeName) {
      case 'lv':
        return 'Napster';
      default:
        return 'Napster';
    }
  }

  String homeQuickNap() {
    switch (localeName) {
      case 'lv':
        return 'Ātra snauda';
      default:
        return 'Quick Nap';
    }
  }

  String homePowerNap() {
    switch (localeName) {
      case 'lv':
        return 'Spēka snauda';
      default:
        return 'Powernap';
    }
  }

  String homeDeepNap() {
    switch (localeName) {
      case 'lv':
        return 'Dziļa snauda';
      default:
        return 'Deep Nap';
    }
  }

  String homeSleepCycle() {
    switch (localeName) {
      case 'lv':
        return 'Miega cikls';
      default:
        return 'Sleep Cycle';
    }
  }

  String homeCustom() {
    switch (localeName) {
      case 'lv':
        return 'Pielāgots';
      default:
        return 'Custom';
    }
  }

  String homeReplaceAlarm() {
    switch (localeName) {
      case 'lv':
        return 'Aizstāt esošo modinātāju?';
      default:
        return 'Replace existing alarm?';
    }
  }

  String homeReplace() {
    switch (localeName) {
      case 'lv':
        return 'Aizstāt';
      default:
        return 'Replace';
    }
  }

  String homeCancel() {
    switch (localeName) {
      case 'lv':
        return 'Atcelt';
      default:
        return 'Cancel';
    }
  }

  String homeAlarmSet(String time) {
    switch (localeName) {
      case 'lv':
        return 'Modinātājs iestatīts uz $time';
      default:
        return 'Alarm set for $time';
    }
  }

  String homeUpgrade() {
    switch (localeName) {
      case 'lv':
        return 'Jaunināt';
      default:
        return 'Upgrade';
    }
  }

  String countdownRemaining() {
    switch (localeName) {
      case 'lv':
        return 'Atlicis';
      default:
        return 'Remaining';
    }
  }

  String countdownWakeTime(String time) {
    switch (localeName) {
      case 'lv':
        return 'Mosties $time';
      default:
        return 'Wake at $time';
    }
  }

  String countdownCancel() {
    switch (localeName) {
      case 'lv':
        return 'Atcelt';
      default:
        return 'Cancel';
    }
  }

  String countdownSnooze() {
    switch (localeName) {
      case 'lv':
        return 'Atlikt';
      default:
        return 'Snooze';
    }
  }

  String settingsTitle() {
    switch (localeName) {
      case 'lv':
        return 'Iestatījumi';
      default:
        return 'Settings';
    }
  }

  String settingsDefaultPreset() {
    switch (localeName) {
      case 'lv':
        return 'Noklusējuma režīms';
      default:
        return 'Default preset';
    }
  }

  String settingsTone() {
    switch (localeName) {
      case 'lv':
        return 'Signāls';
      default:
        return 'Alarm tone';
    }
  }

  String settingsVibration() {
    switch (localeName) {
      case 'lv':
        return 'Vibrācija';
      default:
        return 'Vibration';
    }
  }

  String settingsSnoozeLength() {
    switch (localeName) {
      case 'lv':
        return 'Atlikšanas ilgums';
      default:
        return 'Snooze length';
    }
  }

  String settingsLanguage() {
    switch (localeName) {
      case 'lv':
        return 'Valoda';
      default:
        return 'Language';
    }
  }

  String settingsTwentyFourHour() {
    switch (localeName) {
      case 'lv':
        return '24h formāts';
      default:
        return '24h time';
    }
  }

  String settingsSelectTone() {
    switch (localeName) {
      case 'lv':
        return 'Izvēlies signālu';
      default:
        return 'Select tone';
    }
  }

  String settingsPreview() {
    switch (localeName) {
      case 'lv':
        return 'Priekšskatījums';
      default:
        return 'Preview';
    }
  }

  String settingsSave() {
    switch (localeName) {
      case 'lv':
        return 'Saglabāt';
      default:
        return 'Save';
    }
  }

  String iapProTitle() {
    switch (localeName) {
      case 'lv':
        return 'Napster Pro';
      default:
        return 'Napster Pro';
    }
  }

  String iapProDescription() {
    switch (localeName) {
      case 'lv':
        return 'Atbloķē garākas snaudas, toņus un pielāgošanu.';
      default:
        return 'Unlock longer naps, tones, and customization.';
    }
  }

  String iapBuy() {
    switch (localeName) {
      case 'lv':
        return 'Vienreizējs pirkums';
      default:
        return 'Buy once';
    }
  }

  String iapRestore() {
    switch (localeName) {
      case 'lv':
        return 'Atjaunot';
      default:
        return 'Restore';
    }
  }

  String iapOwned() {
    switch (localeName) {
      case 'lv':
        return 'Iegādāts';
      default:
        return 'Owned';
    }
  }

  String iapFeatureDeep() {
    switch (localeName) {
      case 'lv':
        return 'Dziļa snauda (45 min)';
      default:
        return 'Deep (45 min)';
    }
  }

  String iapFeatureCycle() {
    switch (localeName) {
      case 'lv':
        return 'Miega cikls (90 min)';
      default:
        return 'Sleep Cycle (90 min)';
    }
  }

  String iapFeatureCustom() {
    switch (localeName) {
      case 'lv':
        return 'Pielāgots taimeris līdz 3h';
      default:
        return 'Custom timer up to 3h';
    }
  }

  String iapFeatureTones() {
    switch (localeName) {
      case 'lv':
        return 'Premium signāli';
      default:
        return 'Premium alarm tones';
    }
  }

  String iapFeatureSnooze() {
    switch (localeName) {
      case 'lv':
        return 'Pielāgots atlikšanas laiks';
      default:
        return 'Custom snooze length';
    }
  }

  String aboutTitle() {
    switch (localeName) {
      case 'lv':
        return 'Par un Privātums';
      default:
        return 'About & Privacy';
    }
  }

  String aboutVersion(String version) {
    switch (localeName) {
      case 'lv':
        return 'Versija $version';
      default:
        return 'Version $version';
    }
  }

  String aboutPrivacy() {
    switch (localeName) {
      case 'lv':
        return 'Napster glabā datus ierīcē. Nav kontu, nav izsekošanas.';
      default:
        return 'Napster keeps all data on device. No accounts, no tracking.';
    }
  }

  String aboutMute() {
    switch (localeName) {
      case 'lv':
        return 'iOS: paziņojumi ievēro klusuma slēdzi.';
      default:
        return 'iOS: notifications respect mute switch.';
    }
  }

  String permissionExactAlarm() {
    switch (localeName) {
      case 'lv':
        return 'Atļauj precīzus modinātājus laikus mosties.';
      default:
        return 'Allow exact alarms so naps wake you on time.';
    }
  }

  String permissionNotifications() {
    switch (localeName) {
      case 'lv':
        return 'Ieslēdz paziņojumus signālam.';
      default:
        return 'Enable notifications to ring alarms.';
    }
  }

  String permissionOpenSettings() {
    switch (localeName) {
      case 'lv':
        return 'Atvērt Iestatījumus';
      default:
        return 'Open Settings';
    }
  }

  String customTitle() {
    switch (localeName) {
      case 'lv':
        return 'Pielāgots taimeris';
      default:
        return 'Custom timer';
    }
  }

  String customMinutes() {
    switch (localeName) {
      case 'lv':
        return 'Minūtes';
      default:
        return 'Minutes';
    }
  }

  String customStart() {
    switch (localeName) {
      case 'lv':
        return 'Sākt';
      default:
        return 'Start';
    }
  }

  String customLocked() {
    switch (localeName) {
      case 'lv':
        return 'Jaunini, lai atbloķētu garākas snaudas';
      default:
        return 'Upgrade to unlock longer naps';
    }
  }

  String snoozeAdded(String time) {
    switch (localeName) {
      case 'lv':
        return 'Atlikts līdz $time';
      default:
        return 'Snoozed to $time';
    }
  }

  String alarmStopped() {
    switch (localeName) {
      case 'lv':
        return 'Modinātājs apstādināts';
      default:
        return 'Alarm stopped';
    }
  }

  String toastError() {
    switch (localeName) {
      case 'lv':
        return 'Radās kļūda';
      default:
        return 'Something went wrong';
    }
  }

  String languageEnglish() {
    switch (localeName) {
      case 'lv':
        return 'Angļu';
      default:
        return 'English';
    }
  }

  String languageLatvian() {
    switch (localeName) {
      case 'lv':
        return 'Latviešu';
      default:
        return 'Latvian';
    }
  }

  String iapPrice(String price) {
    switch (localeName) {
      case 'lv':
        return price;
      default:
        return price;
    }
  }

  String iapPending() {
    switch (localeName) {
      case 'lv':
        return 'Notiek apstrāde...';
      default:
        return 'Processing payment...';
    }
  }

  String iapError() {
    switch (localeName) {
      case 'lv':
        return 'Pirkums neizdevās';
      default:
        return 'Purchase failed';
    }
  }

  String iapThankYou() {
    switch (localeName) {
      case 'lv':
        return 'Paldies!';
      default:
        return 'Thank you!';
    }
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.contains(
        Locale(locale.languageCode),
      );

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
