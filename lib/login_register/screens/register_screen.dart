import 'dart:io';

import 'package:crime/account/screens/account_screen.dart';
import 'package:crime/home.dart';
import 'package:crime/login_register/components/header_widget.dart';
import 'package:crime/utils/theme.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../service/api.dart';
import '../../service/firebase.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool checkedValue = false;
  bool checkboxValue = false;

  var uID;
  String fName = "";
  String uName = "";
  String iNo = "";
  String pass = "";
  String cPass = "";
  String? dob;
  String email = "";
  String mobileNo = "";
  String address = "";
  String zipcode = "";

  String imageUrl = "";
  File? image;

  String? countryValue;
  String? stateValue;
  String? cityValue;

  DateTime today = DateTime.now();
  DateTime? pickedDate;
  TextEditingController dateCtl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: 150,
              child: HeaderWidget(150),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(25, 50, 25, 10),
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        getAvatarPicker(),
                        SizedBox(
                          height: 30,
                        ),
                        getTextField(
                            text: 'Full Name',
                            hint:
                                'Enter your full name same as in identity card',
                            valError: 'Please enter your full name',
                            onChanged: (value) {
                              setState(() {
                                fName = value;
                              });
                            }),
                        getTextField(
                            text: 'Identity No.',
                            hint: 'Enter your IC or Passport No.',
                            valError: 'Please your IC or Passport No.',
                            onChanged: (value) {
                              setState(() {
                                iNo = value;
                              });
                            }),
                        Container(
                          child: TextFormField(
                            controller: dateCtl,
                            readOnly: true,
                            style: AppTheme.bodyMedium
                                .copyWith(color: AppTheme.textColor),
                            decoration: InputDecoration(
                              labelText: 'Date of Birth',
                              hintText: 'Enter your date of birth',
                              labelStyle: AppTheme.bodyMedium
                                  .copyWith(color: AppTheme.textSecondary),
                              hintStyle: AppTheme.bodyMedium
                                  .copyWith(color: AppTheme.textLightColor),
                              fillColor: AppTheme.cardColor,
                              filled: true,
                              contentPadding:
                                  EdgeInsets.fromLTRB(20, 10, 20, 10),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide:
                                    BorderSide(color: AppTheme.primaryColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide:
                                    BorderSide(color: AppTheme.dividerColor),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(color: AppTheme.error),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(color: AppTheme.error),
                              ),
                            ),
                            onTap: () async {
                              pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1950),
                                lastDate: DateTime.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.dark(
                                        primary: AppTheme.primaryColor,
                                        onPrimary: Colors.white,
                                        surface: AppTheme.cardColor,
                                        onSurface: AppTheme.textColor,
                                      ),
                                      dialogBackgroundColor:
                                          AppTheme.surfaceColor,
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (pickedDate != null) {
                                String formattedDate = DateFormat('yyyy-MM-dd')
                                    .format(pickedDate!);
                                dateCtl.text = formattedDate;
                                dob = formattedDate;
                              }
                            },
                            validator: (val) {
                              final eighteenY = DateTime(
                                  today.year - 18, today.month, today.day);
                              if (val!.isEmpty) {
                                return "Please select birth date";
                              } else if (pickedDate!.compareTo(eighteenY) > 0) {
                                return "Only 18 years old or above can register";
                              }
                              return null;
                            },
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.0),
                        getTextField(
                            text: 'Password',
                            hint: 'Enter your password',
                            obscureText: true,
                            valError: 'Please enter your password',
                            validator: (val) {
                              if (val!.isEmpty) {
                                return "Please enter the password";
                              } else if (val.length <= 5) {
                                return "Password should be 6 characters or more";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                pass = value;
                              });
                            }),
                        getTextField(
                            text: 'Confirm Password',
                            hint: 'Enter your confirm password',
                            obscureText: true,
                            validator: (val) {
                              if (val!.isEmpty) {
                                return "Please enter the confirm password";
                              } else if (pass != val) {
                                return "Password and Confirm Password should be same";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                cPass = value;
                              });
                            }),
                        getTextField(
                            text: 'E-mail address',
                            hint: 'Enter your email',
                            valError: 'Please enter your email',
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'Please enter your email';
                              } else if (!(val.isEmpty) &&
                                  !RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                                      .hasMatch(val)) {
                                return "Enter a valid email";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                email = value;
                              });
                            }),
                        getTextField(
                          text: 'Mobile Number',
                          hint: 'Enter your mobile number',
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Please enter the mobile number";
                            } else if (!(val.isEmpty) &&
                                !RegExp(r"^(\d+)*$").hasMatch(val)) {
                              return "Enter a valid mobile number";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              mobileNo = value;
                            });
                          },
                        ),
                        getTextField(
                          text: 'Address',
                          hint: 'Enter your house/unit no, and street',
                          valError: 'Please enter your address',
                          onChanged: (value) {
                            setState(() {
                              address = value;
                            });
                          },
                        ),
                        getCSCPicker(),
                        SizedBox(height: 20.0),
                        getTextField(
                          text: 'Zip Code',
                          hint: 'Enter your zip code',
                          valError: 'Please enter your zip code',
                          onChanged: (value) {
                            setState(() {
                              zipcode = value;
                            });
                          },
                        ),
                        getTermCheckBox(),
                        getRegisterButton(),
                        redirectToLogin()
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
    PickedFile? pickedFile = (await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxHeight: 500,
        maxWidth: 500)) as PickedFile?;
    if (pickedFile != null) {
      image = File(pickedFile.path);
      setState(() {
        print('The file name is :$image');
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
                border: Border.all(width: 5, color: Colors.white),
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
                        : const NetworkImage(
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT98A0_6JOy9FNLcNjipGe4xSgzGiCTfgLybw&usqp=CAU')
                            as ImageProvider)),
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

  getTextField(
      {String? text,
      String? hint,
      String? valError,
      Function(String)? onChanged,
      bool? obscureText,
      String? Function(String?)? validator}) {
    return Container(
      padding: EdgeInsets.only(bottom: 20),
      child: TextFormField(
        obscureText: obscureText ?? false,
        style: AppTheme.bodyMedium.copyWith(color: AppTheme.textColor),
        decoration: InputDecoration(
          labelText: text,
          hintText: hint,
          labelStyle:
              AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          hintStyle:
              AppTheme.bodyMedium.copyWith(color: AppTheme.textLightColor),
          fillColor: AppTheme.cardColor,
          filled: true,
          contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: AppTheme.primaryColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: AppTheme.dividerColor),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: AppTheme.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: AppTheme.error),
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
    );
  }

  getCSCPicker() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          CSCPicker(
            dropdownDecoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: AppTheme.cardColor,
              border: Border.all(color: AppTheme.dividerColor, width: 1),
            ),
            disabledDropdownDecoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: AppTheme.cardColor.withOpacity(0.5),
              border: Border.all(color: AppTheme.dividerColor, width: 1),
            ),
            selectedItemStyle:
                AppTheme.bodyMedium.copyWith(color: AppTheme.textColor),
            dropdownItemStyle:
                AppTheme.bodyMedium.copyWith(color: AppTheme.textColor),
            dropdownHeadingStyle:
                AppTheme.bodyMedium.copyWith(color: AppTheme.textColor),
            flagState: CountryFlag.DISABLE,
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
      ),
    );
  }

  getTermCheckBox() {
    return FormField<bool>(
      builder: (state) {
        return Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Checkbox(
                  value: checkboxValue,
                  onChanged: (value) {
                    setState(() {
                      checkboxValue = value!;
                      state.didChange(value);
                    });
                  },
                  activeColor: AppTheme.primaryColor,
                  checkColor: Colors.white,
                  fillColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return AppTheme.primaryColor;
                    }
                    return AppTheme.dividerColor;
                  }),
                ),
                Expanded(
                  child: Text(
                    "I agree to the Terms and Conditions and Privacy Policy.",
                    style: AppTheme.bodyMedium
                        .copyWith(color: AppTheme.textSecondary),
                  ),
                ),
              ],
            ),
            if (state.errorText != null)
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  state.errorText!,
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.error),
                ),
              )
          ],
        );
      },
      validator: (value) {
        if (!checkboxValue) {
          return 'You need to accept terms and conditions';
        }
        return null;
      },
    );
  }

  getRegisterButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          "Register".toUpperCase(),
          style: AppTheme.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            bool isDuplicate = await checkUserExist(iNo);
            if (!isDuplicate) {
              registerUser();
            } else {
              Fluttertoast.showToast(
                  msg: "The account already exists for that Identity No.");
            }
          }
        },
      ),
    );
  }

  registerUser() async {
    //create user account
    uID = await createAccount(email, pass, iNo);
    //check if avatar uploaded
    imageUrl = image != null ? await uploadImage(file: image!) : "";
    //check if user account created
    if (uID != false) {
      //get user child reference
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref().child('users');
      //push information under user/userID
      userRef.child(uID.toString()).set({
        'fName': fName,
        'iNo': iNo,
        'email': email,
        'dob': dob,
        'phone': mobileNo,
        'avatar': imageUrl,
        'address': address,
        'country': countryValue,
        'state': stateValue,
        'city': cityValue,
        'zCode': zipcode
      });

      Fluttertoast.showToast(msg: "Account Created Successfully");
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false);
    }
  }

  redirectToLogin() {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
      child: Text.rich(TextSpan(
        children: [
          TextSpan(
            text: "Already have an account? ",
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
          TextSpan(
            text: 'Sign In',
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              },
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      )),
    );
  }
}
