import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_auth_crud/services/models/main.dart';
import 'package:flutter/material.dart';

class ShopList extends StatefulWidget {
  final MainModel model;
  ShopList(this.model);
  @override
  _ShopListState createState() => _ShopListState();
}

class _ShopListState extends State<ShopList> {
  Stream cars;

  @override
  void initState() {
    widget.model.displayShops().then((results) {
      setState(() {
        cars = results;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Shop List')),
      body: StreamBuilder(
        stream: cars,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, i) {
                  print(snapshot.data.documents.length);
                  return ListTile(
                    title: Text(snapshot.data.documents[i].data['name']),
                    trailing: IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: () {
                        widget.model.addFavShops(
                          selID: snapshot.data.documents[i].documentID,
                          uid: widget.model.getUserID(),
                          name: snapshot.data.documents[i].data['name'],
                          address: snapshot.data.documents[i].data['address'],
                          email: snapshot.data.documents[i].data['email'],
                          services: snapshot.data.documents[i].data['services'],
                          number: snapshot.data.documents[i].data['number'],
                        );
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
