import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firestore_auth_crud/model/shop.dart';
import 'package:firestore_auth_crud/model/user.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';

class ConnectedModel extends Model {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  // collection reference
  final CollectionReference ownerCollection =
      Firestore.instance.collection('Owners');
  final CollectionReference shopCollection =
      Firestore.instance.collection('Shops');
}

class AuthModel extends ConnectedModel {
  Future<String> getUserId() async {
    return (await _auth.currentUser()).uid;
  }

  // create user obj based on firebase user
  User _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(uid: user.uid, email: user.email) : null;
  }

  // auth change user stream
  Stream<User> get user {
    return _auth.onAuthStateChanged
        //.map((FirebaseUser user) => _userFromFirebaseUser(user));
        .map(_userFromFirebaseUser);
  }

  // sign in anon
  Future signInAnon() async {
    try {
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      return user;
    } catch (error) {
      print(error.code);
      return null;
    }
  }

  // register with email and password
  Future registerWithEmailAndPassword(
      String username, String email, String password, bool isLogin) async {
    _isLoading = true;
    notifyListeners();
    var message = 'Something went wrong.';
    AuthResult result;
    try {
      !isLogin
          ? result = await _auth.createUserWithEmailAndPassword(
              email: email, password: password)
          : result = await _auth.signInWithEmailAndPassword(
              email: email, password: password);
      ;
      FirebaseUser user = result.user;
      _isLoading = false;
      notifyListeners();
      return _userFromFirebaseUser(user).toString();
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      if (error.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
        message = 'Email already exists.';
      } else if (error.code == 'ERROR_WRONG_PASSWORD') {
        message = 'Invalid Password';
      } else if (error.code == 'ERROR_USER_NOT_FOUND') {
        message = 'Email not found.';
      } else {
        message = 'Invalid password.';
      }
      // print(error);
      return message;
      // print(error.message);
      // return error.toString();
    }
  }

  getShops() async {
    return Firestore.instance.collection('Shops').snapshots();
  }

  // getFavShopsKey()async{
  //   return Firestore.instance.collection('FavShops').getDocuments();
  // }

  clientName() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    return Firestore.instance
        .collection('Clients')
        .where('id', isEqualTo: uid)
        .getDocuments();
  }

  getData() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    return Firestore.instance
        .collection('Shops')
        .where('id', isEqualTo: uid)
        .snapshots();
  }

  getUserName() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    return Firestore.instance
        .collection('Clients')
        .where('id', isEqualTo: uid)
        .snapshots();
  }

  String _result = '';

  getUserEmailId() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    String uemail = user.email.toString();
    print(uemail);
    return uemail;
  }

  void setResult(var result) {
    notifyListeners();
    _result = result;
    notifyListeners();
  }

  String get result {
    notifyListeners();
    return _result;
  }

  updateData(
      {String name,
      String address,
      String number,
      String email,
      bool isFav,
      String services}) async {
    _isLoading = true;
    notifyListeners();
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    print(shopCollection
        .document(uid)
        .collection('ShopDetails')
        .document()
        .documentID);
    shopCollection.document(uid).updateData({
      'id': uid,
      'isFav': isFav,
      'name': name,
      'address': address,
      'contact': number,
      'email': email,
      'services': services,
    }).catchError((e) {
      print(e);
    });
    _isLoading = false;
    notifyListeners();
  }

  //display shops
  displayShops() async {
    return shopCollection.snapshots();
  }

  getShopsData() {
    return shopCollection.getDocuments();
  }

  //add fav shops
  addFavShops(
      {selID,
      String image,
      String name,
      String address,
      String number,
      uid,
      String email,
      double rating,
      String services}) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    print(selID);
    final uid = user.uid;
    Firestore.instance.collection('FavShops').document().setData({
      'id': uid,
      'isFav': false,
      'name': name,
      'image': image,
      'shopId': selID,
      // 'address': address,
      'contact': number,
      'email': email,
      'services': services,
      'rating': rating
    }).catchError((e) {
      print(e);
    });
    ;
  }

  displayImage() async {
    _isLoading = true;
    notifyListeners();
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    final ref = await FirebaseStorage.instance.ref().child(uid);
    print(ref);
    var url = Uri.parse(await ref.getDownloadURL() as String);
    _isLoading = false;
    notifyListeners();
    return url;
  }

  deleteFavShop(String selID) async {
    Firestore.instance
        .collection('FavShops')
        .document(selID)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  //display fav shops
  displayFavShops() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    return Firestore.instance
        .collection('FavShops')
        .where('id', isEqualTo: uid)
        .snapshots();
  }

  //display fav shops docs
  displayFavShopsDocs() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    return Firestore.instance
        .collection('FavShops')
        .where('id', isEqualTo: uid)
        .getDocuments();
  }

//addClientData
  addClientData(String username, String email) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    Firestore.instance
        .collection('Clients')
        .document(uid)
        .setData({'id': uid, 'name': username, 'email': email});
  }

  //add dummy shop to a database once user got registered
  addUserDetails(String username, String email) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    ownerCollection
        .document(uid)
        .setData({'id': uid, 'name': username, 'email': email});
    shopCollection.document(uid).setData({
      'username': username,
      'id': uid,
      'image':
          'https://themarketco.co.uk/wp-content/plugins/yith-woocommerce-multi-vendor-premium/assets/images/shop-placeholder.jpg',
      'name': 'Test Shop',
      'address': 'Jand',
      'contact': '1234-1234567',
      'email': 'test@test.com',
      'services': 'Electronic',
      'rating': 0,
      'array': FieldValue.arrayUnion([])
    }).catchError((e) {
      print(e);
    });
  }

  Future getCurrentUser() async {
    _isLoading = true;
    notifyListeners();
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    _isLoading = false;
    notifyListeners();
    return ownerCollection.where('id', isEqualTo: uid).snapshots();
  }

  Future getUserID() async {
    _isLoading = true;
    notifyListeners();
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    _isLoading = false;
    notifyListeners();
    return uid;
  }

  uploadImage(var image) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final uid = user.uid;
    final StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(uid);
    final StorageUploadTask task = firebaseStorageRef.putFile(image);
  }

  Future removeFavShop(selID) {
    return Firestore.instance.collection('FavShops').document(selID).delete();
  }

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  bool get isLoading {
    return _isLoading;
  }
}
