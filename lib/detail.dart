import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Detail extends StatefulWidget {
  const Detail({Key? key, required this.symbol}) : super(key: key);

  final String symbol;

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  bool toggle = false;
  List<String> _name = [];
  List<String> _symbol = [];
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<Response?> detailRes;
  late Future<Response?> priceRes;
  late Future<void> checked;

  Future<Response?> _fetchDetail() async {
    try {
      final res = Dio().get(
          'https://finnhub.io/api/v1/stock/profile2?symbol=${widget.symbol}&token=c9u5fiqad3i9vd5jfjpg');
      return res;
    } catch (e) {
      return null;
    }
  }

  Future<Response?> _fetchPrice() async {
    try {
      final res = await Dio().get(
          'https://finnhub.io/api/v1/quote?symbol=${widget.symbol}&token=c9u5fiqad3i9vd5jfjpg');
      return res;
    } catch (e) {
      return null;
    }
    // return Dio().get(
    //     'https://finnhub.io/api/v1/quote?symbol=${widget.symbol}&token=c9u5fiqad3i9vd5jfjpg');
  }

  Future<void> _check() async {
    final _pref = await _prefs;
    _name = _pref.getStringList('name') ?? [];
    _symbol = _pref.getStringList('symbol') ?? [];
    if (_symbol.contains(widget.symbol)) {
      setState(() {
        toggle = true;
      });
    }
  }

  void _addFav() async {
    await checked;
    final res = await detailRes;
    _name.add(res?.data['name'] ?? '');
    _symbol.add(widget.symbol);
    setState(() {
      toggle = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        "${widget.symbol} was added to watchlist",
        style: const TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white,
    ));
  }

  void _removeFav() async {
    await checked;
    for (int i = 0; i < _symbol.length; ++i) {
      if (_symbol[i] == widget.symbol) {
        _name.removeAt(i);
        _symbol.removeAt(i);
      }
    }
    setState(() {
      toggle = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        "${widget.symbol} was removed from watchlist",
        style: const TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white,
    ));
  }

  @override
  void initState() {
    checked = _check();
    detailRes = _fetchDetail();
    priceRes = _fetchPrice();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_sharp,
            ),
            onPressed: () async {
              final _pref = await _prefs;
              await _pref.setStringList('name', _name);
              await _pref.setStringList('symbol', _symbol);
              Navigator.pop(context, null);
            },
          ),
          title: const Text('Details'),
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
          actions: [
            IconButton(
                onPressed: () {
                  if (toggle == true) {
                    _removeFav();
                  } else {
                    _addFav();
                  }
                },
                icon: toggle
                    ? const Icon(Icons.star)
                    : const Icon(Icons.star_border))
          ]),
      body: FutureBuilder(
        future: Future.wait([detailRes, priceRes]),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List res = snapshot.data as List;
            if (res.contains(null)) {
              return Center(
                child: Text('Failed to fetch stock data',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width * 0.07,
                    )),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        res[0].data['ticker'],
                        style:
                            const TextStyle(color: Colors.white, fontSize: 25),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        res[0].data['name'],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 25,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        res[1].data['c'].toString(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 25),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        res[1].data['d'] >= 0
                            ? '+${res[1].data['d']}'
                            : res[1].data['d'].toString(),
                        style: TextStyle(
                          color:
                              res[1].data['d'] >= 0 ? Colors.green : Colors.red,
                          fontSize: 25,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(children: const [
                    Text(
                      'Stats',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Open',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          res[1].data['o'].toString(),
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 18),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'High',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          res[1].data['h'].toString(),
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Low',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          res[1].data['l'].toString(),
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 18),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Prev',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          res[1].data['pc'].toString(),
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: const [
                      Text(
                        'About',
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 110,
                        child: Text(
                          'Start date',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                      Text(
                        res[0].data['ipo'],
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 110,
                        child: Text(
                          'Industry',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                      Text(
                        res[0].data['finnhubIndustry'],
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 110,
                        child: Text(
                          'Website',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final Uri _url = Uri.parse(res[0].data['weburl']);
                          if (await canLaunchUrl(_url)) {
                            await launchUrl(_url);
                          }
                        },
                        child: Text(
                          res[0].data['weburl'],
                          style:
                              const TextStyle(color: Colors.blue, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 110,
                        child: Text(
                          'Exchange',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                      Text(
                        res[0].data['exchange'],
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 110,
                        child: Text(
                          'Market Cap',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                      Text(
                        res[0].data['marketCapitalization'].toString(),
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(
                color: Color.fromRGBO(176, 134, 241, 1),
              ),
            );
          }
        },
      ),
    );
  }
}

//only pass 'symbol' to this page, the 'name' will be replaced by detail fetching's 'name'
//store the 'name' into sharedpreferene and display in the homepage
// does async computation start when Future is returned ?