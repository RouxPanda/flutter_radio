import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("wala"),
        ),
        body: const MainPage(),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Map<String, dynamic> radio = {};
  List _items = [];
  final assetsAudioPlayer = AssetsAudioPlayer();

  // Fetch content from the json file
  Future<void> readJson() async {
    final String response = await rootBundle.loadString('assets/output.json');
    final data = await json.decode(response);
    setState(() {
      _items = data;
    });
  }

  Widget renderAllTags(data) {
    var text = "";
    for (var i = 0; i < data.length; i++) {
      text += data[i] + ", ";
    }
    return Text(text);
  }

  void nouvelleRadio(data) async {
    try {
      setState(() {
        radio = data;
      });
      await assetsAudioPlayer.open(
        Audio.liveStream(data["url"]),
      );
      print("MUSIQUE");
    } catch (t) {
      //mp3 unreachable
    }
  }

  @override
  void initState() {
    super.initState();
    readJson();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 100,
          decoration: const BoxDecoration(color: Colors.green),
          child: radio.isNotEmpty
              ? Center(
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(radio["name"]),
                      subtitle: renderAllTags(radio["tags"]),
                      trailing: Image(
                        image: AssetImage(
                            "assets/img/FRA_20200331/" + radio["img"]),
                      ),
                    ),
                  ),
                )
              : Container(),
        ),
        Container(
          height: 200,
          decoration: const BoxDecoration(color: Colors.red),
        ),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(color: Colors.white),
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  // Display the data loaded from sample.json
                  _items.isNotEmpty
                      ? Expanded(
                          child: ListView.builder(
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              return Card(
                                margin: const EdgeInsets.all(10),
                                child: ListTile(
                                  onTap: () {
                                    nouvelleRadio(_items[index]);
                                  },
                                  title: Text(_items[index]["name"]),
                                  subtitle:
                                      renderAllTags(_items[index]["tags"]),
                                  trailing: Image(
                                    image: AssetImage(
                                        "assets/img/FRA_20200331/" +
                                            _items[index]["img"]),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : Container()
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
