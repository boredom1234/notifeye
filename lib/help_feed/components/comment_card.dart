import 'package:flutter/material.dart';

import '../../login_register/models/user_modal.dart';
import '../../service/firebase.dart';
import '../models/comment_model.dart';

class CommentCard extends StatefulWidget {
  final Comment comment;
  const CommentCard({
    Key? key,
    required this.comment
  }) : super(key: key);


  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {

  User newUser = User();
  bool onLoading = true;

  getUser()async{
    Map data = await getUserData(widget.comment.userID);
    newUser = User.otherUser(data["avatar"] , data["fName"]);
    setState(() {
      onLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return onLoading ? Container(
      child: Text("No comment yet!"),
    ) :
    ListTile(
      leading: Container(
          width:  40.0,
          height:  40.0,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(newUser.avatar!), fit: BoxFit.cover), // border color
            borderRadius: const BorderRadius.all(Radius.circular(40.0)),
            border: Border.all(
                color: Colors.black, width: 1.0),
          )),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(newUser.fName!,style: TextStyle(
              fontWeight: FontWeight.bold
          ),),
          Container(
            padding: const EdgeInsets.only(top: 4, right: 4, bottom: 2),
            child: Text("${widget.comment.comment}"),
          ),
        ],
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text("${widget.comment.dateCreated!}"),
        ],
      ),
    );
  }
}
