import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

const eventChannel = const EventChannel("edu.skku.map.assignment13/Accelerometer");

class AccelerometerEvent {
  final double x;
  final double y;
  final double z;
  AccelerometerEvent(this.x, this.y, this.z);
  @override
  String toString() => '[AccelerometerEvent (x: $x, y: $y, z: $z)]';
}

Stream<AccelerometerEvent> _accelerometerEvents;
Stream<AccelerometerEvent> get accelerometerEventStream {
  Stream<AccelerometerEvent> accelerometerEvents = _accelerometerEvents;
  if (accelerometerEvents == null) {
    accelerometerEvents = eventChannel.receiveBroadcastStream().map(
                (dynamic event) => AccelerometerEvent(event[0] as double, event[1] as double, event[2] as double)
    );
    _accelerometerEvents = accelerometerEvents;
  }
  return accelerometerEvents;
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  String _batteryLevel = "default";
  List<String> _accelerometerValues;
  StreamSubscription<dynamic> _streamSubscription;


  @override
  void initState() {
    super.initState();
    _streamSubscription = accelerometerEventStream.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <String>[
          event.x.toStringAsFixed(3),
          event.y.toStringAsFixed(3),
          event.z.toStringAsFixed(3)
        ];
      });
    });

  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription.cancel();
  }

  static const platform = const MethodChannel("edu.skku.map.assignment13/BatteryLevel");
  Future<void> _getBatteryLevel () async {
    String batteryLevel;
    final int result = await platform.invokeMethod("getBatteryLevel");
    batteryLevel = 'Battery level at $result % .';
    setState(() {
      _batteryLevel = batteryLevel;
    });
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
          children: <Widget>[
            Text(
              'Rotation Vector : $_accelerometerValues',
            ),
            Text(
              '$_batteryLevel',
            ),
            ElevatedButton(onPressed: _getBatteryLevel, child: Text("GetBatteryLevel"))
          ],
        ),
      ),
    );
  }
}
