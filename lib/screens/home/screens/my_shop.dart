import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firestore_auth_crud/helper/helperFunctions.dart';
import 'package:firestore_auth_crud/main.dart';
import 'package:firestore_auth_crud/screens/authenticat/login.dart';
import 'package:firestore_auth_crud/screens/home/screens/clients/chatroom.dart';
import 'package:firestore_auth_crud/screens/home/screens/edit_shop_info.dart';
import 'package:firestore_auth_crud/screens/home/screens/owner/chatRoom.dart';
import 'package:firestore_auth_crud/screens/home/screens/shop_main_page.dart';
import 'package:firestore_auth_crud/services/models/main.dart';
import 'package:firestore_auth_crud/shared/constant.dart';
import 'package:flutter/material.dart';

class MyShop extends StatefulWidget {
  final MainModel model;
  MyShop({this.model});

  @override
  _MyShopState createState() => _MyShopState();
}

class _MyShopState extends State<MyShop> {
  Stream cars;

  @override
  void initState() {
    widget.model.getCurrentUser().then((results) {
      setState(() {
        cars = results;
      });
    });
    super.initState();
  }

  Widget _buildScreenUI(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          InkWell(
            child: _buildNavigationsTile('View Main Page', Icons.person),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ShopMainPage(widget.model)));
            },
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            child: _buildNavigationsTile('Edit Shop Information', Icons.edit),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => EditShopInfo(
                        model: widget.model,
                      )));
            },
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            child: _buildNavigationsTile('Messages', Icons.message),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => OwnerChatRoom()));
            },
          ),
        ]);
  }

  Widget _buildNavigationsTile(String title, IconData iconData) {
    return Card(
      color: Color(0xff1b1b1b),
      child: _buildListTile(title, iconData),
    );
  }

  Widget _buildListTile(String title, IconData iconData) {
    return ListTile(
      title: _buildTitle(title),
      trailing: _buildTrailing(iconData),
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: label_style,
    );
  }

  Widget _buildTrailing(IconData icon) {
    return Icon(
      icon,
      color: icon_color,
    );
  }

  Future<bool> _onBackPressed() {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Do you want to exit?"),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: Text("No")),
                FlatButton(
                    onPressed: () {
                      exit(0);
                    },
                    child: Text("yes"))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: StreamBuilder(
              stream: cars,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                      "Welcome ${snapshot.data.documents[0].data['name']}");
                } else {
                  return Text("Loading....");
                }
              }),
          backgroundColor: Colors.black,
          actions: <Widget>[
            FlatButton.icon(
                onPressed: () {
                  HelperFunctions.ClearSharedPreference();
                  widget.model.signOut().then((value) => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => Login())));
                },
                icon: Icon(
                  Icons.exit_to_app,
                  color: Colors.white,
                ),
                label: Text(
                  "LogOut",
                  style: label_style,
                ))
          ],
          elevation: 0,
        ),
        backgroundColor: Color(0xff282828),
        body: SafeArea(
          child: _buildScreenUI(context),
        ),
      ),
    );
  }
}
