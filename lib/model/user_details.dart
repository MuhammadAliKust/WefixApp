class UserDetails {
//Variables
  String username;
  String user_email;
  String user_dp;
  String user_uid;

  //Constructor
  UserDetails({this.username, this.user_email, this.user_dp, this.user_uid});

  //To User Details
  Map toMap(UserDetails userDetails) {
    var data = Map<String, String>();
    data['username'] = userDetails.username;
    data['user_email'] = userDetails.user_email;
    data['user_dp'] = userDetails.user_dp;
    data['user_uid'] = userDetails.user_uid;
    return data;
  }

  //From User Details
  UserDetails.fromMap(Map<String, String> mapData) {
    this.username = mapData['username'];
    this.user_email = mapData['user_email'];
    this.user_dp = mapData['user_dp'];
    this.user_uid = mapData['user_uid'];
  }

  //Getters
  String get _name => username;
  String get _emailId => user_email;
  String get _photoUrl => user_dp;
  String get _uid => user_uid;


  //Setters
  set _photoUrl(String user_dp) {
    this.user_dp = user_dp;
  }

  set _name(String name) {
    this.username = name;
  }

  set _emailId(String user_email) {
    this.user_email = user_email;
  }

  set _uid(String user_uid) {
    this.user_uid = user_uid;
  }

}