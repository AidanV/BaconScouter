import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'dart:convert';

class MatchStorage {
  MatchStorage._();
  static final MatchStorage _matchStorage = MatchStorage._();

  factory MatchStorage() {
    return _matchStorage;
  }

  Future<String> get _localPath async {
    var directoryPath = (await getApplicationDocumentsDirectory()).path;
    var directory =
        await Directory('$directoryPath/matches').create(recursive: true);
    return directory.path;
  }

  Future<File> localFile(String matchName) async {
    final path = await _localPath;
    return File('$path/$matchName.json');
  }

  void writeMatch(Map<String, String> matchJson, String matchName) async {
    final file = await localFile(matchName);
    file.writeAsString(jsonEncode(matchJson));
  }

  Future<Map<String, dynamic>> readMatch(String matchName) async {
    final file = await localFile(matchName);
    final contents = await file.readAsString();
    return jsonDecode(contents);
  }

  Future<List<MatchData>> readMatches() async {
    List<Map<String, dynamic>> matchList = <Map<String, dynamic>>[];
    try {
      var path = await _localPath;
      Directory directory = Directory(path);
      final matches = directory.listSync().whereType<File>();

      for (var match in matches) {
        var file = File(match.path);
        final contents = await file.readAsString();

        matchList.add(MatchData(jsonDecode(contents)));
      }
    } catch (e) {
      return List.empty();
    }
    return matchList;
  }

  Future<List<Map<String, String>>> readMatchesString() async {
    List<Map<String, dynamic>> JSONList = <Map<String, dynamic>>[];
    try {
      var path = await _localPath;
      Directory directory = Directory(path);
      final matches = directory.listSync().whereType<File>();

      for (var match in matches) {
        print("match: " + match.path);
        var file = File(match.path);
        final contents = await file.readAsString();

        JSONList.add(jsonDecode(contents));
      }
    } catch (e) {
      // If encountering an error, return 0
      return List.empty();
    }
    List<Map<String, String>> retVal = List.filled(JSONList.length, {});
    int counter = 0;
    print("json list: " + JSONList.toString());
    for (var jsonVal in JSONList) {
      jsonVal
          .forEach((key, value) => retVal[counter][key] = (value?.toString())!);

      counter++;
    }
    return retVal;
  }

  Future<void> deleteMatches() async {
    var path = await _localPath;
    Directory directory = Directory(path);
    final matches = directory.listSync().whereType<File>();
    for (var match in matches) {
      match.delete();
    }
  }

  Future<void> deleteMatch(String matchName) async {
    final file = await localFile(matchName);
    file.delete();
  }
}
