import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Page1 extends StatelessWidget {
  final Map<String, String> arguments;
  Page1(this.arguments);

  @override
  Widget build(BuildContext context) {
    Page1CounterProvider counter = Provider.of<Page1CounterProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Page 1"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(arguments["user-msg1"]),
            Text(arguments["user-msg2"]),
            Consumer<Page1CounterProvider> (
              builder: (context, counter, child) => Text(
                '${counter.counter}',
                style: Theme.of(context).textTheme.headline4,
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => counter._incrementCounter(),
        tooltip: "increment",
        child: Icon(Icons.add),
      ),
    );
  }
}

class Page1CounterProvider with ChangeNotifier {
  int _counter;
  get counter => _counter;

  Page1CounterProvider(this._counter);
  void _incrementCounter() {
    _counter++;
    notifyListeners();
  }
}