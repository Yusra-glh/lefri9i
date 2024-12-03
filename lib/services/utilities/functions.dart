import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool isSameDate(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

String formatDate(String createdAt) {
  DateTime dateTime = DateTime.parse(createdAt);
  String formattedDate = DateFormat('dd MMM yy').format(dateTime);
  return formattedDate;
}

String formatEventDateTime(String date, String time) {
  DateTime dateTime = DateTime.parse("$date $time");
  return DateFormat('dd/MM/yy - HH:mm').format(dateTime);
}

String formatEventDate(String date) {
  DateTime dateTime = DateTime.parse(date);
  return DateFormat('dd/MM/yy').format(dateTime);
}

String formatEventTime(String time) {
  final timeFormat = DateFormat.Hms();
  final parsedTime = timeFormat.parse(time);
  return DateFormat('HH:mm').format(parsedTime);
}

Future<String?> getAccessTokenFromStorage() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  } catch (e) {
    // ignore: avoid_print
    print('Error reading accessToken from secure storage: $e');
    return null;
  }
}
