import 'dart:convert';
import 'dart:async';

import 'package:crime/service/firebase.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:intl/intl.dart';

import '../components/post_card.dart';
import '../models/comment_model.dart';
import '../models/post_model.dart';
import 'add_edit_screen.dart';
import '../../service/global.dart';
import '../../utils/custom_widgets.dart';

class MyPostScreen extends StatefulWidget {
  const MyPostScreen({Key? key}) : super(key: key);

  @override
  State<MyPostScreen> createState() => _MyPostScreenState();
}

class _MyPostScreenState extends State<MyPostScreen> {
  List<Post> postList = [];
  TextEditingController controller = TextEditingController();
  String? uID;
  String? postID;
  var postRef = FirebaseDatabase.instance.ref().child('post');
  String filter = "";
  bool onLoading = true;
  String? choosenLocation;

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    getAlldata();
    // Start the timer to auto-refresh every 1 minute
    _timer = Timer.periodic(const Duration(milliseconds: 500), (Timer timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the screen is disposed
    _timer.cancel();
    super.dispose();
  }

  getAlldata() async {
    postList = [];
    postList = await getMyPostList().whenComplete(() => setState(() {
          onLoading = false;
        }));
    setState(() {
      onLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Posts'),
      ),
      body: onLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              constraints: const BoxConstraints(
                maxHeight: double.infinity,
              ),
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    onLoading = true;
                  });
                  await getAlldata();
                },
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: getInitialList(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  getInitialList() {
    postList.sort((b, a) => a.dateCreated!.compareTo(b.dateCreated!));
    return getPostCardComponent(postList);
  }

  getPostCardComponent(List postList) {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: postList.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddEditPostScreen(
                                  isEdit: postList[index].postId)),
                        );
                      },
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.green,
                      )),
                  IconButton(
                      onPressed: () async {
                        //delete data from database
                        postRef.child(postList[index].postId).remove();
                        //get updated post list
                        postList = await getAlldata();
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Colors.redAccent.shade700,
                      ))
                ],
              ),
              PostCard(
                post: postList[index],
                controller: controller,
                onComment: (val, id) async {
                  DatabaseReference commentRef =
                      postRef.child(id).child('comments');

                  String commentID = commentRef.push().key!;

                  await commentRef.child(commentID).set({
                    'userID': uID,
                    'dateCreated':
                        DateFormat('d MM, yyyy, h:mm a').format(DateTime.now()),
                    'comment': val
                  });

                  setState(() {
                    FocusManager.instance.primaryFocus?.unfocus();
                    controller.clear();
                    onLoading = true;
                  });
                  postList = await getAlldata();
                },
              )
            ],
          );
        });
  }
}
