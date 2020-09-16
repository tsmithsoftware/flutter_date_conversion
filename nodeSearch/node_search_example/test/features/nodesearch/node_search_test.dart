import 'dart:collection';

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

  group('finding nodes to update', (){
    test('finds the correct location in a single-level JSON map with one node to update', (){
      var sut = NodeSearch();
      List<NodeUpdateLocation> locations = sut.getUpdateLocations(fixture("basic_json.json"));
      assert(locations != null);
      assert(locations.length == 1); // one node to update
      NodeUpdateLocation route = locations[0];
      assert(route.route.length == 2); // two steps to node
      Node firstFoundNode = route.route.removeFirst();
      assert(firstFoundNode is RootNode);
      assert(firstFoundNode.key == 0);
      Node secondFoundNode = route.route.removeLast();
      assert(secondFoundNode.key == "signInDateTime");
      assert(secondFoundNode.value == "2020-08-28 10:26:31.000");
    });
    test('finds the correct location in a map in a JSON array with a single element with one node to update', (){
      var sut = NodeSearch();
      List<NodeUpdateLocation> locations = sut.getUpdateLocations(fixture("map_with_one_array.json"));
      assert(locations != null);
      assert(locations.length == 1); // one node to update
      NodeUpdateLocation route = locations[0];
      assert(route.route.length == 4); // four steps to node
      Node firstFoundNode = route.route.removeFirst();
      assert(firstFoundNode is RootNode);
      assert(firstFoundNode.key == 0);
      Node secondFoundNode = route.route.removeLast();
      assert(secondFoundNode.key == "signInDateTime");
      assert(secondFoundNode.value == "2020-08-28 10:26:31.000");
    });
    test('finds the correct location in an array in a JSON map with a single element with one node to update', (){
      var sut = NodeSearch();
      List<NodeUpdateLocation> locations = sut.getUpdateLocations(fixture("list_with_one_map.json"));
      assert(locations != null);
      assert(locations.length == 1); // one node to update
      NodeUpdateLocation route = locations[0];
      assert(route.route.length == 3); // four steps to node
      Node firstFoundNode = route.route.removeFirst();
      assert(firstFoundNode is RootNode);
      assert(firstFoundNode.key == 0);
      Node secondFoundNode = route.route.removeLast();
      assert(secondFoundNode.key == "signInDateTime");
      assert(secondFoundNode.value == "2020-08-28 10:26:31.000");
    });
    test('finds the correct location of multiple DT stamps in a nested JSON map', (){
      var sut = NodeSearch();
      List<NodeUpdateLocation> locations = sut.getUpdateLocations(fixture("nested_mixed_dates.json"));
      assert(locations != null);
      assert(locations.length == 10);
    });
  });

  group('updating nodes', (){
    test('node.generateRoute generates correct route', (){
      var nodeOne = Node();
      nodeOne.key = "KEY";
      nodeOne.value = "VALUE";

      var nodeTwo = Node();
      nodeTwo.key = "BASE";
      nodeTwo.value = nodeOne;

      nodeTwo.parent = nodeOne;

      Queue<Node> route = nodeTwo.generateRoute();
      assert(route.length == 2);
      assert(route.contains(nodeOne));
      assert(route.contains(nodeTwo));
      assert(route.removeFirst() == nodeOne);
      assert(route.removeLast() == nodeTwo);
    });
    test('updates the correct node in a single-level JSON map with one node to update', (){});
    test('updates the correct node in a map in a JSON array with a single element with one node to update', (){});
    test('updates the correct node in an array in a JSON map with a single element with one node to update', (){});
    test('updates the correct node of multiple DT stamps in a complex JSON map', (){});
  });
}