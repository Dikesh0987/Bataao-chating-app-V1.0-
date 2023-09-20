import 'package:bataao/models/chat_user.dart';
import 'package:bataao/screens/view_profile_screen/view_profile_screen.dart';
import 'package:bataao/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import 'dialogs/profile_view.dart';

class LikeCard extends StatefulWidget {
  const LikeCard({super.key, required this.user});
  final ChatUser user;
  @override
  State<LikeCard> createState() => _LikeCardState();
}

class _LikeCardState extends State<LikeCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: ListTile(
        leading: Container(
          width: 50.0,
          height: 50.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black45,
                offset: Offset(0, 2),
                blurRadius: 6.0,
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (_) => ProfileViewDialog(user: widget.user));
            },
            child: CircleAvatar(
              child: ClipOval(
                child: Image(
                  height: 50.0,
                  width: 50.0,
                  image: NetworkImage(widget.user.images),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        title: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ViewProfileScreen(user: widget.user)));
          },
          child: Text(
            widget.user.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        subtitle: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ViewProfileScreen(user: widget.user)));
            },
            child: Text(widget.user.about)),
        trailing: IconButton(
          icon: Icon(
            Icons.favorite,
          ),
          color: Colors.red,
          onPressed: () => print('Like comment'),
        ),
      ),
    );
  }
}
