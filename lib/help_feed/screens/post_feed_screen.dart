import 'dart:async';
import 'dart:convert';

import 'package:crime/help_feed/models/comment_model.dart';
import 'package:crime/help_feed/screens/add_edit_screen.dart';
import 'package:crime/utils/bottom_navigation.dart';
import 'package:crime/utils/custom_widgets.dart';
import 'package:crime/utils/theme.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:google_maps_webservice/places.dart';

import '../../service/firebase.dart';
import '../../service/global.dart';
import '../components/post_card.dart';
import '../models/post_model.dart';

class PostFeedScreen extends StatefulWidget {
  const PostFeedScreen({super.key});

  @override
  State<PostFeedScreen> createState() => _PostFeedScreenState();
}

const kGoogleApiKey = 'AIzaSyACR85dcvtoBdJ4i9xsIIs2QDNDfVWduIU';

class _PostFeedScreenState extends State<PostFeedScreen>
    with SingleTickerProviderStateMixin {
  List<Post> initPostList = [];
  List<Post> postList = [];
  late StreamSubscription<DatabaseEvent> _postSubscription;
  bool isLoading = true;
  String? choosenLocation;
  TextEditingController controller = TextEditingController();
  String uID = "0";
  final Mode _mode = Mode.overlay;
  late AnimationController _refreshIconController;

  Future<void> setupPostListener() async {
    final postRef = FirebaseDatabase.instance.ref().child('post');

    _postSubscription = postRef.onValue.listen(
      (event) async {
        if (!mounted) return;

        setState(() => isLoading = true);

        try {
          List<Post> newPosts = [];
          for (final child in event.snapshot.children) {
            List<String> postMedia = [];
            List<Comment> comments = [];

            final postID = child.key!;
            Map data = json.decode(json.encode(child.value));

            if (data['media'] != null) {
              for (int i = 0; i < data['media'].length; i++) {
                postMedia.add(data['media'][i]["file"]);
              }
            }

            if (data['comments'] != null) {
              var commentData = data['comments'];
              commentData.keys.forEach((key) {
                var commentID = key;
                var commentValue = commentData[commentID];
                comments.add(Comment(
                  commentID,
                  commentValue['dateCreated'],
                  commentValue['userID'],
                  commentValue['comment'],
                ));
              });
            }

            newPosts.add(Post(
              postId: postID,
              userId: data['userID'],
              fname: data['userName'],
              location: data['location'],
              dateCreated: DateTime.parse(data['dateCreated']),
              avatar: data['avatar'],
              content: data['content'],
              priority: data['priority'],
              title: data['title'],
              media: postMedia,
              comments: comments,
            ));
          }

          if (mounted) {
            setState(() {
              initPostList = newPosts;
              postList = List.from(newPosts)
                ..sort((b, a) => a.dateCreated!.compareTo(b.dateCreated!));
              isLoading = false;
            });
          }
        } catch (e) {
          if (kDebugMode) {
            print("Error processing posts: $e");
          }
          if (mounted) {
            setState(() => isLoading = false);
            Fluttertoast.showToast(
                msg: "Error loading posts. Please try again.");
          }
        }
      },
      onError: (error) {
        if (kDebugMode) {
          print("Error in post stream: $error");
        }
        if (mounted) {
          setState(() => isLoading = false);
          Fluttertoast.showToast(msg: "Error loading posts. Please try again.");
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _refreshIconController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    if (Global.instance.user!.isLoggedIn) {
      uID = Global.instance.user!.uId!;
    }
    setupPostListener();
  }

  @override
  void dispose() {
    _refreshIconController.dispose();
    _postSubscription.cancel();
    controller.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    _refreshIconController.repeat();
    await setupPostListener();
    _refreshIconController.stop();
    _refreshIconController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: Global.instance.user!.isLoggedIn
          ? customAppBarAction(
              title: 'Post Feed',
              actions: Row(
                children: [
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 1.0)
                        .animate(_refreshIconController),
                    child: IconButton(
                      icon: Icon(Icons.refresh, color: AppTheme.primaryColor),
                      onPressed: _handleRefresh,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: AppTheme.primaryColor),
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  AddEditPostScreen(isEdit: "true"),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            var begin = const Offset(0.0, 1.0);
                            var end = Offset.zero;
                            var curve = Curves.easeInOutCubic;
                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 500),
                        ),
                      ).then((_) => setupPostListener());
                    },
                  ),
                ],
              ))
          : customAppBar(title: ""),
      body: Column(
        children: [
          // Filter button
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: Icon(
                    Icons.filter_alt_rounded,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  label: Text(
                    "Filter",
                    style: AppTheme.titleSmall.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                  onPressed: () => getFilterPopUp(),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: isLoading
                ? Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: child,
                        );
                      },
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  )
                : postList.isEmpty
                    ? Center(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 500),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: child,
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.post_add_rounded,
                                size: 64,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No posts yet',
                                style: AppTheme.titleMedium.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              if (Global.instance.user!.isLoggedIn) ...[
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation,
                                                secondaryAnimation) =>
                                            AddEditPostScreen(isEdit: "true"),
                                        transitionsBuilder: (context, animation,
                                            secondaryAnimation, child) {
                                          var begin = const Offset(0.0, 1.0);
                                          var end = Offset.zero;
                                          var curve = Curves.easeInOutCubic;
                                          var tween = Tween(
                                                  begin: begin, end: end)
                                              .chain(CurveTween(curve: curve));
                                          return SlideTransition(
                                            position: animation.drive(tween),
                                            child: child,
                                          );
                                        },
                                        transitionDuration:
                                            const Duration(milliseconds: 500),
                                      ),
                                    ).then((_) => setupPostListener());
                                  },
                                  style: AppTheme.primaryButtonStyle,
                                  child: const Text('Create First Post'),
                                ),
                              ],
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        color: AppTheme.primaryColor,
                        onRefresh: _handleRefresh,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: postList.length,
                          itemBuilder: (context, index) {
                            return TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0.0, end: 1.0),
                              duration:
                                  Duration(milliseconds: 300 + (index * 100)),
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0.0, 50 * (1 - value)),
                                  child: Opacity(
                                    opacity: value,
                                    child: child,
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                child: PostCard(
                                  post: postList[index],
                                  controller: controller,
                                  onComment: (val, id) async {
                                    DatabaseReference commentRef =
                                        FirebaseDatabase.instance
                                            .ref()
                                            .child('post')
                                            .child(id)
                                            .child('comments');

                                    String commentID = commentRef.push().key!;

                                    await commentRef.child(commentID).set({
                                      'userID': uID,
                                      'dateCreated':
                                          DateFormat('d MM, yyyy, h:mm a')
                                              .format(DateTime.now()),
                                      'comment': val
                                    });

                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    controller.clear();
                                    await setupPostListener();
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        defaultSelectedIndex: 3,
      ),
    );
  }

  Future<void> getFilterPopUp() {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 300),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: Theme(
            data: Theme.of(context).copyWith(
              dialogBackgroundColor: AppTheme.cardColor,
            ),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Filter by Location',
                style: AppTheme.titleLarge,
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton(
                      onPressed: _handlePressButton,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: BorderSide(color: AppTheme.primaryColor),
                        padding: const EdgeInsets.all(16),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              choosenLocation ?? "Select Location",
                              style: AppTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (choosenLocation != null) ...[
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            choosenLocation = null;
                            postList = List.from(initPostList)
                              ..sort((b, a) =>
                                  a.dateCreated!.compareTo(b.dateCreated!));
                          });
                          Navigator.of(context).pop();
                        },
                        icon: Icon(
                          Icons.clear,
                          color: AppTheme.textSecondary,
                          size: 18,
                        ),
                        label: Text(
                          'Clear Filter',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: AppTheme.bodyLarge.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: AppTheme.primaryButtonStyle,
                  child: const Text('Apply'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handlePressButton() async {
    Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      language: 'en',
      mode: _mode,
      strictbounds: false,
      types: [""],
      logo: Container(height: 0),
      decoration: InputDecoration(
        hintText: 'Search Location',
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.primaryColor),
        ),
      ),
      components: [Component(Component.country, "in")],
    );

    if (p != null) {
      setState(() {
        choosenLocation = p.terms[0].value;
        postList = initPostList
            .where((post) =>
                post.location?.toLowerCase() == choosenLocation?.toLowerCase())
            .toList();

        if (postList.isEmpty) {
          Fluttertoast.showToast(msg: "No posts found for this location");
        }
      });
    }
  }
}
