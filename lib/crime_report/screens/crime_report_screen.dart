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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Crime Report', style: AppTheme.titleLarge),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 2,
        centerTitle: true,
      ),
      body: Global.instance.user!.isLoggedIn
          ? SafeArea(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Report Details',
                          style: AppTheme.headlineMedium.copyWith(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        getLocationField(),
                        const SizedBox(height: 16),
                        getDateTimeFields(),
                        const SizedBox(height: 16),
                        selectCrimeTypeField(),
                        const SizedBox(height: 16),
                        getCrimeDescField(),
                        const SizedBox(height: 24),
                        Text(
                          'Evidence & Witnesses',
                          style: AppTheme.headlineMedium.copyWith(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: selectFiles,
                          style: AppTheme.primaryButtonStyle,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Add Evidence Media / Files'),
                        ),
                        const SizedBox(height: 8),
                        getShowSelectedImages(),
                        const SizedBox(height: 16),
                        getRadioButton(),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: getPopUp,
                          style: AppTheme.secondaryButtonStyle,
                          icon: const Icon(Icons.person_add),
                          label: const Text('Add Witness Details'),
                        ),
                        const SizedBox(height: 8),
                        getAddedList(),
                        const SizedBox(height: 24),
                        getTermCheckBox(),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/crimeReport');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.secondaryColor,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    await submitReport();
                                  }
                                },
                                style: AppTheme.primaryButtonStyle,
                                child: const Text('Submit Report'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          size: 48,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Please Log In or Register to Continue",
                          style: AppTheme.titleLarge.copyWith(
                            color: AppTheme.textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            style: AppTheme.primaryButtonStyle,
                            child: const Text('Sign In'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            style: AppTheme.secondaryButtonStyle,
                            child: const Text('Register'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: const CustomBottomNavigationBar(
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
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          height: 150,
          padding: const EdgeInsets.all(16),
          child: ListView.builder(
            itemCount: personas.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.dividerColor,
                  ),
                ),
                child: ListTile(
                  title: Text(
                    personas[index].type!,
                    style: AppTheme.titleSmall,
                  ),
                  subtitle: Text(
                    personas[index].description!,
                    style: AppTheme.bodyMedium,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: AppTheme.error,
                    onPressed: () {
                      setState(() {
                        personas.removeAt(index);
                        if (personas.isEmpty) {
                          havePerson = false;
                        }
                      });
                    },
                  ),
                ),
              );
            },
          ),
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
      child: InkWell(
        onTap: _handlePressButton,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  location ?? "Enter the Location of the Incident",
                  style: AppTheme.bodyMedium.copyWith(
                    color: location != null
                        ? AppTheme.textColor
                        : AppTheme.textLightColor,
                  ),
                ),
              ),
            ],
          ),
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
      children: [
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
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
                          primary: AppTheme.primaryColor,
                          onPrimary: Colors.white,
                          onSurface: AppTheme.textColor,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (pickedDate != null) {
                  formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate!);
                  dateCtl.text = formattedDate!;
                  setState(() {});
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        dateCtl.text.isNotEmpty ? dateCtl.text : 'Select Date',
                        style: AppTheme.bodyMedium.copyWith(
                          color: dateCtl.text.isNotEmpty
                              ? AppTheme.textColor
                              : AppTheme.textLightColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () async {
                pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: AppTheme.primaryColor,
                          onPrimary: Colors.white,
                          onSurface: AppTheme.textColor,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (pickedTime != null) {
                  timeCtl.text = formatTimeOfDay(pickedTime!);
                  setState(() {});
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        timeCtl.text.isNotEmpty ? timeCtl.text : 'Select Time',
                        style: AppTheme.bodyMedium.copyWith(
                          color: timeCtl.text.isNotEmpty
                              ? AppTheme.textColor
                              : AppTheme.textLightColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  selectCrimeTypeField() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          icon: Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
          isExpanded: true,
          hint: Text(
            "Select Type of Crime",
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textLightColor,
            ),
          ),
          value: type,
          items: crimes.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: AppTheme.bodyMedium,
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              type = value;
            });
          },
        ),
      ),
    );
  }

  getCrimeDescField() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextFormField(
          minLines: 3,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: "Enter the description of the incident",
            hintStyle: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textLightColor,
            ),
            border: InputBorder.none,
          ),
          style: AppTheme.bodyMedium,
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
      ),
    );
  }

  getShowSelectedImages() {
    return Visibility(
      visible: haveFile,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          height: 150,
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            itemCount: selectedFiles.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (BuildContext context, int index) {
              final extension = selectedFiles[index].extension ?? 'none';
              return Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '.$extension',
                        style: AppTheme.titleMedium.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedFiles[index].name,
                    style: AppTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  getRadioButton() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "I am the:",
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            RadioListTile(
              title: Text("Victim", style: AppTheme.bodyMedium),
              value: "Victim",
              groupValue: reporterType,
              activeColor: AppTheme.primaryColor,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                setState(() {
                  reporterType = value.toString();
                });
              },
            ),
            RadioListTile(
              title: Text("Witness", style: AppTheme.bodyMedium),
              value: "Witness",
              groupValue: reporterType,
              activeColor: AppTheme.primaryColor,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                setState(() {
                  reporterType = value.toString();
                });
              },
            ),
            RadioListTile(
              title: Text("Anonymous", style: AppTheme.bodyMedium),
              value: "Anonymous",
              groupValue: reporterType,
              activeColor: AppTheme.primaryColor,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                setState(() {
                  reporterType = value.toString();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  getTermCheckBox() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FormField<bool>(
          validator: (value) {
            if (!checkboxValue) {
              return 'You need to accept terms and conditions';
            }
            return null;
          },
          builder: (state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: checkboxValue,
                      activeColor: AppTheme.primaryColor,
                      onChanged: (value) {
                        setState(() {
                          checkboxValue = value!;
                          state.didChange(value);
                        });
                      },
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: AppTheme.bodyMedium,
                          children: [
                            TextSpan(
                              text:
                                  "By submitting this form I acknowledge the information entered is true events and I have read and agree to the ",
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textColor,
                              ),
                            ),
                            TextSpan(
                              text: 'Terms and Conditions',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: '.',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      state.errorText!,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.error,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> submitReport() async {
    String uID = Global.instance.user!.uId!;
    DatabaseReference reportRef =
        FirebaseDatabase.instance.ref().child('reports');
    String reportID = reportRef.push().key!;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Upload report data
      await reportRef.child(reportID).set({
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

      // Add persona details if any
      if (personas.isNotEmpty) {
        add_details =
            "The following are additional details of people involved:";
        DatabaseReference addRef =
            reportRef.child(reportID).child('addDetails');
        int index = 1;
        for (var per in personas) {
          await addRef
              .child('detailNo $index')
              .set({'persona': per.type, 'desc': per.description});
          add_details += "\n$index Person Involved: ${per.type}"
              "\n Person Description: ${per.description}";
          index++;
        }
      }

      // Add media files if any
      if (selectedFiles.isNotEmpty) {
        evidence_list = "The following are links to evidence media attached:";
        DatabaseReference mediaRef = reportRef.child(reportID).child('media');
        var url;
        int index = 1;
        for (var file in selectedFiles) {
          url = await uploadFile(file: file!);
          await mediaRef.child(index.toString()).set({'file': url});
          evidence_list += "\n$index File link: $url";
          index++;
        }
      }

      // Send email
      await sendEmail(reportID);

      // Hide loading indicator
      Navigator.pop(context);

      // Show success message
      Fluttertoast.showToast(
        msg: "Report submitted successfully",
        backgroundColor: AppTheme.success,
        textColor: Colors.white,
      );

      // Navigate back
      Navigator.pushReplacementNamed(context, '/crimeReport');
    } catch (e) {
      // Hide loading indicator
      Navigator.pop(context);

      // Show error message
      Fluttertoast.showToast(
        msg: "Error submitting report: $e",
        backgroundColor: AppTheme.error,
        textColor: Colors.white,
      );
    }
  }

  Future<void> sendEmail(String id) async {
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
