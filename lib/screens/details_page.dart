import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetailPage extends StatefulWidget {
  final DocumentSnapshot recette;

  DetailPage({this.recette});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    List details = widget.recette.data['categoryDetails'];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.recette.data['title'],
        ),
      ),
      body: Container(
        child: details != null
            ? ListView.builder(
                itemCount: details.length,
                itemBuilder: (_, index) {
                  int number = index + 1;
                  return ListTile(
                    trailing: Container(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal:10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.deepPurple[200]),
                      child: Text(
                        number.toString(),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    title: Text(
                      details[index],
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                    ),
                  );
                },
                // separatorBuilder: (BuildContext context, int index) {
                //   return Divider(
                //     height: 10,
                //     indent: 10,
                //     endIndent: 10,
                //     color: Colors.indigo[800],
                //   );
                // },
              )
            : Center(
                child: Text(
                  'Pas de recettes à afficher.',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
                ),
              ),
      ),
    );
  }
}
