import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

String parseDateStrES(String inputString) {
  initializeDateFormatting('es'); // This will initialize Spanish locale
  DateFormat format = DateFormat.yMMMEd('es');
  try {
    return format.format(DateTime.parse(inputString));
  } catch (e) {
    return '';
  }
}

String parseTimeStrES(String inputString) {
  initializeDateFormatting('es'); // This will initialize Spanish locale
  DateFormat format = DateFormat.Hm('es');
  try {
    return format.format(DateTime.parse(inputString));
  } catch (e) {
    return '';
  }
}
