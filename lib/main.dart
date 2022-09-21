import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:core';
import 'package:intl/intl.dart';
import 'package:stock_watch/search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_watch/detail.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Watch',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const MyHomePage(title: 'Stock'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Timer? _timer;
  String? _date;
  late List<String> _name = [];
  late List<String> _symbol = [];

  void _getList() async {
    final _pref = await SharedPreferences.getInstance();
    setState(() {
      _name = _pref.getStringList('name') ?? [];
      _symbol = _pref.getStringList('symbol') ?? [];
    });
  }

  void _getDate() {
    setState(() {
      _date = DateFormat.MMMMd().format(DateTime.now()).toString();
    });
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _getDate();
    });
    _getList();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), actions: [
        IconButton(
            onPressed: () {
              showSearch(context: context, delegate: CustomSearchDelegate())
                  .then((data) {
                if (data != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Detail(
                        symbol: data['symbol'],
                      ),
                    ),
                  ).then((data) {
                    _getList();
                  });
                }
              });
            },
            icon: const Icon(Icons.search)),
      ]),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.03),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Text(
              'STOCK WATCH',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.height * 0.035,
              ),
            ),
            Text(
              _date ?? '',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.height * 0.035,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            Text(
              'Favorites',
              textAlign: TextAlign.start,
              style: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.height * 0.025,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            const Divider(
              color: Colors.white,
              height: 1,
              thickness: 2,
            ),
            Expanded(
              child: ListView.separated(
                  separatorBuilder: (context, index) {
                    return const Divider(
                      color: Colors.white,
                      height: 1,
                      thickness: 2,
                    );
                  },
                  itemCount: _name.isEmpty ? 1 : _name.length,
                  itemBuilder: (context, index) {
                    if (_name.isEmpty) {
                      return Column(
                        children: [
                          const SizedBox(height: 15),
                          Text(
                            'Empty',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.03,
                            ),
                          ),
                        ],
                      );
                    }
                    final key = _symbol[index];
                    return Dismissible(
                      confirmDismiss: (DismissDirection direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              insetPadding: const EdgeInsets.symmetric(
                                  horizontal: 30.0, vertical: 24.0),
                              backgroundColor: Colors.grey[800],
                              title: const Text(
                                "Delete Confirmation",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              content: const Text(
                                "Are you sure you want to delete this item?",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  child: const Text(
                                    "Delete",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                              ],
                            );
                          },
                        );
                      },
                      background: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        color: Colors.red,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [
                            Icon(Icons.delete, color: Colors.white),
                          ],
                        ),
                      ),
                      direction: DismissDirection.endToStart,
                      key: Key(key),
                      onDismissed: (direction) async {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                            "${_symbol[index]} was removed from watchlist",
                            style: const TextStyle(color: Colors.black),
                          ),
                          backgroundColor: Colors.white,
                        ));
                        setState(() {
                          _name.removeAt(index);
                          _symbol.removeAt(index);
                        });
                        final _pref = await SharedPreferences.getInstance();
                        await _pref.setStringList('name', _name);
                        await _pref.setStringList('symbol', _symbol);
                      },
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Detail(
                                symbol: _symbol[index],
                              ),
                            ),
                          ).then((value) => _getList());
                        },
                        title: Text(
                          _symbol[index],
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.02),
                        ),
                        subtitle: Text(
                          _name[index],
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.02),
                        ),
                      ),
                    );
                  }),
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.stretch,
        ),
      ),
    );
  }
}


// UniqueKey() can delete without confirmDismiss, can't delete with confirmDismiss, Y?