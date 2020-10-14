import 'package:node_search_example/features/nodesearch/date_time_converter.dart';

class StringConverter {
  String convertJson(String jsonString, TranslationDirection direction) {
    List<String> jsonCharArray = jsonString.split("\"");
    List<String> convertedArray = new List();
    for(String each in jsonCharArray) {
      each = each.trim();
      if (DateTime.tryParse(each) != null) {
        each = DateTimeConverter.convertToCleanString(each, direction);
      }
      convertedArray.add(each);
    }
    StringBuffer convertedString = StringBuffer();//newStringArr.toString();
    for (String string in convertedArray) {
      // only quote strings not integers or []/{}
      String trimmedString = string.trim();
      if (!(trimmedString.contains("[") || trimmedString.contains("]") || trimmedString.contains("{") || trimmedString.contains("}") || trimmedString.contains(":") || trimmedString.contains(","))) {
        if (double.tryParse(string) != null) { // a number
          convertedString.write(string.trim());
        } else {
          convertedString.write("\"$trimmedString\"");
        }
      } else {
        // need to check if date (contains ':')
        if (DateTime.tryParse(string) == null) { // if not a date string
          convertedString.write(trimmedString);
        } else { // need to add " around date string
          convertedString.write("\"$trimmedString\"");
        }
      }
    }
    return convertedString.toString();
  }
}