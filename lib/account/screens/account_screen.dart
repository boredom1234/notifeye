import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:crime/account/components/color.dart';
import 'package:crime/account/components/sos_setting_popup.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import '../../service/firebase.dart';
import '../../service/global.dart';
import '../../utils/bottom_navigation.dart';
import '../../utils/custom_widgets.dart';
import '../../utils/theme.dart';
import '../components/add_contact_popup.dart';
import '../components/notification.dart';
import '../components/send_email.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool isSwitched = false;
  String? url;

  var val;

  @override
  void initState() {
    super.initState();
    if (Global.instance.user!.isLoggedIn) {
      url = Global.instance.user!.avatar!;
    }
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: (ReceivedAction receivedAction) {
      NotificationController.onActionReceivedMethod(receivedAction);
      return val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Global.instance.user!.isLoggedIn
          ? customAppBarAction(
              title: "        Account",
              actions: IconButton(
                  onPressed: () {
                    signOut();
                    setState(() {
                      Navigator.of(context).pushReplacementNamed("/home");
                    });
                  },
                  icon:
                      Icon(Icons.logout, color: Colors.red.shade900, size: 30)))
          : customAppBar(
              title: "",
            ),
      body: Global.instance.user!.isLoggedIn
          ? Container(
              color: HexColor("#e1d8f2"),
              child: ListView(
                children: [
                  //profile
                  Container(
                    padding: const EdgeInsets.only(
                        top: 20, right: 10, left: 10, bottom: 10),
                    // Set color: 909CC2,
                    color: HexColor("#E8E2F3"),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        getAvatar(),
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0, left: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Global.instance.user!.fName!,
                                style: const TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, '/editProfile');
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        "Edit Profile",
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: HexColor("#031E3A")),
                                      ),
                                      const Icon(
                                        Icons.chevron_right,
                                        color: secondaryColor,
                                        size: 25,
                                      )
                                    ],
                                  ))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  //general
                  Container(
                    padding:
                        const EdgeInsets.only(top: 15, right: 10, left: 10),
                    color: HexColor("#E8E2F3"),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        getHeaderText("General"),
                        // getTextButton(
                        //     text: "Help Center",
                        //     onTap: () {
                        //       Navigator.of(context).pushNamed('/helpCenter');
                        //     }),
                        getTextButton(
                            text: "My Post",
                            onTap: () {
                              Navigator.of(context).pushNamed('/myPost');
                            }),
                        getTextButton(
                            text: "Send Feedback",
                            onTap: () {
                              getSendFeedbackPopUp();
                            }),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  //SOS setting
                  Container(
                    padding:
                        const EdgeInsets.only(top: 15, right: 10, left: 10),
                    color: HexColor("#E8E2F3"),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        getHeaderText("SOS Message"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            getTextButton(
                                text: "Enable SOS Menu Bar", onTap: () {}),
                            Switch(
                              onChanged: (value) {
                                //createPlantFoodNotification();
                                setState(() {
                                  if (isSwitched) {
                                    NotificationController
                                        .dismissNotification();
                                    isSwitched = false;
                                  } else {
                                    NotificationController
                                        .createSOSNotification();
                                    isSwitched = true;
                                  }
                                });
                              },
                              value: isSwitched,
                              activeColor: Colors.grey.shade100,
                              activeTrackColor: Colors.green.shade700,
                              inactiveThumbColor: Colors.white,
                              inactiveTrackColor: Colors.grey,
                            )
                          ],
                        ),
                        getTextButton(
                            text: "Edit SOS Message Content",
                            onTap: () {
                              Navigator.of(context).pushNamed('/editSOS');
                            }),
                        getTextButton(
                            text: "Additional SOS Settings",
                            onTap: () {
                              getSosSettingFormPopUp();
                            }),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  //Emergency Setting
                  Container(
                    padding:
                        const EdgeInsets.only(top: 15, right: 10, left: 10),
                    color: HexColor("#E8E2F3"),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        getHeaderText("Emergency Contacts"),
                        getTextButton(
                            text: "Add Emergency Contacts",
                            onTap: () {
                              getContactFormPopUp();
                            }),
                        getTextButton(
                            text: "Manage Emergency Contacts",
                            onTap: () {
                              Navigator.pushNamed(context, '/manageContact');
                            }),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Please Log In or Register to Continue!",
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Container(
                    child: getCustomButton(
                        text: "Sign In",
                        padding: 115,
                        background: Colors.black,
                        fontSize: 20,
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        }),
                  ),
                  Container(
                    child: getCustomButton(
                        text: "Register",
                        padding: 110,
                        background: Colors.red.shade900,
                        fontSize: 20,
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        }),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        defaultSelectedIndex: 4,
      ),
    );
  }

  getHeaderText(String text) {
    return Text(text,
        style: TextStyle(
            color: Colors.red.shade900,
            fontSize: 25,
            fontWeight: FontWeight.bold));
  }

  getTextButton({String? text, Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(top: 15, bottom: 15),
        child: Text(
          text!,
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  getAvatar() {
    return url != ""
        ? Container(
            height: 85.0,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: NetworkImage(url!),
                fit: BoxFit.cover,
              ), // border color
              borderRadius: const BorderRadius.all(Radius.circular(50.0)),
              border: Border.all(
                color: HexColor("#031E3A"),
                width: 1.0,
              ),
            ),
            child: Container())
        : Container(
            height: 85.0,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.white, // border color
              borderRadius: const BorderRadius.all(Radius.circular(50.0)),
              border: Border.all(
                color: Colors.black,
                width: 3.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: Icon(
                Icons.person,
                color: Colors.red.shade900,
                size: 78.0,
              ),
            ));
  }

  getSendFeedbackPopUp() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return SendEmail(title: "Feedback");
        });
  }

  getContactFormPopUp() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AddEmergencyContact(
            mapEdit: null,
            onEdit: (value) {},
          );
        });
  }

  getSosSettingFormPopUp() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return const SosSettingsPopUp();
        });
  }
}
