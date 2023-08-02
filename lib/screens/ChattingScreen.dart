import 'package:flutter/material.dart';
import 'package:talkster_chatting_app/helper/time_helper.dart';

import '../api/Api.dart';
import '../main.dart';
import '../model/Messages.dart';

class ChattingScreen extends StatefulWidget {
  final Messages msg;
  const ChattingScreen({
    Key? key,
    required this.msg,
  }) : super(key: key);

  @override
  State<ChattingScreen> createState() => _ChattingScreenState();
}

class _ChattingScreenState extends State<ChattingScreen> {
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
            padding: EdgeInsets.all(mq.width * .03),
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
            child: Text(
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
            child: Text(
              widget.msg.msg,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}
