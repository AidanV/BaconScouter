import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'match_data.dart';

import 'match_file_system.dart';

import 'dart:async';

MatchStorage matchStorage = MatchStorage();

List<MatchData> matches = <MatchData>[];

String scouter = "";
String meet = "ORL";

void main() async {
  matches += await MatchStorage().readMatches('r1');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: '2023 Bacon Scouter',
        theme: ThemeData(
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.

            // primaryColor: const Color(0xFF558B6E),
            // splashColor: const Color(0xFFFB6107),
            colorScheme: const ColorScheme(
                brightness: Brightness.dark,
                primary: Color(0xFF558B6E),
                onPrimary: Color.fromARGB(255, 35, 48, 37),
                secondary: Color.fromARGB(255, 251, 96, 7),
                onSecondary: Color(0xFFFEEFDD),
                error: Color(0xFFDD0000),
                onError: Color(0xFFFF0000),
                background: Color(0xFF30362F),
                onBackground: Color.fromARGB(221, 14, 16, 14),
                surface: Color(0xFFEEEBD3),
                onSurface: Color.fromARGB(255, 60, 60, 55))),
        home: const DefaultTabController(
          length: 2,
          child: MyHomePage(title: 'Scouter 2023'),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? eventID;

  String currentRobot = "";

  String get tabletName {
    if (currentRobot == "") return "";
    return (currentRobot[0] == 'r')
        ? "Red ${currentRobot[1]}"
        : "Blue ${currentRobot[1]}";
  }

  void _setRobot(robot) {
    setState(() {
      currentRobot = robot;
    });
  }

  void _setChargingAuto(val) {
    setState(() {
      matches[currentMatchIndex].isScored = true;
      matches[currentMatchIndex].chargingAuto = val;
      matches[currentMatchIndex].writeMatch();
    });
  }

  void _setChargingTele(val) {
    setState(() {
      matches[currentMatchIndex].isScored = true;
      matches[currentMatchIndex].chargingTele = val;
      matches[currentMatchIndex].writeMatch();
    });
  }

  void _setDefenseScore(val) {
    setState(() {
      matches[currentMatchIndex].isScored = true;
      matches[currentMatchIndex].defenseScore = val;
      matches[currentMatchIndex].writeMatch();
    });
  }

  void _setComment(val) {
    setState(() {
      matches[currentMatchIndex].isScored = true;
      matches[currentMatchIndex].comment = val;
      matches[currentMatchIndex].writeMatch();
    });
  }

  void _setFeeder(val) {
    setState(() {
      matches[currentMatchIndex].isScored = true;
      matches[currentMatchIndex].feeder = val;
      matches[currentMatchIndex].writeMatch();
    });
  }

  void _setIsScored(index, val) {
    setState(() {
      matches[index].isScored = val;
      matches[index].writeMatch();
    });
  }

  void _addToDroppedGamePieces(int increment) {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      int changed = matches[currentMatchIndex].droppedGP + increment;
      if (changed >= 0) {
        matches[currentMatchIndex].droppedGP = changed;
      }
      matches[currentMatchIndex].writeMatch();
    });
  }

  void _allianceBoolean(val) {
    setState(() {
      if (matches.isNotEmpty) {
        //might need async await
        matches[currentMatchIndex].isRedAlliance = val;
        matches[currentMatchIndex].writeMatch();
      }
    });
  }

  void _editMatchNumber(val) {
    setState(() {
      if (matches.isNotEmpty) {
        matches[currentMatchIndex].deleteMatch();
        matches[currentMatchIndex].matchNumber = int.parse(val);
        matches[currentMatchIndex].writeMatch();
      }
    });
  }

  void _editTeamNumber(val) {
    setState(() {
      if (matches.isNotEmpty) {
        matches[currentMatchIndex].deleteMatch();
        matches[currentMatchIndex].teamNumber = int.parse(val);
        matches[currentMatchIndex].writeMatch();
      }
    });
  }

  void _changeCurrentMatch(val) {
    setState(() {
      currentMatchIndex = val;
    });
  }

  void _addMatch(MatchData match) {
    setState(() {
      matches.add(match);
    });
  }

  void _setMatches(List<MatchData> inputMatches) {
    for (var match in matches) {
      match.writeMatch();
    }
    setState(() {
      inputMatches.sort(
        (a, b) {
          return a.matchNumber.compareTo(b.matchNumber);
        },
      );
      matches = inputMatches;
    });
  }

  void _incrementNode(int index, bool isAuto) {
    setState(() {
      if (matches.isNotEmpty) {
        matches[currentMatchIndex].isScored = true;
        matches[currentMatchIndex].grid[index].state++;
        matches[currentMatchIndex].grid[index].state %=
            possibleNodeOptions[index].length;
        matches[currentMatchIndex].grid[index].isAuto = isAuto;
        matches[currentMatchIndex].writeMatch();
      }
    });
  }

  void _deleteMatches() {
    setState(() {
      matches.clear();
    });
  }

  void _deleteMatch(index) {
    setState(() {
      if (matches.isNotEmpty) {
        matches[index].deleteMatch();
        matches.removeAt(index);
        if (currentMatchIndex >= matches.length || currentMatchIndex == index) {
          currentMatchIndex = matches.length - 1;
        }
      }
    });
  }

  Widget getImageByNodeOption(NodeOptions nodeOption) {
    switch (nodeOption) {
      case NodeOptions.empty:
        return const SizedBox(
          width: 64,
          height: 64,
        );
      case NodeOptions.cone:
        return Image.asset("assets/images/cone.png");
      case NodeOptions.cube:
        return Image.asset("assets/images/cube.png");
    }
  }

  int currentMatchIndex = 0;

  void deleteAlert() {
    var alert = AlertDialog(
      title: const Text("You sure??"),
      actions: [
        FloatingActionButton(
            child: const Icon(Icons.delete_forever_outlined),
            onPressed: () {
              MatchStorage().deleteMatches();
              Navigator.of(context).pop();
              _deleteMatches();
            })
      ],
    );

    showDialog(
        context: context,
        builder: (context) {
          return alert;
        });
  }

  void successAlert() {
    var alert = AlertDialog(
      title: const Text("Success!"),
      actions: [
        FloatingActionButton(
            child: const Icon(Icons.check),
            onPressed: () {
              Navigator.of(context).pop();
            })
      ],
    );

    showDialog(
        context: context,
        builder: (context) {
          return alert;
        });
  }

  void configureMatches() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: TextFormField(
                  initialValue: eventID,
                  onChanged: (event) {
                    eventID = event;
                  },
                  decoration: const InputDecoration(
                    hintText: "Event ID",
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Center(
                child: FloatingActionButton.extended(
                    //2023isde1
                    onPressed: () async {
                      if (eventID != null) {
                        var request = http.Request(
                            'GET',
                            Uri.parse(
                                'https://www.thebluealliance.com/api/v3/event/$eventID/matches/simple?X-TBA-Auth-Key=Zt9ZHOjjhhakPxAoXWLX1grZg5IRWUkHVfCsMNQMsI8SnHBAyQcaiMiHIJDNnzaJ'));

                        http.StreamedResponse response = await request.send();

                        if (response.statusCode == 200) {
                          var json =
                              jsonDecode(await response.stream.bytesToString());
                          int matchNumber = 1;
                          for (var match in json) {
                            for (var i = 0; i < 3; i++) {
                              MatchData.fromMatchNumberTeamNumberAllianceRobot(
                                      matchNumber,
                                      int.parse(match['alliances']['blue']
                                              ['team_keys'][i]
                                          .toString()
                                          .substring(3)),
                                      false,
                                      'b${i + 1}')
                                  .writeMatch();
                              MatchData.fromMatchNumberTeamNumberAllianceRobot(
                                      matchNumber,
                                      int.parse(match['alliances']['red']
                                              ['team_keys'][i]
                                          .toString()
                                          .substring(3)),
                                      true,
                                      'r${i + 1}')
                                  .writeMatch();
                            }
                            matchNumber++;
                          }
                          print(await response.stream.bytesToString());
                        } else {
                          print(response.reasonPhrase);
                        }
                      }
                    },
                    label: const Text("Download matches")),
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(30.0),
                child: DropdownButton(
                    items: [
                      "red 1",
                      "red 2",
                      "red 3",
                      "blue 1",
                      "blue 2",
                      "blue 3"
                    ].map<DropdownMenuItem<String>>((String val) {
                      return DropdownMenuItem<String>(
                          value: val, child: Text(val));
                    }).toList(),
                    onChanged: (val) async {
                      _setRobot(val![0] + val[val.length - 1]);
                      _setMatches(
                          await MatchStorage().readMatches(currentRobot));
                    }))
          ],
        );
      },
    );
  }

  void settingsMenu() {
    showDialog(
        context: context,
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                  (context as Element).markNeedsBuild();
                },
              ),
            ),
            body: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 500,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          filled: true,
                          icon: Icon(Icons.person),
                          hintText: "Wilbur",
                          labelText: "Scouter Name",
                        ),
                        onChanged: (value) {
                          scouter = value;
                          (context as Element).markNeedsBuild();
                        },
                        initialValue: scouter,
                      ),
                    ),
                    DropdownButton(
                        hint: const Text("Meet"),
                        items: ["SOUTH", "ORL", "TALLY", "WORLDS"]
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        value: meet,
                        onChanged: (val) {
                          meet = val!;
                          (context as Element).markNeedsBuild();
                        }),
                    FloatingActionButton.extended(
                        onPressed: () async {
                          // matchStorage.deleteMatches();
                          // var jsonMatches = await matchStorage.readMatchesString();
                          // NOW ASSUME THAT MATCHES PERFECTLY REPRESENT WHAT IS STORED ON DEVICE
                          var success = true;
                          for (var match in matches) {
                            if (!match.isScored) continue;
                            var request = http.MultipartRequest(
                                'POST',
                                Uri.parse(
                                    'https://script.google.com/macros/s/AKfycbxgImMU5KsvszMAMOaZ5VYsl0u630yrwg3gCCrAhJ8ZdBYqCUXkpVOlZLOqd5kdOMI/exec?action=storeScouting'));

                            request.fields.addAll({
                              'meet': meet,
                              'scouter': scouter,
                            });
                            request.fields.addAll(match.getPostJson());

                            http.StreamedResponse response =
                                await request.send();

                            if (!(response.statusCode == 200 ||
                                response.statusCode == 302)) {
                              success = false;
                            }
                          }
                          if (success) {
                            successAlert();
                          }
                        },
                        icon: const Icon(Icons.upload),
                        label: const Text("Upload")),
                  ]),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                deleteAlert();
              },
              child: const Icon(Icons.delete_forever),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
        appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.

            title: Text((matches.isEmpty)
                ? "Download Matches!"
                : '${matches[currentMatchIndex].getMatchTitle()}      Scouting Tablet: $tabletName'),
            actions: [
              ElevatedButton.icon(
                  onPressed: () {
                    settingsMenu();
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => const SettingsRoute(),
                    //     ));
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text("Settings"))
            ],
            bottom: TabBar(
              labelColor: Theme.of(context).colorScheme.background,
              indicatorColor: Colors.black,
              indicatorWeight: 5,
              tabs: const [
                Tab(child: Text("Auto")),
                Tab(child: Text("Tele")),
              ],
            )
            // leading: IconButton(
            //   color: Theme.of(context).colorScheme.secondary,
            //   icon: const Icon(Icons.menu),
            //   onPressed: () => {},
            // ),
            ),
        drawer: Drawer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: (matches.isEmpty)
                    ? const Center(child: Text("Download Matches"))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: matches.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            leading: IconButton(
                              icon: Icon((matches[index].isScored)
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank),
                              onPressed: () {
                                _setIsScored(index, !matches[index].isScored);
                              },
                            ),
                            trailing: Icon(Icons.handshake,
                                color: (matches[index].isRedAlliance)
                                    ? const Color.fromARGB(255, 255, 0, 0)
                                    : const Color.fromRGBO(0, 0, 255, 1)),
                            title: Text(matches[index].getMatchTitle()),
                            onTap: () {
                              _changeCurrentMatch(index);
                              Navigator.pop(context);
                            },
                          );
                        }),
              ),
              FloatingActionButton.extended(
                onPressed: () {
                  configureMatches();
                },
                icon: const Icon(Icons.edit),
                label: const Text("Configure Matches"),
              )
            ],
          ),
        ),
        body: (matches.isEmpty)
            ? Center(child: Image.asset("assets/images/PigNoBg.png"))
            : (currentRobot == "")
                ? Center(
                    child: FloatingActionButton.extended(
                    onPressed: () {
                      configureMatches();
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Configure Matches"),
                  ))
                : TabBarView(children: [
                    Column(children: [
                      SizedBox(
                          width: double.infinity,
                          height: 300,
                          child: GridView.builder(
                            itemCount: 27, //_items.length,
                            padding: const EdgeInsets.all(1.0),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 9,
                              childAspectRatio: 1.33,
                              mainAxisSpacing: 5.0,
                              crossAxisSpacing: 5.0,
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                alignment: Alignment.center,
                                // tileColor: _items[index].isOdd ? oddItemColor : evenItemColor,
                                // decoration: BoxDecoration(
                                //   borderRadius: BorderRadius.circular(20.0),
                                // ),
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            ((index % 9) >= 3 &&
                                                    (index % 9) <= 5
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .surface
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .secondary)),
                                  ),
                                  child:
                                      //"assets/images/cone.png"
                                      getImageByNodeOption(
                                          (matches[currentMatchIndex]
                                                  .grid[index]
                                                  .isAuto)
                                              ? (possibleNodeOptions[index][
                                                  matches[currentMatchIndex]
                                                      .grid[index]
                                                      .state])
                                              : (NodeOptions.empty)),
                                  onPressed: () {
                                    _incrementNode(index, true);
                                  },
                                ),
                              );
                            },
                          )),
                      Expanded(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: DropdownButton(
                              items: [
                                "Attempted",
                                "Not Attempted",
                                "Other Team Attempted",
                                "Balanced",
                                "Docked"
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              value: matches[currentMatchIndex].chargingAuto,
                              onChanged: (val) {
                                _setChargingAuto(val);
                              },
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                children: [
                                  const Text("Exited Community",
                                      style: TextStyle(fontSize: 20)),
                                  Switch(
                                      onChanged: (val) {
                                        _setFeeder(val);
                                      },
                                      value: matches[currentMatchIndex].feeder),
                                ],
                              )),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Text("Dropped Game Pieces",
                                      style: TextStyle(fontSize: 20)),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      _addToDroppedGamePieces(1);
                                    },
                                  ),
                                  Text(
                                    "${matches[currentMatchIndex].droppedGP}",
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      _addToDroppedGamePieces(-1);
                                    },
                                  ),
                                ]),
                          )
                        ],
                      ))
                    ]),
                    Column(children: [
                      SizedBox(
                        width: double.infinity,
                        height: 320,
                        child: GridView.builder(
                          itemCount: 27, //_items.length,
                          padding: const EdgeInsets.all(1.0),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 9,
                            childAspectRatio: 1.33,
                            mainAxisSpacing: 5.0,
                            crossAxisSpacing: 5.0,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              alignment: Alignment.center,
                              // tileColor: _items[index].isOdd ? oddItemColor : evenItemColor,
                              // decoration: BoxDecoration(
                              //   borderRadius: BorderRadius.circular(20.0),
                              // ),
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          ((index % 9) >= 3 && (index % 9) <= 5
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .surface
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .primary)),
                                ),
                                child: getImageByNodeOption(
                                    possibleNodeOptions[index][
                                        matches[currentMatchIndex]
                                            .grid[index]
                                            .state]),
                                onPressed: () {
                                  if (!matches[currentMatchIndex]
                                          .grid[index]
                                          .isAuto ||
                                      matches[currentMatchIndex]
                                              .grid[index]
                                              .state ==
                                          0) {
                                    _incrementNode(index, false);
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: DropdownButton(
                              items: [
                                "Attempted",
                                "Not Attempted",
                                "Balanced",
                                "Docked"
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              value: matches[currentMatchIndex].chargingTele,
                              onChanged: (val) {
                                _setChargingTele(val);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Text("Dropped Game Pieces",
                                      style: TextStyle(fontSize: 20)),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      _addToDroppedGamePieces(1);
                                    },
                                  ),
                                  Text(
                                    "${matches[currentMatchIndex].droppedGP}",
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      _addToDroppedGamePieces(-1);
                                    },
                                  ),
                                ]),
                          ),
                          Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Slider(
                                label: "Defense",
                                value: matches[currentMatchIndex].defenseScore,
                                onChanged: (value) {
                                  _setDefenseScore(value);
                                },
                                min: 0.0,
                                max: 10.0,
                                divisions: 10,
                              )),
                          Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SizedBox(
                                width: 300,
                                height: 200,
                                child: TextFormField(
                                  initialValue:
                                      matches[currentMatchIndex].comment,
                                  onChanged: (value) {
                                    _setComment(value);
                                  },
                                  maxLines: 6,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Comments',
                                  ),
                                ),
                              ))
                        ],
                      ))
                    ]),
                  ]));
  }
}

// class SettingsRoute extends StatelessWidget {
//   const SettingsRoute({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.close),
//           onPressed: () {
//             Navigator.pop(context);
//             (context as Element).markNeedsBuild();
//           },
//         ),
//       ),
//       body: Center(
//         child:
//             Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
//           SizedBox(
//             width: 500,
//             child: TextFormField(
//               decoration: const InputDecoration(
//                 filled: true,
//                 icon: Icon(Icons.person),
//                 hintText: "Wilbur",
//                 labelText: "Scouter Name",
//               ),
//               onChanged: (value) {
//                 scouter = value;
//                 (context as Element).markNeedsBuild();
//               },
//               initialValue: scouter,
//             ),
//           ),
//           DropdownButton(
//               hint: const Text("Meet"),
//               items: ["ORL", "TALLY", "WORLDS"]
//                   .map<DropdownMenuItem<String>>((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//               value: meet,
//               onChanged: (val) {
//                 meet = val!;
//                 (context as Element).markNeedsBuild();
//               }),
//           FloatingActionButton.extended(
//               onPressed: () async {
//                 // matchStorage.deleteMatches();
//                 // var jsonMatches = await matchStorage.readMatchesString();
//                 // NOW ASSUME THAT MATCHES PERFECTLY REPRESENT WHAT IS STORED ON DEVICE
//                 var success = true;
//                 for (var match in matches) {
//                   var request = http.MultipartRequest(
//                       'POST',
//                       Uri.parse(
//                           'https://script.google.com/macros/s/AKfycbxgImMU5KsvszMAMOaZ5VYsl0u630yrwg3gCCrAhJ8ZdBYqCUXkpVOlZLOqd5kdOMI/exec?action=storeScouting'));

//                   request.fields.addAll({
//                     'meet': meet,
//                     'scouter': scouter,
//                   });
//                   request.fields.addAll(match.getPostJson());

//                   http.StreamedResponse response = await request.send();

//                   if (!(response.statusCode == 200 ||
//                       response.statusCode == 302)) {
//                     success = false;

//                     // print(await response.stream.bytesToString());
//                   }
//                   // print(response.reasonPhrase);
//                 }
//                 if (success) {
//                   SuccessAlertMethod(context);
//                 }
//               },
//               icon: const Icon(Icons.upload),
//               label: const Text("Upload")),
//         ]),
//       ),
//     );
//   }
// }
// void deleteAlert(BuildContext context) {
//   var alert = AlertDialog(
//     title: const Text("You sure??"),
//     actions: [
//       FloatingActionButton(
//           child: const Icon(Icons.delete_forever_outlined),
//           onPressed: () {
//             MatchStorage().deleteMatches();
//             Navigator.of(context).pop();
//             matches.clear();
//             (context as Element).markNeedsBuild();
//           })
//     ],
//   );

//   showDialog(
//       context: context,
//       builder: (context) {
//         return alert;
//       });
// }


