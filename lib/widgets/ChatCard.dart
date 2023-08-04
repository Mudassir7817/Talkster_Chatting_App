import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:talkster_chatting_app/api/Api.dart';
import 'package:talkster_chatting_app/helper/time_helper.dart';
import 'package:talkster_chatting_app/screens/ChatScreen.dart';

import '../main.dart';
import '../model/ChatUser.dart';
import '../model/Messages.dart';

class ChatCard extends StatefulWidget {
  final ChatUser user;
  const ChatCard({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  Messages? message;
  _ChatCardState();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 6),
      child: Card(
        child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ChatScreen(
                            user: widget.user,
                          )));
            },
            child: StreamBuilder(
              stream: APIs.getLastMsg(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                if (data != null && data.first.exists) {
                  message = Messages.fromJson(data.first.data());
                }
                return ListTile(
                  // leading: CircleAvatar(child: Icon(CupertinoIcons.person)),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .3),
                    child: CachedNetworkImage(
                      width: mq.height * .070,
                      height: mq.height * .070,
                      imageUrl: widget.user.image,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          CircleAvatar(child: Icon(CupertinoIcons.person)),
                    ),
                  ),
                  title: Text(
                    widget.user.name,
                    style: TextStyle(fontSize: 17),
                  ),
                  trailing: message == null
                      ? null
                      : message!.read.isEmpty &&
                              message!.fromId != APIs.user.uid
                          ? Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                  color: Colors.greenAccent.shade700,
                                  borderRadius: BorderRadius.circular(10)),
                            )
                          : Text(
                              TimeHelper.getLastMsgTime(
                                  context: context, time: message!.sent),
                              style: TextStyle(fontSize: 12)),
                  subtitle: Text(
                      message != null
                          ? message?.type == Type.image
                              ? 'Photo'
                              : message!.msg
                          : widget.user.about,
                      style: TextStyle(fontSize: 15)),
                );
              },
            )),
      ),
    );
  }
}
