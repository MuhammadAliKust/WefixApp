import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firestore_auth_crud/helper/constants.dart';
import 'package:firestore_auth_crud/helper/helperFunctions.dart';
import 'package:firestore_auth_crud/screens/home/screens/clients/chat.dart';
import 'package:firestore_auth_crud/screens/home/screens/clients/search.dart';
import 'package:firestore_auth_crud/screens/home/screens/clients/shop_details.dart';
import 'package:firestore_auth_crud/services/models/database.dart';
import 'package:firestore_auth_crud/services/models/main.dart';
import 'package:firestore_auth_crud/shared/constant.dart';
import 'package:firestore_auth_crud/shared/drawer.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import 'chatroom.dart';

class ClientHomePage extends StatefulWidget {
  final MainModel model;

  ClientHomePage(this.model);
  @override
  _ClientHomePageState createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  var rating = 0.0;
  QuerySnapshot data;
  var final_rating = 0.0;
  var clientName;
  @override
  void initState() {
    UsersList.clear();
    Firestore.instance
        .collection('FavShops')
        .getDocuments()
        .then((QuerySnapshot shops) {
      shops.documents.forEach((f) => ShopsList.add(f.data));
    });

    widget.model.getShopsData().then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) => LawyerList.add(f.data));
      setState(() {});
    });

    widget.model.displayFavShopsDocs().then((snapshot) {
      snapshot.documents.forEach((f) {
        print(f.data['id']);
        FavShopsList.add(f.data['shopId']);
      });
      setState(() {});
    });

    widget.model.clientName().then((snapshot) {
      snapshot.documents.forEach((f) => UsersList.add(f.data));
      setState(() {});
    });
    getUserName().then((value) {
      setState(() {});
    });
    super.initState();
  }

  getUserName() async {
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    print('=======================');
    print(Constants.myName);
  }

  //List And Filter List

  final List<Map> ShopsList = [];
  final List<Map> LawyerList = [];
  final List<Map> UsersList = [];
  final List<dynamic> FavShopsList = [];
  List<Map> _filteredList = List();
  List<Map> ratingList = List();
  var count = 0.0;
  TextEditingController text = TextEditingController();
  TextEditingController stars = TextEditingController();
  var star;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = true;
  //Assigning values to filter list
  _filterItems(String val) {
    _filteredList.clear();
    for (var i in LawyerList) {
      var name = i['name'].toString().toLowerCase();
      if (name == val || name.contains(val)) {
        _filteredList.add(i);
      }
    }
    setState(() {});
  }

  Widget _buildScreenUI() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: TextField(
            style: TextStyle(
              color: Color(0xffc79035),
            ),
            cursorColor: Color(0xffc79035),
            decoration: InputDecoration(
                labelText: "Search Shop",
                labelStyle: TextStyle(color: Color(0xffc79035)),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffc79035))),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffc79035))),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffc79035)))),
            onChanged: (val) {
              _filterItems(val);
            },
          ),
        ),
        _buildMyListView(context),
      ],
    );
  }

  Widget _buildMyListView(BuildContext context) {
    return Container(
      child: Expanded(
        child: Container(
          child: ListView.builder(
              itemCount: _filteredList.isEmpty
                  ? LawyerList.length
                  : _filteredList.length,
              itemBuilder: (context, i) {
                return GestureDetector(
                  child: Card(
                    color: Colors.transparent,
                    elevation: 0,
                    child: _buildCard(context, i),
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ShopDetails(
                              model: widget.model,
                              i: i,
                              image: LawyerList[i]['image'],
                              name: LawyerList[i]['name'],
                              email: LawyerList[i]['email'],
                              number: LawyerList[i]['contact'],
                              service: LawyerList[i]['services'],
                              rating: LawyerList[i]['rating'].toDouble(),
                            )));
                    // showDialog(
                    //     barrierDismissible: false,
                    //     context: context,
                    //     child: Form(
                    //         key: _formKey, child: _buildDialog(context, i)));
                  },
                );
              }),
        ),
      ),
    );
  }

  // Widget _buildItems(context, i) {
  //   print("Item Called=====================");
  //   return
  // }

  Widget _buildDialog(context, i) {
    return AlertDialog(
      backgroundColor: Color(0xff282828),
      title: Text(
        "Comment Here!",
        style: label_style,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextFormField(
            style: label_style,
            decoration: InputDecoration(
                enabledBorder: underline_input_border,
                focusedBorder: underline_input_border),
            controller: text,
            validator: (val) => val.isEmpty ? 'Comment canot be null' : null,
            onSaved: (val) {
              // review = val;
            },
          ),
          SizedBox(
            height: 10,
          ),
          Text("Give us your feedback!", style: label_style),
          SizedBox(
            height: 20,
          ),
          SmoothStarRating(
            color: Colors.yellow,
            borderColor: Colors.grey,
            rating: rating,
            isReadOnly: false,
            size: 30,
            filledIconData: Icons.star,
            halfFilledIconData: Icons.star_half,
            defaultIconData: Icons.star_border,
            starCount: 5,
            allowHalfRating: true,
            spacing: 2.0,
            onRated: (value) {
              setState(() {
                rating = value;
                count = value;
              });
            },
          )
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Save'),
          onPressed: () async {
            if (!_formKey.currentState.validate()) {
              return;
            }

            var length = 0;
            var star = 0;
            await Firestore.instance
                .collection('Shops')
                .getDocuments()
                .then((QuerySnapshot snapshot) {
              snapshot.documents[i].data['array'].forEach((data) {
                count = (data['rating']).toDouble() + count;

                setState(() {
                  length = snapshot.documents[i].data['array'].length;
                });
                // print('${count / length}');
              });
              print("===================================");
              print(rating);
              final_rating = count / (length + 1);
              print(count);
              print(final_rating);
              count = 0;
            });
            print("%%%%%%%%%%%%");
            print(length);
            //  var length = LawyerList[i]['array'];

            _formKey.currentState.save();
            print('^^^^^^^^^^^^^^^^^^^^^^^^^^');
            await print(final_rating);
            Firestore.instance
                .collection('Shops')
                .document(LawyerList[i]['id'])
                .setData({
              'name': LawyerList[i]['name'],
              // address: snapshot.data.documents[i].data['address'],
              'number': LawyerList[i]['contact'],
              'uid': '1',
              'email': LawyerList[i]['email'],
              'services': LawyerList[i]['services'],
              'rating': final_rating,
              'array': FieldValue.arrayUnion([
                {
                  'name': UsersList[0]['name'],
                  'review': text.text,
                  'rating': rating.toInt()
                }
              ])
            }, merge: true);
            stars.clear();
            text.clear();
            rating = 0;
            Navigator.pop(context);
          },
        )
      ],
    );
  }

  void getData() {
    Firestore.instance
        .collection('Shops')
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) => LawyerList.add(f.data));
    });

    setState(() {});
  }

  get shopRating {
    return final_rating;
  }

  void setRating(int i) async {
    Firestore.instance
        .collection('Shops')
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents[i].data['array'].forEach((data) {
        count = (data['rating']).toDouble() + count;
        var length = snapshot.documents[i].data['array'].length;

        // print('${count / length}');
        final_rating = count / length;
      });
      print("===================================");
      print(count);
      print(final_rating);
      count = 0;
    });
  }

  Widget _buildCard(BuildContext context, int i) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(children: <Widget>[
          _buildContainer(context, i),
          _buildListTile(context, i),
          SizedBox(
            height: 20,
          )
        ]));
  }

  Widget _buildContainer(BuildContext context, int i) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 170,
      decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        child: Image.network(
          LawyerList[i]['image'],
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, int i) {
    return Container(
      color: Colors.blueGrey,
      child: ListTile(
          title: _buildTitle(context, i),
          subtitle: _buildRatings(context, i),
          trailing: _buildTrailing(context, i)),
    );
  }

  Widget _buildTitle(BuildContext context, int i) {
    return Text(
      _filteredList.isEmpty ? LawyerList[i]['name'] : _filteredList[i]['name'],
      style: Theme.of(context)
          .textTheme
          .title
          .merge(TextStyle(color: Colors.white)),
    );
  }

  Widget _buildRatings(BuildContext context, int i) {
    return SmoothStarRating(
      color: Colors.yellow,
      borderColor: Colors.grey,
      rating: LawyerList[i]['rating'].toDouble(),
      isReadOnly: true,
      size: 20,
      filledIconData: Icons.star,
      halfFilledIconData: Icons.star_half,
      defaultIconData: Icons.star_border,
      starCount: 5,
      allowHalfRating: true,
      spacing: 2.0,
    );
  }

  Widget _buildTrailing(BuildContext context, int i) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.chat, color: Colors.white),
          onPressed: () {
            sendMessage(LawyerList[i]['username']);
            // String chatRoomId = getChatRoomId(Constants.myName, userName);
            // Navigator.of(context).push(MaterialPageRoute(
            //     builder: (context) => sendMessage(LawyerList[i]['name'])));
          },
        ),
        IconButton(
            icon: !FavShopsList.contains(LawyerList[i]['id'])
                ? Icon(Icons.favorite_border, color: Colors.red)
                : Icon(
                    Icons.favorite,
                    color: Colors.redAccent,
                  ),
            onPressed: () async {
              if (!FavShopsList.contains(LawyerList[i]['id'])) {
                await widget.model.addFavShops(
                  image: LawyerList[i]['image'],
                  selID: LawyerList[i]['id'],
                  name: LawyerList[i]['name'],
                  // address: snapshot.data.documents[i].data['address'],
                  number: LawyerList[i]['contact'],
                  uid: '1',
                  rating: LawyerList[i]['rating'].toDouble(),
                  email: LawyerList[i]['email'],
                  services: LawyerList[i]['services'],
                );
                _showScaffold("Added to Favourite.");
              }
              setState(() {
                FavShopsList.add(LawyerList[i]['id']);
              });
            }),
        IconButton(
          onPressed: () {
            try {
              print(LawyerList[i]['address']);
              MapsLauncher.launchQuery(LawyerList[i]['address']);
            } catch (e) {
              print(e);
            }
          },
          icon: Icon(Icons.directions),
          color: Colors.white,
        ),
      ],
    );
  }

  DatabaseMethods databaseMethods = new DatabaseMethods();

  /// 1.create a chatroom, send user to the chatroom, other userdetails
  sendMessage(String userName) {
    print("My Name");
    print(Constants.myName);
    print("Username");
    print(userName);
    List<String> users = [Constants.myName, userName];

    String chatRoomId = getChatRoomId(Constants.myName, userName);

    Map<String, dynamic> chatRoom = {
      "users": users,
      "chatRoomId": chatRoomId,
    };

    databaseMethods.addChatRoom(chatRoom, chatRoomId);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Chat(
                  chatRoomId: chatRoomId,
                )));
  }

  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    getUserName();
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xff282828),
      appBar: AppBar(
        title: Text('Our Markets'),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Builder(builder: (BuildContext context) {
          return IconButton(
            icon: Icon(Icons.sort),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        }),
      ),
      drawer: AppDrawer(widget.model),
      body: _buildScreenUI(),
    );
  }

  void _showScaffold(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
}
