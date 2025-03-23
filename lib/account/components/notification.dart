import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../service/firebase.dart';
import '../../service/global.dart';
import '../../utils/theme.dart';
import '../models/info_model.dart';

class NotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Your code goes here
  }

  @pragma("vm:entry-point")
  static Future<void> dismissNotification() async {
    AwesomeNotifications().dismiss(1);
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.buttonKeyPressed == "fire") {
      _sendSMS(2);
    } else if (receivedAction.buttonKeyPressed == "police") {
      _sendSMS(1);
    } else if (receivedAction.buttonKeyPressed == "alarm") {
      FlutterRingtonePlayer().play(
        fromAsset: 'assets/bachao.mp3',
        ios: IosSounds.glass,
        looping: true, // Android only - API >= 28
        volume: 1, // Android only - API >= 28
        asAlarm: false, // Android only - all APIs
      );
      alarmKey = 'stop';
      alarmVal = 'Stop';
    } else if (receivedAction.buttonKeyPressed == "stop") {
      FlutterRingtonePlayer().stop();
      alarmKey = 'alarm';
      alarmVal = 'Ring';
    }
    createSOSNotification();
  }

  static String alarmKey = 'alarm';
  static String alarmVal = 'Ring';

  static Future<void> createSOSNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'basic_channel',
        locked: true,
        title: 'SOS Menu Bar',
        notificationLayout: NotificationLayout.Default,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'fire',
          label: '${Emojis.wheater_fire} Fire SOS',
        ),
        NotificationActionButton(
          key: 'police',
          label: '${Emojis.symbols_sos_button} 911 SOS',
        ),
        NotificationActionButton(
          key: alarmKey,
          label: '${Emojis.sound_loudspeaker} $alarmVal Alarm',
        ),
      ],
    );
  }

  //--------------SOS Message------------------
  static String message = "";
  static String initialMessage = "";
  static String additionalInfo = "";
  static List<String> phoneContacts = [];
  static List<String> emailContacts = [];

  static Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  //get initial message content
  static Future<void> getMessage(int type) async {
    if (type == 1) {
      initialMessage = "🆘 SOS! Immediate Help Required!";
    } else {
      initialMessage = "🔥 FIRE SOS ALERT! Immediate Help Required!";
    }

    String location = await getLocation();
    message = """
Name: ${Global.instance.user!.fName!}
Phone: ${Global.instance.user!.mobileNo!}
$location

This is an automated emergency alert. The sender requires immediate assistance.""";
  }

  //get user's location
  static Future<String> getLocation() async {
    try {
      final position = await _determinePosition();
      String googleMapsLink =
          'https://www.google.com/maps?q=${position.latitude},${position.longitude}';
      return """Location: $googleMapsLink
Coordinates: ${position.latitude}, ${position.longitude}""";
    } catch (e) {
      return "Location: Unable to get current location";
    }
  }

  static Future<void> getInfo() async {
    additionalInfo = "";
    phoneContacts.clear();
    emailContacts.clear();

    try {
      print('Fetching SOS data for user: ${Global.instance.user!.uId!}');
      var data = await getSOSData(Global.instance.user!.uId!);
      print('SOS Data received: $data');

      if (data != null) {
        if (data["info"] != null) {
          List<Info> infoList = [];
          data["info"].forEach((dt) {
            Map info = dt;
            infoList.add(Info(info.keys.first, info.values.first));
          });
          infoList.forEach((i) {
            additionalInfo += "\n${i.type}: ${i.description}";
          });
        }

        print('Fetching emergency contacts...');
        var contacts = await getRecipientContact(Global.instance.user!.uId!);
        print('Emergency contacts received: $contacts');

        if (contacts != null) {
          for (var contact in contacts) {
            if (contact["contactNo"] != null &&
                contact["contactNo"].toString().isNotEmpty) {
              print('Adding phone contact: ${contact["contactNo"]}');
              phoneContacts.add(contact["contactNo"].toString());
            }
            if (contact["email"] != null &&
                contact["email"].toString().isNotEmpty) {
              print('Adding email contact: ${contact["email"]}');
              emailContacts.add(contact["email"].toString());
            }
          }
        }
        print('Final phone contacts list: $phoneContacts');
        print('Final email contacts list: $emailContacts');
      }
    } catch (e) {
      print('Error getting SOS info: $e');
    }
  }

  static Future<void> _sendSMS(int type) async {
    try {
      await getMessage(type);
      print('Getting emergency contacts...');
      await getInfo();
      print('Retrieved phone contacts: $phoneContacts');

      // Get emergency contacts first
      List<String> recipients = [];
      recipients.addAll(phoneContacts);
      print('Recipients after adding contacts: $recipients');

      // Only add default emergency number if no contacts are available
      if (recipients.isEmpty) {
        print('No emergency contacts found, adding default emergency number');
        recipients.add("+911");
      }

      String fullMessage = """$initialMessage

$message""";

      if (additionalInfo.isNotEmpty) {
        fullMessage += "\n\nAdditional Information:$additionalInfo";
      }

      // Send SMS
      if (recipients.isNotEmpty) {
        try {
          // Combine all recipients with semicolons for Android
          String recipientString = recipients.join(';');
          print('Attempting to send SMS to: $recipientString');

          // Create the SMS URI with the message
          final Uri smsUri = Uri.parse(
            'sms:$recipientString?body=${Uri.encodeComponent(fullMessage)}',
          );

          print('SMS URI created: $smsUri');

          // Configure URL launcher
          final bool launched = await launchUrl(
            smsUri,
            mode: LaunchMode.externalApplication,
            webViewConfiguration: const WebViewConfiguration(
              enableJavaScript: true,
              enableDomStorage: true,
            ),
          );

          if (launched) {
            Fluttertoast.showToast(
              msg: 'SMS app opened with emergency message',
              backgroundColor: AppTheme.success,
            );
          } else {
            // If SMS fails, try emergency call with the first recipient
            final Uri telUri = Uri.parse('tel:${recipients[0]}');
            if (await canLaunchUrl(telUri)) {
              await launchUrl(
                telUri,
                mode: LaunchMode.externalApplication,
              );
              Fluttertoast.showToast(
                msg: 'Dialing emergency contact',
                backgroundColor: AppTheme.warning,
              );
            }
          }
        } catch (e) {
          print('Error launching SMS: $e');
          // Try emergency call as fallback
          try {
            final Uri telUri = Uri.parse('tel:${recipients[0]}');
            await launchUrl(
              telUri,
              mode: LaunchMode.externalApplication,
            );
            Fluttertoast.showToast(
              msg: 'Dialing emergency contact',
              backgroundColor: AppTheme.warning,
            );
          } catch (e) {
            print('Error making emergency call: $e');
            Fluttertoast.showToast(
              msg: 'Failed to make emergency call',
              backgroundColor: AppTheme.error,
            );
          }
        }
      } else {
        Fluttertoast.showToast(
          msg: 'No emergency contacts found',
          backgroundColor: AppTheme.warning,
        );
      }

      // Send Email
      if (emailContacts.isNotEmpty) {
        try {
          final String subject = Uri.encodeComponent(initialMessage);
          final String body = Uri.encodeComponent(fullMessage);
          final String emailList = emailContacts.join(',');

          final Uri emailUri = Uri.parse(
            'mailto:$emailList?subject=$subject&body=$body',
          );

          final bool launched = await launchUrl(
            emailUri,
            mode: LaunchMode.externalApplication,
          );

          if (launched) {
            Fluttertoast.showToast(
              msg: 'Email app opened with emergency message',
              backgroundColor: AppTheme.success,
            );
          } else {
            throw 'Could not launch email app';
          }
        } catch (e) {
          print('Error launching email: $e');
          Fluttertoast.showToast(
            msg: 'Failed to open email app',
            backgroundColor: AppTheme.error,
          );
        }
      }
    } catch (e) {
      print('Error in _sendSMS: $e');
      Fluttertoast.showToast(
        msg: 'Error preparing emergency messages',
        backgroundColor: AppTheme.error,
      );
    }
  }
}
