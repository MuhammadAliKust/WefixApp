import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_auth_crud/helper/helperFunctions.dart';
import 'package:firestore_auth_crud/model/user.dart';
import 'package:firestore_auth_crud/screens/authenticat/signUp.dart';
import 'package:firestore_auth_crud/screens/home/screens/clients/client_homepage.dart';
import 'package:firestore_auth_crud/screens/home/screens/my_shop.dart';
import 'package:firestore_auth_crud/screens/home/screens/shop_list.dart';
import 'package:firestore_auth_crud/screens/home/screens/shop_main_page.dart';
import 'package:firestore_auth_crud/services/models/database.dart';
import 'package:firestore_auth_crud/services/models/main.dart';
import 'package:firestore_auth_crud/shared/constant.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class ClientLogin extends StatefulWidget {
  @override
  _ClientLoginState createState() => _ClientLoginState();
}

class _ClientLoginState extends State<ClientLogin> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  bool isObscured = true;

  Map<String, dynamic> _formData = {'email': '', 'password': ''};
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  Widget _buildScreenUI(BuildContext context) {
    return SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
      SizedBox(height: 30),
      _buildImgHeader(),
      SizedBox(
        height: 20,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 128.0),
        child: Divider(thickness: 2, color: Color(0xffc79035)),
      ),
      SizedBox(
        height: 20,
      ),
      _buildHeading(context),
      SizedBox(height: 30),
      Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 38.0),
          child: Column(children: <Widget>[
            _buildEmailField(),
            SizedBox(height: 5),
            _buildPasswordField(),
            SizedBox(height: 5),
            SizedBox(
              height: 10,
            ),
            _buildButton('SignIn'),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 20,
            ),
            _register(
              Icons.person,
              'Register',
            ),
          ]),
        ),
      )
    ]));
  }

  Widget _buildImgHeader() {
    return Image.asset('assets/img/logo.png', width: 150);
  }

  Widget _buildHeading(BuildContext context) {
    return Text(
      'User Login',
      style: Theme.of(context)
          .textTheme
          .headline5
          .merge(TextStyle(color: Colors.white)),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _email,
      style: text_field_text_style,
      onSaved: (val) {
        _formData['email'] = val;
      },
      validator: (value) {
        if (value.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          return 'Please enter a valid email';
        } else {
          return null;
        }
      },
      decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.email,
            color: icon_color,
          ),
          labelText: 'Email',
          labelStyle: label_style,
          focusedBorder: underline_input_border,
          enabledBorder: underline_input_border,
          border: underline_input_border),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _password,
      style: text_field_text_style,
      onSaved: (val) {
        _formData['password'] = val;
      },
      validator: (val) =>
          val.length < 6 ? 'Password should be more than 6 char.' : null,
      obscureText: isObscured,
      decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.lock,
            color: icon_color,
          ),
          suffixIcon: InkWell(
            child: Icon(
              Icons.remove_red_eye,
              color: icon_color,
            ),
            onTap: () {
              setState(() {
                isObscured = !isObscured;
              });
            },
          ),
          labelText: 'Password',
          labelStyle: label_style,
          enabledBorder: underline_input_border,
          focusedBorder: underline_input_border,
          border: underline_input_border),
    );
  }

  Widget _buildButton(String text) {
    return ScopedModelDescendant(builder: (
      BuildContext context,
      Widget child,
      MainModel model,
    ) {
      return model.isLoading
          ? CircularProgressIndicator()
          : Container(
              width: 250,
              height: 55,
              child: FlatButton(
                shape: button_border,
                onPressed: () async {
                  if (!_formKey.currentState.validate()) {
                    return;
                  }
                  _formKey.currentState.save();
                  var successInfo;
                  model
                      .registerWithEmailAndPassword(
                          '', _formData['email'], _formData['password'], true)
                      .then((result) async {
                    if (result != null) {
                      QuerySnapshot userInfoSnapshot =
                          await DatabaseMethods().getUserInfo(_email.text);

                      print(userInfoSnapshot.documents[0].data["name"]);
                      HelperFunctions.saveUserNameSharedPreference(
                          userInfoSnapshot.documents[0].data["name"]);
                      HelperFunctions.saveUserEmailSharedPreference(
                          userInfoSnapshot.documents[0].data["email"]);
                    }
                  });

                  successInfo = await model.registerWithEmailAndPassword(
                      '', _formData['email'], _formData['password'], true);

                  if (successInfo == 'Instance of \'User\'' &&
                      isLogin == true) {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => ClientHomePage(model)));
                  } else {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('An Error Occurred!'),
                            content: Text(successInfo),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('Okay'),
                                onPressed: () {
                                  setState(() {
                                    _email.clear();
                                    _password.clear();
                                  });
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          );
                        });
                  }
                },
                color: Colors.transparent,
                child: Text(text, style: button_text_style),
              ),
            );
    });
  }

  Widget _register(IconData iconData, String text) {
    return Container(
      width: 250,
      height: 55,
      child: FlatButton.icon(
          shape: button_border,
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => SignUp())),
          icon: Icon(
            iconData,
            color: icon_color,
          ),
          label: Text(text, style: button_text_style)),
    );
  }

  Widget _iconButton(IconData iconData, String text, VoidCallback onTap) {
    return Container(
      width: 250,
      height: 55,
      child: FlatButton.icon(
          shape: button_border,
          onPressed: () => onTap(),
          // onPressed: () => Navigator.of(context)
          //     .push(MaterialPageRoute(builder: (context) => SignUp())),
          icon: Icon(
            iconData,
            color: icon_color,
          ),
          label: Text(text, style: button_text_style)),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0),
      child: Row(
        children: <Widget>[
          Expanded(
              child: Divider(
            color: Color(0xffc79035),
            thickness: 1,
          )),
          Text('  OR  ', style: TextStyle(color: Colors.white)),
          Expanded(
              child: Divider(
            color: Color(0xffc79035),
            thickness: 1,
          ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff1b1b1b),
      body: SafeArea(
        child: _buildScreenUI(context),
      ),
    );
  }
}
