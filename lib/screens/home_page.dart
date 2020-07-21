import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'details_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: ListPage(),
      ),
    );
  }
}

class ListPage extends StatefulWidget {
  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  Future _data;
  bool searchResults = false;
  final _debouncer = Debouncer(milliseconds: 1000);

  var _textController = TextEditingController();

  List<String> queryResultSet = [];
  List<String> wordsList = [];
  List<String> filteredWordsList = [];
  Map<String, String> map5 = {};
  Map<String, String> map6 = {};

  _onEditComplete() {
    setState(() {
      searchResults = false;
    });
  }

  _onEdit() {
    setState(() {
      searchResults = true;
    });
  }

  Future getPosts() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore.collection("recettes").getDocuments();
    return qn.documents;
  }

  void navigateToDetail(DocumentSnapshot recette) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(
          recette: recette,
        ),
      ),
    );
  }

  void _retrieveData(List<DocumentSnapshot> docs) {
    String title;
    String categoryDetailsNumber;

    for (int i = 0; i < docs.length; ++i) {
      for (int j = 0; j < docs[i]['categoryDetails'].length; ++j) {
        queryResultSet.add(docs[i]['categoryDetails'][j]);
        // print('queryResultSet');
        // print(queryResultSet);
        title = docs[i]['title'];
        categoryDetailsNumber = (j + 1).toString();
        // print('title');
        // print(title);
        // print('categoryDetailsNumber');
        // print(categoryDetailsNumber);
        for (int k = 0; k < queryResultSet.length; ++k) {
          map5.putIfAbsent(queryResultSet[k], () => title);
          map6.putIfAbsent(queryResultSet[k], () => categoryDetailsNumber);
          // print('map5');
          // print(map5);
          // print('map6');
          // print(map6);
        }
      }
    }
    wordsList = queryResultSet;
    // print('wordsList');
    // print(wordsList);
  }

  _onSearch(String value) {
    if (value != null) {
      setState(() {
        filteredWordsList =
            wordsList.where((item) => item.contains('$value')).toList();
        // print('filteredWordsList');
        // print(filteredWordsList);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _data = getPosts();
    getPosts().then((value) {
      _retrieveData(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
          child: TextField(
            controller: _textController,
            onChanged: (val) {
              val.isNotEmpty
                  ? _debouncer.run(() {
                      _onSearch(val);
                    })
                  : null;
              _onEdit();
            },
            decoration: InputDecoration(
              prefixIcon: IconButton(
                color: Colors.black,
                icon: Icon(Icons.search),
                onPressed: () {
                  // Navigator.of(context).pop();
                },
              ),
              contentPadding: EdgeInsets.only(left: 25.0),
              hintText: 'Recherche',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              suffixIcon: searchResults == true
                  ? IconButton(
                      color: Colors.black,
                      icon: Icon(Icons.close),
                      onPressed: () {
                        _textController.clear();
                        FocusScopeNode currentFocus = FocusScope.of(context);

                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                          setState(() {
                            _onEditComplete();
                          });
                        }
                      },
                    )
                  : null,
            ),
          ),
        ),
        Expanded(
          child: Container(
            child: FutureBuilder(
              future: _data,
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return searchResults == false
                      ? ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (_, index) {
                            return ListTile(
                              trailing:
                                  snapshot.data[index].data['number'] != null
                                      ? Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 10),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: Colors.indigo[300]),
                                          child: Text(
                                            snapshot.data[index].data['number'],
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        )
                                      : null,
                              title: Text(
                                snapshot.data[index].data['title'],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              onTap: () =>
                                  navigateToDetail(snapshot.data[index]),
                            );
                          },
                        )
                      : ListView.builder(
                          itemCount: filteredWordsList.length,
                          itemBuilder: (_, index) {
                            return ListTile(
                              trailing: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.lightGreen[300]),
                                child: Text(
                                  map6[filteredWordsList[index]],
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              title: Text(
                                filteredWordsList[index],
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w400),
                              ),
                              subtitle: Text(
                                map5[filteredWordsList[index]],
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w400),
                              ),
                            );
                          },
                        );
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

class Debouncer {
  final int milliseconds;
  VoidCallback action;
  Timer _timer;

  Debouncer({this.milliseconds});

  run(VoidCallback action) {
    if (null != _timer) {
      _timer.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
