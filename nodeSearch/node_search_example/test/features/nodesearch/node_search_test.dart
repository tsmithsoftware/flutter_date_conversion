import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:node_search_example/features/nodesearch/node_search.dart';

import '../../fixtures/fixture_reader.dart';

void main() async {
  group('graph creation', (){
    test('search adds a root node to search map', (){
      var sut = NodeSearch();
      Node map = sut.buildMap(fixture("list_json_body_with_dates.json"));
      assert(map != null);
    });
    test('search  adds a root Container node to search map', (){
      var sut = NodeSearch();
      Node map = sut.buildMap(fixture("list_json_body_with_dates.json"));
      assert(map is Node);
    });
    test('search adds a root Container node and one Value node to search map when provided with an array with one element', (){
      var sut = NodeSearch();
      Node map = sut.buildMap(fixture("list_json_body_with_dates.json"));
      Map<dynamic, Node> children = map.value;
      assert(children.length == 1);
      Node child = children[0];
      Map values = child.value;
      Node visitId = values["visitId"];
      Node notificationId = values["notificationId"];
      Node signInDateTime = values["signInDateTime"];
      assert(visitId.value == 316);
      assert(notificationId.value == 599135627);
      assert(signInDateTime.value == "2020-08-28 10:26:31.000");
    });
    test('search adds a root Container node, with one Container node containing one Value node to search map when provided with a map with one array', (){
      var sut = NodeSearch();
      Node map = sut.buildMap(fixture("map_with_one_array.json"));
      Map<dynamic, Node> rootChildren = map.value; // root node {}
      assert(rootChildren.length == 1);
      var visitsElement = rootChildren["visits"]; // visits nodes { visits: [] }
      Node containerChild = visitsElement;
      assert(containerChild.key == "visits");
      assert(containerChild.value.length == 1); // one visit element
      Node firstVisitDetailsElement = containerChild.value[0]; // first visit element
      Node visitDetailsId = firstVisitDetailsElement.value["visitId"];
      Node visitDetailsDescription = firstVisitDetailsElement.value["visitDescription"];

      assert(visitDetailsId.value == 1);
      assert(visitDetailsDescription.value == "Nice!");
    });
    test('search adds a root Container nodes with other nested Container and Value nodes as described in json', (){
      var sut = NodeSearch();
      Node map = sut.buildMap(fixture("multiple_nested_dates.json"));
      Map<dynamic, Node> rootChildren = map.value;
      assert(rootChildren.length == 1);
    });
  });

  group('updating nodes', (){

    group('local to UTC', () {
      test('updates the correct node in a single-level JSON map with one node to update and returns correct JSON', (){
        var sut = NodeSearch();
        RootNode node = sut.buildMap(fixture("basic_json.json"));
        NodeConfigurationObject configurationObject = NodeConfigurationObject();
        configurationObject.directionOfTranslation = TranslationDirection.LocalToUtc;
        sut.setConfigurationObject(node, configurationObject);
        String toString = node.toString();
        dynamic jsonObject = json.decode(toString);
        assert(jsonObject["signInDateTime"] == "2020-08-28 09:26:31.000");
      });
      test('updates the correct node in a map in a JSON array with a single element with one node to update and returns correct JSON', (){
        var sut = NodeSearch();
        RootNode node = sut.buildMap(fixture("map_with_one_array.json"));
        NodeConfigurationObject configurationObject = NodeConfigurationObject();
        configurationObject.directionOfTranslation = TranslationDirection.LocalToUtc;
        sut.setConfigurationObject(node, configurationObject);
        String jsonEncodedString = node.toString();
        dynamic jsonObject = json.decode(jsonEncodedString);
        assert(jsonObject["visits"][0]["signInDateTime"] == "2020-08-28 09:26:31.000");
      });

      test('updates the correct node in an array in a JSON map with a single element with one node to update and returns correct JSON', (){
        var sut = NodeSearch();
        RootNode node = sut.buildMap(fixture("list_with_one_map.json"));
        NodeConfigurationObject configurationObject = NodeConfigurationObject();
        configurationObject.directionOfTranslation = TranslationDirection.LocalToUtc;
        sut.setConfigurationObject(node, configurationObject);
        String jsonEncodedString = node.toString();
        dynamic jsonObject = json.decode(jsonEncodedString);
        assert(jsonObject[0]["signInDateTime"] == "2020-08-28 09:26:31.000");
      });

      test('updates the correct node of multiple DT stamps in a medium-complex JSON map and returns correct JSON', (){
        var sut = NodeSearch();
        String jsonString = fixture("medium_complex.json");
        RootNode node = sut.buildMap(jsonString);
        NodeConfigurationObject configurationObject = NodeConfigurationObject();
        configurationObject.directionOfTranslation = TranslationDirection.LocalToUtc;
        sut.setConfigurationObject(node, configurationObject);
        String nodeString = node.toString();

        print(nodeString);
        dynamic jsonObject = json.decode(node.toString());
        assert(jsonObject["visitor"]["nestedDateLevelTwo"] == "2020-06-10 09:00:00.000");
      });

      test('updates the correct node of multiple DT stamps in a complex JSON map and returns correct JSON', (){
        var sut = NodeSearch();
        String jsonString = fixture("nested_mixed_dates.json");
        RootNode node = sut.buildMap(jsonString);
        NodeConfigurationObject configurationObject = NodeConfigurationObject();
        configurationObject.directionOfTranslation = TranslationDirection.LocalToUtc;
        sut.setConfigurationObject(node, configurationObject);
        String nodeString = node.toString();

        print(nodeString);
        dynamic jsonObject = json.decode(node.toString());
        assert(jsonObject["nestedDateLevelOne"] == "2020-06-10 09:00:00.000");
      });
    });

    group('UTC to local', (){
    });

    group('toJson', (){
      test('toJson', (){
        var sut = NodeSearch();
        RootNode node = sut.buildMap(fixture("basic_json.json"));
        NodeConfigurationObject configurationObject = NodeConfigurationObject();
        configurationObject.directionOfTranslation = TranslationDirection.NotSpecified;
        sut.setConfigurationObject(node, configurationObject);
        String nodeString = node.toString();
        var decodedObjectFromString = json.decode(nodeString);
        assert(decodedObjectFromString["signInDateTime"] == "2020-08-28 10:26:31.000");
      });
      test('toJson mk 2', (){
        var sut = NodeSearch();
        String originalJson = fixture("list_json_body_with_dates.json");
        RootNode map = sut.buildMap(originalJson);
        NodeConfigurationObject configurationObject = NodeConfigurationObject();
        configurationObject.directionOfTranslation = TranslationDirection.NotSpecified;
        sut.setConfigurationObject(map, configurationObject);
        String nodeString = map.toString();

        Map decodedObjectFromString = json.decode(nodeString)[0];
        Map decodedOriginalObjectFromString = json.decode(originalJson)[0];

        assert(
        (decodedObjectFromString["visitId"] == decodedOriginalObjectFromString["visitId"]) &&
            (decodedObjectFromString["notificationId"] == decodedOriginalObjectFromString["notificationId"]) &&
            (decodedObjectFromString["signInDateTime"] == decodedOriginalObjectFromString["signInDateTime"])
        );
      });
      test('toJson mk 3', (){
        var sut = NodeSearch();
        String originalJson = fixture("list_json_body_with_multiple_dates.json");
        RootNode map = sut.buildMap(originalJson);
        NodeConfigurationObject configurationObject = NodeConfigurationObject();
        configurationObject.directionOfTranslation = TranslationDirection.NotSpecified;
        sut.setConfigurationObject(map, configurationObject);
        String nodeString = map.toString();

        dynamic originalObject = json.decode(originalJson);
        Map firstOriginalVisit = originalObject[0];
        Map secondOriginalVisit = originalObject[1];

        dynamic updatedObject = json.decode(nodeString);
        Map firstDecodedVisit = updatedObject[0];
        Map secondDecodedVisit = updatedObject[1];

        assert(
        // check first visit details
        (firstOriginalVisit["visitId"] == firstDecodedVisit["visitId"]) &&
            (firstOriginalVisit["notificationId"] == firstDecodedVisit["notificationId"]) &&
            (firstOriginalVisit["signInDateTime"] == firstDecodedVisit["signInDateTime"]) &&
            // check second visit details
            (secondOriginalVisit["visitId"] == secondDecodedVisit["visitId"]) &&
            (secondOriginalVisit["notificationId"] == secondDecodedVisit["notificationId"]) &&
            (secondOriginalVisit["signInDateTime"] == secondDecodedVisit["signInDateTime"])
        );
      });
      test('complex json', (){
        var sut = NodeSearch();
        String originalJson = fixture("multiple_nested_dates.json");
        RootNode map = sut.buildMap(originalJson);
        NodeConfigurationObject configurationObject = NodeConfigurationObject();
        configurationObject.directionOfTranslation = TranslationDirection.NotSpecified;
        sut.setConfigurationObject(map, configurationObject);
        String nodeString = map.toString();

        dynamic originalObject = json.decode(originalJson);
        String firstDate = originalObject["visitor"]["imageLink"]["dateTaken"];
        DateTime dtFirstDate = DateTime.parse(firstDate);

        String secondDate = originalObject["visitor"]["imageLink"]["modifications"]["dateOfModification"];
        DateTime dtSecondDate = DateTime.parse(secondDate);

        String thirdDate = originalObject["visitor"]["imageLink"]["modifications"]["additionalNesting"]["nestedDate"];
        DateTime dtThirdDate = DateTime.parse(thirdDate);

        dynamic updatedObject = json.decode(nodeString);
        String firstDecodedDate = updatedObject["visitor"]["imageLink"]["dateTaken"];
        DateTime dtFirstDateUpdated = DateTime.parse(firstDecodedDate);

        String secondDecodedDate = updatedObject["visitor"]["imageLink"]["modifications"]["dateOfModification"];
        DateTime dtSecondDateUpdated = DateTime.parse(secondDecodedDate);

        String thirdDecodedDate = updatedObject["visitor"]["imageLink"]["modifications"]["additionalNesting"]["nestedDate"];
        DateTime dtThirdDateUpdated = DateTime.parse(thirdDecodedDate);

        // convert to DT to get around additional decimal places in timestamp
        assert(
        (dtFirstDate == dtFirstDateUpdated) &&
            (dtSecondDate == dtSecondDateUpdated) &&
            (dtThirdDate == dtThirdDateUpdated)
        );
      });
      test('very complex json', (){
        var sut = NodeSearch();
        String originalJson = fixture("nested_mixed_dates.json");
        RootNode map = sut.buildMap(originalJson);
        NodeConfigurationObject configurationObject = NodeConfigurationObject();
        configurationObject.directionOfTranslation = TranslationDirection.NotSpecified;
        sut.setConfigurationObject(map, configurationObject);
        String nodeString = map.toString();
        assert(nodeString != null);
      });
    });

  });
}