import 'package:bataao/api/apis.dart';
import 'package:bataao/helper/dialogs.dart';
import 'package:bataao/helper/my_date_util.dart';
import 'package:bataao/models/message.dart';
import 'package:bataao/theme/style.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isSelf = APIs.user.uid == widget.message.fromId;
    return InkWell(
        onLongPress: () {
          _showBottomShit(isSelf);
        },
        child: isSelf ? _greenMessage() : _blueMessage());
  }

  Widget _blueMessage() {
    // Update last read mesage ..
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.text ? 15 : 2),
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
                color: White,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                    topRight: Radius.circular(10))),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.image,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Text(
            myDateUtil.getFormattedTime(
                context: context, time: widget.message.sent),
            style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                myDateUtil.getFormattedTime(
                    context: context, time: widget.message.sent),
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600),
              ),
            ),
            // SizedBox(
            //   height: 10,
            // ),

            if (widget.message.read.isNotEmpty)
              Icon(
                Icons.done_all,
                size: 18,
                color: Colors.blue,
              )
            else
              Icon(
                Icons.done,
                size: 18,
                color: Color.fromARGB(255, 0, 0, 0),
              )
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.text ? 15 : 2),
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
                color: PrimaryBlue,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    topRight: Radius.circular(10))),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.image,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

// Bottom shit for modify bottom shit
  void _showBottomShit(bool isSelf) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (context) {
          return ListView(
            shrinkWrap: true,
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 150),
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(8)),
              ),
              widget.message.type == Type.text
                  ? InkWell(
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.message.msg))
                            .then((value) {
                          Navigator.pop(context);
                          DialogSnackBar.showSnackBar(context, "Copied Text !");
                        });
                      },
                      child: _OptionItem(
                        icon: Icon(
                          Icons.copy,
                          color: Colors.blue,
                          size: 26,
                        ),
                        name: "Copy Text",
                      ),
                    )
                  : InkWell(
                      onTap: () async {
                        try {
                          Navigator.pop(context);
                          await GallerySaver.saveImage(widget.message.msg,
                                  albumName: 'Bataao')
                              .then((success) {});
                        } catch (e) {
                          print('\nSaving Image $e');
                        }
                      },
                      child: _OptionItem(
                        icon: Icon(
                          Icons.save,
                          color: Colors.blue,
                          size: 26,
                        ),
                        name: "Save",
                      ),
                    ),
              if (isSelf)
                Divider(
                  color: Colors.black54,
                  indent: 20,
                  endIndent: 20,
                ),
              if (widget.message.type == Type.text && isSelf)
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _showMessageUpdateDialog();
                  },
                  child: _OptionItem(
                    icon: Icon(
                      Icons.edit,
                      color: Colors.blue,
                      size: 26,
                    ),
                    name: "Edit Message",
                  ),
                ),
              if (isSelf)
                InkWell(
                  onTap: () {
                    APIs.deleteMessage(widget.message)
                        .then((value) => Navigator.pop(context));
                  },
                  child: _OptionItem(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 26,
                    ),
                    name: "Delete Message",
                  ),
                ),
              Divider(
                color: Colors.black54,
                indent: 20,
                endIndent: 20,
              ),
              _OptionItem(
                icon: Icon(
                  Icons.remove_red_eye,
                  color: Colors.blue,
                  size: 26,
                ),
                name:
                    "Send At : ${myDateUtil.getMessagesTime(context: context, time: widget.message.sent)}",
              ),
              _OptionItem(
                icon: Icon(
                  Icons.remove_red_eye,
                  color: Colors.red,
                  size: 26,
                ),
                name: widget.message.read.isNotEmpty
                    ? "Read At : ${myDateUtil.getMessagesTime(context: context, time: widget.message.read)}"
                    : "Read At : Not seen Yet",
              ),
            ],
          );
        });
  }

  // Dialogs for updating msg.
  void _showMessageUpdateDialog() {
    String updateMsg = widget.message.msg;
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding:
                  EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.message,
                      size: 26,
                      color: Colors.black,
                    ),
                    Text(
                      "Update Message",
                      style: TextStyle(color: Colors.black),
                    )
                  ]),

              // content
              content: TextFormField(
                initialValue: updateMsg,
                maxLines: null,
                onChanged: (value) => updateMsg = value,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    APIs.updateMessage(widget.message, updateMsg);
                  },
                  child: Text(
                    "Update",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              ],
            ));
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  // final VoidCallback onTap;
  const _OptionItem({required this.icon, required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 50, top: 10, bottom: 10),
      child: Row(children: [
        icon,
        Flexible(
          child: Text(
            "    $name",
            style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
                fontWeight: FontWeight.w500),
          ),
        )
      ]),
    );
  }
}