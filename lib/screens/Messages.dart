import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talkster_chatting_app/helper/time_helper.dart';
import '../api/Api.dart';
import '../helper/dialog.dart';
import '../main.dart';
import '../model/Messages_Model.dart';

class Messages_Container extends StatefulWidget {
  final Messages_Model msg;
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
    bool isMe = APIs.me.id == widget.msg.fromId;
    return InkWell(
        onLongPress: () {
          _showBottomSheet(isMe);
        },
        child: isMe ? greenMsg() : blueMsg());
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
                      placeholder: (context, url) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
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
                      placeholder: (context, url) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
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

  void _showBottomSheet(bool isMe) {
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
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * .015, horizontal: mq.width * .4),
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(20)),
              ),
              widget.msg.type == Type.image && isMe
                  ? OptionItems(
                      icon: Icon(
                        Icons.download,
                        size: 26,
                        color: Colors.blue,
                      ),
                      name: 'Save image',
                      onTap: () {})
                  : OptionItems(
                      icon: Icon(
                        Icons.copy_all,
                        size: 26,
                        color: Colors.blue,
                      ),
                      name: 'Copy Text',
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.msg.msg))
                            .then((value) {
                          Dialogs.newSnackBar(context, 'Text Copied');
                          Navigator.pop(context);
                        });
                        ;
                      }),
              if (widget.msg.type == Type.text && isMe)
                Divider(
                  color: Colors.black54,
                  endIndent: mq.width * .04,
                  indent: mq.width * .04,
                ),
              if (widget.msg.type == Type.text && isMe)
                OptionItems(
                    icon: Icon(
                      Icons.edit,
                      size: 26,
                      color: Colors.blue,
                    ),
                    name: 'Edit Message',
                    onTap: () {
                      Navigator.pop(context);
                      _showUpdateMsg();
                    }),
              OptionItems(
                  icon: Icon(
                    Icons.delete_forever,
                    size: 26,
                    color: Colors.red,
                  ),
                  name: 'Delete Message',
                  onTap: () {
                    APIs.deleteMsg(widget.msg);
                    Navigator.pop(context);
                  }),
              Divider(
                color: Colors.black54,
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),
              OptionItems(
                  icon: Icon(
                    Icons.remove_red_eye,
                    size: 26,
                    color: Colors.blue,
                  ),
                  name:
                      'Sent At: ${TimeHelper.getMsgTime(context: context, time: widget.msg.sent)}',
                  onTap: () {}),
              OptionItems(
                  icon: Icon(
                    Icons.remove_red_eye,
                    size: 26,
                    color: Colors.green,
                  ),
                  name: widget.msg.read.isEmpty
                      ? 'Not readed yet'
                      : 'Read At: ${TimeHelper.getMsgTime(context: context, time: widget.msg.read)}',
                  onTap: () {}),
            ],
          );
        });
  }

  void _showUpdateMsg() {
    String updatedMsg = widget.msg.msg;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding:
            EdgeInsets.only(bottom: 10, left: 24, right: 24, top: 24),
        title: Row(children: [
          Icon(
            Icons.message,
            color: Colors.blue,
            size: 24,
          ),
          Text(
            '  Update Message',
            style: TextStyle(fontSize: 20),
          ),
        ]),
        content: TextFormField(
          initialValue: updatedMsg,
          maxLines: null,
          onChanged: (value) => updatedMsg = value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancle',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
          MaterialButton(
            onPressed: () {
              APIs.updateMsg(widget.msg, updatedMsg);
              Navigator.pop(context);
            },
            child: Text(
              'Update',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          )
        ],
      ),
    );
  }
}

class OptionItems extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const OptionItems(
      {super.key, required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: EdgeInsets.only(
            top: mq.height * .015,
            bottom: mq.height * .025,
            left: mq.width * .05),
        child: Row(
          children: [
            icon,
            Flexible(
              child: Text(
                '       $name',
                style: TextStyle(
                    fontSize: 15, color: Colors.black54, letterSpacing: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
