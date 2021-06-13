import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Page3 extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    Page3CounterProvider counter = Provider.of<Page3CounterProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Page 3"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Hi! Welcome to Page 3"),
            Consumer<Page3CounterProvider> (
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

class Page3CounterProvider with ChangeNotifier {
  int _counter;
  get counter => _counter;

  Page3CounterProvider(this._counter);
  void _incrementCounter() {
    _counter++;
    notifyListeners();
  }
}