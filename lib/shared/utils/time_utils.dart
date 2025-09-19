import 'package:intl/intl.dart';

typedef EpochMillis = int;

class TimeUtils {
  const TimeUtils();

  DateTime nowUtc() => DateTime.now().toUtc();

  DateTime nowLocal() => DateTime.now();

  DateTime fromEpochMillis(EpochMillis millis) =>
      DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true).toLocal();

  EpochMillis toEpochMillis(DateTime time) => time.toUtc().millisecondsSinceEpoch;

  DateTime addMinutes(DateTime base, int minutes) => base.add(Duration(minutes: minutes));

  String formatClock(DateTime time, {bool use24h = true}) {
    final format = use24h ? DateFormat.Hm() : DateFormat.jm();
    return format.format(time);
  }

  String formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Duration remainingUntil(DateTime target) {
    final diff = target.difference(DateTime.now());
    if (diff.isNegative) {
      return Duration.zero;
    }
    return diff;
  }
}
