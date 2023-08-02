// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:talkster_chatting_app/model/ChatUser.dart';

import '../ThemeColor.dart';
import '../api/Api.dart';
import '../main.dart';
import '../model/Messages.dart';
import 'ChattingScreen.dart';
import 'HomeScreen.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Messages> _list = [];
  final textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: _appBar(),
        ),
        body: Column(children: [
          Expanded(
            child: StreamBuilder(
                stream: APIs.getAllMsg(widget.user),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    //if data is loading
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                    // return Center(child: CircularProgressIndicator());

                    //if some or all data is loaded the show it:
                    case ConnectionState.active:
                    case ConnectionState.done:
                      final Data = snapshot.data?.docs;
                      _list = Data?.map((e) => Messages.fromJson(e.data()))
                              .toList() ??
                          [];
                  }

                  if (_list.isNotEmpty) {
                    return ListView.builder(
                        itemCount: _list.length,
                        padding: EdgeInsets.only(top: mq.width * .03),
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return ChattingScreen(
                            msg: _list[index],
                          );
                        });
                  } else {
                    return Center(
                      child: Text(
                        "Say Hello!",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                }),
          ),
          _chatInput()
        ]),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(mq.height * .3),
            child: CachedNetworkImage(
              width: mq.height * .055,
              height: mq.height * .055,
              imageUrl: widget.user.image,
              fit: BoxFit.cover,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) =>
                  CircleAvatar(child: Icon(CupertinoIcons.person)),
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user.name,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              SizedBox(
                height: 2,
              ),
              Text(
                'last seen not Available',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  IconButton(
                      iconSize: 26,
                      onPressed: () {},
                      icon: Icon(
                        Icons.emoji_emotions_outlined,
                        color: clr,
                      )),
                  Expanded(
                    child: TextField(
                      controller: textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type Something...',
                      ),
                    ),
                  ),
                  IconButton(
                      iconSize: 26,
                      onPressed: () {},
                      icon: Icon(
                        Icons.photo,
                        color: clr,
                      )),
                  IconButton(
                    iconSize: 26,
                    onPressed: () {},
                    icon: Icon(
                      Icons.camera_alt_rounded,
                      color: clr,
                    ),
                  ),
                ],
              ),
            ),
          ),
          MaterialButton(
            minWidth: 0,
            padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 5),
            color: clr,
            shape: CircleBorder(),
            onPressed: () {
              if (textController.text.isNotEmpty) {
                APIs.sendMsg(widget.user, textController.text);
                textController.clear();
              }
            },
            child: Icon(
              Icons.send,
              color: Colors.white,
              size: 28,
            ),
          )
        ],
      ),
    );
  }
}
