import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talkster_chatting_app/ThemeColor.dart';

import 'package:talkster_chatting_app/model/ChatUser.dart';
import 'package:talkster_chatting_app/screens/auth/LoginScreen.dart';

import '../api/Api.dart';
import '../helper/dialog.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  final ChatUser user;
  const SettingsScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(fontSize: 24),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: mq.height * .05,
                    width: mq.width,
                  ),
                  Stack(
                    children: [
                      _image != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * .3),
                              child: Image.file(
                                File(_image!),
                                width: mq.height * .2,
                                height: mq.height * .2,
                                fit: BoxFit.cover,
                              ),
                            )
                          : ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * .3),
                              child: CachedNetworkImage(
                                width: mq.height * .2,
                                height: mq.height * .2,
                                imageUrl: widget.user.image,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    CircleAvatar(
                                        child: Icon(
                                  CupertinoIcons.person,
                                  size: mq.width * .3,
                                )),
                              ),
                            ),
                      Positioned(
                        bottom: 0,
                        right: -20,
                        child: MaterialButton(
                          color: clr,
                          shape: CircleBorder(),
                          onPressed: () {
                            _showBottomSheet();
                          },
                          child: Icon(
                            CupertinoIcons.camera,
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: mq.height * .03,
                  ),
                  Text(
                    widget.user.email,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(
                    height: mq.height * .03,
                  ),
                  TextFormField(
                    onSaved: (value) => APIs.me.name = value ?? '',
                    validator: (value) =>
                        value!.isNotEmpty ? null : 'Please Enter some username',
                    initialValue: widget.user.name,
                    decoration: InputDecoration(
                      labelText: "Name",
                      labelStyle: TextStyle(fontSize: 16),
                      hintText: "eg. Ali ",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                      prefixIcon: Icon(
                        Icons.person,
                        color: clr,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: mq.height * .03,
                  ),
                  TextFormField(
                    onSaved: (value) => APIs.me.about = value ?? '',
                    validator: (value) =>
                        value!.isNotEmpty ? null : 'Required Field',
                    initialValue: widget.user.about,
                    decoration: InputDecoration(
                        labelText: "About",
                        labelStyle: TextStyle(fontSize: 16),
                        hintText: "eg. Happy:)",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16)),
                        prefixIcon: Icon(
                          Icons.info_outline_rounded,
                          color: clr,
                        )),
                  ),
                  SizedBox(
                    height: mq.height * .03,
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: clr,
                        minimumSize: Size(mq.width * .4, mq.height * .055),
                        shape: StadiumBorder()),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        APIs.updateUserInfo();
                        Dialogs.newSnackBar(context, 'Updated Successfully');
                      }
                    },
                    icon: Icon(
                      Icons.edit,
                      size: 28,
                    ),
                    label: Text(
                      "Update",
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(14),
        child: FloatingActionButton.extended(
          onPressed: () async {
            Dialogs.newProgressBar(context);
            await APIs.auth.signOut().then((value) async {
              await GoogleSignIn().signOut().then((value) {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => LoginScreen()));
              });
            });
          },
          icon: Icon(Icons.logout_rounded),
          backgroundColor: Colors.redAccent.shade200,
          label: Text(
            "Logout",
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'Pick an image',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(mq.width * .3, mq.height * .15),
                      shape: CircleBorder(),
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();

                      final XFile? image =
                          await picker.pickImage(source: ImageSource.gallery);

                      if (image != null) {
                        setState(() {
                          _image = image.path;
                          APIs.updateImage(File(_image!));
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: Image.asset("assets/images/gallery.png"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(mq.width * .3, mq.height * .15),
                      shape: CircleBorder(),
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();

                      final XFile? image =
                          await picker.pickImage(source: ImageSource.camera);

                      if (image != null) {
                        setState(() {
                          _image = image.path;
                          APIs.updateImage(File(_image!));
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: Image.asset("assets/images/camera.png"),
                  ),
                ],
              ),
            ],
          );
        });
  }
}
