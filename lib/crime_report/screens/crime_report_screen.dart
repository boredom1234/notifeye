import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:crime/crime_report/models/person_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:crime/crime_alert/screens/crime_alert_screen.dart';
import 'package:intl/intl.dart';
import 'package:emailjs/emailjs.dart';

import '../../utils/theme.dart';
import '../../service/api.dart';
import '../../service/global.dart';
import '../../utils/bottom_navigation.dart';
import '../../utils/custom_widgets.dart';
import 'package:google_maps_webservice/places.dart';

import '../components/popup_form.dart';
import '../models/crime_list.dart';
import 'package:http/http.dart' as http;

class CrimeReportScreen extends StatefulWidget {
  const CrimeReportScreen({Key? key}) : super(key: key);

  @override
  State<CrimeReportScreen> createState() => _CrimeReportScreenState();
}

const kGoogleApiKey = 'AIzaSyACR85dcvtoBdJ4i9xsIIs2QDNDfVWduIU';

class _CrimeReportScreenState extends State<CrimeReportScreen> {
  final _formKey = GlobalKey<FormState>();
  bool checkedValue = false;
  bool checkboxValue = false;

  bool haveFile = false;
  bool havePerson = false;

  String evidence_list = "";
  String add_details = "";

  String? formattedDate;

  String? type;
  final Mode _mode = Mode.overlay;

  String? location;
  double? lng;
  double? lat;

  String? description;

  DateTime? pickedDate;
  TextEditingController dateCtl = TextEditingController();

  TimeOfDay? pickedTime;
  TextEditingController timeCtl = TextEditingController();

  String? reporterType;

  List selectedFiles = [];

  List<Person> personas = [];

  void selectFiles() async {
    final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'pdf', 'mp3', 'mp4', 'jpeg'],
        allowMultiple: true);
    if (result == null) return;

    selectedFiles = result.files;

    setState(() {
      haveFile = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(title: 'Crime Report'),
      body: Global.instance.user!.isLoggedIn
          ? ListView(children: [
              SafeArea(
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        getLocationField(),
                        getDateTimeFields(),
                        selectCrimeTypeField(),
                        getCrimeDescField(),
                        getCustomButton(
                            text: "       Add Evidence Media / Files",
                            background: Colors.white,
                            fontSize: 15,
                            padding: 45,
                            icon: const Icon(Icons.camera_alt),
                            onPressed: () {
                              selectFiles();
                            }),
                        getShowSelectedImages(),
                        getRadioButton(),
                        Container(
                          child: getCustomButton(
                              text:
                                  "          Additional Other Witness Details",
                              background: Colors.white,
                              padding: 10,
                              fontSize: 15,
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                getPopUp();
                              }),
                        ),
                        getAddedList(),
                        getTermCheckBox(),
                        getSubmitCancelButtonBar()
                      ],
                    ),
                  ),
                ),
              ),
            ])
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
      bottomNavigationBar: CustomBottomNavigationBar(
        defaultSelectedIndex: 1,
      ),
    );
  }

  getPopUp() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return PopUpForm(
            onAdd: (value) {
              setState(() {
                personas.add(value);
                print(personas);
                havePerson = true;
              });
            },
          );
        });
  }

  getAddedList() {
    return Visibility(
      visible: havePerson,
      child: Container(
        padding: EdgeInsets.only(bottom: 10),
        child: Container(
          height: 150,
          color: Colors.white,
          child: ListView.builder(
              itemCount: personas.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: ListTile(
                      title: Text(personas[index].type!),
                      subtitle: Text(personas[index].description!),
                      trailing: IconButton(
                        icon: Icon(Icons.cancel_outlined),
                        onPressed: () {
                          setState(() {
                            personas.removeAt(index);
                          });
                        },
                      )),
                );
              }),
        ),
      ),
    );
  }

  getLocationField() {
    return Container(
        padding: EdgeInsets.only(bottom: 10),
        child: OutlinedButton(
          onPressed: _handlePressButton,
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.grey.shade900))),
            backgroundColor: MaterialStateProperty.all(Colors.white),
            padding: MaterialStateProperty.all(EdgeInsets.all(15)),
          ),
          child: GestureDetector(
            onTap: () {
              CrimeAlertsScreen.getCurrentLocation();
            },
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: Colors.red.shade900,
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  width: 250,
                  height: 18,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Text(
                        location ?? "Enter the Location of the Incident",
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
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
        components: [
          Component(Component.country, "in"),
        ]);
    displayPrediction(p!);
    setState(() {
      location = p!.terms[0].value + " " + p!.terms[1].value;
    });
  }

  Future<void> displayPrediction(Prediction p) async {
    GoogleMapsPlaces places = GoogleMapsPlaces(
        apiKey: kGoogleApiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders());

    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);

    lat = detail.result.geometry!.location.lat;
    lng = detail.result.geometry!.location.lng;
  }

  getDateTimeFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 10),
          width: 175,
          decoration: ThemeHelper().inputBoxDecorationShaddow(),
          child: TextFormField(
            controller: dateCtl,
            readOnly: true,
            decoration: ThemeHelper().textInputDecoReport('Select Date',
                Icon(Icons.calendar_today, color: Colors.red.shade900)),
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
                        onSurface: Colors.grey[900]!, // <-- SEE HERE
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red, // button text color
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate!);
              dateCtl.text = formattedDate!;
            },
            validator: (val) {
              if (val!.isEmpty) {
                return "Please select a date";
              }
              return null;
            },
          ),
        ),
        Container(
          width: 155,
          padding: EdgeInsets.only(bottom: 10),
          child: TextFormField(
            controller: timeCtl,
            readOnly: true,
            decoration: ThemeHelper().textInputDecoReport(
                'Select Time',
                Icon(
                  Icons.watch_later_outlined,
                  color: Colors.red.shade900,
                )),
            onTap: () async {
              pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Colors.red, // <-- SEE HERE
                        onPrimary: Colors.white, // <-- SEE HERE
                        onSurface: Colors.grey[900]!, // <-- SEE HERE
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red, // button text color
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              //String formattedDate = DateFormat('HH:mm:ss').format(pickedDate!);
              timeCtl.text = formatTimeOfDay(pickedTime!);
            },
            validator: (val) {
              if (val!.isEmpty) {
                return "Please enter a time";
              }
              return null;
            },
          ),
          decoration: ThemeHelper().inputBoxDecorationShaddow(),
        ),
      ],
    );
  }

  selectCrimeTypeField() {
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      child: Container(
          width: 400,
          padding: EdgeInsets.only(left: 20, right: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              isExpanded: true,
              hint: Text("Select Type of Crime"),
              items: crimes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              validator: (value) {
                if (type == null) {
                  return "Please select the type of Crime";
                }
                return null;
              },
              onChanged: (value) {
                type = value.toString();
              },
            ),
          )),
    );
  }

  getCrimeDescField() {
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      child: TextFormField(
        minLines: 3,
        maxLines: 5,
        keyboardType: TextInputType.multiline,
        decoration: ThemeHelper()
            .textInputDecoReport("Enter the description of the incident"),
        onChanged: (val) {
          setState(() {
            description = val;
          });
        },
        validator: (val) {
          if (val!.isEmpty) {
            return "Description of the incident is required";
          }
          return null;
        },
      ),
      decoration: ThemeHelper().inputBoxDecorationShaddow(),
    );
  }

  getShowSelectedImages() {
    return Visibility(
      visible: haveFile,
      child: Container(
        padding: EdgeInsets.only(bottom: 10),
        child: Container(
            height: 150,
            color: Colors.white,
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                    itemCount: selectedFiles.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3),
                    itemBuilder: (BuildContext context, int index) {
                      final extension =
                          selectedFiles[index].extension ?? 'none';
                      return Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.grey.shade500,
                                borderRadius: BorderRadius.circular(8)),
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            child: Text(
                              '.$extension',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          ),
                          Text(selectedFiles[index].name)
                        ],
                      );
                    }))),
      ),
    );
  }

  getRadioButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "Please Select, I am the ",
          style: TextStyle(fontSize: 16),
        ),
        RadioListTile(
          visualDensity: VisualDensity(horizontal: 0, vertical: -4),
          contentPadding: EdgeInsets.symmetric(vertical: 0.0),
          activeColor: Colors.red.shade900,
          title: Text("Victim"),
          value: "Victim",
          groupValue: reporterType,
          onChanged: (value) {
            setState(() {
              reporterType = value.toString();
            });
          },
        ),
        RadioListTile(
          visualDensity: VisualDensity(horizontal: 0, vertical: -4),
          contentPadding: EdgeInsets.symmetric(vertical: 0.0),
          activeColor: Colors.red.shade900,
          title: Text("Witness"),
          value: "Witness",
          groupValue: reporterType,
          onChanged: (value) {
            setState(() {
              reporterType = value.toString();
            });
          },
        ),
        RadioListTile(
          visualDensity: VisualDensity(horizontal: 0, vertical: -4),
          contentPadding: EdgeInsets.symmetric(vertical: 0.0),
          activeColor: Colors.red.shade900,
          title: Text("Anonymous"),
          value: "Anonymous",
          groupValue: reporterType,
          onChanged: (value) {
            setState(() {
              reporterType = value.toString();
            });
          },
        )
      ],
    );
  }

  getTermCheckBox() {
    return FormField<bool>(
      builder: (state) {
        return Padding(
          padding: const EdgeInsets.only(top: 10.0, bottom: 10),
          child: Column(
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
                  RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        const TextSpan(
                            text: "By submitting this form I acknowledge the"
                                "\ninformation entered is true events and I have"
                                "\nread and agree to the",
                            style: TextStyle(color: Colors.grey)),
                        TextSpan(
                            text: ' Terms and Conditions.',
                            style: TextStyle(
                                color: Colors.red.shade900,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
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
          ),
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

  getSubmitCancelButtonBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        getCustomButton(
            text: "Cancel",
            padding: 45,
            background: Colors.black,
            fontSize: 16,
            onPressed: () {
              Navigator.pushNamed(context, '/crimeReport');
            }),
        getCustomButton(
            text: "Submit",
            padding: 45,
            background: Colors.red.shade900,
            fontSize: 16,
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                String uID = Global.instance.user!.uId!;

                DatabaseReference reportRef =
                    FirebaseDatabase.instance.ref().child('reports');

                String reportID = reportRef.push().key!;

                //upload new report data to database
                reportRef.child(reportID).set({
                  'location': location,
                  'longitude': lng!.toStringAsFixed(6),
                  'userID': uID,
                  'latitude': lat!.toStringAsFixed(6),
                  'date': formattedDate,
                  'time': formatTimeOfDay(pickedTime!),
                  'type': type,
                  'descr': description,
                  'persona': reporterType,
                });

                //add persona list if have any in the report
                if (personas.isNotEmpty) {
                  add_details =
                      "The following are additional details of people involved:";
                  DatabaseReference addRef =
                      reportRef.child(reportID).child('addDetails');
                  int index = 1;
                  for (var per in personas) {
                    addRef
                        .child('detailNo $index')
                        .set({'persona': per.type, 'desc': per.description});
                    add_details += "\n$index Person Involved: ${per.type}"
                        "\n Person Description: ${per.description}";
                    index++;
                  }
                }

                //add media files list if have any in the report
                if (selectedFiles.isNotEmpty) {
                  evidence_list =
                      "The following are links to evidence media attached:";
                  DatabaseReference mediaRef =
                      reportRef.child(reportID).child('media');
                  var url;
                  int index = 1;
                  selectedFiles.forEach((file) async {
                    url = await uploadFile(file: file!);
                    mediaRef.child(index.toString()).set({'file': url});
                    evidence_list += "\n$index File link: $url";
                    index++;
                  });
                }

                //send email to official services and auto-reply to user
                sendEmail(reportID).whenComplete(() {
                  Fluttertoast.showToast(
                      msg:
                          "Report Submitted and Emailed to Respected Officials Successfully");
                  Navigator.pushReplacementNamed(context, '/crimeReport');
                });
              }
            })
      ],
    );
  }

  Future<void> sendEmail(String id) async {
    // final user = Global.instance.user!;
    // const serviceId = 'service_3wtntnq';
    // const templateId = 'template_e4h860o';
    // const userId = 'ogi9Qqhh-2V13gpmU';

    // final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    // try {
    //   final response = await http.post(
    //     url,
    //     headers: {
    //       'Content-Type': 'application/json',
    //     },
    //     body: json.encode({
    //       'service_id': serviceId,
    //       'template_id': templateId,
    //       'user_id': userId,
    //       'template_params': {
    //         'subject': '$id - $type Case at $formattedDate',
    //         'user_contact': user.mobileNo,
    //         'user_name': user.fName,
    //         'user_email': user.email,
    //         'address': '${user.address}, ${user.zipcode}, ${user.city}, '
    //             '${user.state}, ${user.country}',
    //         'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
    //         'crime': type,
    //         'persona': reporterType,
    //         'in_date': formattedDate,
    //         'in_time': formatTimeOfDay(pickedTime!),
    //         'in_location': location,
    //         'description': description,
    //         'evidence_list': evidence_list,
    //         'add_details': add_details,
    //       }
    //     }),
    //   );

    //   if (kDebugMode) {
    //     print(response.body);
    //   }
    // } catch (error) {
    //   if (kDebugMode) {
    //     print('Error sending email: $error');
    //   }
    //   // Handle error as needed
    // }

    Map<String, dynamic> templateParams = {
      'name': 'James',
      'notes': 'Check this out!'
    };

    try {
      await EmailJS.send(
        'service_3wtntnq',
        'template_e4h860o',
        templateParams,
        const Options(
          publicKey: 'ogi9Qqhh-2V13gpmU',
          privateKey: 'a1kmQhJhgv5P5LNbljlCH',
        ),
      );
      if (kDebugMode) {
        print('SUCCESS!');
      }
    } catch (error) {
      if (kDebugMode) {
        print(error.toString());
      }
    }
  }

  String formatTimeOfDay(TimeOfDay tod) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm(); //"6:00 AM"
    return format.format(dt);
  }
}
