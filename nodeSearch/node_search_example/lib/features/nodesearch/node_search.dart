import 'dart:collection';
import 'dart:convert';

import 'package:quiver/core.dart';

// each line of the json is a node
class Node {
  dynamic key;
  dynamic value;
  Node parent;

  Queue<Node> generateRoute() {
    var route = Queue<Node>();
    if (parent != null) {
      route.addAll(parent.generateRoute());
    }
    route.add(this);
    return route;
  }

  @override
  bool operator ==(Object other) {
    if (other is Node) {
      if (other.parent == parent) {
        if (other.key == key) {
          if (other.value == value) {
            return true;
          }
        }
      }
    }
    return false;
  }

  @override
  int get hashCode => hashObjects([key, value]);

}

// to mark root of graph
class RootNode extends Node {}

// to represent where in the graph to update a DT stamp
class NodeUpdateLocation {
  Node nodeToUpdate;
  Queue<Node> route = Queue();
}

class NodeSearch {
  // Build a map of nodes given a JSON string
  Node buildMap(String jsonData) {
    dynamic jsonValue = json.decode(jsonData);
    Map<dynamic, Node> newChildren = Map<dynamic, Node>();

    RootNode rootNode = RootNode();
    rootNode.key = 0;
    if (jsonValue is List) {
      for (int position = 0; position < jsonValue.length; position++) {
        newChildren[position] =
            _createChildNodes(jsonValue[position], position, rootNode);
      }
    }

    if (jsonValue is Map) {
      Map valueMap = jsonValue;
      for (dynamic key in valueMap.keys) {
        newChildren[key] = _createChildNodes(jsonValue[key], key, rootNode);
      }
    }

    rootNode.value = newChildren;
    return rootNode;
  }

  // find all places in the JSON which need updating
  List<NodeUpdateLocation> getUpdateLocations(String jsonData) {
    Node map = buildMap(jsonData);
    List<NodeUpdateLocation> locations = List();
    locations = searchMapForLocations(map, locations);
    return locations;
  }

  // Helper methods
  Node _createChildNodes(dynamic listJsonValue, dynamic position, Node parent) {
    Node childNode = Node();
    childNode.key = position;
    Map<dynamic, Node> subChildren = Map<dynamic, Node>();
    // Map
    if (listJsonValue is Map) {
      for (dynamic key in listJsonValue.keys) {
        subChildren[key] =
            _createChildNodes(listJsonValue[key], key, childNode);
      }
      childNode.value = subChildren;
    }
    // List
    else if (listJsonValue is List) {
      for (int position = 0; position < listJsonValue.length; position++) {
        subChildren[position] =
            _createChildNodes(listJsonValue[position], position, childNode);
      }
      childNode.value = subChildren;
    }
    // Value
    else {
      childNode.value = listJsonValue;
    }
    childNode.parent = parent;
    return childNode;
  }

  List<NodeUpdateLocation> searchMapForLocations(
      Node map, List<NodeUpdateLocation> locations) {
    if (map.value is String) {
      if (isDateTime(map.value)) {
        NodeUpdateLocation location = createLocation(map);
        locations.add(location);
      }
    } else {
      if (!(map.value is int)) {
        Map<dynamic, Node> value = map.value;
        if (value != null) {
          for (dynamic mapEntry in value.values) {
            if (mapEntry is Node) {
              searchMapForLocations(mapEntry, locations);
            }
          }
        }
      }
    }
    return locations;
  }

  bool isDateTime(value) {
    try {
      DateTime.parse(value);
      return true;
    } catch (e) {
      return false;
    }
  }

  NodeUpdateLocation createLocation(Node value) {
    var newLocation = NodeUpdateLocation();
    newLocation.nodeToUpdate = value;
    newLocation.route = value.generateRoute();
    return newLocation;
  }
}
