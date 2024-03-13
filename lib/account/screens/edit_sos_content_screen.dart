import 'dart:convert';

import 'package:crime/service/global.dart';
import 'package:crime/utils/custom_widgets.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../login_register/models/user_modal.dart';
import '../../service/firebase.dart';
import '../../utils/theme.dart';
import '../components/add_edit_info_popUp.dart';
import '../models/info_model.dart';
import 'account_screen.dart';

class EditSOSContent extends StatefulWidget {
  const EditSOSContent({Key? key}) : super(key: key);

  @override
  State<EditSOSContent> createState() => _EditSOSContentState();
}

class _EditSOSContentState extends State<EditSOSContent> {
  final _formKey = GlobalKey<FormState>();

  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('sos');

  List<Info> infoList = [];
  bool haveInfo = false;

  String? sample;

  String? location;

  User user = Global.instance.user!;

  String message = "SOS! Immediate Help required:";

  String addtionalInfo = "";

  getInfo() async {
    var data = await getSOSData(user.uId!);

    if (data != null) {
      data["info"].forEach((dt) {
        Map info = dt;
        infoList.add(Info(info.keys.first, info.values.first));
      });
      setState(() {
        haveInfo = true;
      });
    }
  }

  getMessage() async {
    location = await getLocation();
    setState(() {
      message += "\nName: ${user.fName!} \n$location";
    });
  }

  getLocation() async {
    final position = await _determinePosition();
    return "Longitude: ${position.longitude} and Latitude: ${position.latitude}";
  }

  @override
  void initState() {
    getMessage();
    getInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: customAppBar(title: "Edit SOS Content"),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(25, 50, 25, 10),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          getTextField(
                            text: message!,
                            label: 'Message',
                            readonly: true,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              color: Colors.grey.shade200,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Add Addtional Content",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            getPopUp();
                                          },
                                          icon: Icon(
                                            Icons.add_circle,
                                            size: 30,
                                            color: Colors.red.shade900,
                                          ))
                                    ],
                                  ),
                                  getAddedList()
                                ],
                              ),
                            ),
                          ),
                          showSampleMessage(),
                          getSubmitButton(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  getSubmitButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
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
              DatabaseReference sosRef = dbRef.child(user.uId!);

              await sosRef.child('info').remove();

              for (int i = 0; i < infoList.length; i++) {
                sosRef
                    .child('info')
                    .child("$i")
                    .set({'${infoList[i].type}': '${infoList[i].description}'});
              }

              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => AccountScreen()),
                  (Route<dynamic> route) => false);
            }
          },
        ),
      ),
    );
  }

  getPopUp() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AddEditInfoPopUP(
            onAdd: (value) {
              setState(() {
                infoList.add(value);
                print(infoList);
                haveInfo = true;
                addtionalInfo += "\n${value.type!}: "
                    "\n${value.description},";
              });
            },
          );
        });
  }

  getAddedList() {
    return Visibility(
      visible: haveInfo,
      child: Container(
        padding: EdgeInsets.only(bottom: 10),
        child: Container(
          height: 150,
          color: Colors.white,
          child: ListView.builder(
              itemCount: infoList.length,
              itemBuilder: (BuildContext context, int index) {
                addtionalInfo = "";
                infoList.forEach((i) {
                  addtionalInfo += "\n${i.type!}: "
                      "\n${i.description!},";
                });
                return Card(
                  child: ListTile(
                      title: Text(infoList[index].type!),
                      subtitle: Text(infoList[index].description!),
                      trailing: IconButton(
                        icon: const Icon(Icons.cancel_outlined),
                        onPressed: () {
                          setState(() {
                            infoList.removeAt(index);

                            infoList =
                                infoList.where((i) => i != null).toList();

                            addtionalInfo = "";
                            infoList.forEach((i) {
                              addtionalInfo += "\n${i.type!}: "
                                  "\n${i.description!},";
                            });
                          });
                        },
                      )),
                );
              }),
        ),
      ),
    );
  }

  showSampleMessage() {
    sample = message + addtionalInfo;
    return Container(
      color: Colors.grey.shade200,
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Text(
              "Sample Message",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              color: Colors.white,
              child: Text(sample!)),
        ],
      ),
    );
  }

  getTextField({
    String? text,
    String? label,
    bool? readonly,
  }) {
    TextEditingController controller = TextEditingController();
    controller.text = text!;
    return Container(
      padding: EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        minLines: 4,
        maxLines: 6,
        readOnly: readonly ?? false,
        decoration: ThemeHelper().textInputDecoration(label!),
      ),
      decoration: ThemeHelper().inputBoxDecorationShaddow(),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    return position;
  }
}
