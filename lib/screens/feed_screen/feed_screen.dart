// ignore_for_file: library_private_types_in_public_api

import 'package:bataao/models/chat_user.dart';
import 'package:bataao/theme/style.dart';
import 'package:bataao/widgets/feed_cards.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/post_model.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({
    super.key,
    required this.users,
  });

  final ChatUser users;

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    // for searching status ..
    return Scaffold(
        backgroundColor: Background,
        body: SafeArea(
            child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('posts').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final posts = snapshot.data!.docs
                .map(
                    (doc) => Post.fromJson(doc.data()! as Map<String, dynamic>))
                .toList();

            final postsId = snapshot.data!.docs.map((e) => e.id).toList();

            return StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!.docs
                    .map((doc) =>
                        ChatUser.fromJson(doc.data()! as Map<String, dynamic>))
                    .toList();

                final Map<String, ChatUser> userMap = { for (var user in users) user.id : user };

                return Container(
                  decoration: BoxDecoration(gradient: gradient0),
                  child: ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (BuildContext context, int index) {
                      final post = posts[index];
                      final user = userMap[post.uId];
 
                      return FeedCards( 
                        post: post,
                        cuser: user!,
                        postsId: postsId[index],
                        users: widget.users,
                      );
                    },
                  ),
                );
              },
            );
          },
        )));
  }
}
