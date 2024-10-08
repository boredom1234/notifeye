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
      backgroundColor: Colors.white,
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
                            decoration: ThemeHelper().textInputDecoration(
                                'Date of Birth', 'Enter your date of birth'),
                            onTap: () async {
                              pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1950),
                                lastDate: DateTime.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: Colors.red, // <-- SEE HERE
                                        onPrimary: Colors.white, // <-- SEE HERE
                                        onSurface:
                                            Colors.grey[900]!, // <-- SEE HERE
                                      ),
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor:
                                              Colors.red, // button text color
                                        ),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              String formattedDate =
                                  DateFormat('yyyy-MM-dd').format(pickedDate!);
                              dateCtl.text = formattedDate;
                              dob = formattedDate;
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
                          decoration: ThemeHelper().inputBoxDecorationShaddow(),
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
        decoration: ThemeHelper().textInputDecoration(text!, hint!),
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

  getCSCPicker() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            CSCPicker(
              dropdownDecoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade400, width: 1)),
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
        ));
  }

  getTermCheckBox() {
    return FormField<bool>(
      builder: (state) {
        return Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Checkbox(
                    activeColor: Colors.red.shade900,
                    value: checkboxValue,
                    onChanged: (value) {
                      setState(() {
                        checkboxValue = value!;
                        state.didChange(value);
                      });
                    }),
                Text(
                  "I agree to the Terms and Conditions "
                  "\nand Privacy Policy.",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                state.errorText ?? '',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Theme.of(context).errorColor,
                  fontSize: 12,
                ),
              ),
            )
          ],
        );
      },
      validator: (value) {
        if (!checkboxValue) {
          return 'You need to accept terms and conditions';
        } else {
          return null;
        }
      },
    );
  }

  getRegisterButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        decoration: ThemeHelper().buttonBoxDecoration(context),
        child: ElevatedButton(
          style: ThemeHelper().buttonStyle(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
            child: Text(
              "Register".toUpperCase(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
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
      child: Text.rich(TextSpan(children: [
        TextSpan(text: "Already have an account? "),
        TextSpan(
          text: 'Sign In',
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginScreen()));
            },
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.redAccent.shade700),
        ),
      ])),
    );
  }
}
