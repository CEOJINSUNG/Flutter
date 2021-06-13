import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

class ClickButton extends ChangeNotifier {
  int click = 0;

  ClickButton(this.click);

  int getClick() {
    return click * click;
  }

  void increase() {
    click++;
    notifyListeners();
  }
}

void main() {
  runApp(MyApp());
}

Future<List<Photo>> fetchPhotos(http.Client client) async {
  final response = await client
      .get(Uri.parse('https://jsonplaceholder.typicode.com/photos'));
  return compute(parsePhotos, response.body);
}

List<Photo> parsePhotos(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Photo>((json) => Photo.fromJson(json)).toList();
}

class Photo {
  final int albumId;
  final int id;
  final String title;
  final String url;
  final String thumbnailUrl;

  Photo(
      {@required this.albumId,
      @required this.id,
      @required this.title,
      @required this.url,
      @required this.thumbnailUrl});

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
        albumId: json['albumId'] as int,
        id: json['id'] as int,
        title: json['title'] as String,
        url: json['url'] as String,
        thumbnailUrl: json['thumbnailUrl'] as String);
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ClickButton>(
        create: (_) => ClickButton(0),
        child: MaterialApp(
          title: '2016311902 KimJinSung',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: MyHomePage(title: '2016311902 KimJinSung'),
        ));
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: FutureBuilder<List<Photo>>(
        future: fetchPhotos(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);
          return snapshot.hasData
              ?
                    Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 30, bottom: 30),
                          child: TextButton(
                              onPressed: () => {
                                    Provider.of<ClickButton>(context,
                                            listen: false)
                                        .increase()
                                  },
                              child: Text(
                                  "Http request button ${Provider.of<ClickButton>(context).click} clicked", style: TextStyle(fontSize: 16, color: Colors.blue))),
                        ),
                        Flexible(child: PhotoList(photos: snapshot.data.sublist(0, Provider.of<ClickButton>(context).getClick())))
                      ],
                    )
              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class PhotoList extends StatelessWidget {
  final ScrollController _controllerOne = ScrollController();
  final List<Photo> photos;

  PhotoList({Key key, @required this.photos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _controllerOne,
      child:  GridView.builder(
        controller: _controllerOne,
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          return Image.network(photos[index].thumbnailUrl);
        }),
    );
  }
}
