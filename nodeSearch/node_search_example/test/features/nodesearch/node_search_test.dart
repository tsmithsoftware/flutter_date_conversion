import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:node_search_example/features/nodesearch/date_time_converter.dart';
import 'package:node_search_example/features/nodesearch/node_search.dart';

import '../../fixtures/fixture_reader.dart';

void main() async {
  group('graph creation', (){
    test('search adds a root node to search map', (){
      var sut = NodeSearch();
      NodeRoot map = sut.buildMapFromString(fixture("list_json_body_with_dates.json"));
      assert(map != null);
    });
    test('search  adds a root Container node to search map', (){
      var sut = NodeSearch();
      NodeRoot map = sut.buildMapFromString(fixture("list_json_body_with_dates.json"));
      assert(map is NodeRoot);
    });
    test('search adds a root Container node and one Value node to search map when provided with an array with one element', (){
      var sut = NodeSearch();
      NodeRoot map = sut.buildMapFromString(fixture("list_json_body_with_dates.json"));
      dynamic nodes = map.getNodes();
      assert(nodes != null);
      assert(map is ListNode);
      List child = map.getNodes();
      assert(child.length == 1);
      assert(child[0] is MapNode);
      Map<String, NodeRoot> children = child[0].nodes;
      assert(children.length == 3);
      ValueNode visitId = children["visitId"];
      ValueNode notificationId = children["notificationId"];
      ValueNode signInDateTime = children["signInDateTime"];
      assert(visitId.getNodes() == 316);
      assert(notificationId.getNodes() == 599135627);
      assert(signInDateTime.getNodes() == "2020-08-28 10:26:31.000");
    });
    test('search adds a root Container node, with one Container node containing one Value node to search map when provided with a map with one array', (){
      var sut = NodeSearch();
      NodeRoot map = sut.buildMapFromString(fixture("map_with_one_array.json"));
      dynamic nodes = map.getNodes();
      assert(nodes != null);
      assert(map is MapNode);
      Map children = map.getNodes();
      assert(children.length == 1);
      ListNode arrayChild = children["visits"];
      MapNode firstChild = arrayChild.getNodes()[0];
      assert(firstChild != null);
      Map mapChildren = firstChild.getNodes();
      ValueNode visitId = mapChildren["visitId"];
      ValueNode visitDescription = mapChildren["visitDescription"];
      ValueNode signInDateTime = mapChildren["signInDateTime"];

      assert(visitId.getNodes() == 1);
      assert(visitDescription.getNodes() == "Nice!");
      assert(signInDateTime.getNodes() == "2020-08-28 10:26:31.000");
    });
    test('search adds a root Container nodes with other nested Container and Value nodes as described in json', (){
      var sut = NodeSearch();
      NodeRoot map = sut.buildMapFromString(fixture("multiple_nested_dates.json"));
      Map nodes = map.getNodes();
      assert(nodes != null);
    });
  });

  group('toJson', (){

    test ('toJson successfully returns correct string for simple value node',(){
      ValueNode vNode = ValueNode();
      vNode.values = "value";
      assert(vNode.toString() == "\"value\"");
    });

    test ('toJson successfully returns correct string for simple Map node',(){
      MapNode mNode = MapNode();
      ValueNode vNode = ValueNode();
      vNode.values = "value";
      mNode.nodes["mapKey"] = vNode;
      dynamic translatedJson = json.decode(mNode.toString());
      assert(translatedJson["mapKey"] == "value");
    });

    test ('toJson successfully returns correct string for simple json',(){
      var sut = NodeSearch();
      NodeRoot map = sut.buildMapFromString(fixture("basic_json.json"));
      String jsonString = map.toString();
      dynamic originalObject = json.decode(jsonString);
      assert(originalObject["signInDateTime"] == "2020-08-28 10:26:31.000");
    });

    test ('toJson successfully returns correct string for simple List json',(){
      var sut = NodeSearch();
      NodeRoot map = sut.buildMapFromString(fixture("list_json_body_with_dates.json"));
      String jsonString = map.toString();
      dynamic originalObject = json.decode(jsonString);
      assert(originalObject[0]["visitId"] == 316);
      assert(originalObject[0]["notificationId"] == 599135627);
      assert(originalObject[0]["signInDateTime"] == "2020-08-28 10:26:31.000");
    });

    test ('toJson successfully returns correct string for List json',(){
      var sut = NodeSearch();
      NodeRoot map = sut.buildMapFromString(fixture("list_json_body_with_multiple_dates.json"));
      String jsonString = map.toString();
      dynamic originalObject = json.decode(jsonString);

      assert(originalObject[0]["visitId"] == 316);
      assert(originalObject[0]["notificationId"] == 599135627);
      assert(originalObject[0]["signInDateTime"] == "2020-08-28 10:26:31.000");

      assert(originalObject[1]["visitId"] == 317);
      assert(originalObject[1]["notificationId"] == 938432345);
      assert(originalObject[1]["signInDateTime"] == "2020-08-28 11:26:31.000");
    });

    test ('toJson successfully returns correct string for a map with a single array',(){
      var sut = NodeSearch();
      NodeRoot map = sut.buildMapFromString(fixture("map_with_one_array.json"));
      String jsonString = map.toString();
      dynamic originalObject = json.decode(jsonString);
      dynamic visitObject = originalObject["visits"][0];
      assert(visitObject != null);
      assert(visitObject["visitId"] == 1);
      assert(visitObject["visitDescription"] == "Nice!");
      assert(visitObject["signInDateTime"] == "2020-08-28 10:26:31.000");
    });

    test ('toJson successfully returns correct string for nested map',(){
      var sut = NodeSearch();
      NodeRoot map = sut.buildMapFromString(fixture("medium_complex.json"));
      String jsonString = map.toString();
      dynamic originalObject = json.decode(jsonString);
      dynamic visitObject = originalObject["visits"][0];
      assert(visitObject != null);
      assert(visitObject["visitId"] == 1);
      assert(visitObject["visitDescription"] == "Nice!");
      assert(visitObject["signInDateTime"] == "2020-08-28 10:26:31.000");
    });

    test('blah', (){
      String jsonString = fixture("medium_complex.json");
      List<String> stringArr = jsonString.split("\"");
      List<String> newStringArr = new List();
      for(String each in stringArr) {
        each = each.trim();
        if (DateTime.tryParse(each) != null) {
          each = DateTimeConverter.convertToCleanString(each, TranslationDirection.LocalToUtc);
        }
        newStringArr.add(each);
      }
      StringBuffer convertedString = StringBuffer();//newStringArr.toString();
      for (String string in stringArr) {
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
          } else { // need to add "
            convertedString.write("\"${DateTimeConverter.convertToCleanString(trimmedString, TranslationDirection.LocalToUtc)}\"");
          }

        }
        /**
        if (double.tryParse(string) != null) { // a number
          convertedString.write(string.trim());
        } else {
          convertedString.write("\"${string.trim()}\"");
        } **/
      }
      String st = convertedString.toString();
      dynamic originalObject = json.decode(convertedString.toString().trim());
      assert(originalObject["visitor"]["nestedDateLevelTwo"] == "2020-06-10 09:00:00");
    });

  });

}