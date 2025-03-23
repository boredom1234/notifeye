import 'dart:convert';

import 'package:crime/service/global.dart';
import 'package:crime/utils/theme.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SosSettingsPopUp extends StatefulWidget {
  const SosSettingsPopUp({Key? key}) : super(key: key);

  @override
  State<SosSettingsPopUp> createState() => _SosSettingsPopUpState();
}

class _SosSettingsPopUpState extends State<SosSettingsPopUp> {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('sos');
  String uID = Global.instance.user!.uId!;
  bool messageEnabled = false;
  bool _isLoading = false;

  Future<Map?> fetchUserSetting() async {
    try {
      DatabaseReference sosRef = dbRef.child(uID).child("setting");
      final snapshot = await sosRef.get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return null;
    } catch (e) {
      print('Error fetching user settings: $e');
      return null;
    }
  }

  Future<void> getMessageEnabled() async {
    setState(() => _isLoading = true);
    try {
      Map? data = await fetchUserSetting();
      if (data != null && data.isNotEmpty) {
        setState(() {
          messageEnabled = data["messageContact"] ?? false;
        });
      }
    } catch (e) {
      print('Error getting message enabled status: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> saveSettings() async {
    setState(() => _isLoading = true);
    try {
      DatabaseReference sosRef = dbRef.child(uID).child("setting");
      await sosRef.set({
        'messageContact': messageEnabled,
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      Fluttertoast.showToast(
        msg: 'SOS settings saved successfully',
        backgroundColor: AppTheme.success,
        toastLength: Toast.LENGTH_SHORT,
      );

      Navigator.of(context).pop();
    } catch (e) {
      print('Error saving settings: $e');
      Fluttertoast.showToast(
        msg: 'Error saving settings. Please try again.',
        backgroundColor: AppTheme.error,
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    getMessageEnabled();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.cardColor,
      title: Text(
        'SOS Settings',
        style: AppTheme.titleLarge.copyWith(color: AppTheme.textColor),
      ),
      content: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configure your emergency response preferences',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.dividerColor),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.message_outlined,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          title: Text(
                            'Emergency Contact Messaging',
                            style: AppTheme.titleSmall,
                          ),
                          subtitle: Text(
                            'Send SOS alerts to your emergency contacts',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          trailing: Switch(
                            value: messageEnabled,
                            onChanged: (value) {
                              setState(() => messageEnabled = value);
                            },
                            activeColor: AppTheme.primaryColor,
                          ),
                        ),
                        if (messageEnabled) ...[
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'When enabled, your emergency contacts will receive SMS alerts with your location when you trigger an SOS.',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.textSecondary,
          ),
          child: Text('Cancel', style: AppTheme.bodyMedium),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : saveSettings,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Save Changes'),
        ),
      ],
    );
  }
}
