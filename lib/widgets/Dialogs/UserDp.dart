import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:talkster_chatting_app/model/ChatUser.dart';

import '../../ThemeColor.dart';
import '../../main.dart';
import '../../screens/ViewFriendsBio.dart';

class UserDp extends StatelessWidget {
  final ChatUser user;
  const UserDp({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white.withOpacity(.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: SizedBox(
        width: mq.width * .6,
        height: mq.height * .35,
        child: Stack(children: [
          Positioned(
            top: mq.width * .04,
            left: mq.width * .04,
            width: mq.width * .55,
            child: Text(
              user.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
          Positioned(
            child: Align(
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .25),
                child: CachedNetworkImage(
                  width: mq.width * .5,
                  imageUrl: user.image,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => CircleAvatar(
                      child: Icon(
                    CupertinoIcons.person,
                    size: mq.width * .3,
                  )),
                ),
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 8,
            child: IconButton(
              iconSize: 30,
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ViewFrndsBio(
                              user: user,
                            )));
              },
              icon: Icon(
                Icons.info_outline_rounded,
                color: clr,
              ),
            ),
          )
        ]),
      ),
    );
  }
}
