
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

String parseDateStrES(String inputString) {
  initializeDateFormatting('es'); // This will initialize Spanish locale
  DateFormat format = DateFormat.yMMMEd('es');
  return format.format(DateTime.parse(inputString));
}
String parseTimeStrES(String inputString) {
  initializeDateFormatting('es'); // This will initialize Spanish locale
  DateFormat format = DateFormat.jm('es');
  return format.format(DateTime.parse(inputString));
}