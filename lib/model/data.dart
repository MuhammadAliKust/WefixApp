import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class Data{
 final  String name;
 FirebaseAuth _auth = FirebaseAuth.instance;
//  final  id = _auth.currentUser();

 Data({this.name});


}