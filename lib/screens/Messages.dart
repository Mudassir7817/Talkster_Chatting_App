import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:talkster_chatting_app/helper/time_helper.dart';
import '../api/Api.dart';
import '../main.dart';
import '../model/Messages.dart';

class Messages_Container extends StatefulWidget {
  final Messages msg;
  const Messages_Container({
    Key? key,
    required this.msg,
  }) : super(key: key);

  @override
  State<Messages_Container> createState() => _Messages_ContainerState();
}

class _Messages_ContainerState extends State<Messages_Container> {
  @override
  Widget build(BuildContext context) {
    return APIs.me.id == widget.msg.fromId ? greenMsg() : blueMsg();
  }

  Widget blueMsg() {
    if (widget.msg.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.msg);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.msg.type == Type.image
                ? mq.width * .01
                : mq.width * .03),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              color: Color.fromARGB(255, 216, 232, 247),
            ),
            child: widget.msg.type == Type.image
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * 0.05),
                    child: CachedNetworkImage(
                      imageUrl: widget.msg.msg,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => CircleAvatar(
                          child: Icon(
                        Icons.image,
                        size: mq.width * .3,
                      )),
                    ),
                  )
                : Text(
                    widget.msg.msg,
                    style: TextStyle(fontSize: 18),
                  ),
          ),
        ),
        Row(children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                if (widget.msg.read.isEmpty)
                  Icon(
                    Icons.done_all_rounded,
                    color: Colors.blue,
                  ),
                SizedBox(
                  width: mq.width * .04,
                ),
                Text(
                  TimeHelper.getExactTime(
                      context: context, time: widget.msg.sent),
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ]),
      ],
    );
  }

  Widget greenMsg() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                if (widget.msg.read.isNotEmpty)
                  Icon(
                    Icons.done_all_rounded,
                    color: Colors.blue,
                  ),
                SizedBox(
                  width: mq.width * .04,
                ),
                Text(
                  TimeHelper.getExactTime(
                      context: context, time: widget.msg.sent),
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ]),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * .03),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
              color: Color.fromARGB(255, 219, 248, 220),
            ),
            child: widget.msg.type == Type.image
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * 0.01),
                    child: CachedNetworkImage(
                      imageUrl: widget.msg.msg,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => CircleAvatar(
                          child: Icon(
                        Icons.image,
                        size: mq.width * .3,
                      )),
                    ),
                  )
                : Text(
                    widget.msg.msg,
                    style: TextStyle(fontSize: 18),
                  ),
          ),
        ),
      ],
    );
  }
}
