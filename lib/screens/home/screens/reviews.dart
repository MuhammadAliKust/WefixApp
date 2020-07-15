import 'package:firestore_auth_crud/services/models/main.dart';
import 'package:firestore_auth_crud/shared/constant.dart';
import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class Reviews extends StatefulWidget {
  final MainModel model;
  Reviews(this.model);
  @override
  _ReviewsState createState() => _ReviewsState();
}

class _ReviewsState extends State<Reviews> {
  Stream cars;
  @override
  void initState() {
    widget.model.getData().then((results) {
      setState(() {
        cars = results;
      });
    });
    super.initState();
  }

  Widget _buildScreenUI() {
    return StreamBuilder(
        stream: cars,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildListView(snapshot);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget _buildListView(var snapshot) {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: snapshot.data.documents.length,
        itemBuilder: (context, i) {
          return _buildColumn(snapshot, i);
          // return Column(
          //   children: <Widget>[
          //     for (var j = 0;
          //         j <
          //             snapshot
          //                 .data.documents[i].data['comments'].length;
          //         j++)
          //       Column(
          //         children: <Widget>[
          //           Text(snapshot.data.documents[i].data['comments']
          //               [j]['name']),
          //           Text(snapshot.data.documents[i].data['comments']
          //               [j]['review']),
          //         ],
          //       )
          //   ],
          // );
        });
  }

  Widget _buildColumn(var snapshot, int i) {
    print(snapshot.data.documents[i].data['array'].length);
    if (snapshot.data.documents[i].data['array'].length > 0) {
      return Column(
        children: <Widget>[
          ...snapshot.data.documents[i].data['array'].map((values) {
            return Column(
              children: <Widget>[
                ListTile(
                  leading: CircleAvatar(child: Text(values['name'][0])),
                  title: Text(
                    values['name'],
                    style: label_style,
                  ),
                  subtitle: Text(
                    values['review'],
                    style: label_style,
                  ),
                  trailing: SmoothStarRating(
                    color: Colors.yellow,
                    borderColor: Colors.grey,
                    rating: values['rating'].toDouble(),
                    isReadOnly: true,
                    size: 20,
                    filledIconData: Icons.star,
                    halfFilledIconData: Icons.star_half,
                    defaultIconData: Icons.star_border,
                    starCount: 5,
                    allowHalfRating: true,
                    spacing: 2.0,
                  ),
                ),
                Divider(),
              ],
            );
          }).toList()
        ],
      );
    } else {
      return Container(
        height: MediaQuery.of(context).size.height - 50,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Text(
            "No reviews available for your shop",
            style: label_style,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xff282828),
        appBar: AppBar(
          title: Text("Reviews"),
          backgroundColor: Colors.black,
          elevation: 0,
        ),
        body: SafeArea(child: _buildScreenUI()));
  }
}
