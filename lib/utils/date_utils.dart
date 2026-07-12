import 'package:intl/intl.dart';

String formatFriendlyDate(DateTime date) {
  return DateFormat('d MMMM yyyy').format(date);
}

String formatShortDate(DateTime date) {
  return DateFormat('d MMM').format(date);
}
