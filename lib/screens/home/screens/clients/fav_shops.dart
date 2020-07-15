import 'package:firestore_auth_crud/services/models/main.dart';
import 'package:firestore_auth_crud/shared/drawer.dart';
import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class MyFavShops extends StatefulWidget {
  final MainModel model;
  MyFavShops(this.model);
  @override
  _MyFavShopsState createState() => _MyFavShopsState();
}

class _MyFavShopsState extends State<MyFavShops> {
  Stream cars;
  @override
  void initState() {
    widget.model.displayFavShops().then((results) {
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
            return _buildListView(snapshot, context);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget _buildListView(var snapshot, BuildContext context) {
    return ListView.builder(
        itemCount: snapshot.data.documents.length,
        itemBuilder: (context, i) {
          return Card(
            color: Colors.transparent,
            elevation: 0,
            child: _buildCard(snapshot, context, i),
          );
        });
  }

  Widget _buildCard(var snapshot, BuildContext context, int i) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(children: <Widget>[
          _buildContainer(snapshot, context, i),
          _buildListTile(snapshot, context, i),
          SizedBox(
            height: 20,
          )
        ]));
  }

  Widget _buildContainer(var snapshot, BuildContext context, int i) {
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
          snapshot.data.documents[i].data['image'],
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildListTile(var snapshot, BuildContext context, int i) {
    return Container(
      color: Colors.blueGrey,
      child: ListTile(
          title: _buildTitle(snapshot, context, i),
          subtitle: _buildRatings(snapshot, context, i),
          trailing: _buildTrailing(snapshot, context, i)),
    );
  }

  Widget _buildTitle(var snapshot, BuildContext context, int i) {
    return Text(
      snapshot.data.documents[i].data['name'],
      style: Theme.of(context)
          .textTheme
          .title
          .merge(TextStyle(color: Colors.white)),
    );
  }

  Widget _buildRatings(var snapshot, BuildContext context, int i) {
    print(snapshot.data.documents[i].data['rating']);
    return SmoothStarRating(
      color: Colors.yellow,
      borderColor: Colors.grey,
      rating:snapshot.data.documents[i].data['rating'],
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
          // rating = snapshot.data.documents[i].data['rating'];
        });
        // print("rating value dd -> ${value.truncate()}");
      },
    );
  }

  Widget _buildTrailing(var snapshot, BuildContext context, int i) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
            icon: Icon(
              Icons.favorite,
              color: Colors.red,
            ),
            onPressed: () {
              widget.model.removeFavShop(
                snapshot.data.documents[i].documentID,
              );
            }),
        Icon(
          Icons.directions,
          color: Colors.white,
        ),
      ],
    );
  }

  bool _isFav = false;
  int _index;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff282828),
      appBar: AppBar(
        title: Text('Favourite Markets'),
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
      // body: SafeArea(child: ListView.builder(itemBuilder: (context, i) {
      //   return ListTile(
      //     title: Text('title'),
      //     subtitle: Text("subtitle"),
      //     trailing: IconButton(
      //         icon:
      //             i!=id ? Icon(Icons.favorite_border) : Icon(Icons.favorite),
      //         onPressed: () {
      //           print(i);
      //           setState(() {
      //             _isFav = true;
      //           });
      //           selID(i);
      //         }),
      //   );
      // })),
    );
  }

  int selectedIndex = 0;

  // changeValue(int val, int index) {
  //   setState(() {
  //     radio[index].selectedRadio = val;
  //   });
  // }

  void selectedValue(int index) {
    selectedIndex = index;
  }

  int get selectIndex {
    return selectedIndex;
  }

  void selID(int index) {
    _index = index;
  }

  int get id {
    return _index;
  }
}
