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
      backgroundColor: secondaryColor,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(25, 50, 25, 10),
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        getAvatarPicker(),
                        const SizedBox(
                          height: 30,
                        ),
                        getTextField(
                          text: user.fName!,
                          isEdit: true,
                          decoration: ThemeHelper()
                              .textInputDecoration('Full Name', ' '),
                          readonly: true,
                        ),
                        getTextField(
                          text: user.iNo!,
                          isEdit: true,
                          decoration: ThemeHelper()
                              .textInputDecoration('Identity No.', ' '),
                          readonly: true,
                        ),
                        Container(
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
                          child: TextFormField(
                            controller: dateCtl,
                            readOnly: true,
                            decoration: ThemeHelper()
                                .textInputDecoration('Date of Birth', ' '),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        getTextField(
                          text: user.email!,
                          isEdit: true,
                          decoration: ThemeHelper()
                              .textInputDecoration('E-mail address', ''),
                          valError: 'Please enter your email',
                          readonly: true,
                        ),
                        getTextField(
                          text: user.mobileNo!,
                          isEdit: true,
                          decoration: ThemeHelper().textInputDecoration(
                              'Mobile Number', 'Enter your mobile number'),
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Please enter the mobile number";
                              // ignore: prefer_is_not_empty
                            } else if (!(val.isEmpty) &&
                                !RegExp(r"^(\d+)*$").hasMatch(val)) {
                              return "Enter a valid mobile number";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            mobileNo = value;
                          },
                        ),
                        getTextField(
                          text: user.address!,
                          isEdit: true,
                          decoration: ThemeHelper().textInputDecoration(
                              'Address',
                              'Enter your house/unit no, and street'),
                          valError: 'Please enter your address',
                          onChanged: (value) {
                            address = value;
                          },
                        ),
                        getCSCPicker(),
                        const SizedBox(height: 20.0),
                        getTextField(
                          text: user.zipcode!,
                          isEdit: true,
                          decoration: ThemeHelper().textInputDecoration(
                              'Zip Code', 'Enter your zip code'),
                          valError: 'Please enter your zip code',
                          onChanged: (value) {
                            zipcode = value;
                          },
                        ),
                        getSubmitButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(width: 5, color: Colors.black),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20,
                  offset: Offset(5, 5),
                ),
              ],
              image: DecorationImage(
                image: image != null
                    ? FileImage(image!)
                    : NetworkImage(imageURL) as ImageProvider,
              ),
            ),
            child: Icon(
              Icons.person,
              color: Colors.grey.withOpacity(0.02),
              size: 80.0,
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(80, 80, 0, 0),
            child: Icon(
              Icons.add_circle,
              color: Colors.grey.shade700,
              size: 25.0,
            ),
          ),
        ],
      ),
    );
  }

  getCSCPicker() {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            CSCPicker(
              dropdownDecoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade400, width: 1)),
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
          ],
        ));
  }

  getSubmitButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        decoration: ThemeHelper().buttonBoxDecoration(context),
        child: ElevatedButton(
          style: ThemeHelper().buttonStyle(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
            child: Text(
              "Submit".toUpperCase(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              uID = Global.instance.user!.uId;
              print(uID);
              var iURL = image != null ? await uploadImage(file: image!) : "";

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

              //get user data snapshot
              final snapshot = await userRef.child(uID.toString()).get();
              if (snapshot.exists) {
                Map data = await json.decode(json.encode(snapshot.value));
                //set new data to Global User instance
                Global.instance.user!.setUserInfo(uID.toString(), data);
                Fluttertoast.showToast(
                    msg: "Profile Details Updated Successfully");
                if (image != null) {
                  //edit user profile in posts data
                  await editAvatarPostList();
                }
                ;
              } else {
                Fluttertoast.showToast(msg: 'Error Updating user profile');
              }

              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const AccountScreen()),
                  (Route<dynamic> route) => false);
            }
          },
        ),
      ),
    );
  }
}
