import 'dart:convert';

// Representing how we want the DT stamps to look. One map of nodes would have a reference to one config object
// all the nodes would use the same config object to e.g. choose which DT stamp to return (local or UTC)
class NodeConfigurationObject {
  TranslationDirection directionOfTranslation = TranslationDirection.NotSpecified;
}

// Representing which way DT stamp conversion works
enum TranslationDirection { NotSpecified, UtcToLocal, LocalToUtc }


abstract class NodeRoot {
  NodeConfigurationObject config;
  String toString();
  dynamic getNodes();
}

abstract class CollectionNode extends NodeRoot {}

class ListNode extends CollectionNode {
  List<NodeRoot> nodes = List<NodeRoot>();

  @override
  getNodes() {
   return nodes;
  }

  bool add(NodeRoot node) {
    nodes.add(node);
    return true;
  }

  @override
  String toString() {
    StringBuffer buffer = StringBuffer();
    buffer.write("[");
    for (int pos = 0; pos < nodes.length; pos ++) {
      buffer.write(nodes[pos]);
      if ( (nodes.length > 1 ) && (pos < (nodes.length - 1) ) )  {
        buffer.write(",");
      }
    }
    buffer.write("]");
    return buffer.toString();
  }
}
class MapNode extends CollectionNode {
  Map<String, NodeRoot> nodes = Map<String, NodeRoot>();

  @override
  getNodes() {
    return nodes;
  }

  bool add(String key, NodeRoot node) {
    nodes[key] = node;
    return true;
  }

  @override
  String toString() {
    StringBuffer buffer = StringBuffer();
    buffer.write("{");
    nodes.forEach((key, valueNode) {
      buffer = writeNodeToBuffer(valueNode, buffer, key);
    });
    String stringWithComma = buffer.toString();
    buffer = StringBuffer(stringWithComma.substring(0, stringWithComma.length - 1));
    buffer.write("}");
    return buffer.toString();
  }

  StringBuffer writeNodeToBuffer(NodeRoot valueNode, StringBuffer buffer, String key) {
    dynamic valueToWrite = "";
    dynamic value = valueNode.getNodes();
    if (value is String) {
      valueToWrite = "\"$value\"";
      buffer.write("\"$key\": $valueToWrite,");
    } else {
     if (value is Map) {
       /** for (dynamic key in value.keys) {
          NodeRoot node = value[key];
          String valueString = node.toString();
          buffer.write("\"$key\": ${node.toString()},");
         // buffer = writeNodeToBuffer(node, buffer, key);
        }**/
        //String stringWithComma = buffer.toString();
        //buffer = StringBuffer(stringWithComma.substring(0, stringWithComma.length - 2));
       StringBuffer _internalBuffer = StringBuffer();
       for (dynamic key in value.keys) {
         _internalBuffer.write("\"$key\": ${value[key]},");
       }
       String stringWithComma = _internalBuffer.toString();
       _internalBuffer = StringBuffer(stringWithComma.substring(0, stringWithComma.length - 2));
       valueToWrite = _internalBuffer.toString();
       buffer.write("\"$key\":{ $valueToWrite}");
      }
    }
    return buffer;
  }
}
class ValueNode extends NodeRoot {
  dynamic values = dynamic;

  @override
  getNodes() {
    return values;
  }

  bool add(dynamic value) {
    values = value;
    return true;
  }

  @override
  String toString() {
    if (values is String) {
      return "\"$values\"";
    } else {
      return "$values";
    }
  }

}

class NodeSearch {

  NodeRoot buildMapFromString(String jsonValue) {
    return _buildMap(json.decode(jsonValue));
  }

  /// Build a map of nodes given a JSON string
  /// all we need is a list of the nodes, the nodes themselves handle stringifying themselves
  NodeRoot _buildMap(dynamic jsonValue) {
    NodeRoot root;
    if (jsonValue is List) {
      ListNode list = ListNode();
      for (int position = 0; position < jsonValue.length; position++) {
        list.nodes.add(_buildMap(jsonValue[position]));
      }
      root = list;
    } else if (jsonValue is Map) {
      // either a Map node or a Value node
        MapNode mapNode = MapNode();
        for (dynamic key in jsonValue.keys) {
          mapNode.nodes[key] = _buildMap(jsonValue[key]);
        }
        root = mapNode;
    } else { // a Value node
      ValueNode valueNode = ValueNode();
      valueNode.add(jsonValue);
      root = valueNode;
    }
    return root;
  }

  /// Set configuration object - used when converting to String. We use a reference to a single object so that all the nodes in the map can be updated easily, by changes to this one object
  void setConfigurationObject(NodeRoot rootNode, NodeConfigurationObject configurationObject) {
    rootNode.config = configurationObject;
  }

  String returnDtConvertedString(NodeRoot rootNode) {
    return rootNode.toString().trim();
  }

}
