import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:filter_list/filter_list.dart';

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
        primarySwatch: Colors.deepPurple,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Radio"),
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
  List _itemsSelected = [];
  final player = AudioPlayer();
  List<String> _tags = [];
  List<String>? selectedCountList = [];

  // Fetch content from the json file
  Future<void> readJson() async {
    final String response = await rootBundle.loadString('assets/output.json');
    final data = await json.decode(response);
    setState(() {
      _items = data;
      _itemsSelected = data;
    });
    getAllTags(data);
  }

  void getAllTags(data) {
    for (var i = 0; i < data.length; i++) {
      for (var j = 0; j < data[i]["tags"].length; j++) {
        _tags.add(data[i]["tags"][j]);
      }
    }
    _tags = _tags.toSet().toList();
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
      // Unload audio and release decoders until needed again.
      await player.stop();
      await player.setUrl(data["url"]);
      // Acquire platform decoders and start loading audio.
      var duration = await player.load();
      player.play();
      setState(() {
        radio = data;
      });
    } catch (t) {
      //mp3 unreachable
    }
  }

  void _openFilterDialog() async {
    await FilterListDialog.display<String>(context,
        listData: _tags,
        selectedListData: selectedCountList,
        height: 480,
        headlineText: "Select Count",
        searchFieldHintText: "Search Here", choiceChipLabel: (item) {
      return item;
    }, validateSelectedItem: (list, val) {
      return list!.contains(val);
    }, onItemSearch: (list, text) {
      if (list!.any(
          (element) => element.toLowerCase().contains(text.toLowerCase()))) {
        return list
            .where(
                (element) => element.toLowerCase().contains(text.toLowerCase()))
            .toList();
      } else {
        return [];
      }
    }, onApplyButtonClick: (list) {
      if (list != null) {
        setState(() {
          selectedCountList = List.from(list);
          _itemsSelected =
              _items.where((i) => list.any(i["tags"].contains)).toList();
        });
        print(selectedCountList);
      }
      Navigator.pop(context);
    });
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
          decoration: const BoxDecoration(color: Colors.white),
          child: radio.isNotEmpty
              ? Center(
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                        title: Text(radio["name"]),
                        subtitle: renderAllTags(radio["tags"]),
                        trailing: SizedBox(
                          width: 120,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      player.playing
                                          ? player.stop()
                                          : player.play();
                                    });
                                  },
                                  icon: Icon(player.playing
                                      ? Icons.pause
                                      : Icons.play_arrow)),
                              Image(
                                image: AssetImage(
                                    "assets/img/FRA_20200331/" + radio["img"]),
                              )
                            ],
                          ),
                        )),
                  ),
                )
              : Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text("Aucune radio en lecture"),
                    trailing: IconButton(
                        onPressed: () {}, icon: Icon(Icons.play_arrow)),
                  ),
                ),
        ),
        Center(
          child: Container(
            height: 100,
            width: 400,
            decoration: const BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _openFilterDialog,
                ),
                selectedCountList!.isNotEmpty
                    ? Container(
                        width: 330,
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                  children: selectedCountList!.map((item) {
                                return Container(
                                    margin: EdgeInsets.all(5),
                                    child: Text(item));
                              }).toList()),
                            )),
                      )
                    : Container()
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(color: Colors.white),
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  // Display the data loaded from sample.json
                  _itemsSelected.isNotEmpty
                      ? Expanded(
                          child: ListView.builder(
                            itemCount: _itemsSelected.length,
                            itemBuilder: (context, index) {
                              return Card(
                                margin: const EdgeInsets.all(10),
                                child: ListTile(
                                  onTap: () {
                                    nouvelleRadio(_itemsSelected[index]);
                                  },
                                  title: Text(_itemsSelected[index]["name"]),
                                  subtitle: renderAllTags(
                                      _itemsSelected[index]["tags"]),
                                  trailing: Image(
                                    image: AssetImage(
                                        "assets/img/FRA_20200331/" +
                                            _itemsSelected[index]["img"]),
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
