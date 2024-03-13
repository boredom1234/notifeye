import 'package:crime/help_feed/models/comment_model.dart';

import 'package:intl/intl.dart';

class Post {
  String? postId, userId;
  String? fname, avatar, title, content;
  DateTime? dateCreated;
  String? location;
  int? priority;
  List<String> media = [];
  int? countComment;
  List<Comment> comments = [];

  Post(
      {this.postId,
      this.userId,
      this.fname,
      this.avatar,
      this.title,
      this.content,
      this.priority,
      this.dateCreated,
      this.location,
      required this.media,
      this.countComment,
      required this.comments});

  // factory Post.fromMap(Map<String, dynamic> data) {
  //
  //   return Post(
  //       postId : BigInt.from(data['postId']),
  //       userId : BigInt.from(data['userId']),
  //       username : data['username'],
  //       avatar : data['avatar'],
  //       content : data['content'],
  //       date : data['dateCreated'],
  //       media : data['media'],
  //       countComment : data['countLike'],
  //       comments: data['comments']);
  // }

  // Map<String, dynamic> toMap() => {
  //   'postId': postId,
  //   'userId': userId,
  //   'user': fname,
  //   'avatar': avatar,
  //   'content': content,
  //   'dateCreated': dateCreated,
  //   'media': media,
  //   'countLike': countComment,
  //   'comments': comments
  // };
}
