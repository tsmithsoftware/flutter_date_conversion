import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:node_search_example/features/nodesearch/date_time_converter.dart';
import 'package:node_search_example/features/stringConverter/string_converter.dart';

import '../../fixtures/fixture_reader.dart';

void main() async {

  group('String Converter', (){

    group('Test no timezone change', (){
      test ('parses basic json successfully', (){
        String jsonString = fixture("basic_json.json");
        String convertedString = StringConverter().convertJson(jsonString, TranslationDirection.NotSpecified);
        dynamic originalObject = json.decode(convertedString.toString().trim());
        assert(originalObject["signInDateTime"] == "2020-08-28 10:26:31.000");
      });
      test ('parses basic list json successfully', (){
        String jsonString = fixture("list_json_body_with_dates.json");
        String convertedString = StringConverter().convertJson(jsonString, TranslationDirection.NotSpecified);
        dynamic originalObject = json.decode(convertedString.toString().trim());
        assert(originalObject[0]["signInDateTime"] == "2020-08-28 10:26:31.000");
      });
      test ('parses multiple list json successfully', (){
        String jsonString = fixture("list_json_body_with_multiple_dates.json");
        String convertedString = StringConverter().convertJson(jsonString, TranslationDirection.NotSpecified);
        dynamic originalObject = json.decode(convertedString.toString().trim());
        assert(originalObject[0]["signInDateTime"] == "2020-08-28 10:26:31.000");
        assert(originalObject[1]["signInDateTime"] == "2020-08-28 11:26:31.000");
      });
      test ('parses map with one array successfully', (){
        String jsonString = fixture("map_with_one_array.json");
        String convertedString = StringConverter().convertJson(jsonString, TranslationDirection.NotSpecified);
        dynamic originalObject = json.decode(convertedString.toString().trim());
        assert(originalObject["visits"][0]["signInDateTime"] == "2020-08-28 10:26:31.000");
      });
      test('parses map with multiple nested dates successfully ', (){
        String jsonString = fixture("multiple_nested_dates.json");
        String convertedString = StringConverter().convertJson(jsonString, TranslationDirection.NotSpecified);
        dynamic originalObject = json.decode(convertedString.toString().trim());
        assert(originalObject["visitor"]["imageLink"]["dateTaken"] == "2020-05-10 10:00:00.000");
        assert(originalObject["visitor"]["imageLink"]["modifications"]["dateOfModification"] == "2020-05-10 12:00:00.000");
        assert(originalObject["visitor"]["imageLink"]["modifications"]["additionalNesting"]["nestedDate"] == "2020-06-10 10:00:00.000");
      });
      test ('parses map with four levels successfully', (){
        String jsonString = fixture("medium_complex.json");
        String convertedString = StringConverter().convertJson(jsonString, TranslationDirection.NotSpecified);
        dynamic originalObject = json.decode(convertedString.toString().trim());
        assert(originalObject["visitor"]["nestedDateLevelTwo"] == "2020-06-10 10:00:00.000");
        assert(originalObject["visitor"]["someOtherLink"]["someDate"] == "2020-05-10 10:00:00.000");
        assert(originalObject["visitor"]["someLink"]["someDate"] == "2020-05-10 10:00:00.000");
        assert(originalObject["visitor"]["imageLink"]["nestedDateLevelThree"] == "2020-05-10 10:00:00.000");
        assert(originalObject["visitor"]["imageLink"]["modifications"]["nestedDateLevelFour"] == "2020-05-10 12:00:00.000");
        assert(originalObject["visitor"]["imageLink"]["modifications"]["additionalNesting"]["nestedDateLevelFive"] == "2020-06-10 10:00:00.000");
      });
    });
    group('Test local to UTC timezone change', (){
      test ('parses basic json successfully', (){
        String jsonString = fixture("basic_json.json");
        String convertedString = StringConverter().convertJson(jsonString, TranslationDirection.LocalToUtc);
        dynamic originalObject = json.decode(convertedString.toString().trim());
        assert(originalObject["signInDateTime"] == "2020-08-28 09:26:31.000");
      });
      test ('parses basic list json successfully', (){
        String jsonString = fixture("list_json_body_with_dates.json");
        String convertedString = StringConverter().convertJson(jsonString, TranslationDirection.LocalToUtc);
        dynamic originalObject = json.decode(convertedString.toString().trim());
        assert(originalObject[0]["signInDateTime"] == "2020-08-28 09:26:31.000");
      });
      test ('parses multiple list json successfully', (){
        String jsonString = fixture("list_json_body_with_multiple_dates.json");
        String convertedString = StringConverter().convertJson(jsonString, TranslationDirection.LocalToUtc);
        dynamic originalObject = json.decode(convertedString.toString().trim());
        assert(originalObject[0]["signInDateTime"] == "2020-08-28 09:26:31.000");
        assert(originalObject[1]["signInDateTime"] == "2020-08-28 10:26:31.000");
      });
      test ('parses map with one array successfully', (){
        String jsonString = fixture("map_with_one_array.json");
        String convertedString = StringConverter().convertJson(jsonString, TranslationDirection.LocalToUtc);
        dynamic originalObject = json.decode(convertedString.toString().trim());
        assert(originalObject["visits"][0]["signInDateTime"] == "2020-08-28 09:26:31.000");
      });
      test('parses map with multiple nested dates successfully ', (){
        String jsonString = fixture("multiple_nested_dates.json");
        String convertedString = StringConverter().convertJson(jsonString, TranslationDirection.LocalToUtc);
        dynamic originalObject = json.decode(convertedString.toString().trim());
        assert(originalObject["visitor"]["imageLink"]["dateTaken"] == "2020-05-10 09:00:00.000");
        assert(originalObject["visitor"]["imageLink"]["modifications"]["dateOfModification"] == "2020-05-10 11:00:00.000");
        assert(originalObject["visitor"]["imageLink"]["modifications"]["additionalNesting"]["nestedDate"] == "2020-06-10 09:00:00.000");
      });
      test ('parses map with four levels successfully', (){
        String jsonString = fixture("medium_complex.json");
        String convertedString = StringConverter().convertJson(jsonString, TranslationDirection.LocalToUtc);
        dynamic originalObject = json.decode(convertedString.toString().trim());
        assert(originalObject["visitor"]["nestedDateLevelTwo"] == "2020-06-10 09:00:00.000");
        assert(originalObject["visitor"]["someOtherLink"]["someDate"] == "2020-05-10 09:00:00.000");
        assert(originalObject["visitor"]["someLink"]["someDate"] == "2020-05-10 09:00:00.000");
        assert(originalObject["visitor"]["imageLink"]["nestedDateLevelThree"] == "2020-05-10 09:00:00.000");
        assert(originalObject["visitor"]["imageLink"]["modifications"]["nestedDateLevelFour"] == "2020-05-10 11:00:00.000");
        assert(originalObject["visitor"]["imageLink"]["modifications"]["additionalNesting"]["nestedDateLevelFive"] == "2020-06-10 09:00:00.000");
      });
    });
    group('Test UTC to local timezone change', (){
      test ('parses basic json successfully', (){
        String jsonString = fixture("basic_json.json");
        String convertedString = StringConverter().convertJson(jsonString, TranslationDirection.UtcToLocal);
        dynamic originalObject = json.decode(convertedString.toString().trim());
        assert(originalObject["signInDateTime"] == "2020-08-28 11:26:31.000");
      });
      test ('parses basic list json successfully', (){
        String jsonString = fixture("list_json_body_with_dates.json");
        String convertedString = StringConverter().convertJson(jsonString, TranslationDirection.UtcToLocal);
        dynamic originalObject = json.decode(convertedString.toString().trim());
        assert(originalObject[0]["signInDateTime"] == "2020-08-28 11:26:31.000");
      });
      test ('parses multiple list json successfully', (){
        String jsonString = fixture("list_json_body_with_multiple_dates.json");
        String convertedString = StringConverter().convertJson(jsonString, TranslationDirection.UtcToLocal);
        dynamic originalObject = json.decode(convertedString.toString().trim());
        assert(originalObject[0]["signInDateTime"] == "2020-08-28 11:26:31.000");
        assert(originalObject[1]["signInDateTime"] == "2020-08-28 12:26:31.000");
      });
      test ('parses map with one array successfully', (){
        String jsonString = fixture("map_with_one_array.json");
        String convertedString = StringConverter().convertJson(jsonString, TranslationDirection.UtcToLocal);
        dynamic originalObject = json.decode(convertedString.toString().trim());
        assert(originalObject["visits"][0]["signInDateTime"] == "2020-08-28 11:26:31.000");
      });
      test('parses map with multiple nested dates successfully ', (){
        String jsonString = fixture("multiple_nested_dates.json");
        String convertedString = StringConverter().convertJson(jsonString, TranslationDirection.UtcToLocal);
        dynamic originalObject = json.decode(convertedString.toString().trim());
        assert(originalObject["visitor"]["imageLink"]["dateTaken"] == "2020-05-10 11:00:00.000");
        assert(originalObject["visitor"]["imageLink"]["modifications"]["dateOfModification"] == "2020-05-10 13:00:00.000");
        assert(originalObject["visitor"]["imageLink"]["modifications"]["additionalNesting"]["nestedDate"] == "2020-06-10 11:00:00.000");
      });
      test ('parses map with four levels successfully', (){
        String jsonString = fixture("medium_complex.json");
        String convertedString = StringConverter().convertJson(jsonString, TranslationDirection.UtcToLocal);
        dynamic originalObject = json.decode(convertedString.toString().trim());
        assert(originalObject["visitor"]["nestedDateLevelTwo"] == "2020-06-10 11:00:00.000");
        assert(originalObject["visitor"]["someOtherLink"]["someDate"] == "2020-05-10 11:00:00.000");
        assert(originalObject["visitor"]["someLink"]["someDate"] == "2020-05-10 11:00:00.000");
        assert(originalObject["visitor"]["imageLink"]["nestedDateLevelThree"] == "2020-05-10 11:00:00.000");
        assert(originalObject["visitor"]["imageLink"]["modifications"]["nestedDateLevelFour"] == "2020-05-10 13:00:00.000");
        assert(originalObject["visitor"]["imageLink"]["modifications"]["additionalNesting"]["nestedDateLevelFive"] == "2020-06-10 11:00:00.000");
      });
    });
  });

}