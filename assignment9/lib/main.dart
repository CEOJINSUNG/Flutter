import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  int _counter = 0;
  String _name = "kimjinsung";
  String _email = "jinsung1048@gmail.com";
  String _password = "qwer1234";
  String _imagepath = "assets/images/bob.png";
  int _imageNum = 0;

  final namefieldController = TextEditingController();
  final emailfieldController = TextEditingController();
  final passwordfieldController = TextEditingController();

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void _changeName() {
    setState(() {
      if (_password == passwordfieldController.text) {
        _name = namefieldController.text;
      }
    });
  }

  void _changeEmail() {
    setState(() {
      if (_password == passwordfieldController.text) {
        _email = emailfieldController.text;
      }
    });
  }

  void _changeImage() {
    setState(() {
      if (_password == passwordfieldController.text) {
        if (_imageNum % 5 == 0) {
          _imagepath = "assets/images/chicken.jpeg";
          _imageNum++;
        } else if (_imageNum % 5 == 1) {
          _imagepath = "assets/images/jjala.jpeg";
          _imageNum++;
        } else if (_imageNum % 5 == 2) {
          _imagepath = "assets/images/meat.jpeg";
          _imageNum++;
        } else if (_imageNum % 5 == 3) {
          _imagepath = "assets/images/sugar.jpeg";
          _imageNum++;
        } else if (_imageNum % 5 == 4) {
          _imagepath = "assets/images/bob.png";
          _imageNum++;
        }
      }
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
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Profile Image"
            ),
            Text(
                "Name : $_name"
            ),
            Text(
                "Email : $_email"
            ),
            SizedBox(
              width: 300,
              child: Image.asset(_imagepath),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget> [
                Text("Change Name : "),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: namefieldController,
                  ),
                ),
                ElevatedButton(onPressed: _changeName, child: Text("change Name")),
              ]
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget> [
                  Text("Change Email : "),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: emailfieldController,
                    ),
                  ),
                  ElevatedButton(onPressed: _changeEmail, child: Text("change Email")),
                ]
            ),
            TextButton(onPressed: _changeImage, child: Text("changeImage")),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget> [
                  Text("password : "),
                  SizedBox(
                    width: 150,
                    child: TextField(
                      controller: passwordfieldController,
                    ),
                  ),
                ]
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
