import 'package:crime/service/firebase.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../login_register/models/user_modal.dart';
import '../../service/global.dart';
import '../../utils/theme.dart';
import '../models/comment_model.dart';
import '../models/post_model.dart';
import 'comment_card.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final Function(String, String) onComment;
  final TextEditingController controller;

  PostCard(
      {Key? key,
      required this.post,
      required this.controller,
      required this.onComment})
      : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool haveImage = false;
  String comment = "";
  User user = User();
  bool haveComment = false;
  String uID = "0";

  @override
  void initState() {
    if (widget.post.media.isNotEmpty) {
      haveImage = true;
    }
    if (widget.post.comments.isNotEmpty) {
      haveComment = true;
    }
    if (Global.instance.user!.isLoggedIn) {
      uID = Global.instance.user!.uId!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[300],
      elevation: 0.0,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: GestureDetector(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Container(
                  width: 50.0,
                  height: 50.0,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(widget.post.avatar!),
                        fit: BoxFit.cover), // border color
                    borderRadius: const BorderRadius.all(Radius.circular(40.0)),
                    border: Border.all(color: Colors.black, width: 1.0),
                  )),
              title: uID == widget.post.userId
                  ? Text("${widget.post.fname!} (me)")
                  : Text(widget.post.fname!),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateFormat('d MMM yyyy, h:mm a')
                      .format(widget.post.dateCreated!)),
                  // Text(
                  //   widget.post.location!,
                  //   style: TextStyle(color: Colors.red.shade900),
                  // ),
                ],
              ),
            ),
            Container(
                padding: const EdgeInsets.only(left: 15, top: 15, right: 15),
                child: Text(
                  widget.post.title!,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                )),
            Container(
                padding: const EdgeInsets.only(left: 15, top: 10, right: 15),
                child:
                    Text(widget.post.content!, style: TextStyle(fontSize: 15))),
            Visibility(
              visible: haveImage,
              child: Container(
                height: 150,
                padding:
                    EdgeInsets.only(bottom: 10, top: 10, left: 15, right: 15),
                child: GridView.builder(
                    itemCount: widget.post.media!.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3),
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Image.network(widget.post.media![index]));
                    }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      padding: EdgeInsets.only(left: 2),
                      onPressed: () {
                        showCommentSheet();
                      },
                      icon: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${!haveComment ? 0 : widget.post.comments!.length}",
                            style: TextStyle(color: Colors.red.shade900),
                          ),
                          Icon(
                            Icons.mode_comment_outlined,
                            color: Colors.red.shade900,
                          ),
                        ],
                      )),
                ],
              ),
            ),
            Visibility(
              visible: Global.instance.user!.isLoggedIn,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: getTextField(
                    hint: 'Write a comment..',
                    onChanged: (val) {
                      comment = val;
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getTextField(
      {String? text,
      String? label,
      String? hint,
      String? valError,
      Function(String)? onChanged,
      bool? obscureText,
      String? Function(String?)? validator}) {
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: widget.controller,
        decoration: ThemeHelper().textInputDecoReport(
            hint!,
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                widget.onComment(comment, widget.post.postId!);
              },
            )),
        onChanged: onChanged,
        validator: validator ??
            (val) {
              if (val!.isEmpty) {
                return valError;
              }
              return null;
            },
      ),
      decoration: ThemeHelper().inputBoxDecorationShaddow(),
    );
  }

  showCommentSheet() {
    return showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 500,
          child: Center(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Comments",
                        style:
                            TextStyle(fontSize: 22, color: Colors.red.shade900),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                haveComment
                    ? ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: widget.post.comments!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return CommentCard(
                              comment: widget.post.comments![index]);
                        })
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("No comments yet!"),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
