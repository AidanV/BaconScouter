import 'dart:ffi';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'dart:convert';

import 'match_data.dart';

class MatchStorage {
  MatchStorage._();
  static final MatchStorage _matchStorage = MatchStorage._();

  factory MatchStorage() {
    return _matchStorage;
  }

  Future<String> localPath(String robot) async {
    var directoryPath = (await getApplicationDocumentsDirectory()).path;
    var directory = await Directory('$directoryPath/matches/$robot')
        .create(recursive: true);
    return directory.path;
  }

  Future<File> localFile(String robot, String matchName) async {
    final path = await localPath(robot);
    return File('$path/$matchName.json');
  }

  // void writeMatch(Map<String, String> matchJson, String matchName) async {
  //   final file = await localFile(matchName);
  //   file.writeAsString(jsonEncode(matchJson));
  //   // print(await file.readAsString());
  // }

  void writeMatch(MatchData matchData) async {
    final file = await localFile(matchData.robot, matchData.matchFileName);
    file.writeAsString(jsonEncode(matchData.getMatchJson()));
  }

  Future<Map<String, dynamic>> readMatch(MatchData matchData) async {
    final file = await localFile(matchData.robot, matchData.matchFileName);
    final contents = await file.readAsString();
    return jsonDecode(contents);
  }

  Future<List<MatchData>> readMatches(String robot) async {
    // print("in read matches");
    // print(robot);
    List<MatchData> matchList = <MatchData>[];
    try {
      var path = await localPath(robot);
      Directory directory = Directory(path);
      final matches = directory.listSync().whereType<File>();

      // print("found matches");
      // print(matches);
      for (var match in matches) {
        // print(match);
        var file = File(match.path);
        final contents = await file.readAsString();
        // print(contents);
        var stringed = jsonDecode(contents);
        // print(stringed);
        matchList.add(MatchData.fromJSON(stringed));
        // print("match list" + matchList.toString());
      }
      // print("made it through read matches");
    } catch (e) {
      return List.empty();
    }
    return matchList;
  }

  // Future<List<Map<String, String>>> readMatchesString() async {
  //   List<Map<String, dynamic>> jsonList = <Map<String, dynamic>>[];
  //   try {
  //     var path = await localPath();
  //     Directory directory = Directory(path);
  //     final matches = directory.listSync().whereType<File>();

  //     for (var match in matches) {
  //       // print("match: " + match.path);
  //       var file = File(match.path);
  //       final contents = await file.readAsString();

  //       jsonList.add(jsonDecode(contents));
  //     }
  //   } catch (e) {
  //     // If encountering an error, return 0
  //     return List.empty();
  //   }
  //   List<Map<String, String>> retVal = List.filled(jsonList.length, {});
  //   int counter = 0;
  //   // print("json list: " + jsonList.toString());
  //   for (var jsonVal in jsonList) {
  //     jsonVal
  //         .forEach((key, value) => retVal[counter][key] = (value?.toString())!);

  //     counter++;
  //   }
  //   return retVal;
  // }

  Future<void> deleteMatches() async {
    List<String> colors = ['r', 'b'];
    for (var color in colors) {
      for (var i = 1; i < 4; i++) {
        var path = await localPath("$color$i");
        Directory directory = Directory(path);
        final matches = directory.listSync().whereType<File>();
        for (var match in matches) {
          match.delete();
        }
      }
    }
  }

  Future<void> deleteMatch(MatchData matchData) async {
    try {
      final file = await localFile(matchData.robot, matchData.matchFileName);
      if (file.existsSync()) {
        file.delete();
      }
    } catch (e) {
      return;
    }
  }
}
