import 'package:crime/service/firebase.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

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

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  bool haveImage = false;
  String comment = "";
  User user = User();
  bool haveComment = false;
  String uID = "0";
  late AnimationController _likeController;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    if (widget.post.media.isNotEmpty) {
      haveImage = true;
    }
    if (widget.post.comments.isNotEmpty) {
      haveComment = true;
    }
    if (Global.instance.user!.isLoggedIn) {
      uID = Global.instance.user!.uId!;
    }
  }

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likeController.forward();
      } else {
        _likeController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.95, end: 1.0),
      duration: const Duration(milliseconds: 200),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Card(
        color: AppTheme.cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Hero(
                tag: 'avatar_${widget.post.userId}',
                child: Container(
                  width: 50.0,
                  height: 50.0,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.post.avatar!),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(25.0)),
                    border:
                        Border.all(color: AppTheme.primaryColor, width: 2.0),
                  ),
                ),
              ),
              title: Text(
                uID == widget.post.userId
                    ? "${widget.post.fname!} (me)"
                    : widget.post.fname!,
                style: AppTheme.titleMedium,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('d MMM yyyy, h:mm a')
                        .format(widget.post.dateCreated!),
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                widget.post.title!,
                style: AppTheme.titleMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.post.content!,
                style: AppTheme.bodyMedium,
              ),
            ),
            if (haveImage) ...[
              Container(
                height: 150,
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  itemCount: widget.post.media!.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return Hero(
                      tag: 'image_${widget.post.postId}_$index',
                      child: GestureDetector(
                        onTap: () => _showImageViewer(context, index),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.scale(
                                scale: value,
                                child: child,
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.post.media![index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ScaleTransition(
                        scale: Tween<double>(begin: 1, end: 1.2).animate(
                          CurvedAnimation(
                            parent: _likeController,
                            curve: Curves.elasticOut,
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isLiked ? Icons.favorite : Icons.favorite_border,
                            color:
                                _isLiked ? Colors.red : AppTheme.textSecondary,
                          ),
                          onPressed: _toggleLike,
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _isLiked ? "Liked" : "Like",
                          key: ValueKey<bool>(_isLiked),
                          style: AppTheme.bodySmall.copyWith(
                            color:
                                _isLiked ? Colors.red : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: showCommentSheet,
                    icon: Icon(
                      Icons.mode_comment_outlined,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    label: Text(
                      "${!haveComment ? 0 : widget.post.comments!.length}",
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (Global.instance.user!.isLoggedIn) ...[
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: getTextField(
                    hint: 'Write a comment...',
                    onChanged: (val) {
                      comment = val;
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget getTextField({
    String? text,
    String? label,
    String? hint,
    String? valError,
    Function(String)? onChanged,
    bool? obscureText,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppTheme.surfaceColor,
      ),
      child: TextFormField(
        controller: widget.controller,
        style: AppTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppTheme.dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppTheme.dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppTheme.primaryColor),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.send_rounded,
              color: AppTheme.primaryColor,
            ),
            onPressed: () {
              if (comment.trim().isNotEmpty) {
                widget.onComment(comment, widget.post.postId!);
              }
            },
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: onChanged,
        validator: validator ??
            (val) {
              if (val!.isEmpty) {
                return valError;
              }
              return null;
            },
      ),
    );
  }

  void showCommentSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Comments",
                      style: AppTheme.titleLarge,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: AppTheme.textPrimary,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Divider(color: AppTheme.dividerColor),
              Expanded(
                child: haveComment
                    ? ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: widget.post.comments!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return CommentCard(
                            comment: widget.post.comments![index],
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          "No comments yet!",
                          style: AppTheme.bodyLarge.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImageViewer(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              PhotoViewGallery.builder(
                scrollPhysics: const BouncingScrollPhysics(),
                builder: (BuildContext context, int index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: NetworkImage(widget.post.media![index]),
                    initialScale: PhotoViewComputedScale.contained,
                    heroAttributes: PhotoViewHeroAttributes(
                      tag: 'image_${widget.post.postId}_$index',
                    ),
                  );
                },
                itemCount: widget.post.media!.length,
                loadingBuilder: (context, event) => Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                    value: event == null
                        ? 0
                        : event.cumulativeBytesLoaded /
                            event.expectedTotalBytes!,
                  ),
                ),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                pageController: PageController(initialPage: initialIndex),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      if (widget.post.media!.length > 1)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${initialIndex + 1}/${widget.post.media!.length}',
                            style: AppTheme.bodyMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
