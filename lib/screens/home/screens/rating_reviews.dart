import 'package:firestore_auth_crud/shared/constant.dart';
import 'package:flutter/material.dart';

class RatingReviews extends StatelessWidget {
  Widget _buildScreenUI() {
    return ListView.builder(
        itemCount: 2,
        itemBuilder: (context, i) {
          return _buildListTile();
        });
  }

  Widget _buildListTile() {
    return ListTile(
      isThreeLine: true,
      leading: _buildLeading(),
      title: _buildTitle(),
      subtitle: _buildSubTitle(),
      //trailing: _buildTrailing(),
    );
  }

  Widget _buildLeading() {
    return CircleAvatar();
  }

  Widget _buildTitle() {
    return Text(
      "Customer 1",
      style: label_style,
    );
  }

  Widget _buildSubTitle() {
    return Text(
      "Customer 1 Reviews",
      style: label_style,
    );
  }

  Widget _buildTrailing() {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Shop'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: _buildScreenUI(),
      ),
    );
  }
}
