import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firestore_auth_crud/model/shop.dart';
import 'package:firestore_auth_crud/services/models/main.dart';
import 'package:firestore_auth_crud/shared/constant.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:scoped_model/scoped_model.dart';

class EditShopInfo extends StatefulWidget {
  final MainModel model;
  EditShopInfo({this.model});
  @override
  _EditShopInfoState createState() => _EditShopInfoState();
}

class _EditShopInfoState extends State<EditShopInfo> {
  static final kInitialPosition = LatLng(-33.8567844, 151.213108);
  String address = 'null';
  String apiKey = "AIzaSyC9pxEiVyuGXjWMhUmhZYd-EDgVqLLViuk";
  PickResult selectedPlace;
  Future<File> imageFile;
  Map<String, dynamic> updatedData = {
    'contact': '',
    'name': '',
    'email': '',
    'services': '',
    'address': ''
  };
  Stream cars;
  var myImageUrl;
  int counter = 0;
  @override
  void initState() {
    widget.model.getData().then((results) {
      setState(() {
        cars = results;
      });
    });

    super.initState();
  }

  pickImageFromGallery(ImageSource source) {
    setState(() {
      imageFile = ImagePicker.pickImage(source: source);
    });
  }

  File sampleImage;

  Future getImage() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      sampleImage = tempImage;
    });
  }

  bool isPressed = false;
  final _formKey = GlobalKey<FormState>();

  bool isObscured = true;

  // final ImagePicker _picker = ImagePicker();

  Map<String, dynamic> _formData = {
    'username': '',
    'email': '',
    'password': ''
  };

  Shop shop;
  String test;
  Widget _buildScreenUI(BuildContext context) {
    pr = new ProgressDialog(context);
    return SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
      SizedBox(height: 30),
      _buildHeading(context),
      SizedBox(height: 30),
      StreamBuilder(
        stream: cars,
        builder: (context, snapshot) {
          print("============================");
          print(myImageUrl.toString());
          // if (sampleImage == null){myImageUrl = snapshot.data.documents[0].data['image'];}
          //
          // print(snapshot.data.documents[0].data['isFav']);
          if (snapshot.hasData) {
            test = snapshot.data.documents[0].data['address'];
            // if (sampleImage == null) {
            //   myImageUrl = snapshot.data.documents[0].data['image'];
            // } else if (snapshot.data.documents[0].data['isFav'] == false) {
            //   print("1st Condition========================");
            //   widget.model.displayImage().then((f) async {
            //     myImageUrl = f;

            //     await myImageUrl;
            //   });
            // } else if (snapshot.data.documents[0].data['isFav'] == true &&
            //     isPressed != false) {
            //   print("2nd Condition=======================");
            //   widget.model.displayImage().then((f) async {
            //     myImageUrl = f;

            //     await myImageUrl;
            //   });
            //   print(myImageUrl);
            // }
            return Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 38.0),
                child: Column(children: <Widget>[
                  _buildNumberField(snapshot.data.documents[0].data['name']),
                  SizedBox(height: 5),
                  _buildEmailField(snapshot.data.documents[0].data['email']),
                  SizedBox(
                    height: 5,
                  ),
                  _buildContactField(
                      snapshot.data.documents[0].data['contact']),
                  SizedBox(height: 5),
                  _buildServicesField(
                      snapshot.data.documents[0].data['services']),
                  SizedBox(height: 5),
                  SizedBox(
                    height: 10,
                  ),
                  _buildAddressField(
                      snapshot.data.documents[0].data['address']),
                  SizedBox(
                    height: 30,
                  ),
                  _buildDivider(),
                  SizedBox(
                    height: 20,
                  ),
                  sampleImage == null
                      ? Image.network(snapshot.data.documents[0].data['image'])
                      : Container(),
                  SizedBox(
                    height: 20,
                  ),
                ]),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      )
    ]));
  }

  String url;
  File _image;
  ProgressDialog pr;
  FirebaseStorage _storage = FirebaseStorage.instance;
//Upload User pROFIle picture to database
  Future<Uri> uploadPic() async {
    //Get the file from the image picker and store it
    _image = await ImagePicker.pickImage(source: ImageSource.gallery);

    String mUid = (await FirebaseAuth.instance.currentUser()).uid;
    await pr.show();
    //Create a reference to the location you want to upload to in firebase
    StorageReference reference = _storage
        .ref()
        .child(mUid)
        .child((await FirebaseAuth.instance.currentUser()).uid);

    //Upload the file to firebase
    StorageUploadTask uploadTask = reference.putFile(_image);
    uploadTask.onComplete.then((result) async {
      pr.update(
        progress: 50.0,
        message: "Please wait...",
        progressWidget: Container(
            padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
      );
      pr.hide().then((isHidden) {
        print(isHidden);
      });
      url = await result.ref.getDownloadURL();

      // _showScaffold('Data Updated Successfully');
      await Firestore.instance.collection("Shops").document(mUid).updateData({
        'image': url,
      });
      print(mUid);
      setState(() {});
    });
  }

  Widget _buildHeading(BuildContext context) {
    return Text(
      'Edit Shop Info',
      style: Theme.of(context)
          .textTheme
          .headline5
          .merge(TextStyle(color: Colors.white)),
    );
  }

  Widget _buildNumberField(var snapshot) {
    return TextFormField(
      initialValue: snapshot,
      style: text_field_text_style,
      onSaved: (val) {
        updatedData['name'] = val;
      },
      decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.shopping_basket,
            color: icon_color,
          ),
          labelText: 'Shop Name',
          labelStyle: label_style,
          focusedBorder: underline_input_border,
          enabledBorder: underline_input_border,
          border: underline_input_border),
    );
  }

  Widget _buildEmailField(var snapshot) {
    return TextFormField(
      initialValue: snapshot,
      style: text_field_text_style,
      onSaved: (val) {
        updatedData['email'] = val;
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

  Widget _buildContactField(var snapshot) {
    return TextFormField(
      initialValue: snapshot,
      style: text_field_text_style,
      onSaved: (val) {
        updatedData['contact'] = val;
      },
      validator: (val) =>
          val.length < 6 ? 'Password should be more than 6 char.' : null,
      decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.call,
            color: icon_color,
          ),
          labelText: 'Contact Number',
          labelStyle: label_style,
          enabledBorder: underline_input_border,
          focusedBorder: underline_input_border,
          border: underline_input_border),
    );
  }

  Widget _buildServicesField(var snapshot) {
    return TextFormField(
      initialValue: snapshot,
      style: text_field_text_style,
      onSaved: (val) {
        updatedData['services'] = val;
      },
      validator: (val) =>
          val.length < 6 ? 'Password should be more than 6 char.' : null,
      decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.work,
            color: icon_color,
          ),
          labelText: 'Services',
          labelStyle: label_style,
          enabledBorder: underline_input_border,
          focusedBorder: underline_input_border,
          border: underline_input_border),
    );
  }

  Widget _buildAddressField(var snapshot) {
    updatedData['address'] = snapshot;
    bool isPressed = false;
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        model.setResult(updatedData['address']);
        return RaisedButton(
          color: Colors.transparent,
          elevation: 0,
          shape: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xffc79035))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.edit_location,
                color: Colors.white,
              ),
              SizedBox(
                width: 10,
              ),
              Text(snapshot, style: label_style),
            ],
          ),
          onPressed: () {
            isPressed = true;
            {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return PlacePicker(
                        apiKey: apiKey,
                        initialPosition: kInitialPosition,
                        useCurrentLocation: true,
                        //usePlaceDetailSearch: true,
                        onPlacePicked: (result) {
                          selectedPlace = result;
                          print("===========================");
                          print(selectedPlace.formattedAddress);
                          print("===========================");
                          setState(() {
                            updatedData['address'] =
                                selectedPlace.formattedAddress;
                            snapshot = selectedPlace.formattedAddress;
                          });

                          model.setResult(updatedData['address']);
                          _formKey.currentState.save();
                          model
                              .updateData(
                                  name: updatedData['name'],
                                  address: updatedData['address'],
                                  number: updatedData['contact'],
                                  email: updatedData['email'],
                                  services: updatedData['services'])
                              .then((val) {});
                          Navigator.of(context).pop();
                        });
                  },
                ),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildButton(String text) {
    return Container(
      width: 250,
      height: 55,
      child: FlatButton(
        shape: button_border,
        onPressed: () {
          if (!_formKey.currentState.validate()) {
            return;
          }
          _formKey.currentState.save();
          // Navigator.pushNamed(context,LoginView);
        },
        color: Colors.transparent,
        child: Text(text, style: button_text_style),
      ),
    );
  }

  Widget _iconButton(IconData iconData, String text) {
    return Container(
      width: 250,
      height: 55,
      child: FlatButton.icon(
          shape: button_border,
          onPressed: null,
          icon: Icon(
            iconData,
            color: icon_color,
          ),
          label: Text(text, style: button_text_style)),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: <Widget>[
        Expanded(
            child: Divider(
          color: Color(0xffc79035),
          thickness: 2,
        )),
        Text('  Add Photos  ', style: TextStyle(color: Colors.white)),
        Expanded(
            child: Divider(
          color: Color(0xffc79035),
          thickness: 2,
        ))
      ],
    );
  }

  Widget showImage() {
    return FutureBuilder<File>(
      future: imageFile,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          return Image.file(
            snapshot.data,
            width: 300,
            height: 300,
          );
        } else if (snapshot.error != null) {
          return const Text(
            'Error Picking Image',
            textAlign: TextAlign.center,
          );
        } else {
          return const Text(
            'No Image Selected',
            textAlign: TextAlign.center,
          );
        }
      },
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xff282828),
      appBar: AppBar(
        title: Text('My Shop'),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: <Widget>[
          ScopedModelDescendant(
              builder: (BuildContext context, Widget child, MainModel model) {
            return model.isLoading
                ? CircularProgressIndicator()
                : FlatButton(
                    child: Text(
                      'Save',
                      style: label_style,
                    ),
                    onPressed: () async {
                      setState(() {
                        counter = 1;
                      });
                      print("--------------------");
                      print(myImageUrl);
                      _formKey.currentState.save();
                      model
                          .updateData(
                              name: updatedData['name'],
                              address: test,
                              isFav: true,
                              number: updatedData['contact'],
                              email: updatedData['email'],
                              services: updatedData['services'])
                          .then((val) {
                        _showScaffold("Data updated Successfully.");
                      });

                      //model.updateData('How are you');
                    },
                  );
          })
        ],
      ),
      body: SafeArea(
        child: _buildScreenUI(context),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: uploadPic,
        tooltip: 'Add Image',
        child: new Icon(Icons.add),
      ),
    );
  }

  Widget enableUpload() {
    return Container(
      child: Column(
        children: <Widget>[
          Image.file(sampleImage, height: 300.0, width: 300.0),
          RaisedButton(
            elevation: 7.0,
            child: Text('Upload'),
            textColor: Colors.white,
            color: Colors.blue,
            onPressed: () {
              setState(() {
                isPressed = true;
              });
              widget.model.uploadImage(sampleImage);
            },
          )
        ],
      ),
    );
  }

  void _showScaffold(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
}
