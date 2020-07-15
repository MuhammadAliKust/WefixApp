import 'package:firestore_auth_crud/helper/helperFunctions.dart';
import 'package:firestore_auth_crud/screens/home/screens/clients/client_homepage.dart';
import 'package:firestore_auth_crud/screens/home/screens/clients/fav_shops.dart';
import 'package:firestore_auth_crud/screens/home/screens/clients/profile.dart';
import 'package:firestore_auth_crud/screens/home/screens/clients/signUp.dart';
import 'package:firestore_auth_crud/screens/home/screens/fav_shops.dart';
import 'package:firestore_auth_crud/services/models/main.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final MainModel model;
  AppDrawer(this.model);
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _createHeader(),
          _createDrawerItem(
              icon: Icons.shopping_basket,
              text: 'Shops',
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ClientHomePage(model)));
                // Navigator.pushNamed(context, OrdersView);
              }),
          _createDrawerItem(
            icon: Icons.history,
            text: 'Favourite Shops',
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => MyFavShops(model)));

              // Navigator.pushNamed(context, OrderHistoryView);
            },
          ),
          Divider(),
          _createDrawerItem(
              icon: Icons.person,
              text: 'Profile',
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => Profile(model)));

                // Navigator.pushNamed(context, DetailedProfileView);
              }),

          // _createDrawerItem(icon: Icons.help, text: 'Help and Support'),
          Divider(),
          // _createDrawerItem(icon: Icons.bug_report, text: 'Report an issue'),
          _createDrawerItem(
              icon: Icons.exit_to_app,
              text: 'Logout',
              onTap: () {
                HelperFunctions.ClearSharedPreference();
                model.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => ClientLogin()),
                    (Route<dynamic> route) => false);
              }),
          ListTile(
            title: Text('0.0.1'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _createHeader() {
    return DrawerHeader(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.fill, image: AssetImage("assets/img/bg.jpg"))),
        child: Stack(children: <Widget>[]));
  }

  Widget _createDrawerItem(
      {IconData icon, String text, GestureTapCallback onTap}) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(icon),
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(text),
          )
        ],
      ),
      onTap: onTap,
    );
  }
}
