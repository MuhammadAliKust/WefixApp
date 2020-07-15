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

class ShopDetails extends StatefulWidget {
  final MainModel model;
  final String image;
  final String name;
  final String email;
  final String number;
  final String service;
  final double rating;
  final int i;

  ShopDetails(
      {this.i,
      this.image,
      this.name,
      this.email,
      this.number,
      this.service,
      this.rating,
      this.model});
  @override
  _ShopDetailsState createState() => _ShopDetailsState();
}

class _ShopDetailsState extends State<ShopDetails> {
  // FirebaseUser user = await FirebaseAuth.instance.currentUser();
  var rating = 0.0;
  Stream cars;
  var myImageUrl;
  final _formKey = GlobalKey<FormState>();
  var count = 0.0;
  var final_rating = 0.0;
  final List<Map> ShopsList = [];
  final List<Map> LawyerList = [];
  final List<Map> UsersList = [];
  final List<dynamic> FavShopsList = [];
  List<Map> ratingList = List();
  TextEditingController text = TextEditingController();
  TextEditingController stars = TextEditingController();
  var star;

  @override
  void initState() {
    UsersList.clear();

    widget.model.getShopsData().then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) => LawyerList.add(f.data));
      setState(() {});
    });

    widget.model.clientName().then((snapshot) {
      snapshot.documents.forEach((f) => UsersList.add(f.data));
      setState(() {});
    });
    super.initState();
  }

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
            Firestore.instance
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

              print(final_rating);
              print(rating);
              final_rating = count / (length + 1);
              print(count);
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

  Widget _buildScreenUI(BuildContext context) {
    print("1===========================");
    print(myImageUrl.toString());
    return SingleChildScrollView(
      child: Column(children: <Widget>[
        _buildImage(context, widget.image),
        _buildRow(context),
        SizedBox(
          height: 20,
        ),
        _buildShopDetails(context),
        _buildReviewsRatingCard(widget.rating),
        SizedBox(
          height: 20,
        )
      ]),
    );
  }

  Widget _buildImage(BuildContext context, String image) {
    return Container(
      height: 200,
      color: Colors.white,
      child: Image.network(
        image,
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildRow(BuildContext context) {
    return Container(
      height: 70,
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildShopName(widget.name),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    _buildRatings(widget.rating),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      '${widget.rating.toStringAsFixed(2)}',
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

  Widget _buildRatings(double rating) {
    return SmoothStarRating(
      color: Colors.yellow,
      borderColor: Colors.grey,
      rating: rating,
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

  Widget _buildShopDetails(BuildContext context) {
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
            _buildShopEmail(widget.email),
            _buildPhone(widget.number),
            _buildServices(widget.service),
            _buildAddress(widget.number),
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

  Widget _buildServices(String services) {
    return ListTile(
      leading: Icon(Icons.work),
      title: Text(services),
    );
  }

  Widget _buildShopEmail(String email) {
    return ListTile(
      leading: Icon(Icons.email),
      title: Text(email),
    );
  }

  Widget _buildAddress(String address) {
    return ListTile(
      leading: Icon(Icons.location_on),
      title: Text(address),
    );
  }

  Widget _buildPhone(String number) {
    return ListTile(
      leading: Icon(Icons.call),
      title: Text(number),
    );
  }

  Widget _buildReviewsRatingCard(double rating) {
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
            _buildRatingTile(rating),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingTile(double rating) {
    return ListTile(
      leading: Text(
        '${rating.toStringAsFixed(2)}',
        style: Theme.of(context)
            .textTheme
            .headline5
            .merge(TextStyle(color: Colors.blueGrey)),
      ),
      title: Text("Tap to view detailed Reviews"),
      onTap: () {
        showDialog(
            barrierDismissible: false,
            context: context,
            child: Form(key: _formKey, child: _buildDialog(context, widget.i)));
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
