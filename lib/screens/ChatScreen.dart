// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:talkster_chatting_app/model/ChatUser.dart';

import '../ThemeColor.dart';
import '../api/Api.dart';
import '../main.dart';
import '../model/Messages.dart';
import 'Messages.dart';
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
  bool isEmoji = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (isEmoji) {
              setState(() {
                isEmoji = !isEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            backgroundColor: Colors.blue.shade50,
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
                            reverse: true,
                            itemCount: _list.length,
                            padding: EdgeInsets.only(top: mq.width * .03),
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Messages_Container(
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
              _chatInput(),
              if (isEmoji)
                SizedBox(
                  height: mq.height * .35,
                  child: EmojiPicker(
                    textEditingController: textController,
                    config: Config(
                      columns: 8,
                      emojiSizeMax: 26 * (Platform.isIOS ? 1.30 : 1.0),
                      initCategory: Category.RECENT,
                      bgColor: Color(0xFFF2F2F2),
                    ),
                  ),
                )
            ]),
          ),
        ),
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
                      onPressed: () {
                        setState(() {
                          isEmoji = !isEmoji;
                        });
                      },
                      icon: IconButton(
                        color: clr,
                        icon: Icon(Icons.emoji_emotions_outlined),
                        onPressed: () {
                          setState(() {
                            FocusScope.of(context).unfocus();
                            isEmoji = !isEmoji;
                          });
                        },
                      )),
                  Expanded(
                    child: TextField(
                      onTap: () {
                        if (isEmoji)
                          setState(() {
                            isEmoji = !isEmoji;
                          });
                      },
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
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();

                      final XFile? image =
                          await picker.pickImage(source: ImageSource.camera);

                      if (image != null) {
                        log("message");
                        await APIs.sendChatImage(widget.user, File(image.path));
                      }
                    },
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
                APIs.sendMsg(widget.user, textController.text, Type.text);
                textController.text = '';
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
