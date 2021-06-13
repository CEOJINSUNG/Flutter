import 'package:flutter/material.dart';
import 'package:assignment11/pages/page1.dart';
import 'package:assignment11/pages/page2.dart';
import 'package:assignment11/pages/page3.dart';
import 'package:assignment11/pages/page4.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => Page1CounterProvider(0)),
          ChangeNotifierProvider(create: (context) => Page2CounterProvider(0)),
          ChangeNotifierProvider(create: (context) => Page3CounterProvider(0)),
          ChangeNotifierProvider(create: (context) => Page4CounterProvider(0)),
        ],
        child:MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          initialRoute: "/",
          onGenerateRoute: (routerSettings) {
            switch (routerSettings.name) {
              case "/":
                return MaterialPageRoute(builder: (_) => MyHomePage(title: "Dynamic Routing"));
              case "/page1":
                return MaterialPageRoute(builder: (_) => Page1(routerSettings.arguments));
              case "/page2":
                return MaterialPageRoute(builder: (_) => Page2());
              case "/page3":
                return MaterialPageRoute(builder: (_) => Page3());
              case "/page4":
                return MaterialPageRoute(builder: (_) => Page4());
              default:
                return MaterialPageRoute(builder: (_) => MyHomePage(title: "Error Unknown Route!"));
            }
          },
        ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

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

  @override
  Widget build(BuildContext context) {
    final Page1CounterProvider counter = Provider.of<Page1CounterProvider>(context);
    final Page2CounterProvider counter1 = Provider.of<Page2CounterProvider>(context);
    final Page3CounterProvider counter2 = Provider.of<Page3CounterProvider>(context);
    final Page4CounterProvider counter3 = Provider.of<Page4CounterProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                      context, "/page1",
                      arguments: {
                        "user-msg1": "Move to Page1 by Dynamic Navigation",
                        "user-msg2": "Welcome to Page1",
                      }
                  );
                },
                child: Text("Move to Page 1"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/page2");
              },
              child: Text("Move to Page 2"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/page3");
              },
              child: Text("Move to Page 3"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/page4");
              },
              child: Text("Move to Page 4"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "");
              },
              child: Text("Unknown"),
            ),
            Consumer<Page1CounterProvider> (
              builder: (context, counter, child) => Text(
                "Page 1 Count: ${counter.counter}",
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            Consumer<Page2CounterProvider> (
              builder: (context, counter, child) => Text(
                "Page 2 Count: ${counter.counter}",
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            Consumer<Page3CounterProvider> (
              builder: (context, counter, child) => Text(
                "Page 3 Count: ${counter.counter}",
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            Consumer<Page4CounterProvider> (
              builder: (context, counter, child) => Text(
                "Page 4 Count: ${counter.counter}",
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
