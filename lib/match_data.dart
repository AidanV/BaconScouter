import 'match_file_system.dart';

class MatchData {
  late int matchNumber;
  late int teamNumber;
  late bool isRedAlliance;
  late String matchTitle;
  late String chargingAuto;
  late String chargingTele;
  late double defenseScore;
  late int droppedGP;
  late String comment;
  late bool feeder;

  List<Node> grid = List<Node>.generate(27, (index) => Node(), growable: false);

  MatchData() {
    matchNumber = -1;
    teamNumber = -1;
    isRedAlliance = false;
    chargingAuto = "Not Attempted";
    chargingTele = "Not Attempted";
    defenseScore = 0;
    droppedGP = 0;
    comment = "";
    feeder = false;
  }

  MatchData.fromJSON(Map<String, dynamic> matchJson) {
    // print("inside from JSON constructor");
    setMatchFromJson(matchJson);
  }

  String get matchFileName {
    return '$matchNumber-$teamNumber';
  }

  String getMatchTitle() {
    if (teamNumber == -1 || matchNumber == -1) {
      matchTitle = "Enter Match Data";
    } else {
      matchTitle = "Match: $matchNumber \t Team: $teamNumber";
    }
    return matchTitle;
  }

  String gamePieceInRange(int lower, int upper, bool isAuto, bool isCone) {
    int gp = 0;
    for (var i = lower; i < upper; i++) {
      if (possibleNodeOptions[i][grid[i].state] ==
              ((isCone) ? NodeOptions.cone : NodeOptions.cube) &&
          grid[i].isAuto == isAuto) gp++;
    }
    return gp.toString();
  }

  Map<String, String> getPostJson() {
    return {
      'matchNumber': matchNumber.toString(),
      'teamNumber': teamNumber.toString(),
      'allianceColor': isRedAlliance ? 'RED' : 'BLUE',
      'L3ConesAuto': gamePieceInRange(0, 9, true, true),
      'L2ConesAuto': gamePieceInRange(9, 18, true, true),
      'L1ConesAuto': gamePieceInRange(18, 27, true, true),
      'L3CubesAuto': gamePieceInRange(0, 9, true, false),
      'L2CubesAuto': gamePieceInRange(9, 18, true, false),
      'L1CubesAuto': gamePieceInRange(18, 27, true, false),
      'L3ConesTele': gamePieceInRange(0, 9, false, true),
      'L2ConesTele': gamePieceInRange(9, 18, false, true),
      'L1ConesTele': gamePieceInRange(18, 27, false, true),
      'L3CubesTele': gamePieceInRange(0, 9, false, false),
      'L2CubesTele': gamePieceInRange(9, 18, false, false),
      'L1CubesTele': gamePieceInRange(18, 27, false, false),
      'droppedGP': droppedGP.toString(),
      'defenseScore': (defenseScore.round()).toString(),
      'chargingAuto': chargingAuto,
      'chargingTele': chargingTele,
      'comment': comment,
      'feeder': feeder.toString(),
    };
  }

  Map<String, String> getMatchJson() {
    var gridJson = <String, String>{};
    var index = 0;
    for (var node in grid) {
      var nodeInfo = ((node.isAuto) ? "A" : "T") + node.state.toString();
      gridJson.addAll({'$index': nodeInfo});
      index++;
    }
    var matchInfo = {
      'matchNumber': matchNumber.toString(),
      'teamNumber': teamNumber.toString(),
      'allianceColor': isRedAlliance.toString(),
      'chargingAuto': chargingAuto,
      'chargingTele': chargingTele,
      'comment': comment,
      'defenseScore': defenseScore.toString(),
      'droppedGP': droppedGP.toString(),
      'feeder': feeder.toString(),
    };

    matchInfo.addAll(gridJson);
    return matchInfo;
  }

  void updateFromJson() async {
    // TODO validate this needs to exist
    var matchJson = await MatchStorage().readMatch(matchFileName);
    setMatchFromJson(matchJson);
  }

  void setMatchFromJson(Map<String, dynamic> matchJson) {
    matchNumber = int.parse(matchJson['matchNumber']);
    teamNumber = int.parse(matchJson['teamNumber']);
    isRedAlliance =
        matchJson['allianceColor'].toString() == "true" ? true : false;
    chargingAuto = matchJson['chargingAuto'];
    chargingTele = matchJson['chargingTele'];
    droppedGP = int.parse(matchJson['droppedGP']);
    defenseScore = double.parse(matchJson['defenseScore']);
    feeder = matchJson['feeder'].toString() == "true" ? true : false;
    comment = matchJson['comment'];

    var index = 0;
    for (var node in grid) {
      var nodeString = matchJson['$index'];
      node.isAuto = (nodeString[0] == "A") ? true : false;
      node.state = int.parse(nodeString[1]);
      index++;
    }
    // print("finished set match from json");
  }

  void writeMatch() {
    // print(getMatchJson());
    MatchStorage().writeMatch(getMatchJson(), matchFileName);
  }

  void deleteMatch() async {
    await MatchStorage().deleteMatch(matchFileName);
  }
}

class Node {
  int state = 0;
  bool isAuto = false;
}

enum NodeOptions {
  empty,
  cone,
  cube,
}

final List<List<NodeOptions>> possibleNodeOptions = [
  [NodeOptions.empty, NodeOptions.cone],
  [NodeOptions.empty, NodeOptions.cube],
  [NodeOptions.empty, NodeOptions.cone],
  [NodeOptions.empty, NodeOptions.cone],
  [NodeOptions.empty, NodeOptions.cube],
  [NodeOptions.empty, NodeOptions.cone],
  [NodeOptions.empty, NodeOptions.cone],
  [NodeOptions.empty, NodeOptions.cube],
  [NodeOptions.empty, NodeOptions.cone],
  [NodeOptions.empty, NodeOptions.cone],
  [NodeOptions.empty, NodeOptions.cube],
  [NodeOptions.empty, NodeOptions.cone],
  [NodeOptions.empty, NodeOptions.cone],
  [NodeOptions.empty, NodeOptions.cube],
  [NodeOptions.empty, NodeOptions.cone],
  [NodeOptions.empty, NodeOptions.cone],
  [NodeOptions.empty, NodeOptions.cube],
  [NodeOptions.empty, NodeOptions.cone],
  [NodeOptions.empty, NodeOptions.cone, NodeOptions.cube],
  [NodeOptions.empty, NodeOptions.cone, NodeOptions.cube],
  [NodeOptions.empty, NodeOptions.cone, NodeOptions.cube],
  [NodeOptions.empty, NodeOptions.cone, NodeOptions.cube],
  [NodeOptions.empty, NodeOptions.cone, NodeOptions.cube],
  [NodeOptions.empty, NodeOptions.cone, NodeOptions.cube],
  [NodeOptions.empty, NodeOptions.cone, NodeOptions.cube],
  [NodeOptions.empty, NodeOptions.cone, NodeOptions.cube],
  [NodeOptions.empty, NodeOptions.cone, NodeOptions.cube]
];


//delete match file
//read match files and set matches to that
//