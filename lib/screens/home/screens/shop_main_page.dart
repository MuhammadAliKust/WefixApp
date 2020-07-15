// import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firestore_auth_crud/screens/home/screens/reviews.dart';
import 'package:firestore_auth_crud/services/models/main.dart';
import 'package:firestore_auth_crud/shared/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class ShopMainPage extends StatefulWidget {
  final MainModel model;
  ShopMainPage(this.model);
  @override
  _ShopMainPageState createState() => _ShopMainPageState();
}

class _ShopMainPageState extends State<ShopMainPage> {
  // FirebaseUser user = await FirebaseAuth.instance.currentUser();
  int rating = 3;
  Stream cars;
  var myImageUrl;
  @override
  void initState() {
    final_rating = 0;

    widget.model.getData().then((results) {
      setState(() {
        cars = results;
      });
    });
    if (final_rating!=0) {
      try {
        widget.model.displayImage().then((f) {
          setState(() {
            myImageUrl = f;
          });
        });
      } catch (e) {
        print(e);
      }
    }else{
      print('kfjklsd');
    }

    super.initState();
  }

  var count = 0.0;
  var final_rating = 0.0;

  Widget _buildScreenUI(BuildContext context) {
    print("1===========================");
    print(myImageUrl.toString());
    return SingleChildScrollView(
      child: Column(children: <Widget>[
        StreamBuilder(
          stream: cars,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, i) {
                    print("2===========================");
                    print(myImageUrl.toString());

                    snapshot.data.documents[i].data['array'].map((values) {});
                    Map<String, dynamic> map = snapshot
                        .data.documents[i].data['array']
                        .forEach((data) {
                      // count = 0;
                      // count = double.parse(data['rating'] + count;
                      print(data['name']);
                      print(data['review']);

                      print(data['rating']);
                      print("Length");
                      print(count);
                      final_rating = 0;

                      var length =
                          snapshot.data.documents[i].data['array'].length;
                      // print(length);
                      // print("===");
                      // print('${count / length}');
                      final_rating = count / length;
                      // count = 0;
                      // length = 0;
                    });
                    count = 0;
                    // widget.model.updateData(rating: final_rating);

                    // print(map["name"]);
                    // print(map["review"]);
                    //return _buildRow(snapshot.data.documents[i].data['name']);
                    return SingleChildScrollView(
                      child: Column(children: <Widget>[
                        _buildImage(context, snapshot, i),
                        _buildRow(context, snapshot, i),
                        SizedBox(
                          height: 20,
                        ),
                        _buildShopDetails(context, snapshot, i),
                        _buildReviewsRatingCard(snapshot, i),
                      ]),
                    );
                  });
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
        SizedBox(
          height: 20,
        )
      ]),
    );
  }

  Widget _buildImage(BuildContext context, var snapshot, int i) {
    print("3===========================");
    print(
      snapshot.data.documents[i].data['image'],
    );
    // return Container(
    //   height: 200,
    //   color: Colors.white,
    //   child: Image.asset(
    //     'assets/img/pic.jpg',
    //     width: MediaQuery.of(context).size.width,
    //     fit: BoxFit.cover,
    //   ),
    // );
    return snapshot.data.documents[i].data['image'] != null
        ? Container(
            height: 200,
            color: Colors.white,
            child: Image.network(
              snapshot.data.documents[i].data['image'],
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
          )
        : CircularProgressIndicator();
  }

  Widget _buildRow(BuildContext context, var snapshot, int i) {
   
    return Container(
      height: 70,
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildShopName(snapshot.data.documents[i].data['name']),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    _buildRatings(snapshot, i),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      '${(snapshot.data.documents[i].data['rating']).toStringAsFixed(2)}',
                      style: label_style,
                    ),
                  ],
                ),
              ),
            ]),
      ),
    );
  }

  Widget _buildShopName(String title) {
    return Text(
      title,
      style: label_style,
    );
  }

  Widget _buildRatings(var snapshot, int i) {
    return SmoothStarRating(
      color: Colors.yellow,
      borderColor: Colors.grey,
      rating: snapshot.data.documents[i].data['rating'].toDouble(),
      isReadOnly: true,
      size: 20,
      filledIconData: Icons.star,
      halfFilledIconData: Icons.star_half,
      defaultIconData: Icons.star_border,
      starCount: 5,
      allowHalfRating: true,
      spacing: 2.0,
      onRated: (value) {
        setState(() {
          rating = snapshot.data.documents[i].data['rating'];
        });
        // print("rating value dd -> ${value.truncate()}");
      },
    );
  }

  Widget _buildShopDetails(BuildContext context, var snapshot, int i) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Card(
        elevation: 6,
        shape: button_border_radius,
        child: Column(
          children: <Widget>[
            _buildHeader('Shop Details', Icons.work),
            Divider(
              thickness: 1.5,
            ),
            _buildShopEmail(snapshot, i),
            _buildPhone(snapshot, i),
            _buildServices(snapshot, i),
            _buildAddress(snapshot, i),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title, IconData iconData) {
    return ListTile(
      leading: Icon(iconData),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildServices(var snapshot, int i) {
    return ListTile(
      leading: Icon(Icons.work),
      title: Text(snapshot.data.documents[i].data['services']),
    );
  }

  Widget _buildShopEmail(var snapshot, int i) {
    return ListTile(
      leading: Icon(Icons.email),
      title: Text(snapshot.data.documents[i].data['email']),
    );
  }

  Widget _buildAddress(var snapshot, int i) {
    return ListTile(
      leading: Icon(Icons.location_on),
      title: Text(snapshot.data.documents[i].data['address']),
    );
  }

  Widget _buildPhone(var snapshot, int i) {
    return ListTile(
      leading: Icon(Icons.call),
      title: Text(snapshot.data.documents[i].data['contact']),
    );
  }

  Widget _buildReviewsRatingCard(var snapshot, int i) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Card(
        elevation: 6,
        shape: button_border_radius,
        child: Column(
          children: <Widget>[
            _buildHeader('Rating & Reviews', Icons.star),
            Divider(
              thickness: 1.5,
            ),
            _buildRatingTile(snapshot, i),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingTile(var snapshot, int i) {
    return ListTile(
      leading: Text(
        '${(snapshot.data.documents[i].data['rating']).toStringAsFixed(2)}',
        style: Theme.of(context)
            .textTheme
            .headline5
            .merge(TextStyle(color: Colors.blueGrey)),
      ),
      title: Text("Tap to view detailed Reviews"),
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => Reviews(widget.model)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff282828),
      body: SafeArea(
        child: _buildScreenUI(context),
      ),
    );
  }
}
