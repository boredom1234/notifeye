import 'dart:io';

import 'package:crime/help_feed/screens/my_post_screen.dart';
import 'package:crime/help_feed/screens/post_feed_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../login_register/models/user_modal.dart';
import '../../service/api.dart';
import '../../service/firebase.dart';
import '../../service/global.dart';
import '../../utils/custom_widgets.dart'
    show getCustomButton, customAppBar, getTextField;
import '../../utils/theme.dart' hide getCustomButton;
import '../models/comment_model.dart';
import 'package:google_maps_webservice/places.dart';

class AddEditPostScreen extends StatefulWidget {
  var isEdit;

  AddEditPostScreen({required this.isEdit, Key? key}) : super(key: key);

  @override
  State<AddEditPostScreen> createState() => _AddEditPostScreenState();
}

const kGoogleApiKey = 'AIzaSyACR85dcvtoBdJ4i9xsIIs2QDNDfVWduIU';

class _AddEditPostScreenState extends State<AddEditPostScreen> {
  final _formKey = GlobalKey<FormState>();

  User user = Global.instance.user!;
  String? postId;
  String? fname, avatar, title, content, dateCreated;
  String? location;
  String? priority;

  List<String> media = [];

  bool haveImage = false;
  bool haveEditImage = false;

  bool isEdit = false;
  final ImagePicker imagePicker = ImagePicker();
  List<XFile> imageFileList = [];

  List<String> imageFileListEdit = [];

  void selectImages() async {
    final List<XFile>? selectedImages = await imagePicker.pickMultiImage();
    if (selectedImages!.isNotEmpty) {
      imageFileList!.addAll(selectedImages);
    }
    print("Image List Length:" + imageFileList!.length.toString());
    setState(() {
      haveImage = true;
    });
  }

  List<String> priorityList = [
    'Missing Person',
    'Missing Pet',
    'Missing Vehicle / Item',
    'Alert',
    'Informative',
    'Charity / Donation',
    'Announcements'
  ];

  final Mode _mode = Mode.overlay;

  getPostDataDetails() async {
    var data = await getPostData(postId!);
    title = data["title"];
    content = data["content"];
    priority = priorityList[data["priority"]];
    location = data["location"];
    if (data['media'] != null) {
      for (int i = 0; i < data['media'].length; i++) {
        if (data['media'][i] != null) {
          imageFileListEdit.add(data['media'][i]["file"]);
        }
      }
      haveEditImage = true;
      print(imageFileListEdit);
    }
    setState(() {
      isEdit = true;
    });
  }

  @override
  void initState() {
    super.initState();
    fname = user.fName;
    avatar = user.avatar;
    if (widget.isEdit != "false") {
      postId = widget.isEdit;
      getPostDataDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: customAppBar(
        title: isEdit ? "Edit Post" : "Add New Post",
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Title
                Text(
                  'Post Details',
                  style: AppTheme.headlineMedium.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Location and Type Fields
                getLocationField(),
                const SizedBox(height: 16),
                selectPurposeField(),
                const SizedBox(height: 16),

                // Title Field
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      style: AppTheme.bodyMedium
                          .copyWith(color: AppTheme.textColor),
                      decoration: InputDecoration(
                        hintText: 'Enter title of the post',
                        hintStyle: AppTheme.bodyMedium
                            .copyWith(color: AppTheme.textLightColor),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        title = value;
                      },
                      validator: (val) {
                        if (val!.isEmpty) {
                          return "Please enter a title";
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Content Field
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      style: AppTheme.bodyMedium
                          .copyWith(color: AppTheme.textColor),
                      decoration: InputDecoration(
                        hintText: 'Write the post content...',
                        hintStyle: AppTheme.bodyMedium
                            .copyWith(color: AppTheme.textLightColor),
                        border: InputBorder.none,
                      ),
                      minLines: 5,
                      maxLines: 8,
                      onChanged: (val) {
                        content = val;
                      },
                      validator: (val) {
                        if (val!.isEmpty) {
                          return "Please enter the content";
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Media Section
                Text(
                  'Media',
                  style: AppTheme.headlineMedium.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Attach Images Button
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: selectImages,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Attach Images",
                            style: AppTheme.titleMedium.copyWith(
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Image Grid
                if (haveImage)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: imageFileList.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          return Stack(
                            children: <Widget>[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(imageFileList[index].path),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardColor.withOpacity(0.7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.close, size: 20),
                                    color: AppTheme.error,
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        imageFileList.removeAt(index);
                                        if (imageFileList.isEmpty) {
                                          haveImage = false;
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                // Edit Image Grid
                if (haveEditImage)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: imageFileListEdit.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          return Stack(
                            children: <Widget>[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageFileListEdit[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardColor.withOpacity(0.7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.close, size: 20),
                                    color: AppTheme.error,
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        imageFileListEdit.removeAt(index);
                                        if (imageFileListEdit.isEmpty) {
                                          haveEditImage = false;
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (isEdit) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyPostScreen()),
                            );
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PostFeedScreen()),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.cardColor,
                          foregroundColor: AppTheme.textColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isEdit ? handleEdit : handleUpload,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: AppTheme.textColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(isEdit ? "Save" : "Upload"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> handleEdit() async {
    if (_formKey.currentState!.validate()) {
      String uID = user.uId!;
      DatabaseReference postRef =
          FirebaseDatabase.instance.ref().child('post').child(postId!);
      int prior = priorityList.indexOf(priority!);

      await postRef.update({
        'location': location,
        'priority': prior,
        'title': title,
        'content': content,
      });

      DatabaseReference mediaRef = postRef.child('media');
      int index = haveEditImage ? imageFileListEdit.length : 0;

      if (imageFileList.isNotEmpty) {
        for (var file in imageFileList) {
          var url = await uploadXImage(file: file);
          await mediaRef.child(index.toString()).set({'file': url});
          index++;
        }
      }

      Fluttertoast.showToast(
        msg: "Post Updated successfully",
        backgroundColor: AppTheme.success,
        textColor: AppTheme.textColor,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyPostScreen()),
      );
    }
  }

  Future<void> handleUpload() async {
    if (_formKey.currentState!.validate()) {
      String uID = user.uId!;
      DatabaseReference postRef = FirebaseDatabase.instance.ref().child('post');
      String postID = postRef.push().key!;
      int prior = priorityList.indexOf(priority!);

      await postRef.child(postID).set({
        'userID': uID,
        'userName': fname,
        'avatar': avatar,
        'location': location,
        'dateCreated': DateTime.now().toString(),
        'priority': prior,
        'title': title,
        'content': content,
      });

      if (imageFileList.isNotEmpty) {
        DatabaseReference mediaRef = postRef.child(postID).child('media');
        int index = 0;
        for (var file in imageFileList) {
          var url = await uploadXImage(file: file);
          await mediaRef.child(index.toString()).set({'file': url});
          index++;
        }
      }

      Fluttertoast.showToast(
        msg: "New Post Uploaded successfully",
        backgroundColor: AppTheme.success,
        textColor: AppTheme.textColor,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PostFeedScreen()),
      );
    }
  }

  selectPurposeField() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            hintText: "Select Type of Crime",
            hintStyle: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textLightColor,
            ),
          ),
          icon: Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
          dropdownColor: AppTheme.cardColor,
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textColor,
          ),
          isExpanded: true,
          value: priority,
          items: priorityList.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textColor,
                ),
              ),
            );
          }).toList(),
          validator: (value) {
            if (priority == null) {
              return "Please select the purpose";
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              priority = value.toString();
            });
          },
        ),
      ),
    );
  }

  getLocationField() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextButton(
        onPressed: _handlePressButton,
        style: ButtonStyle(
          padding: MaterialStateProperty.all(
            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              color: AppTheme.primaryColor,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                location ?? "Enter the Location of the Incident",
                style: AppTheme.bodyMedium.copyWith(
                  color: location != null
                      ? AppTheme.textColor
                      : AppTheme.textLightColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
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
        logo: Container(
          height: 1,
        ),
        decoration: InputDecoration(
            hintText: 'Enter the Location of the Incident',
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.white))),
        components: [Component(Component.country, "in")]);
    setState(() {
      location = p!.terms[0].value;
    });
  }
}
