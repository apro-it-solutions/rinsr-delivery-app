import 'package:intl/intl.dart';

// Backend timestamps are UTC (ISO `...Z`); always convert to device-local
// time before formatting or every displayed time is 5h30m behind IST.
// `.toLocal()` is a no-op for DateTimes that are already local.
String formatDateMMMDDYYYY(DateTime date) {
  return DateFormat('MMM dd, yyyy').format(date.toLocal());
}

String formatDateMMMDDYYYYHHMM(DateTime date) {
  return DateFormat('MMM dd, yyyy hh:mm a').format(date.toLocal());
}

String formatTimeDifference(DateTime targetTime) {
  final now = DateTime.now();
  final difference = targetTime.difference(now);
  final minutes = difference.inMinutes;
  final hours = difference.inHours;
  final days = difference.inDays;

  if (days > 0) {
    return 'in $days ${days == 1 ? 'day' : 'days'}';
  } else if (hours > 0) {
    return 'in $hours ${hours == 1 ? 'hour' : 'hours'}';
  } else if (minutes > 0) {
    return 'in $minutes ${minutes == 1 ? 'min' : 'mins'}';
  } else if (minutes == 0) {
    return 'now';
  } else {
    // For past times
    final pastMinutes = -minutes;
    final pastHours = -hours;
    final pastDays = -days;

    if (pastDays > 0) {
      return '$pastDays ${pastDays == 1 ? 'day' : 'days'} ago';
    } else if (pastHours > 0) {
      return '$pastHours ${pastHours == 1 ? 'hour' : 'hours'} ago';
    } else {
      return '$pastMinutes ${pastMinutes == 1 ? 'min' : 'mins'} ago';
    }
  }
}
