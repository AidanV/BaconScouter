class MatchData {
  int matchNumber = -1;
  int teamNumber = -1;
  bool isRedAlliance = false;
  late String matchTitle;

  List<int> grid = List.generate(27, (index) => 0, growable: false);

  String getMatchTitle() {
    if (teamNumber == -1 || matchNumber == -1) {
      matchTitle = "Enter Match Data";
    } else {
      matchTitle = "Match: $matchNumber \t Team: $teamNumber";
    }
    return matchTitle;
  }
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
