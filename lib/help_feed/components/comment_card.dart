import 'package:flutter/material.dart';

import '../../login_register/models/user_modal.dart';
import '../../service/firebase.dart';
import '../../utils/theme.dart';
import '../models/comment_model.dart';

class CommentCard extends StatefulWidget {
  final Comment comment;
  const CommentCard({Key? key, required this.comment}) : super(key: key);

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  User newUser = User();
  bool isLoading = true;

  Future<void> getUser() async {
    try {
      Map data = await getUserData(widget.comment.userID);
      newUser = User.otherUser(data["avatar"], data["fName"]);
    } catch (e) {
      debugPrint("Error fetching user: $e");
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(newUser.avatar!),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppTheme.primaryColor,
                width: 2,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  newUser.fName!,
                  style: AppTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.comment.comment!,
                  style: AppTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.comment.dateCreated!,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
