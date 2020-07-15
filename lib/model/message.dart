import 'package:cloud_firestore/cloud_firestore.dart';

class Message {

  //Variables
  String senderUid;
  String receiverUid;
  String type;
  String message;
  FieldValue timestamp;
  String photoUrl;
//Constructor
  Message({this.senderUid, this.receiverUid, this.type, this.message, this.timestamp});
  Message.withoutMessage({this.receiverUid, this.senderUid, this.type, this.timestamp, this.photoUrl});


  //Send Message to user
  Map toMap() {
    var map = Map<String, dynamic>();
    map['senderUid'] = this.senderUid;
    map['receiverUid'] = this.receiverUid;
    map['type'] = this.type;
    map['message'] = this.message;
    map['timestamp'] = this.timestamp;
    return map;
  }

  //Receive Message From User
  Message fromMap(Map<String, dynamic> map) {
    Message _message = Message();
    _message.senderUid = map['senderUid'];
    _message.receiverUid = map['receiverUid'];
    _message.type = map['type'];
    _message.message = map['message'];
    _message.timestamp = map['timestamp'];
    return _message;
  }

  

}