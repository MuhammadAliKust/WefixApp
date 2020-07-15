import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firestore_auth_crud/services/models/main.dart';
import 'package:firestore_auth_crud/shared/drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ProfileSettingsDialog.dart';

class Profile extends StatefulWidget {
  final MainModel model;
  Profile(this.model);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Stream data;
  @override
  void initState() {
    widget.model.getUserName().then((results) {
      setState(() {
        data = results;
      });
    });
    super.initState();
  }

  Widget _buildScreenUI(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 0.2 * MediaQuery.of(context).size.height,
        ),
        _buildDeliveryBoyDetails(context),
      ],
    );
  }

  Widget _buildDpRow(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 28.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // _buildUserDp(),
          // SizedBox(
          //   width: 40,
          // ),
          _buildEditButton(context),
        ],
      ),
    );
  }

  Widget _buildUserDp() {
    return CircleAvatar(
      radius: 40,
      // backgroundImage: AssetImage('assets/img/germany.png'),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildName(context),
        SizedBox(
          height: 3,
        ),
        _buildEmail(context),
      ],
    );
  }

  Widget _buildName(BuildContext context) {
    return Text(
      'kdjf',
      // Firestore.instance.collection('Clients').document[0].snapshots(),
      style: Theme.of(context).textTheme.headline6,
    );
  }

  Widget _buildEmail(BuildContext context) {
    //   FirebaseUser user = await FirebaseAuth.instance.currentUser();
    // final uid = user.email;
    return Text(
      widget.model.getUserEmailId(),
      style: Theme.of(context).textTheme.subtitle2,
    );
  }

  Widget _buildDeliveryBoyDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0),
      child: Card(
        elevation: 6,
        // shape: button_border_radius,
        child: Column(
          children: <Widget>[
            _buildHeader('Profile'),
            _buildSettingName(),
            _buildSettingEmail(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return ListTile(
      leading: Icon(Icons.account_circle),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      // trailing: ButtonTheme(
      //   padding: EdgeInsets.all(0),
      //   minWidth: 50.0,
      //   height: 25.0,
      //   child: ProfileSettingsDialog(),
    );
  }

  Widget _buildSettingName() {
    return ListTile(
      leading: Icon(Icons.person),
      title: StreamBuilder(
        stream: data,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Text("${snapshot.data.documents[0].data['name']}");
          } else {
            return Text("Loading....");
          }
        },
      ),
    );
  }

  Widget _buildSettingEmail(BuildContext context) {
    print(widget.model.getUserEmailId());
    return ListTile(
        leading: Icon(Icons.email),
        title: FutureBuilder(
          future: widget.model.getUserEmailId(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data);
            }
            return Container();
          },
        ));
  }

  Widget _buildAddress() {
    return ListTile(
      leading: Icon(Icons.location_on),
      title: Text('Kohat, Pakistan'),
    );
  }

  Widget _buildPhone() {
    return ListTile(
      leading: Icon(Icons.call),
      title: Text('+92-321-1234567'),
    );
  }

  Widget _buildRemoveAccountCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0),
      child: Card(
          elevation: 6,
          // shape: button_border_radius,
          child: Column(
            children: <Widget>[
              _buildAppSettingHeader(),
              _buildLanguageBar(),
              _buildHelpSupportBar(),
            ],
          )),
    );
  }

  Widget _buildAppSettingHeader() {
    return ListTile(
      leading: Icon(Icons.settings),
      title: Text(
        'App Setting',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLanguageBar() {
    return ListTile(
      leading: Icon(Icons.language),
      title: Text('English'),
    );
  }

  Widget _buildHelpSupportBar() {
    return ListTile(
      leading: Icon(Icons.help),
      title: Text('Help and Support'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff282828),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        title: Text(
          "Profile",
        ),
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
      body: SafeArea(child: _buildScreenUI(context)),
    );
  }
}
