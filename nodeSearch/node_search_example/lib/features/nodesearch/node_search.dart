import 'dart:convert';

import 'package:node_search_example/features/nodesearch/date_time_converter.dart';
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
    if (type == JsonType.List) {
      dynamic valueOfNode = value.values;
      String encodedNode = valueOfNode.toString();
      // toString encodes the values in brackets. We need to remove them.
      String cleanedEncodedNode = encodedNode.substring(1, encodedNode.length - 1);
      // and replace the round brackets with []
      if (key is String) {
        var encodedNodeAsList =  [
          cleanedEncodedNode
        ];
        return "\"$key\": $encodedNodeAsList".trim();
      }
      var encodedNodeAsList =   [
        cleanedEncodedNode
      ];
      return encodedNodeAsList.toString().trim();
    } else if (type == JsonType.Value) {
      // Only string values need to be quoted
      if (value is String) {
        String valueCopy = value; //to prevent multiple conversions of the same string
        // check if DT and convert
        if (isDateTime(valueCopy)) {
          valueCopy = DateTimeConverter.convertToCleanString(value, configurationObject.directionOfTranslation);
        }
        return "\"$key\":\"$valueCopy\"";
      } else {
        return "\"$key\":$value";
      }
    } else if (type == JsonType.Map){
      // value is an InternalLinkedHashMap, so calling a straight { key: value }.toString() will also encode the keys in the json
      // so first we need to strip the keys out
      dynamic initialObjectRepresentation = value.values.map((e) => e.toString()).toString();
      String initialStringRepresentation = initialObjectRepresentation.toString();
      // toString encodes the values in brackets. We need to remove them.
      String cleanedString = initialStringRepresentation.substring(1, initialStringRepresentation.length);
      cleanedString = cleanedString.substring(0, cleanedString.length -1 );
      // and replace the round brackets with {}
      String check = "{$cleanedString}";
      // if key is an integer, this map is a value in an array.
      // we should only return json in key:value format if the key is a string
      if (key is String) {
        var a =   "\"$key\": $check";
        return a;
      } else {
        return check;
      }
    }
    return "";
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

class NodeSearch {
  /// Build a map of nodes given a JSON string
  Node buildMap(String jsonData) {
    dynamic jsonValue = json.decode(jsonData);
    Map<dynamic, Node> newChildren = Map<dynamic, Node>();

    RootNode rootNode = RootNode();
    rootNode.key = 0;
    if (jsonValue is List) {
      rootNode.type = JsonType.List;
      for (int position = 0; position < jsonValue.length; position++) {
        newChildren[position] =
            _createChildNodes(jsonValue[position], position, rootNode);
      }
    }

    if (jsonValue is Map) {
      rootNode.type = JsonType.Map;
      Map valueMap = jsonValue;
      for (dynamic key in valueMap.keys) {
        newChildren[key] = _createChildNodes(jsonValue[key], key, rootNode);
      }
    }

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
    Map<dynamic, Node> subChildren = Map<dynamic, Node>();
    // Map
    if (listJsonValue is Map) {
      childNode.type = JsonType.Map;
      for (dynamic key in listJsonValue.keys) {
        subChildren[key] =
            _createChildNodes(listJsonValue[key], key, childNode);
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
