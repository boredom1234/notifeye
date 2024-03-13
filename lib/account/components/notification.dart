import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
// import 'package:flutter_sms/flutter_sms.dart';
import 'package:geolocator/geolocator.dart';

import '../../service/firebase.dart';
import '../../service/global.dart';
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
  static String addtionalInfo = "";
  static List<String> contacts = [];

  static Future<Position> _determinePosition() async {
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

  //get initial message content
  static Future getMessage(int type) async {
    if (type == 1) {
      initialMessage = "SOS! Immediate Help required:";
    } else {
      initialMessage = "Fire SOS Alert! Immediate Help required:";
    }
    // bool _result = await canSendSMS();
    String location = await getLocation();
    message = "\nName: ${Global.instance.user!.fName!} \n$location";
  }

  //get user's location
  static getLocation() async {
    final position = await _determinePosition();
    return "Longitude: ${position.longitude} and Latitude: ${position.latitude}";
  }

  static Future getInfo() async {
    addtionalInfo = "";
    var data = await getSOSData(Global.instance.user!.uId!);
    print(data);
    List<Info> infoList = [];
    if (data != null) {
      if (data["info"] != null) {
        data["info"].forEach((dt) {
          Map info = dt;
          infoList.add(Info(info.keys.first, info.values.first));
        });
        infoList.forEach((i) {
          addtionalInfo += "\n${i.type}: "
              "\n${i.description}";
        });
      }
      if (data["setting"] != null) {
        if (data["setting"]["messageContact"] == true) {
          contacts = await getRecipientContact(Global.instance.user!.uId!);
          print(contacts);
        }
      }
    }
  }

  static Future<void> _sendSMS(int type) async {
    List<String> recipents = ["+918145181703"];

    await getMessage(type).whenComplete(() {
      getInfo().whenComplete(() async {
        recipents.addAll(contacts);

        // try {
        //   String _result = await sendSMS(
        //       message: "$initialMessage \n$message \n$addtionalInfo",
        //       recipients: recipents,
        //       sendDirect: true);

        //   print(_result);
        // } catch (onError) {
        //   print(onError);
        // }
        // ;
      });
    });
  }
}
