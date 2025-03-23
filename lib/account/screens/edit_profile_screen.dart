import 'dart:convert';

import 'package:crime/account/components/color.dart';
import 'package:crime/service/global.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../../login_register/models/user_modal.dart';
import '../../service/api.dart';
import '../../service/firebase.dart';
import '../../utils/custom_widgets.dart';
import '../../utils/theme.dart';
import 'account_screen.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();

  String imageURL =
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT98A0_6JOy9FNLcNjipGe4xSgzGiCTfgLybw&usqp=CAU';
  User user = Global.instance.user!;

  // ignore: prefer_typing_uninitialized_variables
  var uID;

  String mobileNo = "";
  String address = "";
  String zipcode = "";

  File? image;

  String? countryValue;
  String? stateValue;
  String? cityValue;

  bool haveImage = false;

  TextEditingController dateCtl = TextEditingController();

  @override
  initState() {
    super.initState();
    dateCtl.text = user.dob!;
    if (user.avatar! != "") {
      imageURL = user.avatar!;
      haveImage = true;
    }
    mobileNo = user.mobileNo!;
    address = user.address!;
    zipcode = user.zipcode!;
    countryValue = user.country!;
    cityValue = user.city!;
    stateValue = user.state!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        title: "Edit Profile",
      ),
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: getAvatarPicker()),
                    const SizedBox(height: 32),
                    Text('Personal Information',
                        style: AppTheme.titleMedium
                            .copyWith(color: AppTheme.primaryColor)),
                    const SizedBox(height: 16),
                    getTextField(
                      text: user.fName!,
                      isEdit: true,
                      decoration: AppTheme.inputDecoration.copyWith(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline,
                            color: AppTheme.primaryColor),
                      ),
                      readonly: true,
                    ),
                    const SizedBox(height: 16),
                    getTextField(
                      text: user.iNo!,
                      isEdit: true,
                      decoration: AppTheme.inputDecoration.copyWith(
                        labelText: 'Identity No.',
                        prefixIcon: Icon(Icons.badge_outlined,
                            color: AppTheme.primaryColor),
                      ),
                      readonly: true,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppTheme.cardColor,
                      ),
                      child: TextFormField(
                        controller: dateCtl,
                        readOnly: true,
                        style: AppTheme.bodyLarge,
                        decoration: AppTheme.inputDecoration.copyWith(
                          labelText: 'Date of Birth',
                          prefixIcon: Icon(Icons.calendar_today_outlined,
                              color: AppTheme.primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Contact Information',
                        style: AppTheme.titleMedium
                            .copyWith(color: AppTheme.primaryColor)),
                    const SizedBox(height: 16),
                    getTextField(
                      text: user.email!,
                      isEdit: true,
                      decoration: AppTheme.inputDecoration.copyWith(
                        labelText: 'E-mail address',
                        prefixIcon: Icon(Icons.email_outlined,
                            color: AppTheme.primaryColor),
                      ),
                      readonly: true,
                    ),
                    const SizedBox(height: 16),
                    getTextField(
                      text: user.mobileNo!,
                      isEdit: true,
                      decoration: AppTheme.inputDecoration.copyWith(
                        labelText: 'Mobile Number',
                        hintText: 'Enter your mobile number',
                        prefixIcon: Icon(Icons.phone_outlined,
                            color: AppTheme.primaryColor),
                      ),
                      validator: (val) {
                        if (val!.isEmpty) {
                          return "Please enter the mobile number";
                        } else if (!RegExp(r"^(\d+)*$").hasMatch(val)) {
                          return "Enter a valid mobile number";
                        }
                        return null;
                      },
                      onChanged: (value) {
                        mobileNo = value;
                      },
                    ),
                    const SizedBox(height: 24),
                    Text('Address Information',
                        style: AppTheme.titleMedium
                            .copyWith(color: AppTheme.primaryColor)),
                    const SizedBox(height: 16),
                    getTextField(
                      text: user.address!,
                      isEdit: true,
                      decoration: AppTheme.inputDecoration.copyWith(
                        labelText: 'Address',
                        hintText: 'Enter your house/unit no, and street',
                        prefixIcon: Icon(Icons.home_outlined,
                            color: AppTheme.primaryColor),
                      ),
                      onChanged: (value) {
                        address = value;
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppTheme.cardColor,
                      ),
                      child: CSCPicker(
                        dropdownDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppTheme.cardColor,
                          border: Border.all(color: AppTheme.dividerColor),
                        ),
                        dropdownHeadingStyle: AppTheme.bodyLarge,
                        dropdownItemStyle: AppTheme.bodyMedium,
                        selectedItemStyle: AppTheme.bodyLarge
                            .copyWith(color: AppTheme.primaryColor),
                        flagState: CountryFlag.DISABLE,
                        currentCountry: user.country,
                        currentCity: user.city,
                        currentState: user.state,
                        onCountryChanged: (value) {
                          setState(() {
                            countryValue = value;
                          });
                        },
                        onStateChanged: (value) {
                          setState(() {
                            stateValue = value;
                          });
                        },
                        onCityChanged: (value) {
                          setState(() {
                            cityValue = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    getTextField(
                      text: user.zipcode!,
                      isEdit: true,
                      decoration: AppTheme.inputDecoration.copyWith(
                        labelText: 'Zip Code',
                        hintText: 'Enter your zip code',
                        prefixIcon: Icon(Icons.location_on_outlined,
                            color: AppTheme.primaryColor),
                      ),
                      onChanged: (value) {
                        zipcode = value;
                      },
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: AppTheme.primaryButtonStyle,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            "Save Changes",
                            style: AppTheme.titleSmall
                                .copyWith(color: Colors.white),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            uID = Global.instance.user!.uId;
                            print(uID);
                            var iURL = image != null
                                ? await uploadImage(file: image!)
                                : "";

                            DatabaseReference userRef =
                                FirebaseDatabase.instance.ref().child('users');

                            await userRef.child(uID.toString()).update({
                              'fName': user.fName,
                              'iNo': user.iNo,
                              'email': user.email,
                              'dob': user.dob,
                              'phone': mobileNo,
                              'avatar': iURL,
                              'address': address,
                              'country': countryValue,
                              'state': stateValue,
                              'city': cityValue,
                              'zCode': zipcode
                            });

                            final snapshot =
                                await userRef.child(uID.toString()).get();
                            if (snapshot.exists) {
                              Map data = await json
                                  .decode(json.encode(snapshot.value));
                              Global.instance.user!
                                  .setUserInfo(uID.toString(), data);
                              Fluttertoast.showToast(
                                  msg: "Profile Details Updated Successfully");
                              if (image != null) {
                                await editAvatarPostList();
                              }
                            } else {
                              Fluttertoast.showToast(
                                  msg: 'Error Updating user profile');
                            }

                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const AccountScreen()),
                                (Route<dynamic> route) => false);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void pickImage() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
      maxHeight: 500,
      maxWidth: 500,
    );
    if (pickedFile != null) {
      image = File(pickedFile.path);
      setState(() {
        if (kDebugMode) {
          print('The file name is :$image');
        }
      });
    }
  }

  getAvatarPicker() {
    return GestureDetector(
      onTap: () {
        setState(() {
          pickImage();
        });
      },
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 4,
                color: AppTheme.primaryColor.withOpacity(0.2),
              ),
              color: AppTheme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
              image: DecorationImage(
                fit: BoxFit.cover,
                image: image != null
                    ? FileImage(image!)
                    : NetworkImage(imageURL) as ImageProvider,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(
                  width: 2,
                  color: AppTheme.backgroundColor,
                ),
              ),
              child: Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
