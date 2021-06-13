import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    title: 'Navigation Basics',
    initialRoute: '/',
    routes: {
      '/': (_) => ChangeNotifierProvider<Login>(
        create: (context) => Login('Login Please...', false),
        child: FirstRoute(),
      ),
      '/second': (context) => SecondRoute(),
      '/third': (context) => ThirdRoute(),
      '/fourth': (context) => FourthRoute(),
    },
  ));
}

class Login extends ChangeNotifier {
  String subTitle = '';
  bool complete = false;

  Login(this.subTitle, this.complete);

  String getTitle() => subTitle;
  bool getComplete() => complete;

  void checkTrue(String login, String password) {
    if (login == 'skku' && password == '1234') {
      subTitle = "Login Success Hello $login!!";
      complete = true;
      log('true');
    } else {
      subTitle = "Login Please...";
      complete = false;
      log('false');
    }
    notifyListeners();
  }
}

//Vaccine Class 설정
class Vaccine {
  final String date;
  final int total_vaccinations;
  final int people_vaccinated;
  final int people_fully_vaccinated;
  final int daily_vaccinations_raw;
  final int daily_vaccinations;
  final double people_vaccinated_per_hundred;
  final double people_fully_vaccinated_per_hundred;
  final int daily_vaccinations_per_million;

  Vaccine({
    this.date, this.total_vaccinations, this.people_vaccinated, this.people_fully_vaccinated,
    this.daily_vaccinations_raw, this.daily_vaccinations,
    this.people_vaccinated_per_hundred, this.people_fully_vaccinated_per_hundred,
    this.daily_vaccinations_per_million
  });

  factory Vaccine.fromJson(Map<String, dynamic> json) {
    return Vaccine(
      date: json['date'] as String,
      total_vaccinations: json['total_vaccinations'] as int,
      people_vaccinated: json['people_vaccinated'] as int,
      people_fully_vaccinated: json['people_fully_vaccinated'] as int,
      daily_vaccinations_raw: json['daily_vaccinations_raw'] as int,
      daily_vaccinations: json['daily_vaccinations'] as int,
      people_vaccinated_per_hundred: json['people_vaccinated_per_hundred'] as double,
      people_fully_vaccinated_per_hundred: json['people_fully_vaccinated_per_hundred'] as double,
      daily_vaccinations_per_million: json['daily_vaccinations_per_million'] as int,
    );
  }
}

//Vaccine List 선언
List<Vaccine> parseVaccine(List data) {
  List<Vaccine> list = [];
  for (int i = 0; i < 7; i++) {
    var parsed = data[i];
    list.add(Vaccine.fromJson(parsed));
  }
  print(list);
  return list;
}

//http 통신을 위한 headers 설정하기
Map<String, String> headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
};

//Vaccine 정보 가져와서 최신의 7개를 설정하기
Future<List<Vaccine>> fetchVaccine() async {
  final res = await http.get(Uri.parse(
      'https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/vaccinations.json'),
      headers: headers);
  if (res.statusCode == 200) {
    var entire = json.decode(res.body);
    var today = DateTime.now();
    var array = [];
    for (int i = 0; i < entire.length; i++) {
      var element = entire[i]["data"];
      var len = element.length;
      int differ = int.parse(today
          .difference(DateTime.parse(element[len - 1]["date"]))
          .inDays
          .toString());
      var dict = { "position": i, "date": differ};
      array.add(dict);
    }

    var pos;
    if (array != null && array.isNotEmpty) {
      array.sort((a, b) => a['date'].compareTo(b['date']));
      pos = array.first['position'];
    }

    var returnArray = [];
    var finalElement = entire[pos]["data"].length;
    for (int j = 1; j < 8; j++) {
      returnArray.add(entire[pos]["data"][finalElement - j]);
    }

    var finalArray = returnArray;

    return parseVaccine(finalArray);
  } else {
    // 만약 응답이 OK가 아니면, 에러를 던집니다.
    throw Exception('Failed to load post');
  }
}

//Vaccine 정보 가져와서 위 정보 설정하기
Future<List> fetchOneVaccine() async {
  final res = await http.get(Uri.parse(
      'https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/vaccinations.json'),
      headers: headers);
  if (res.statusCode == 200) {
    var totalVacc = 0;
    var totalFullyVacc = 0;
    var dailyVacc = 0;
    var information = [];
    var koreaPosition;
    var entire = json.decode(res.body);
    for (int i = 0; i < entire.length; i++) {
      var element = entire[i]["data"];
      var len = element.length;

      //Parsed Latest date 한국
      if (entire[i]["iso_code"] == "KOR") {
        koreaPosition = i;
        information.add(element[len-1]["date"]);
      }
    }

    var koreaLen = entire[koreaPosition]['data'].length;
    var koreaParseDate = DateTime.parse(entire[koreaPosition]['data'][koreaLen - 1]["date"].toString());
    for (int i=0; i < entire.length; i++) {
      var element = entire[i]["data"];
      var len = element.length;
      int differ = int.parse(koreaParseDate
          .difference(DateTime.parse(element[len - 1]["date"]))
          .inDays
          .toString());
      if (len >= 1) {
        if (differ >= 0) {
          totalVacc = totalVacc +
              (element[len - 1]['total_vaccinations'] != null ?
              element[len - 1]['total_vaccinations'] :
              element[len - 1]['people_vaccinated'] != null ?
              element[len - 1]['people_vaccinated'] :
              element[len - 1]['people_fully_vaccinated'] != null ?
              element[len - 1]['people_fully_vaccinated'] : 0);
        } else {
          if (len + differ >= 0) {
            totalVacc = totalVacc +
                (element[len + differ]['total_vaccinations'] != null ?
                element[len + differ]['total_vaccinations'] :
                element[len + differ]['people_vaccinated'] != null ?
                element[len + differ]['people_vaccinated'] :
                element[len + differ]['people_fully_vaccinated'] != null ?
                element[len + differ]['people_fully_vaccinated'] : 0);
          } else {
            totalVacc = totalVacc +
                (element[len - 1]['total_vaccinations'] != null ?
                element[len - 1]['total_vaccinations'] :
                element[len - 1]['people_vaccinated'] != null ?
                element[len - 1]['people_vaccinated'] :
                element[len - 1]['people_fully_vaccinated'] != null ?
                element[len - 1]['people_fully_vaccinated'] : 0);
          }
        }
      }
      if (len == 1) {
        if (element[len - 1]['people_fully_vaccinated'] != null) {
          var a = element[len - 1]['people_fully_vaccinated'];
          totalFullyVacc = totalFullyVacc + a;
        }
        if (element[len - 1]['daily_vaccinations'] != null) {
          var a = element[len - 1]['daily_vaccinations'];
          dailyVacc = dailyVacc + a;
        }
      } else if (len > 1) {
        if (differ >= 0) {
          if (element[len - 1]['people_fully_vaccinated'] != null) {
            var a = element[len - 1]['people_fully_vaccinated'];
            totalFullyVacc = totalFullyVacc + a;
          } else if (element[len - 2]['people_fully_vaccinated'] != null) {
            var a = element[len - 2]['people_fully_vaccinated'];
            totalFullyVacc = totalFullyVacc + a;
          }
          if (element[len - 1]['daily_vaccinations'] != null) {
            var a = element[len - 1]['daily_vaccinations'];
            dailyVacc = dailyVacc + a;
          } else if (element[len - 2]['daily_vaccinations'] != null) {
            var a = element[len - 2]['daily_vaccinations'];
            dailyVacc = dailyVacc + a;
          }
        } else {
          if (len + differ >= 0) {
            if (element[len + differ]['people_fully_vaccinated'] != null) {
              var a = element[len - 1]['people_fully_vaccinated'];
              totalFullyVacc = totalFullyVacc + a;
            } else if (element[len + differ - 1]['people_fully_vaccinated'] != null) {
              var a = element[len - 2]['people_fully_vaccinated'];
              totalFullyVacc = totalFullyVacc + a;
            }
            if (element[len + differ]['daily_vaccinations'] != null) {
              var a = element[len - 1]['daily_vaccinations'];
              dailyVacc = dailyVacc + a;
            } else if (element[len + differ - 1]['daily_vaccinations'] != null) {
              var a = element[len - 2]['daily_vaccinations'];
              dailyVacc = dailyVacc + a;
            }
          } else {
            if (element[len - 1]['people_fully_vaccinated'] != null) {
              var a = element[len - 1]['people_fully_vaccinated'];
              totalFullyVacc = totalFullyVacc + a;
            } else if (element[len - 2]['people_fully_vaccinated'] != null) {
              var a = element[len - 2]['people_fully_vaccinated'];
              totalFullyVacc = totalFullyVacc + a;
            }
            if (element[len - 1]['daily_vaccinations'] != null) {
              var a = element[len - 1]['daily_vaccinations'];
              dailyVacc = dailyVacc + a;
            } else if (element[len - 2]['daily_vaccinations'] != null) {
              var a = element[len - 2]['daily_vaccinations'];
              dailyVacc = dailyVacc + a;
            }
          }
        }
      }
    }
    information.add(totalVacc);
    information.add(totalFullyVacc);
    information.add(dailyVacc);
    print(information);

    return information;
  } else {
    // 만약 응답이 OK가 아니면, 에러를 던집니다.
    throw Exception('Failed to load post');
  }
}

Future<List> fetchOneCase() async {
  final res = await http.get(Uri.parse(
      'https://covid.ourworldindata.org/data/owid-covid-data.json'),
      headers: headers);
  if (res.statusCode == 200) {
    var entire = json.decode(res.body);
    List<dynamic> information = [];
    List countryKey = entire.keys.toList();
    var totalCase = 0.0;
    var totalDeaths = 0.0;
    var newCases = 0.0;

    entire.keys.forEach((key) {
      var element = entire[key]["data"];
      var len = element.length;

      if (key == "KOR") {
        print(element[len - 1]);
        information.add(element[len - 1]["date"]);
      }
    });

    //totalCase
    entire.keys.forEach((key) {
      var element = entire[key];
      if (element["data"] != null) {
        var len = element["data"].length;
        if (len > 1) {
          int differ = int.parse(DateTime.parse(information[0].toString())
              .difference(DateTime.parse(element["data"][len - 1]["date"]))
              .inDays
              .toString());
          var one = element["data"][len - 1]["total_cases"];
          var two = element["data"][len - 2]["total_cases"];

          if (differ >= 0) {
            if (one != null) {
              totalCase = totalCase + one;
            } else if (two != null) {
              totalCase = totalCase + two;
            }
          } else {
            if (len + differ >= 0) {
              var diffOne = element["data"][len + differ]["total_cases"];
              var diffTwo = element["data"][len + differ - 1]["total_cases"];
              if (diffOne != null) {
                totalCase = totalCase + diffOne;
              } else if (diffTwo != null) {
                totalCase = totalCase + diffTwo;
              }
            } else {
              if (one != null) {
                totalCase = totalCase + one;
              } else if (two != null) {
                totalCase = totalCase + two;
              }
            }
          }
        } else {
          var one = element["data"][len - 1]["total_cases"];
          if (one != null) {
            totalCase = totalCase + one;
          }
        }
      }
    });

    //totalDeaths
    entire.keys.forEach((key) {
      var element = entire[key];
      if (element["data"] != null) {
        var len = element["data"].length;
        if (len > 1) {
          int differ = int.parse(DateTime.parse(information[0].toString())
              .difference(DateTime.parse(element["data"][len - 1]["date"]))
              .inDays
              .toString());
          var one = element["data"][len - 1]["total_deaths"];
          var two = element["data"][len - 2]["total_deaths"];

          if (differ >= 0) {
            if (one != null) {
              totalDeaths = totalDeaths + one;
            } else if (two != null) {
              totalDeaths = totalDeaths + two;
            }
          } else {
            if (len + differ >= 0) {
              var diffOne = element["data"][len + differ]["total_deaths"];
              var diffTwo = element["data"][len + differ - 1]["total_deaths"];
              if (diffOne != null) {
                totalDeaths = totalDeaths + diffOne;
              } else if (diffTwo != null) {
                totalDeaths = totalDeaths + diffTwo;
              }
            } else {
              if (one != null) {
                totalDeaths = totalDeaths + one;
              } else if (two != null) {
                totalDeaths = totalDeaths + two;
              }
            }
          }
        } else {
          var one = element["data"][len - 1]["total_deaths"];
          if (one != null) {
            totalDeaths = totalDeaths + one;
          }
        }
      }
    });

    //newCases
    entire.keys.forEach((key) {
      var element = entire[key];
      if (element["data"] != null) {
        var len = element["data"].length;
        if (len > 1) {
          int differ = int.parse(DateTime.parse(information[0].toString())
              .difference(DateTime.parse(element["data"][len - 1]["date"]))
              .inDays
              .toString());
          var one = element["data"][len - 1]["new_cases"];
          var two = element["data"][len - 2]["new_cases"];

          if (differ >= 0) {
            if (one != null) {
              newCases = newCases + one;
            } else if (two != null) {
              newCases = newCases + two;
            }
          } else {
            if (len + differ >= 0) {
              var diffOne = element["data"][len + differ]["new_cases"];
              var diffTwo = element["data"][len + differ - 1]["new_cases"];
              if (diffOne != null) {
                newCases = newCases + diffOne;
              } else if (diffTwo != null) {
                newCases = newCases + diffTwo;
              }
            } else {
              if (one != null) {
                newCases = newCases + one;
              } else if (two != null) {
                newCases = newCases + two;
              }
            }
          }
        } else {
          var one = element["data"][len - 1]["new_cases"];
          if (one != null) {
            newCases = newCases + one;
          }
        }
      }
    });

    information.add(totalCase.toInt());
    information.add(totalDeaths.toInt());
    information.add(newCases.toInt());

    print(information);

    return information;
  } else {
    // 만약 응답이 OK가 아니면, 에러를 던집니다.
    throw Exception('Failed to load post');
  }
}

class FirstRoute extends StatelessWidget {
  final idControl = TextEditingController();
  final pwControl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('2016311902 KimJinSung'),
      ),
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  'CORONA LIVE',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 40),
                child: Text(
                  Provider.of<Login>(context).getTitle().toString(),
                  style: TextStyle(
                    color: Provider.of<Login>(context).getComplete() ? Colors.blue : Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
              Provider.of<Login>(context).getComplete() ? Column(
                children: <Widget>[
                  Container(
                    child: Image.asset('assets/images/world.png', width: 300, fit: BoxFit.contain),
                    margin: EdgeInsets.only(top: 50, bottom: 50),
                  ),
                  RaisedButton(
                      child: Text('Start Corona Live'),
                      onPressed: () {
                        Navigator.pushNamed(
                            context,
                            '/second',
                            arguments: ScreenArguments(
                                idControl.text, 'login')
                        );
                      }
                  ),
                ],
              ) : Container(
                width: 250,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.all(
                      Radius.circular(5.0)
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'ID :',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(
                            width: 180,
                            child: TextField(
                              controller: idControl,
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: <Widget>[
                          Text(
                            'PW :',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(
                            width: 180,
                            child: TextField(
                              controller: pwControl,
                            ),
                          )
                        ],
                      ),
                    ),
                    RaisedButton(
                        child: Text('Login'),
                        onPressed: () {
                          Provider.of<Login>(context, listen: false).checkTrue(idControl.text, pwControl.text);
                        }
                    ),
                  ],
                ),
              ),
            ],
          )
      ),
    );
  }
}

class SecondRoute extends StatelessWidget {
  void thirdPush({context, params}) {
    Navigator.pushNamed(context, '/third', arguments: thirdParams(params));
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute
        .of(context)
        .settings
        .arguments as ScreenArguments;
    return Scaffold(
      appBar: AppBar(
        leading: null,
        title: Text("Menu"),
      ),
      body: Center(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                      icon: Icon(Icons.coronavirus_outlined), onPressed: () {
                    Navigator.pushNamed(context, '/fourth', arguments: ScreenArguments(args.userName, 'Cases/Deaths'));
                  }),
                  SizedBox(
                    width: 300.0,
                    height: 50.0,
                    child: new FlatButton(
                      padding: EdgeInsets.only(left: 20.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Cases/Deaths', textAlign: TextAlign.left),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/fourth', arguments: ScreenArguments(args.userName, 'Cases/Deaths'));
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  IconButton(icon: Icon(Icons.local_hospital), onPressed: () {
                    Navigator.pushNamed(context, '/third', arguments: ScreenArguments(args.userName, 'Vaccine'));
                  }),
                  SizedBox(
                    width: 300.0,
                    height: 50.0,
                    child: new FlatButton(
                      padding: EdgeInsets.only(left: 20.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Vaccine', textAlign: TextAlign.left),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/third', arguments: ScreenArguments(args.userName, 'Vaccine'));
                      },
                    ),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(top: 250),
                child: Text(
                  'Welcome! ${args.userName}',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 16),
                child: Text(
                  'Previous ${args.routeName} Page',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.blueAccent
                  ),
                ),
              ),
            ],
          )
      ),
    );
  }
}

class ThirdRoute extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute
        .of(context)
        .settings
        .arguments as ScreenArguments;
    return Scaffold(
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 320,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 3),
                  borderRadius: BorderRadius.all(
                      Radius.circular(8.0)
                  ),
                ),
                child: VaccineTitle(),
              ),
              VaccineGraph(),
              VaccineOrder(),
            ],
          ),
      ),
      floatingActionButton: FloatingActionButton(
        child: new Icon(Icons.list),
        onPressed: () {
          Navigator.popAndPushNamed(context, '/second', arguments: ScreenArguments(args.userName, 'Vaccine'));
        },
      ),
    );
  }
}

class FourthRoute extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute
        .of(context)
        .settings
        .arguments as ScreenArguments;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 320,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 3),
                borderRadius: BorderRadius.all(
                    Radius.circular(8.0)
                ),
              ),
              child: CaseTitle(),
            ),
            CasesGraph(),
            CasesOrder(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: new Icon(Icons.list),
        onPressed: () {
          Navigator.popAndPushNamed(context, '/second', arguments: ScreenArguments(args.userName, 'Cases/Deaths'));
        },
      ),
    );
  }
}

class VaccineTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new FutureBuilder<List>(
      future: fetchOneVaccine(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if(snapshot.hasData) {
          return Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      SizedBox(
                        width: 150,
                        child:
                        Text(
                          'Total Vacc.',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child:
                        Text(
                          snapshot.data[1].toString() + " people",
                          style: TextStyle(
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      SizedBox(
                        width: 150,
                        child: Text(
                          'Parsed latest date',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: Text(
                          snapshot.data[0].toString(),
                          style: TextStyle(
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      SizedBox(
                        width: 150,
                        child: Text(
                          'Total fully Vacc.',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: Text(
                          snapshot.data[2].toString() + " people",
                          style: TextStyle(
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      SizedBox(
                        width: 150,
                        child: Text(
                          'Daily Vacc.',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: Text(
                          snapshot.data[3].toString() + " people",
                          style: TextStyle(
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )
                ],
              )
            ],
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}

class VaccineCountry extends ChangeNotifier {
  int num = 0;
  int graphNum = 1;
  List<String> graphDate = [];
  List finalArray = [];
  List<FlSpot> graphArray = [];
  List oneReversed = [];
  List twoReversed = [];
  List threeReversed = [];
  List fourReversed = [];

  VaccineCountry(this.num, this.finalArray, this.graphNum, this.graphArray);

  int getNum() => num;

  int getGraphNum() => graphNum;
  
  List<String> getGraphDate() => graphDate;

  List getOne() => oneReversed;
  List getTwo() => twoReversed;
  List getThree() => threeReversed;
  List getFour() => fourReversed;

  void GraphOne() {
    graphNum = 1;
    notifyListeners();
  }

  void GraphTwo() {
    graphNum = 2;
    notifyListeners();
  }

  void GraphThree() {
    graphNum = 3;
    notifyListeners();
  }

  void GraphFour() {
    graphNum = 4;
    notifyListeners();
  }

  void CountryName() {
    num = 1;
    finalArray.sort((a, b) {
      return a[0].toString().toLowerCase().compareTo(b[0].toString().toLowerCase());
    });
    notifyListeners();
  }

  void TotalVacc() {
    num = 2;
    finalArray.sort((a, b) {
      if (a[1] == null && b[1] == null) {
        return 0;
      } else if (a[1] == null) {
        return 1;
      } else if (b[1] == null) {
        return -1;
      } else {
        return b[1].compareTo(a[1]);
      }
    });
    notifyListeners();
  }

  Future<List> loadVaccine() async {
    final res = await http.get(Uri.parse(
        'https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/vaccinations.json'),
        headers: headers);
    if (res.statusCode == 200) {
      finalArray.clear();
      var entire = json.decode(res.body);
      var koreaPosition;
      for (int i = 0; i < entire.length; i++) {
        //Parsed Latest date 한국
        if (entire[i]["iso_code"] == "KOR") {
          koreaPosition = i;
        }
      }
      var koreaLen = entire[koreaPosition]['data'].length;
      var koreaParseDate = DateTime.parse(entire[koreaPosition]['data'][koreaLen - 1]["date"].toString());

      for (int i = 0; i < entire.length; i++) {
        var element = entire[i]["data"];
        var len = element.length;
        int differ = int.parse(koreaParseDate
            .difference(DateTime.parse(element[len - 1]["date"]))
            .inDays
            .toString());

        if (len > 0) {
          if (differ >= 0) {
            var a = [];
            a.add(entire[i]["country"]);
            a.add(element[len - 1]['total_vaccinations']);
            a.add(element[len - 1]['people_fully_vaccinated']);
            a.add(element[len - 1]['daily_vaccinations']);
            finalArray.add(a);
            notifyListeners();
          } else {
            if (len + differ >= 0) {
              var a = [];
              a.add(entire[i]["country"]);
              a.add(element[len + differ]['total_vaccinations']);
              a.add(element[len + differ]['people_fully_vaccinated']);
              a.add(element[len + differ]['daily_vaccinations']);
              finalArray.add(a);
              notifyListeners();
            }
          }
        }
      }
      if (num == 1) {
        CountryName();
      } else if (num == 2) {
        TotalVacc();
      }
      return finalArray;
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future<List<FlSpot>> loadVaccineGraph() async {
    final res = await http.get(Uri.parse(
        'https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/vaccinations.json'),
        headers: headers);
    if (res.statusCode == 200) {
      graphArray.clear();
      var entire = json.decode(res.body);

      //한국 위치를 찾음
      var koreaPosition;
      for (int i = 0; i < entire.length; i++) {
        //Parsed Latest date 한국
        if (entire[i]["iso_code"] == "KOR") {
          koreaPosition = i;
          break;
        }
      }
      var koreaLen = entire[koreaPosition]['data'].length;
      var koreaParseDate = DateTime.parse(entire[koreaPosition]['data'][koreaLen - 1]["date"].toString());

      //graphDate 더하기
      graphDate.clear();
      for (int k = 0; k < 28; k++) {
        DateTime dateTime = new DateTime(koreaParseDate.year, koreaParseDate.month, koreaParseDate.day - k);
        var md = DateFormat('yyyy-MM-dd').format(dateTime).toString();
        graphDate.add(md);
      }

      var graphOne = [0, 0, 0, 0, 0, 0, 0];
      var graphTwo = [0, 0, 0, 0, 0, 0, 0];
      var graphThree = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      var graphFour = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      for (int i = 0; i < entire.length; i++) {
        var element = entire[i]["data"];
        var len = element.length;

        int maxLength = 28;
        if (len < 28) {
          maxLength = len;
        }

        for (int j = 0; j < maxLength; j++) {
          var dataExist = graphDate.contains(
              element[len - j - 1]["date"].toString());
          if (dataExist) {
            if (j < 7) {
              var totalVaccine = element[len - j - 1]["total_vaccinations"] ?? 0;
              var dailyVaccine = element[len - j - 1]["daily_vaccinations"] ?? 0;
              graphOne[j] = graphOne[j] + totalVaccine;
              graphTwo[j] = graphTwo[j] + dailyVaccine;
              graphThree[j] = graphThree[j] + totalVaccine;
              graphFour[j] = graphFour[j] + dailyVaccine;
            } else {
              var totalVaccine = element[len - j - 1]["total_vaccinations"] ?? 0;
              var dailyVaccine = element[len - j - 1]["daily_vaccinations"] ?? 0;
              graphThree[j] = graphThree[j] + totalVaccine;
              graphFour[j] = graphFour[j] + dailyVaccine;
            }
          }
        }
      }


      oneReversed = graphOne.reversed.toList();
      twoReversed = graphTwo.reversed.toList();
      threeReversed = graphThree.reversed.toList();
      fourReversed = graphFour.reversed.toList();

      if (graphNum == 1) {
        for (int g = 0; g < 7; g++) {
          graphArray.add(FlSpot(g.toDouble(), oneReversed[g].toDouble()));
          notifyListeners();
        }
      } else if (graphNum == 2) {
        for (int g = 0; g < 7; g++) {
          graphArray.add(FlSpot(g.toDouble(), twoReversed[g].toDouble()));
          notifyListeners();
        }
      } else if (graphNum == 3) {
        for (int g = 0; g < 28; g++) {
          graphArray.add(FlSpot(g.toDouble(), threeReversed[g].toDouble()));
          notifyListeners();
        }
      } else if (graphNum == 4) {
        for (int g = 0; g < 28; g++) {
          graphArray.add(FlSpot(g.toDouble(), fourReversed[g].toDouble()));
          notifyListeners();
        }
      }

      print(graphArray);

      return graphArray;
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }
}

class VaccineOrder extends StatelessWidget {
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: VaccineCountry(0, [], 0 , []),
      child: Consumer<VaccineCountry>(
        builder: (BuildContext context, VaccineCountry provider, Widget child) => FutureBuilder(
          future: provider.loadVaccine(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List countryList = snapshot.data?.sublist(0, 8);
              if (provider.getNum() == 0) {
                return Container(
                  width: 320,
                  margin: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 3),
                    borderRadius: BorderRadius.all(
                        Radius.circular(8.0)
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: Colors.grey,
                                    width: 3
                                )
                            )
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextButton(
                              child: Text('Country_name', style: TextStyle(
                                  fontSize: 12, color: Colors.blue)),
                              onPressed: () => provider.CountryName(),
                            ),
                            TextButton(
                              child: Text('Total_vacc', style: TextStyle(
                                  fontSize: 12, color: Colors.blue)),
                              onPressed: () => provider.TotalVacc(),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 320,
                        height: 100,
                        child: ListView(
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceEvenly,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 78,
                                      child: Text('Country',
                                          style: TextStyle(fontSize: 10),
                                          textAlign: TextAlign.center),
                                    ),
                                    SizedBox(
                                      width: 78,
                                      child: Text('total',
                                          style: TextStyle(fontSize: 10),
                                          textAlign: TextAlign.center),
                                    ),
                                    SizedBox(
                                      width: 78,
                                      child: Text('fully',
                                          style: TextStyle(fontSize: 10),
                                          textAlign: TextAlign.center),
                                    ),
                                    SizedBox(
                                      width: 78,
                                      child: Text('daily',
                                          style: TextStyle(fontSize: 10),
                                          textAlign: TextAlign.center),
                                    ),
                                  ],
                                ),

                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else if (provider.getNum() == 1) {
                return Container(
                  width: 320,
                  margin: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 3),
                    borderRadius: BorderRadius.all(
                        Radius.circular(8.0)
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: Colors.grey,
                                    width: 3
                                )
                            )
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextButton(
                              child: Text('Country_name', style: TextStyle(
                                  fontSize: 12, color: Colors.blue)),
                              onPressed: () => provider.CountryName(),
                            ),
                            TextButton(
                              child: Text('Total_vacc', style: TextStyle(
                                  fontSize: 12, color: Colors.blue)),
                              onPressed: () => provider.TotalVacc(),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 320,
                        height: 100,
                        child: ListView(
                          children: [
                            Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceEvenly,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 78,
                                      child: Text('Country',
                                          style: TextStyle(fontSize: 10),
                                          textAlign: TextAlign.center),
                                    ),
                                    SizedBox(
                                      width: 78,
                                      child: Text('total',
                                          style: TextStyle(fontSize: 10),
                                          textAlign: TextAlign.center),
                                    ),
                                    SizedBox(
                                      width: 78,
                                      child: Text('fully',
                                          style: TextStyle(fontSize: 10),
                                          textAlign: TextAlign.center),
                                    ),
                                    SizedBox(
                                      width: 78,
                                      child: Text('daily',
                                          style: TextStyle(fontSize: 10),
                                          textAlign: TextAlign.center),
                                    ),
                                  ],
                                ),
                                ListView.builder(
                                    controller: scrollController,
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    itemCount: countryList.length,
                                    itemBuilder: (context, index) {
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceEvenly,
                                        children: <Widget>[
                                          SizedBox(
                                            width: 78,
                                            child: Text(
                                                '${countryList[index][0]}',
                                                style: TextStyle(fontSize: 10),
                                                textAlign: TextAlign.center),
                                          ),
                                          SizedBox(
                                            width: 78,
                                            child: Text(
                                                '${countryList[index][1]}',
                                                style: TextStyle(fontSize: 10),
                                                textAlign: TextAlign.center),
                                          ),
                                          SizedBox(
                                            width: 78,
                                            child: Text(
                                                '${countryList[index][2]}',
                                                style: TextStyle(fontSize: 10),
                                                textAlign: TextAlign.center),
                                          ),
                                          SizedBox(
                                            width: 78,
                                            child: Text(
                                                '${countryList[index][3]}',
                                                style: TextStyle(fontSize: 10),
                                                textAlign: TextAlign.center),
                                          ),
                                        ],
                                      );
                                    }
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else if (provider.getNum() == 2) {
                return Container(
                  width: 320,
                  margin: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 3),
                    borderRadius: BorderRadius.all(
                        Radius.circular(8.0)
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: Colors.grey,
                                    width: 3
                                )
                            )
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextButton(
                              child: Text('Country_name', style: TextStyle(
                                  fontSize: 12, color: Colors.blue)),
                              onPressed: () => provider.CountryName(),
                            ),
                            TextButton(
                              child: Text('Total_vacc', style: TextStyle(
                                  fontSize: 12, color: Colors.blue)),
                              onPressed: () => provider.TotalVacc(),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 320,
                        height: 100,
                        child: ListView(
                          children: [
                            Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceEvenly,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 78,
                                      child: Text('Country',
                                          style: TextStyle(fontSize: 10),
                                          textAlign: TextAlign.center),
                                    ),
                                    SizedBox(
                                      width: 78,
                                      child: Text('total',
                                          style: TextStyle(fontSize: 10),
                                          textAlign: TextAlign.center),
                                    ),
                                    SizedBox(
                                      width: 78,
                                      child: Text('fully',
                                          style: TextStyle(fontSize: 10),
                                          textAlign: TextAlign.center),
                                    ),
                                    SizedBox(
                                      width: 78,
                                      child: Text('daily',
                                          style: TextStyle(fontSize: 10),
                                          textAlign: TextAlign.center),
                                    ),
                                  ],
                                ),
                                ListView.builder(
                                    controller: scrollController,
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    itemCount: countryList.length,
                                    itemBuilder: (context, index) {
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceEvenly,
                                        children: <Widget>[
                                          SizedBox(
                                            width: 78,
                                            child: Text(
                                                '${countryList[index][0]}',
                                                style: TextStyle(fontSize: 10),
                                                textAlign: TextAlign.center),
                                          ),
                                          SizedBox(
                                            width: 78,
                                            child: Text(
                                                '${countryList[index][1]}',
                                                style: TextStyle(fontSize: 10),
                                                textAlign: TextAlign.center),
                                          ),
                                          SizedBox(
                                            width: 78,
                                            child: Text(
                                                '${countryList[index][2]}',
                                                style: TextStyle(fontSize: 10),
                                                textAlign: TextAlign.center),
                                          ),
                                          SizedBox(
                                            width: 78,
                                            child: Text(
                                                '${countryList[index][3]}',
                                                style: TextStyle(fontSize: 10),
                                                textAlign: TextAlign.center),
                                          ),
                                        ],
                                      );
                                    }
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
            } else {
              return CircularProgressIndicator();
            }
          },
        )
      )
    );
  }
}

class VaccineGraph extends StatelessWidget {
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: VaccineCountry(0, [], 1, []),
        child: Consumer<VaccineCountry>(
            builder: (BuildContext context, VaccineCountry provider, Widget child) => FutureBuilder(
                  future: provider.loadVaccineGraph(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                        width: 320,
                        margin: EdgeInsets.only(top: 20),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 3),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.grey, width: 3))),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  TextButton(
                                    child: Text('Graph1',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.blue)),
                                    onPressed: () => provider.GraphOne(),
                                  ),
                                  TextButton(
                                    child: Text('Graph2',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.blue)),
                                    onPressed: () => provider.GraphTwo(),
                                  ),
                                  TextButton(
                                    child: Text('Graph3',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.blue)),
                                    onPressed: () => provider.GraphThree(),
                                  ),
                                  TextButton(
                                    child: Text('Graph4',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.blue)),
                                    onPressed: () => provider.GraphFour(),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                                width: 320,
                                height: 150,
                                padding: EdgeInsets.only(top: 8, right: 16),
                                child: LineChart(
                                  LineChartData(
                                    borderData: FlBorderData(
                                      show: false,
                                    ),
                                    gridData: FlGridData(
                                      show: true,
                                    ),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      bottomTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 14,
                                        getTextStyles: (value) => const TextStyle(
                                          color: Colors.black,
                                          fontSize: 10,
                                        ),
                                        getTitles: (value) {
                                          if (provider.getGraphNum() == 1 || provider.getGraphNum() == 2) {
                                              List<String> date = provider.getGraphDate();
                                              switch (value.toInt()) {
                                                case 0:
                                                  return date[6].substring(5, 10);
                                                case 1:
                                                  return date[5].substring(5, 10);
                                                case 2:
                                                  return date[4].substring(5, 10);
                                                case 3:
                                                  return date[3].substring(5, 10);
                                                case 4:
                                                  return date[2].substring(5, 10);
                                                case 5:
                                                  return date[1].substring(5, 10);
                                                case 6:
                                                  return date[0].substring(5, 10);
                                              }
                                              return '';
                                            } else {
                                              List<String> date = provider.getGraphDate();
                                              switch (value.toInt()) {
                                                case 2:
                                                  return date[24].substring(5, 10);
                                                case 6:
                                                  return date[20].substring(5, 10);
                                                case 10:
                                                  return date[16].substring(5, 10);
                                                case 14:
                                                  return date[12].substring(5, 10);
                                                case 18:
                                                  return date[8].substring(5, 10);
                                                case 22:
                                                  return date[4].substring(5, 10);
                                                case 26:
                                                  return date[0].substring(5, 10);
                                              }
                                            }
                                          },
                                      ),
                                    ),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: snapshot.data,
                                        colors: [Colors.blue],
                                        barWidth: 2,
                                      )
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
            )
        )
    );
  }
}

class CaseTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new FutureBuilder<List>(
      future: fetchOneCase(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if(snapshot.hasData) {
          return Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      SizedBox(
                        width: 150,
                        child:
                        Text(
                          'Total Cases.',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child:
                        Text(
                          snapshot.data[1].toString() + " people",
                          style: TextStyle(
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      SizedBox(
                        width: 150,
                        child: Text(
                          'Parsed latest date',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: Text(
                          snapshot.data[0].toString(),
                          style: TextStyle(
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      SizedBox(
                        width: 150,
                        child: Text(
                          'Total Deaths.',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: Text(
                          snapshot.data[2].toString() + " people",
                          style: TextStyle(
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      SizedBox(
                        width: 150,
                        child: Text(
                          'Daily Cases.',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: Text(
                          snapshot.data[3].toString() + " people",
                          style: TextStyle(
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )
                ],
              )
            ],
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}

class CaseCountry extends ChangeNotifier {
  int num = 0;
  int graphNum = 1;
  List<String> graphDate = [];
  List finalArray = [];
  List<FlSpot> graphArray = [];
  List oneReversed = [];
  List twoReversed = [];
  List threeReversed = [];
  List fourReversed = [];

  CaseCountry(this.num, this.finalArray, this.graphNum, this.graphArray);

  int getNum() => num;

  int getGraphNum() => graphNum;

  List<String> getGraphDate() => graphDate;

  List getOne() => oneReversed;
  List getTwo() => twoReversed;
  List getThree() => threeReversed;
  List getFour() => fourReversed;

  void GraphOne() {
    graphNum = 1;
    notifyListeners();
  }

  void GraphTwo() {
    graphNum = 2;
    notifyListeners();
  }

  void GraphThree() {
    graphNum = 3;
    notifyListeners();
  }

  void GraphFour() {
    graphNum = 4;
    notifyListeners();
  }

  void TotalCases() {
    num = 1;
    finalArray.sort((a, b) {
      if (a[1] == null && b[1] == null) {
        return 0;
      } else if (a[1] == null) {
        return 1;
      } else if (b[1] == null) {
        return -1;
      } else {
        return b[1].compareTo(a[1]);
      }
    });
    notifyListeners();
  }

  void TotalDeaths() {
    num = 2;
    finalArray.sort((a, b) {
      if (a[3] == null && b[3] == null) {
        return 0;
      } else if (a[3] == null) {
        return 1;
      } else if (b[3] == null) {
        return -1;
      } else {
        return b[3].compareTo(a[3]);
      }
    });
    notifyListeners();
  }

  Future<List> loadCases() async {
    final res = await http.get(Uri.parse(
        'https://covid.ourworldindata.org/data/owid-covid-data.json'),
        headers: headers);
    if (res.statusCode == 200) {
      finalArray.clear();
      var entire = json.decode(res.body);
      var koreaDate;

      //koreaDate 찾기
     entire.keys.forEach((key) {
        if (key == "KOR") {
          var len = entire[key]["data"].length;
          koreaDate = entire[key]["data"][len - 1]["date"];
        }
      });

      entire.keys.forEach((key) {
        var element = entire[key]["data"];
        var len = element.length;
        int differ = int.parse(DateTime.parse(koreaDate)
            .difference(DateTime.parse(element[len - 1]["date"]))
            .inDays
            .toString());
        var location = entire[key]["location"] ?? "";
        var totalCase = element[len - 1]['total_cases'] ?? 0.0;
        var newCase = element[len - 1]['new_cases'] ?? 0.0;
        var totalDeaths = element[len - 1]['total_deaths'] ?? 0.0;
        if (differ >= 0) {
          if (location.toString().length > 0) {
            List<dynamic> a = [];
            a.add(location.toString());
            a.add(totalCase);
            a.add(newCase);
            a.add(totalDeaths);
            finalArray.add(a);
            notifyListeners();
          }
        } else {
          if (len + differ >= 0) {
            if (location.toString().length > 0) {
              List<dynamic> a = [];
              a.add(location.toString());
              a.add(totalCase);
              a.add(newCase);
              a.add(totalDeaths);
              finalArray.add(a);
              notifyListeners();
            }
          }
        }
      });

      if (num == 1) {
        TotalCases();
      } else if (num == 2) {
        TotalDeaths();
      }
      return finalArray;
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future<List<FlSpot>> loadCasesGraph() async {
    final res = await http.get(Uri.parse(
        'https://covid.ourworldindata.org/data/owid-covid-data.json'),
        headers: headers);
    if (res.statusCode == 200) {
      graphArray.clear();
      var entire = json.decode(res.body);
      var koreaDate;

      //koreaDate 찾기
      entire.keys.forEach((key) {
        if (key == "KOR") {
          var len = entire[key]["data"].length;
          koreaDate = entire[key]["data"][len - 1]["date"];
        }
      });

      var koreaParseDate = DateTime.parse(koreaDate.toString());

      //graphDate 더하기
      graphDate.clear();
      for (int k = 0; k < 28; k++) {
        DateTime dateTime = new DateTime(koreaParseDate.year, koreaParseDate.month, koreaParseDate.day - k);
        var md = DateFormat('yyyy-MM-dd').format(dateTime).toString();
        graphDate.add(md);
      }

      List graphOne = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
      List graphTwo = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
      List graphThree = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
      List graphFour = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];

      entire.keys.forEach((key) {
        var element = entire[key]["data"];
        var len = element.length;

        int maxLength = 28;
        if (len < 28) {
          maxLength = len;
        }

        for (int j = 0; j < maxLength; j++) {
          var dataExist = graphDate.contains(
              element[len - j - 1]["date"].toString());
          if (dataExist) {
            if (j < 7) {
              var totalCase = element[len - j - 1]["total_cases"] ?? 0.0;
              var newCase = element[len - j - 1]["new_cases"] ?? 0.0;
              if (totalCase != null) {
                graphOne[j] = graphOne[j] + totalCase;
                graphThree[j] = graphThree[j] + totalCase;
              }
              if (newCase != null) {
                graphTwo[j] = graphTwo[j] + newCase;
                graphFour[j] = graphFour[j] + newCase;
              }
            } else {
              var totalCase = element[len - j - 1]["total_cases"] ?? 0.0;
              var newCase = element[len - j - 1]["new_cases"] ?? 0.0;
              if (totalCase != null) {
                graphThree[j] = graphThree[j] + totalCase;
              }
              if (newCase != null) {
                graphFour[j] = graphFour[j] + newCase;
              }
            }
          }
        }
      });

      oneReversed = graphOne.reversed.toList();
      twoReversed = graphTwo.reversed.toList();
      threeReversed = graphThree.reversed.toList();
      fourReversed = graphFour.reversed.toList();

      if (graphNum == 1) {
        for (int g = 0; g < 7; g++) {
          graphArray.add(FlSpot(g.toDouble(), oneReversed[g].toDouble()));
          notifyListeners();
        }
      } else if (graphNum == 2) {
        for (int g = 0; g < 7; g++) {
          graphArray.add(FlSpot(g.toDouble(), twoReversed[g].toDouble()));
          notifyListeners();
        }
      } else if (graphNum == 3) {
        for (int g = 0; g < 28; g++) {
          graphArray.add(FlSpot(g.toDouble(), threeReversed[g].toDouble()));
          notifyListeners();
        }
      } else if (graphNum == 4) {
        for (int g = 0; g < 28; g++) {
          graphArray.add(FlSpot(g.toDouble(), fourReversed[g].toDouble()));
          notifyListeners();
        }
      }

      print(graphArray);

      return graphArray;
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }
}

class CasesOrder extends StatelessWidget {
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: CaseCountry(0, [], 1, []),
        child: Consumer<CaseCountry>(
            builder: (BuildContext context, CaseCountry provider, Widget child) => FutureBuilder(
              future: provider.loadCases(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List countryList = snapshot.data?.sublist(0, 8);
                  if (provider.getNum() == 0) {
                    return Container(
                      width: 320,
                      margin: EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 3),
                        borderRadius: BorderRadius.all(
                            Radius.circular(8.0)
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Colors.grey,
                                        width: 3
                                    )
                                )
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                TextButton(
                                  child: Text('Total Cases', style: TextStyle(
                                      fontSize: 12, color: Colors.blue)),
                                  onPressed: () => provider.TotalCases(),
                                ),
                                TextButton(
                                  child: Text('Total Deaths', style: TextStyle(
                                      fontSize: 12, color: Colors.blue)),
                                  onPressed: () => provider.TotalDeaths(),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 320,
                            height: 100,
                            child: ListView(
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceEvenly,
                                      children: <Widget>[
                                        SizedBox(
                                          width: 78,
                                          child: Text('Country',
                                              style: TextStyle(fontSize: 10),
                                              textAlign: TextAlign.center),
                                        ),
                                        SizedBox(
                                          width: 78,
                                          child: Text('total cases',
                                              style: TextStyle(fontSize: 10),
                                              textAlign: TextAlign.center),
                                        ),
                                        SizedBox(
                                          width: 78,
                                          child: Text('daily cases',
                                              style: TextStyle(fontSize: 10),
                                              textAlign: TextAlign.center),
                                        ),
                                        SizedBox(
                                          width: 78,
                                          child: Text('total deaths',
                                              style: TextStyle(fontSize: 10),
                                              textAlign: TextAlign.center),
                                        ),
                                      ],
                                    ),

                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (provider.getNum() == 1) {
                    return Container(
                      width: 320,
                      margin: EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 3),
                        borderRadius: BorderRadius.all(
                            Radius.circular(8.0)
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Colors.grey,
                                        width: 3
                                    )
                                )
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                TextButton(
                                  child: Text('Total Cases', style: TextStyle(
                                      fontSize: 12, color: Colors.blue)),
                                  onPressed: () => provider.TotalCases(),
                                ),
                                TextButton(
                                  child: Text('Total Deaths', style: TextStyle(
                                      fontSize: 12, color: Colors.blue)),
                                  onPressed: () => provider.TotalDeaths(),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 320,
                            height: 100,
                            child: ListView(
                              children: [
                                Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceEvenly,
                                      children: <Widget>[
                                        SizedBox(
                                          width: 78,
                                          child: Text('Country',
                                              style: TextStyle(fontSize: 10),
                                              textAlign: TextAlign.center),
                                        ),
                                        SizedBox(
                                          width: 78,
                                          child: Text('total cases',
                                              style: TextStyle(fontSize: 10),
                                              textAlign: TextAlign.center),
                                        ),
                                        SizedBox(
                                          width: 78,
                                          child: Text('daily cases',
                                              style: TextStyle(fontSize: 10),
                                              textAlign: TextAlign.center),
                                        ),
                                        SizedBox(
                                          width: 78,
                                          child: Text('total deaths',
                                              style: TextStyle(fontSize: 10),
                                              textAlign: TextAlign.center),
                                        ),
                                      ],
                                    ),
                                    ListView.builder(
                                        controller: scrollController,
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        itemCount: countryList.length,
                                        itemBuilder: (context, index) {
                                          return Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceEvenly,
                                            children: <Widget>[
                                              SizedBox(
                                                width: 78,
                                                child: Text(
                                                    '${countryList[index][0]}',
                                                    style: TextStyle(fontSize: 10),
                                                    textAlign: TextAlign.center),
                                              ),
                                              SizedBox(
                                                width: 78,
                                                child: Text(
                                                    '${countryList[index][1]}',
                                                    style: TextStyle(fontSize: 10),
                                                    textAlign: TextAlign.center),
                                              ),
                                              SizedBox(
                                                width: 78,
                                                child: Text(
                                                    '${countryList[index][2]}',
                                                    style: TextStyle(fontSize: 10),
                                                    textAlign: TextAlign.center),
                                              ),
                                              SizedBox(
                                                width: 78,
                                                child: Text(
                                                    '${countryList[index][3]}',
                                                    style: TextStyle(fontSize: 10),
                                                    textAlign: TextAlign.center),
                                              ),
                                            ],
                                          );
                                        }
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (provider.getNum() == 2) {
                    return Container(
                      width: 320,
                      margin: EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 3),
                        borderRadius: BorderRadius.all(
                            Radius.circular(8.0)
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Colors.grey,
                                        width: 3
                                    )
                                )
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                TextButton(
                                  child: Text('Total Cases', style: TextStyle(
                                      fontSize: 12, color: Colors.blue)),
                                  onPressed: () => provider.TotalCases(),
                                ),
                                TextButton(
                                  child: Text('Total Deaths', style: TextStyle(
                                      fontSize: 12, color: Colors.blue)),
                                  onPressed: () => provider.TotalDeaths(),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 320,
                            height: 100,
                            child: ListView(
                              children: [
                                Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceEvenly,
                                      children: <Widget>[
                                        SizedBox(
                                          width: 78,
                                          child: Text('Country',
                                              style: TextStyle(fontSize: 10),
                                              textAlign: TextAlign.center),
                                        ),
                                        SizedBox(
                                          width: 78,
                                          child: Text('total cases',
                                              style: TextStyle(fontSize: 10),
                                              textAlign: TextAlign.center),
                                        ),
                                        SizedBox(
                                          width: 78,
                                          child: Text('daily cases',
                                              style: TextStyle(fontSize: 10),
                                              textAlign: TextAlign.center),
                                        ),
                                        SizedBox(
                                          width: 78,
                                          child: Text('total deaths',
                                              style: TextStyle(fontSize: 10),
                                              textAlign: TextAlign.center),
                                        ),
                                      ],
                                    ),
                                    ListView.builder(
                                        controller: scrollController,
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        itemCount: countryList.length,
                                        itemBuilder: (context, index) {
                                          return Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceEvenly,
                                            children: <Widget>[
                                              SizedBox(
                                                width: 78,
                                                child: Text(
                                                    '${countryList[index][0]}',
                                                    style: TextStyle(fontSize: 10),
                                                    textAlign: TextAlign.center),
                                              ),
                                              SizedBox(
                                                width: 78,
                                                child: Text(
                                                    '${countryList[index][1]}',
                                                    style: TextStyle(fontSize: 10),
                                                    textAlign: TextAlign.center),
                                              ),
                                              SizedBox(
                                                width: 78,
                                                child: Text(
                                                    '${countryList[index][2]}',
                                                    style: TextStyle(fontSize: 10),
                                                    textAlign: TextAlign.center),
                                              ),
                                              SizedBox(
                                                width: 78,
                                                child: Text(
                                                    '${countryList[index][3]}',
                                                    style: TextStyle(fontSize: 10),
                                                    textAlign: TextAlign.center),
                                              ),
                                            ],
                                          );
                                        }
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                } else {
                  return CircularProgressIndicator();
                }
              },
            )
        )
    );
  }
}

class CasesGraph extends StatelessWidget {
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: CaseCountry(0, [], 1, []),
        child: Consumer<CaseCountry>(
            builder: (BuildContext context, CaseCountry provider, Widget child) => FutureBuilder(
              future: provider.loadCasesGraph(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    width: 320,
                    margin: EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 3),
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    child: Column(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.grey, width: 3))),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextButton(
                                child: Text('Graph1',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.blue)),
                                onPressed: () => provider.GraphOne(),
                              ),
                              TextButton(
                                child: Text('Graph2',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.blue)),
                                onPressed: () => provider.GraphTwo(),
                              ),
                              TextButton(
                                child: Text('Graph3',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.blue)),
                                onPressed: () => provider.GraphThree(),
                              ),
                              TextButton(
                                child: Text('Graph4',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.blue)),
                                onPressed: () => provider.GraphFour(),
                              ),
                            ],
                          ),
                        ),
                        Container(
                            width: 320,
                            height: 150,
                            padding: EdgeInsets.only(top: 8, right: 16),
                            child: LineChart(
                              LineChartData(
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                gridData: FlGridData(
                                  show: true,
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 14,
                                    getTextStyles: (value) => const TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                    ),
                                    getTitles: (value) {
                                      if (provider.getGraphNum() == 1 || provider.getGraphNum() == 2) {
                                        List<String> date = provider.getGraphDate();
                                        switch (value.toInt()) {
                                          case 0:
                                            return date[6].substring(5, 10);
                                          case 1:
                                            return date[5].substring(5, 10);
                                          case 2:
                                            return date[4].substring(5, 10);
                                          case 3:
                                            return date[3].substring(5, 10);
                                          case 4:
                                            return date[2].substring(5, 10);
                                          case 5:
                                            return date[1].substring(5, 10);
                                          case 6:
                                            return date[0].substring(5, 10);
                                        }
                                        return '';
                                      } else {
                                        List<String> date = provider.getGraphDate();
                                        switch (value.toInt()) {
                                          case 2:
                                            return date[24].substring(5, 10);
                                          case 6:
                                            return date[20].substring(5, 10);
                                          case 10:
                                            return date[16].substring(5, 10);
                                          case 14:
                                            return date[12].substring(5, 10);
                                          case 18:
                                            return date[8].substring(5, 10);
                                          case 22:
                                            return date[4].substring(5, 10);
                                          case 26:
                                            return date[0].substring(5, 10);
                                        }
                                      }
                                    },
                                  ),
                                ),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: snapshot.data,
                                    colors: [Colors.blue],
                                    barWidth: 2,
                                  )
                                ],
                              ),
                            )),
                      ],
                    ),
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            )
        )
    );
  }
}

class thirdParams {
  final String params;

  thirdParams(this.params);
}

class ScreenArguments {
  final String userName;
  final String routeName;

  ScreenArguments(this.userName, this.routeName);
}