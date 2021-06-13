import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

Future<Subway> fetchSubway() async {
  String url = "http://swopenAPI.seoul.go.kr/api/subway/64434c756f736b3138344b506a486a/json/realtimeStationArrival/0/5/성균관대";
  final response = await http.get(url);
  print(response.body);

  if (response.statusCode == 200) {
    return Subway.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Failed to load subway");
  }

}

class Subway {
  final int rowNum;
  final String subwayId;
  final String trainLineNm;
  final String subwayHeading;
  final String arvlMsg2;

  Subway({@required this.rowNum, @required this.subwayId, @required this.trainLineNm, @required this.subwayHeading, @required this.arvlMsg2});

  factory Subway.fromJson(Map<String, dynamic> json) {
    return Subway(rowNum: json["realtimeArrivalList"][0]["rowNum"],
        subwayId: json["realtimeArrivalList"][0]["subwayId"],
        trainLineNm: json["realtimeArrivalList"][0]["trainLineNm"],
        subwayHeading: json["realtimeArrivalList"][0]["subwayHeading"],
        arvlMsg2: json["realtimeArrivalList"][0]["arvlMsg2"]);
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
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
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Fetch Data Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<Subway> futureSubway;

  @override
  void initState() {
    super.initState();
    futureSubway = fetchSubway();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("rowNum : "),
                FutureBuilder<Subway>(future: futureSubway,builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text("${snapshot.data.rowNum}");
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }

                  return CircularProgressIndicator();
                })
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("subwayId : "),
                FutureBuilder<Subway>(future: futureSubway,builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text("${snapshot.data.subwayId}");
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }

                  return CircularProgressIndicator();
                })
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("trainLineNm : "),
                FutureBuilder<Subway>(future: futureSubway,builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text("${snapshot.data.trainLineNm}");
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }

                  return CircularProgressIndicator();
                })
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("subwayHeading : "),
                FutureBuilder<Subway>(future: futureSubway,builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text("${snapshot.data.subwayHeading}");
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }

                  return CircularProgressIndicator();
                })
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("arvlMsg2 : "),
                FutureBuilder<Subway>(future: futureSubway,builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text("${snapshot.data.arvlMsg2}");
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }

                  return CircularProgressIndicator();
                })
              ],
            ),
          ],
        ),
      ),
    );
  }
}
