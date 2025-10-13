import 'package:flutter_date_formatter/flutter_date_formatter.dart';
import 'package:intl/intl.dart';

//Formatting to get time
String formatTime(String date) {
  final DateTime? formattedDate = DateTime.tryParse(date);
  if (formattedDate == null) {
    return "";
  }

  DateTime localTime =
      formattedDate.isUtc ? formattedDate.toLocal() : formattedDate;
  final String timeOnly = DateFormat('h:mm a').format(localTime);
  return timeOnly;
}

//Formatting to get date
String formatDate(String date) {
  final DateTime? formattedDate = DateTime.tryParse(date);
  if (formattedDate == null) {
    return "";
  }

  final DateTime localTime = formattedDate.toLocal();
  if (formattedDate.isToday) {
    return "Today";
  }

  if (formattedDate.isYesterday) {
    return "Yesterday";
  }
  final String dateOnly = DateFormat('d MMMM y').format(localTime);
  return dateOnly;
}
