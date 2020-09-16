import 'dart:io';
import 'package:path/path.dart' as path;
// Using Path library to work with Azure DevOps build pipeline (flutter test from project root directory)
String fixture(String name){
  var currentLocation = path.current;
  if(!(currentLocation.endsWith("test"))){
    currentLocation = path.join(currentLocation, "test");
  }
  var fixtures = path.join(currentLocation, "fixtures");
  var fullPath = path.join(fixtures, name);
  return File(fullPath).readAsStringSync();
}