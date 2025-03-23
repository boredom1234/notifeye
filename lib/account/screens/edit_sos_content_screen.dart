import 'dart:convert';

import 'package:crime/service/global.dart';
import 'package:crime/utils/custom_widgets.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  bool _isLoading = false;
  String? sample;
  String? location;
  User user = Global.instance.user!;
  String message = "🆘 EMERGENCY SOS ALERT!";

  String additionalInfo = "";

  Future<void> getInfo() async {
    setState(() => _isLoading = true);
    try {
      var data = await getSOSData(user.uId!);
      if (data != null) {
        infoList.clear();
        data["info"].forEach((dt) {
          Map info = dt;
          infoList.add(Info(info.keys.first, info.values.first));
        });
        setState(() {
          haveInfo = true;
        });
      }
    } catch (e) {
      print('Error fetching SOS data: $e');
      Fluttertoast.showToast(
        msg: 'Error loading SOS information',
        backgroundColor: AppTheme.error,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> getMessage() async {
    try {
      location = await getLocation();
      setState(() {
        message = """🆘 EMERGENCY SOS ALERT!
        
Name: ${user.fName}
Phone: ${user.mobileNo}
$location

This is an automated emergency alert. The sender requires immediate assistance.""";
      });
    } catch (e) {
      print('Error getting location for message: $e');
    }
  }

  Future<String> getLocation() async {
    final position = await _determinePosition();
    String googleMapsLink =
        'https://www.google.com/maps?q=${position.latitude},${position.longitude}';
    return """Location: $googleMapsLink
Coordinates: ${position.latitude}, ${position.longitude}""";
  }

  @override
  void initState() {
    super.initState();
    getMessage();
    getInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: customAppBar(title: "Edit SOS Message"),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Default Message',
                        style: AppTheme.titleMedium.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.dividerColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message,
                              style: AppTheme.bodyMedium,
                            ),
                            if (message.contains('Location not available')) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Enable location services to include your location in the SOS message',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.warning,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Additional Information Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Additional Information',
                            style: AppTheme.titleMedium.copyWith(
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          IconButton(
                            onPressed: () => getPopUp(),
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add,
                                color: AppTheme.primaryColor,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (!haveInfo)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.dividerColor.withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppTheme.textSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Add additional information that should be included in your SOS message',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: infoList.length,
                          itemBuilder: (context, index) {
                            final info = infoList[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceColor,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: AppTheme.dividerColor),
                              ),
                              child: ListTile(
                                title: Text(
                                  info.type!,
                                  style: AppTheme.titleSmall,
                                ),
                                subtitle: Text(
                                  info.description!,
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: AppTheme.error,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      infoList.removeAt(index);
                                      if (infoList.isEmpty) {
                                        haveInfo = false;
                                      }
                                      updateSampleMessage();
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 24),

                      // Preview Section
                      Text(
                        'Message Preview',
                        style: AppTheme.titleMedium.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.dividerColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getFullMessage(),
                              style: AppTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Save Changes'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  void getPopUp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddEditInfoPopUP(
          onAdd: (value) {
            setState(() {
              infoList.add(value);
              haveInfo = true;
              updateSampleMessage();
            });
          },
        );
      },
    );
  }

  void updateSampleMessage() {
    setState(() {
      additionalInfo = "";
      for (var info in infoList) {
        additionalInfo += "\n${info.type}: ${info.description}";
      }
    });
  }

  String getFullMessage() {
    String fullMessage = message;
    if (haveInfo && additionalInfo.isNotEmpty) {
      fullMessage += "\n\nAdditional Information:$additionalInfo";
    }
    return fullMessage;
  }

  Future<void> saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        DatabaseReference sosRef = dbRef.child(user.uId!);
        await sosRef.child('info').remove();

        if (infoList.isNotEmpty) {
          for (int i = 0; i < infoList.length; i++) {
            await sosRef
                .child('info')
                .child(i.toString())
                .set({infoList[i].type: infoList[i].description});
          }
        }

        Fluttertoast.showToast(
          msg: 'SOS message updated successfully',
          backgroundColor: AppTheme.success,
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AccountScreen()),
          (Route<dynamic> route) => false,
        );
      } catch (e) {
        print('Error saving SOS content: $e');
        Fluttertoast.showToast(
          msg: 'Error saving changes. Please try again.',
          backgroundColor: AppTheme.error,
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permission denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied';
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
