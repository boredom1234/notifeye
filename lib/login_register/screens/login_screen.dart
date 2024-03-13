import 'package:crime/login_register/components/header_widget.dart';
import 'package:crime/utils/theme.dart';
import 'package:crime/login_register/screens/register_screen.dart';
import 'package:crime/utils/custom_widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../account/screens/account_screen.dart';
import '../../service/firebase.dart';
import '../../service/global.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  double _headerHeight = 250;
  Key _formKey = GlobalKey<FormState>();

  String email = "";
  String pass = "";
  String? uID;

  Map? userInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: _headerHeight,
              child: HeaderWidget(
                  _headerHeight), //let's create a common header widget
            ),
            SafeArea(
              child: Container(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  // This will be the login form
                  child: Column(
                    children: [
                      Text(
                        'Welcome Back',
                        style: TextStyle(
                            fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Sign In to your account',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 30.0),
                      Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              getTextField(
                                  text: 'E-mail address',
                                  hint: 'Enter your email',
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
                              SizedBox(height: 15.0),
                              getSignInButton(),
                              redirectToRegister()
                            ],
                          )),
                    ],
                  )),
            ),
          ],
        ),
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

  redirectToRegister() {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
      //child: Text('Don\'t have an account? Create'),
      child: Text.rich(TextSpan(children: [
        TextSpan(text: "Don\'t have an account? "),
        TextSpan(
          text: 'Create',
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              Navigator.pushNamed(context, "/register");
            },
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.redAccent.shade700),
        ),
      ])),
    );
  }

  getSignInButton() {
    return Container(
      decoration: ThemeHelper().buttonBoxDecoration(context),
      child: ElevatedButton(
        style: ThemeHelper().buttonStyle(),
        child: Padding(
          padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
          child: Text(
            'Sign In'.toUpperCase(),
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        onPressed: () async {
          var value = await signIn(email, pass);
          //check if user credentials are correct
          if (value != false) {
            //assign userID
            uID = value;
            //get userInfo from database
            userInfo = await getUserData(uID!);
            //assign userID to global User instance
            Global.instance.user!.setUserInfo(uID!, userInfo!);

            Fluttertoast.showToast(msg: "User Logged In Successfully");
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/home', (Route<dynamic> route) => false);
          }
        },
      ),
    );
  }
}
