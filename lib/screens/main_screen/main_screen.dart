import 'dart:io';
import 'package:bataao/screens/all_users_screen/all_users_screen.dart';
import 'package:bataao/screens/notification_screen/notification_screen.dart';
import 'package:bataao/screens/profile_screen/profile_screen.dart';
import 'package:bataao/screens/status_screen/status_screen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../api/apis.dart';
import '../../models/chat_user.dart';
import '../../theme/style.dart';
import '../../widgets/chat_user_card.dart';
import '../feed_screen/feed_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    APIs.getCurrentUserInfo();
    APIs.getAllUsers();

    SystemChannels.lifecycle.setMessageHandler((message) {
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume'))
          APIs.updateActiveStatus(true);
        if (message.toString().contains('pause'))
          APIs.updateActiveStatus(false);
      }
      return Future.value(message);
    });
  }

  int _pageIndex = 0;
  List<Color> _colo = [
    White,
    White,
    White,
    White,
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floating action buttton
      floatingActionButton: _pageIndex == 0
          ? FloatingActionButton(
              materialTapTargetSize: MaterialTapTargetSize.padded,
              backgroundColor: White,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AllUsersScreen()));
              },
              child: Icon(
                Icons.search_rounded,
                size: 26,
                color: Orange,
              ),
            )
          : null,

      // Main Body
      body: getSelectedPage(index: _pageIndex),

      // Bottom nav bar
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: White,
        height: 60,
        color: White,
        items: <Widget>[
          Icon(
            Icons.chat_outlined,
            size: 24,
            color: Orange,
          ),
          Icon(
            Icons.fiber_manual_record_outlined,
            size: 24,
            color: Orange,
          ),
          Icon(
            Icons.person_2_outlined,
            size: 24,
            color: Orange,
          ),
        ],
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 200),
        onTap: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
      ),
    );
  }

  Widget getSelectedPage({required int index}) {
    Widget widget;
    switch (index) {
      case 0:
        widget = const _mainBody();
        break;

      case 1:
        widget = FeedScreen(
          users: APIs.selfInfo,
        );
        break;

      // case 2:
      //   widget = StatusScreen(
      //     user: APIs.selfInfo,
      //   );
      //   break;

      default:
        widget = ProfileScreen(
          user: APIs.selfInfo,
        );
        break;
    }
    return widget;
  }
}

// Main Body
class _mainBody extends StatefulWidget {
  const _mainBody({super.key});

  @override
  State<_mainBody> createState() => __mainBodyState();
}

class __mainBodyState extends State<_mainBody> {
  // for all users ..
  List<ChatUser> _list = [];

  // for all connections
  List<String> _connList = [];

  // for searching values ..
  List<ChatUser> _searchList = [];

  // for searching status ..
  bool _isSearching = false;

  // loding
  bool _loading = false;

  // Form Key

  final _formKey = GlobalKey<FormState>();

  String? _image;

  // for some filsds text editing controller

  final _mentionTextController = TextEditingController();
  final _locationTextController = TextEditingController();
  final _titleTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              automaticallyImplyLeading: false,
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: _isSearching
                    ? TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "search name or email ",
                        ),
                        style: TextStyle(fontSize: 16, letterSpacing: 0.5),
                        autofocus: true,
                        onChanged: (val) {
                          _searchList.clear();
                          for (var i in _list) {
                            if (i.name
                                    .toLowerCase()
                                    .contains(val.toLowerCase()) ||
                                i.email
                                    .toLowerCase()
                                    .contains(val.toLowerCase())) {
                              _searchList.add(i);
                            }
                            setState(() {
                              _searchList;
                            });
                          }
                        },
                      )
                    : const Text(
                        'Bataao',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Body),
                      ),
              ),
              elevation: 0,

              actions: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                      });
                    },
                    icon: Icon(
                      _isSearching ? Icons.clear : Icons.search,
                      color: Body,
                      size: 24,
                    )),
                if (_isSearching == false)
                  IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NotificationScreen()));
                      },
                      icon: Icon(
                        Icons.notification_important_outlined,
                        size: 24,
                        color: Body,
                      )),
                if (_isSearching == false)
                  Padding(
                    padding: const EdgeInsets.only(right: 0),
                    child: IconButton(
                        onPressed: () {
                          _showPostBottomShit();
                        },
                        icon: Icon(
                          Icons.add_box_outlined,
                          size: 24,
                          color: Body,
                        )),
                  ),
                if (_isSearching == false)
                  Padding(
                    padding: const EdgeInsets.only(right: 0),
                    child: IconButton(
                        onPressed: () {
                          // _showPostBottomShit();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      StatusScreen(user: APIs.selfInfo)));
                        },
                        icon: Icon(
                          Icons.looks,
                          size: 24,
                          color: Body,
                        )),
                  )
              ],
              // floating: true,
              // expandedHeight: 60.0,
              // forceElevated: innerBoxIsScrolled,
            ),
          ];
        },
        body: Column(
          children: [
            Expanded(
                child: Container(
                    decoration: BoxDecoration(
                        // color: Background,
                        gradient: gradient0,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    child: StreamBuilder(
                      stream: APIs.getAllUsersConn(),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          // if data is loading
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return Center(
                              child: CircularProgressIndicator(),
                            );

                          // data loaded
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;
                            _connList = data?.map((e) => e.id).toList() ?? [];

                            print(_connList);

                            if (_connList.isNotEmpty) {
                              return StreamBuilder(
                                stream: APIs.getSalectedUserData(_connList),
                                builder: (context, snapshot) {
                                  switch (snapshot.connectionState) {
                                    // if data is loading
                                    case ConnectionState.waiting:
                                    case ConnectionState.none:
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );

                                    // data loaded
                                    case ConnectionState.active:
                                    case ConnectionState.done:
                                      final data = snapshot.data?.docs;
                                      _list = data
                                              ?.map((e) =>
                                                  ChatUser.fromJson(e.data()))
                                              .toList() ??
                                          [];

                                      if (_list.isNotEmpty) {
                                        return ListView.builder(
                                          itemCount: _isSearching
                                              ? _searchList.length
                                              : _list.length,
                                          padding: EdgeInsets.only(top: 5),
                                          physics: BouncingScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            return ChatUserCard(
                                              user: _isSearching
                                                  ? _searchList[index]
                                                  : _list[index],
                                            );
                                          },
                                        );
                                      } else {
                                        return Center(
                                          child: Text(
                                            "No Data Found",
                                            style: TextStyle(fontSize: 20),
                                          ),
                                        );
                                      }
                                  }
                                },
                              );
                            } else {
                              return Center(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    shape: StadiumBorder(),
                                    backgroundColor: Colors.white,
                                    minimumSize: Size(
                                      MediaQuery.of(context).size.width * .5,
                                      MediaQuery.of(context).size.height * .05,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AllUsersScreen()),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.add_reaction,
                                    size: 28,
                                    color: Colors.black,
                                  ),
                                  label: Text(
                                    "Make Some Connections",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black),
                                  ),
                                ),
                              );
                            }
                        }
                      },
                    ))),
          ],
        ),
      ),
    );
  }

  // Show Bottom Shit for new post
  void _showPostBottomShit() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                // mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          icon: Icon(
                                            Icons.clear,
                                            size: 24,
                                          )),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Text(
                                          "New Post",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Body,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    ],
                                  ),
                                  Divider(),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 10,
                                      ),
                                      _image != null
                                          ? Container(
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image:
                                                        NetworkImage(_image!),
                                                    fit: BoxFit.cover),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              width: 150,
                                              height: 150,
                                              child: IconButton(
                                                  onPressed: () {
                                                    _showBottomShit();
                                                  },
                                                  icon: Icon(
                                                    Icons.post_add_outlined,
                                                    size: 50,
                                                  )),
                                            )
                                          : Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: Background),
                                              width: 150,
                                              height: 150,
                                              child: IconButton(
                                                  onPressed: () {
                                                    _showBottomShit();
                                                  },
                                                  icon: Icon(
                                                    Icons.post_add_outlined,
                                                    size: 40,
                                                    color: Body,
                                                  )),
                                            ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              TextFormField(
                                                  // initialValue: "#nature",
                                                  controller:
                                                      _mentionTextController,
                                                  decoration: InputDecoration(
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      prefixIcon:
                                                          Icon(Icons.bolt),
                                                      hintText:
                                                          "Just Burn Out.",
                                                      labelText: "Mention")),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              TextFormField(
                                                  controller:
                                                      _locationTextController,
                                                  // initialValue: 's',
                                                  decoration: InputDecoration(
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      prefixIcon: Icon(Icons
                                                          .pin_drop_outlined),
                                                      hintText: "Naya Raipur",
                                                      labelText: "Location")),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        )),
                    SizedBox(
                      height: 20,
                    ),
                    Expanded(
                        flex: 5,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Background,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10))),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 30),
                            child: Column(
                              children: [
                                // input Form
                                TextFormField(
                                    controller: _titleTextController,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        prefixIcon: Icon(Icons.label),
                                        hintText: "Just Burn Out.",
                                        labelText: "Title")),
                                SizedBox(
                                  height: 20,
                                ),

                                ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                        shape: StadiumBorder(),
                                        backgroundColor: Colors.white,
                                        minimumSize: Size(
                                            MediaQuery.of(context).size.width *
                                                .9,
                                            MediaQuery.of(context).size.height *
                                                .06)),
                                    onPressed: () async {
                                      FocusScope.of(context).unfocus;
                                      setState(() {
                                        _loading = true;
                                      });

                                      await APIs.uploadPostPicture(
                                              APIs.selfInfo,
                                              _mentionTextController.text,
                                              _titleTextController.text,
                                              _locationTextController.text,
                                              File(_image!))
                                          .then((value) {
                                        setState(() {
                                          _loading = false;
                                        });
                                        Navigator.pop(context);
                                      });
                                    },
                                    icon: _loading
                                        ? Icon(
                                            Icons.circle_outlined,
                                            size: 28,
                                            color: PrimaryBlue,
                                          )
                                        : Icon(
                                            Icons.post_add_outlined,
                                            size: 28,
                                            color: Colors.black,
                                          ),
                                    label: _loading
                                        ? Center(
                                            child: CircularProgressIndicator(),
                                          )
                                        : Text(
                                            "Post",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black),
                                          )),
                              ],
                            ),
                          ),
                        ))
                  ],
                ),
              ),
            ),
          );
        });
  }

  // Show Bottom Shit for uploding pic .
  void _showBottomShit() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (context) {
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(top: 30, bottom: 60),
            children: [
              Text(
                "Pick Profile Pictures ",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery, imageQuality: 80);

                        if (image != null) {
                          print("Image Path : ${image.path}");
                          //update image
                          setState(() {
                            _image = image.path;
                          });
                          // APIs.uploadStatusPicture(File(_image!));
                          //for hide bottom sheet
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          backgroundColor: Colors.white,
                          fixedSize: Size(80, 80)),
                      child: Image.asset('assets/images/picture.png')),
                  ElevatedButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 80);

                        if (image != null) {
                          print("Image Path : ${image.path}");
                          //update image
                          setState(() {
                            _image = image.path;
                          });
                          // APIs.uploadStatusPicture(File(_image!));
                          //for hide bottom sheet
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          backgroundColor: Colors.white,
                          fixedSize: Size(80, 80)),
                      child: Image.asset('assets/images/camera.png')),
                ],
              )
            ],
          );
        });
  }
}
