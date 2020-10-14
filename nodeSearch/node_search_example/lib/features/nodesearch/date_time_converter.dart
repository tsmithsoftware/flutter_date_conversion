import 'package:intl/intl.dart';

enum TranslationDirection { NotSpecified, UtcToLocal, LocalToUtc }

class DateTimeConverter {
  static String convertToCleanString(String dtValue, TranslationDirection direction) {
    String converted = convert(dtValue, direction).toString();
    // Remove 'Z'
    if (converted.endsWith("Z")) {
      converted = converted.substring(0, converted.length - 1);
    }
    return converted;
  }

  static DateTime convert(String dtValue, TranslationDirection direction) {
    var newDt;
    switch (direction) {
      case TranslationDirection.LocalToUtc:
        newDt =
            DateFormat("yyyy-MM-dd HH:mm:ss").parse(dtValue, false).toUtc();
        break;
      case TranslationDirection.UtcToLocal:
        newDt =
            DateFormat("yyyy-MM-dd HH:mm:ss").parse(dtValue, true).toLocal();
        break;
      case TranslationDirection.NotSpecified:
        newDt = DateTime.parse(dtValue);
        break;
    }
    return newDt;
  }
}