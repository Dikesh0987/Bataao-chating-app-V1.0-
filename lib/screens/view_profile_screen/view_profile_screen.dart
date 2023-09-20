import 'package:bataao/api/apis.dart';
import 'package:bataao/models/chat_user.dart';
import 'package:bataao/models/connection_model.dart';
import 'package:bataao/screens/view_post_screen/view_post_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import '../../models/post_model.dart';
import '../../theme/style.dart';

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key, required this.user});
  final ChatUser user;

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final String imgUrl = widget.user.images;

    List<Connection> _clist = [];

    List<Post> _posts = [];

    List<String> _postId = [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  Icons.arrow_back,
                                  size: 28,
                                )),
                            IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.deblur_outlined,
                                  size: 28,
                                )),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.grey,
                              backgroundImage: NetworkImage(imgUrl),
                            ),
                            SizedBox(
                              width: 200,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "${widget.user.name}",
                                    maxLines: 2,
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    widget.user.about,
                                    maxLines: 2,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  StreamBuilder(
                                      stream: APIs
                                          .getCurrentUserConnectionsAccepted(
                                              widget.user),
                                      builder: (context, snapshot) {
                                        switch (snapshot.connectionState) {
                                          // if data has been loading
                                          case ConnectionState.waiting:
                                          case ConnectionState.none:
                                            return Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );

                                          // data lodede

                                          case ConnectionState.active:
                                          case ConnectionState.done:
                                            final data = snapshot.data?.docs;
                                            _clist = data
                                                    ?.map((e) =>
                                                        Connection.fromJson(
                                                            e.data()))
                                                    .toList() ??
                                                [];

                                            if (_clist.isNotEmpty) {
                                              return ElevatedButton.icon(
                                                  style: ElevatedButton.styleFrom(
                                                      shape: StadiumBorder(),
                                                      backgroundColor:
                                                          Colors.white,
                                                      minimumSize: Size(
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .5,
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              .045)),
                                                  onPressed: () async {
                                                    await APIs.dropConnections(
                                                        widget.user);
                                                  },
                                                  icon: Icon(
                                                    Icons.cut,
                                                    size: 26,
                                                    color: Colors.black,
                                                  ),
                                                  label: Text(
                                                    "Disconnect Now",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black),
                                                  ));
                                            } else {
                                              return ElevatedButton.icon(
                                                  style: ElevatedButton.styleFrom(
                                                      shape: StadiumBorder(),
                                                      backgroundColor: White,
                                                      minimumSize: Size(
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .5,
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              .045)),
                                                  onPressed: () async {
                                                    await APIs
                                                        .makeNewConnections(
                                                            widget.user);
                                                  },
                                                  icon: Icon(
                                                    Icons.cut,
                                                    size: 26,
                                                    color: Colors.black,
                                                  ),
                                                  label: Text(
                                                    "Connect Now",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black),
                                                  ));
                                            }
                                        }
                                      }),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
            Expanded(
                flex: 8,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Background,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: APIs.getPostsByUser(widget.user.id),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasData) {
                          _posts = snapshot.data!.docs
                              .map((doc) => Post.fromJson(
                                  doc.data() as Map<String, dynamic>))
                              .toList();

                          _postId =
                              snapshot.data!.docs.map((e) => e.id).toList();
                        }

                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 10.0,
                          ),
                          itemCount: _posts.length,
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ViewPostScreen(
                                            post: _posts[index],
                                            cuser: widget.user,
                                            postsId: _postId[index],
                                          ))),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    image: DecorationImage(
                                        image: NetworkImage(_posts[index].link),
                                        fit: BoxFit.cover)),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
