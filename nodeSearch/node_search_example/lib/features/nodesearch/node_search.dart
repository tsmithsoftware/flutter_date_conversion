import 'dart:convert';

import 'package:quiver/core.dart';

// Representing how we want the DT stamps to look. One map of nodes would have a reference to one config object
// all the nodes would use the same config object to e.g. choose which DT stamp to return (local or UTC)
class NodeConfigurationObject {
  TranslationDirection directionOfTranslation = TranslationDirection.NotSpecified;
}

// Representing which way DT stamp conversion works
enum TranslationDirection { NotSpecified, UtcToLocal, LocalToUtc }
enum JsonType { Map, List, Value }
// each line of the json is a node
class Node {
  dynamic key;
  dynamic value;
  Node parent;
  JsonType type;
  NodeConfigurationObject configurationObject;

  dynamic toJson() {
    if (type == JsonType.List) {
      final List<dynamic> data = new List();
      data[0] = value;
      return data;
    }
    else if (type == JsonType.Map) {
      return
          {
            key: value
          };
      }
    else if (type == JsonType.Value) {
      // check if DT and convert
      return "'$key':'$value'";
    }
  }

  bool isDateTime(value) {
    try {
      DateTime.parse(value);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  String toString() {
  }

  StringBuffer _convertRootNodeToString(StringBuffer buffer) {
  }

  StringBuffer _convertChildNodeToString(StringBuffer buffer) {
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

  /// Used to set how the node returns itself as JSON. Allows the configurationObject to be changed outside of the map.
  void setConfigurationObject(NodeConfigurationObject configurationObject) {
    this.configurationObject = configurationObject;
    if (this.value is Map) {
      Map valueAsMap = this.value;
      for(dynamic child in valueAsMap.values) {
        if (child is Node) {
          child.setConfigurationObject(configurationObject);
        }
      }
    }
  }

}

/// to mark root of graph
class RootNode extends Node {}



abstract class NodeRoot {
  NodeConfigurationObject config;
  String toString();
}

class CollectionNode extends NodeRoot {}

class ListNode extends CollectionNode {
  List<Node> nodes;
}
class MapNode extends CollectionNode {
  Map<dynamic, Node> nodes;
}
class ValueNode extends NodeRoot {
  Map<dynamic, dynamic> values;
}




class NodeSearch {
  /// Build a map of nodes given a JSON string
  /// all we need is a list of the nodes, the nodes themselves handle  stringifying themselves
  Node buildMap(String jsonData) {
    dynamic jsonValue = json.decode(jsonData);
    List<Node> newChildren  = List();

    RootNode rootNode = RootNode();
    if (jsonValue is List) {
      rootNode.type = JsonType.List;
    }
    if (jsonValue is Map) {
      rootNode.type = JsonType.Map;
    }

    Node value = _createChildNodes(jsonValue, 0, rootNode);
    newChildren.add(
        value
    );

    rootNode.value = newChildren;
    return rootNode;
  }

  /// Set configuration object - used when converting to String. We use a reference to a single object so that all the nodes in the map can be updated easily, by changes to this one object
  void setConfigurationObject(Node rootNode, NodeConfigurationObject configurationObject) {
    rootNode.setConfigurationObject(configurationObject);
  }

  String returnDtConvertedString(Node rootNode) {
    return rootNode.toString().trim();
  }


  // Helper methods
  // Helper method for buildMap
  Node _createChildNodes(dynamic listJsonValue, dynamic position, Node parent) {
    Node childNode = Node();
    childNode.key = position;
   List<Node> subChildren = List<Node>();
    // Map
    if (listJsonValue is Map) {
      childNode.type = JsonType.Map;
      for (dynamic key in listJsonValue.keys) {
        subChildren.add(_createChildNodes(listJsonValue[key], key, childNode));
      }
      childNode.value = subChildren;
    }
    // List
    else if (listJsonValue is List) {
      childNode.type = JsonType.List;
      for (int position = 0; position < listJsonValue.length; position++) {
        subChildren[position] =
            _createChildNodes(listJsonValue[position], position, childNode);
      }
      childNode.value = subChildren;
    }
    // Value
    else {
      childNode.type = JsonType.Value;
      childNode.value = listJsonValue;
    }
    childNode.parent = parent;
    return childNode;
  }
}
