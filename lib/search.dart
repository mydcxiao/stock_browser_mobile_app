import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class CustomSearchDelegate extends SearchDelegate {
  Future<Response> _search() async {
    return Dio().get(
        'https://finnhub.io/api/v1/search?q=$query&token=c9u5fiqad3i9vd5jfjpg');
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          iconTheme: theme.primaryIconTheme.copyWith(color: Colors.grey),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: InputBorder.none,
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color.fromRGBO(176, 134, 241, 1),
        ),
        hintColor: Colors.grey,
        textTheme: theme.textTheme.copyWith(
          headline6: const TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          ),
        ));
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
          }
        },
        icon: const Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_sharp),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return Center(
          child: Text(
        'No suggestion found!',
        style: TextStyle(
            fontSize: MediaQuery.of(context).size.height * 0.04,
            color: Colors.white),
      ));
    }
    return FutureBuilder(
      future: _search(),
      builder: ((context, snapshot) {
        Widget child;
        if (snapshot.hasData) {
          Response res = snapshot.data as Response;
          if (res.data['count'] == 0) {
            child = Center(
                child: Text(
              'No suggestion found!',
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.04,
                  color: Colors.white),
            ));
          } else {
            child = ListView.builder(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.02),
              itemCount: res.data['count'],
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    close(context, res.data['result'][index]);
                  },
                  title: Text(
                    '${res.data['result'][index]['displaySymbol']} | ${res.data['result'][index]['description']}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width * 0.045,
                    ),
                  ),
                );
              },
            );
          }
        } else if (snapshot.hasError) {
          child = Center(
              child: Text(
            'No suggestion found!',
            style: TextStyle(
                fontSize: MediaQuery.of(context).size.height * 0.04,
                color: Colors.white),
          ));
        } else {
          child = const Center(
            child: CircularProgressIndicator(
              color: Color.fromRGBO(176, 134, 241, 1),
            ),
          );
        }
        return child;
      }),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(
          child: Text(
        'No suggestion found!',
        style: TextStyle(
            fontSize: MediaQuery.of(context).size.height * 0.04,
            color: Colors.white),
      ));
    }
    return FutureBuilder(
      future: _search(),
      builder: ((context, snapshot) {
        Widget child;
        if (snapshot.hasData) {
          Response res = snapshot.data as Response;
          if (res.data['count'] == 0) {
            child = Center(
                child: Text(
              'No suggestion found!',
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.04,
                  color: Colors.white),
            ));
          } else {
            child = ListView.builder(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.02),
              itemCount: res.data['count'],
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    close(context, res.data['result'][index]);
                  },
                  title: Text(
                    '${res.data['result'][index]['displaySymbol']} | ${res.data['result'][index]['description']}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width * 0.045,
                    ),
                  ),
                );
              },
            );
          }
        } else if (snapshot.hasError) {
          child = Center(
              child: Text(
            'No suggestion found!',
            style: TextStyle(
                fontSize: MediaQuery.of(context).size.height * 0.04,
                color: Colors.white),
          ));
        } else {
          child = const Center(
            child: CircularProgressIndicator(
              color: Color.fromRGBO(176, 134, 241, 1),
            ),
          );
        }
        return child;
      }),
    );
  }
}
