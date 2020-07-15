import 'package:firestore_auth_crud/screens/home/screens/clients/signUp.dart';
import 'package:firestore_auth_crud/services/models/main.dart';
import 'package:firestore_auth_crud/shared/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';

import 'login.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  bool isObscured = true;

  bool isLogin = false;
  Map<String, dynamic> _formData = {
    'username': '',
    'email': '',
    'password': '',
    'category': ''
  };

  TextEditingController _name = TextEditingController();
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
            _buildSwitch(),
            _buildNameField(),
            SizedBox(height: 5),
            _buildEmailField(),
            SizedBox(height: 5),
            _buildPasswordField(),
            SizedBox(height: 5),
            SizedBox(
              height: 20,
            ),
            _buildButton('Register'),
            SizedBox(
              height: 20,
            ),
            _buildDivider(),
            SizedBox(
              height: 20,
            ),
            _iconButton(
                Icons.person,
                'SignIn Owner Account',
                () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => Login()))),
            SizedBox(
              height: 10,
            ),
            _iconButton(
                Icons.person,
                'SignIn User Account',
                () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ClientLogin()))),
            SizedBox(
              height: 10,
            ),
          ]),
        ),
      )
    ]));
  }

  bool isSwitched = false;

  Widget _buildSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          'Do you want to register shop?',
          style: label_style,
        ),
        Switch(
            activeColor: Colors.white,
            activeTrackColor: Color(0xffc79035),
            inactiveTrackColor: Colors.grey,
            inactiveThumbColor: Colors.blueGrey,
            value: isSwitched,
            onChanged: (val) {
              setState(() {
                isSwitched = val;
              });
            }),
      ],
    );
  }

  Widget _buildImgHeader() {
    return Image.asset('assets/img/logo.png', width: 150);
  }

  Widget _buildHeading(BuildContext context) {
    return Text(
      'SignUp',
      style: Theme.of(context)
          .textTheme
          .headline5
          .merge(TextStyle(color: Colors.white)),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _name,
      style: text_field_text_style,
      onSaved: (val) {
        _formData['username'] = val;
      },
      validator: (val) => val.isEmpty ? 'Username cannot be empty' : null,
      decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.person,
            color: icon_color,
          ),
          labelText: 'Username',
          labelStyle: label_style,
          focusedBorder: underline_input_border,
          enabledBorder: underline_input_border,
          border: underline_input_border),
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
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, MainModel model) {
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
                    String successInfo =
                        await model.registerWithEmailAndPassword(
                            _formData['username'],
                            _formData['email'],
                            _formData['password'],
                            false);
                    if (successInfo == 'Instance of \'User\'' &&
                        isLogin == false &&
                        isSwitched == true) {
                      model
                          .addUserDetails(
                              _formData['username'], _formData['email'])
                          .then((val) {
                        setState(() {
                          _name.clear();
                          _email.clear();
                          _password.clear();
                        });
                      });
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => Login()));
                    } else if (successInfo == 'Instance of \'User\'' &&
                        isLogin == false &&
                        isSwitched == false) {
                      model.addClientData(
                        _formData['username'],
                        _formData['email']
                      );
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => ClientLogin()));
                      setState(() {
                        _name.clear();
                        _email.clear();
                        _password.clear();
                      });
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
                                      _name.clear();
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
      },
    );
  }

  Widget _iconButton(IconData iconData, String text, VoidCallback onTap) {
    return Container(
      width: 250,
      height: 55,
      child: FlatButton.icon(
          shape: button_border,
          onPressed: () => onTap(),
          // onPressed: () => Navigator.of(context).pushReplacement(
          //     MaterialPageRoute(builder: (context) => Login())),
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
