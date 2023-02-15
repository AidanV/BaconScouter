import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'dart:convert';

class MatchStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/matches.json');
  }

  Future<void> saveMatches(matches) async {
    final file = await _localFile;
    Map<String, dynamic> returnJSON = <String, dynamic>{};
    for (var match in matches) {
      returnJSON.addAll(match.getJSON());
    }
    file.writeAsString(jsonEncode(returnJSON));
  }

  Future<Map<String, dynamic>> readMatches() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      return jsonDecode(contents);
    } catch (e) {
      // If encountering an error, return 0
      return <String, dynamic>{};
    }
  }
}
