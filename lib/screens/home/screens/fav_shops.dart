import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:firestore_auth_crud/services/models/main.dart';
import 'package:flutter/material.dart';

class FavShops extends StatefulWidget {
  final MainModel model;
  FavShops(this.model);
  @override
  _FavShopsState createState() => _FavShopsState();
}

class _FavShopsState extends State<FavShops> {
  List cars;
  Stream cars1;
  @override
  void initState() {
    widget.model.displayShops().then((results) {
      setState(() {
        cars1 = results;
      });
    });
    super.initState();
  }

  // List<String> productName = [];

  // Stream<QuerySnapshot> productRef =
  //     Firestore.instance.collection('Shops').snapshots();

  // var collection = Firestore.instance.collection('Shops').snapshots();

  @override
  Widget build(BuildContext context) {
    // print("===========");
    // productRef.forEach((field) async {
    //   await field.documents.asMap().forEach((index, data) {
    //     productName.add(field.documents[index]["address"]);
    //   });
    // });
    // print(productName);
    bool isAvailable = false;
    return Scaffold(
      appBar: AppBar(title: Text('Favourite Shops')),
      body: StreamBuilder(
        stream: cars1,
        builder: (context, snapshot) {
          // _list = Firestore.instance.collection('shops').snapshots();
          if (snapshot.hasData) {
            print(snapshot.data.documents.length);
            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, i) {
                  // snapshot.data.documents[i].data['user'].forEach((data) {
                  //   print(data);
                  //   // if (data == '1') {
                  //   //   print("done");
                  //   //   isAvailable = true;
                  //   // }
                  // });
                  return ListTile(
                    title: Text(snapshot.data.documents[i].data['name']),
                    trailing: IconButton(
                      icon: isAvailable
                          ? Icon(Icons.arrow_forward)
                          : Icon(Icons.favorite),
                      onPressed: () {
                        widget.model.deleteFavShop(
                            snapshot.data.documents[i].documentID);
                      },
                    ),
                  );
                });
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
