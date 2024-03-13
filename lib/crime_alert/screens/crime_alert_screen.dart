import 'dart:async';
import 'dart:convert';

import 'package:crime/service/global.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../utils/bottom_navigation.dart';
import '../../utils/custom_widgets.dart';
import '../models/alert_model.dart';

class CrimeAlertsScreen extends StatefulWidget {
  const CrimeAlertsScreen({Key? key}) : super(key: key);

  @override
  State<CrimeAlertsScreen> createState() => _CrimeAlertsScreenState();

  static void getCurrentLocation() {
    getCurrentLocation();
  }
}

const kGoogleApiKey = 'AIzaSyACR85dcvtoBdJ4i9xsIIs2QDNDfVWduIU';
final homeScaffoldKey = GlobalKey<ScaffoldState>();

class _CrimeAlertsScreenState extends State<CrimeAlertsScreen> {
  CameraPosition? initialCameraPosition;

  Set<Marker> markersList = {};
  List<Alert> alerts = [];

  double lng = 2.814014;
  double lat = 101.758337;
  late GoogleMapController googleMapController;

  final Mode _mode = Mode.overlay;

  getCurrentLocation() async {
    final position = await _determinePosition();
    setState(() {
      lng = position.longitude;
      lat = position.latitude;

      markersList.add(Marker(
          markerId: const MarkerId("0"),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen)));

      googleMapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(lat, lng), zoom: 17.0)));
      getCrimeAlerts();
    });
  }

  Future<void> getAlertList() async {
    final reportRef = FirebaseDatabase.instance.ref().child('reports');
    reportRef.onValue.listen((event) async {
      for (final child in event.snapshot.children) {
        final alertID = await json.decode(json.encode(child.key));
        Map data = await json.decode(json.encode(child.value));

        double? latitude = double.tryParse(data['latitude'] ?? '');
        double? longitude = double.tryParse(data['longitude'] ?? '');

        if (latitude != null && longitude != null) {
          double distanceInMeters =
              await Geolocator.distanceBetween(lat, lng, latitude, longitude);

          // Check if the distance is less than 2 kilometres
          if (distanceInMeters < 2000) {
            // Send a notification
            sendNotification(data["type"], data["date"]);
          }

          // Add marker only if latitude and longitude are valid
          markersList.add(Marker(
            markerId: MarkerId(alertID),
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(
              title: data["type"],
              snippet:
                  'Date: ${data["date"]}', // Add the incident date and time here
            ),
          ));
        }
      }
      setState(() {});
    }, onError: (error) {
      if (kDebugMode) {
        print('Error getting post List');
      }
    });
  }

  // Method to send notification
  void sendNotification(String type, String date) {
    // Initialize the notification plugin
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    // Define Android initialization settings
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    // Define IOS initialization settings
    // var initializationSettingsIOS = IOSInitializationSettings();

    // Initialize settings for both platforms
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      // iOS: initializationSettingsIOS,
    );

    // Initialize the notification plugin with the initialization settings
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Define notification details
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'crime_alert_channel', // channel ID
      'Crime Alert', // channel name
      importance: Importance.max,
      priority: Priority.high,
      // sound: RawResourceAndroidNotificationSound('bgm'),
      // playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Create the notification
    flutterLocalNotificationsPlugin.show(
      0, // notification ID
      'Crime Alert', // notification title
      'Nearby $type reported on $date', // notification body
      platformChannelSpecifics,
    );
  }

  getCrimeAlerts() async {
    await getAlertList();
    setState(() {});
  }

  @override
  void initState() {
    initialCameraPosition =
        CameraPosition(target: LatLng(lng, lat), zoom: 16.0);
    super.initState();
    getCurrentLocation();
    getCrimeAlerts();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print(markersList.length);
    }
    return Scaffold(
      appBar: customAppBar(title: 'Crime Alerts'),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialCameraPosition!,
            markers: markersList.map((e) => e).toSet(),
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              googleMapController = controller;
            },
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
                onPressed: _handlePressButton,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                  padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: Colors.red.shade900,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Enter Area, City or State",
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 16),
                    )
                  ],
                )),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding:
                  const EdgeInsets.only(bottom: 10.0, left: 10, right: 100),
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        getCurrentLocation();
                        // Show toast
                        Fluttertoast.showToast(
                            msg: 'Getting current location...',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.grey,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      },
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.black,
                      ),
                    ),
                    // Icon(Icons.location_on, color: Colors.deepPurple.shade400),
                    // const Text(
                    //   "Current Location",
                    //   style: TextStyle(fontSize: 12),
                    // ),
                    GestureDetector(
                      onTap: () {
                        getCrimeAlerts();
                        // Show toast
                        Fluttertoast.showToast(
                            msg: 'Getting crime alerts...',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.grey,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      },
                      child: const Icon(
                        Icons.notifications,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        defaultSelectedIndex: 0,
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(
          msg: "Please enable the location services to use this feature");
      return Future.error('Location services are disabled');
    }
    //get permissions
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
    //get location using geolocator
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    return position;
  }

  Future<void> _handlePressButton() async {
    Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: kGoogleApiKey,
        onError: onError,
        mode: _mode,
        language: 'en',
        strictbounds: false,
        types: [""],
        logo: Container(
          height: 1,
        ),
        decoration: InputDecoration(
            hintText: 'Enter Area, City or State',
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.white))),
        components: [Component(Component.country, "in")]);

    displayPrediction(p!, homeScaffoldKey.currentState);
  }

  void onError(PlacesAutocompleteResponse response) {}

  Future<void> displayPrediction(
      Prediction p, ScaffoldState? currentState) async {
    GoogleMapsPlaces places = GoogleMapsPlaces(
        apiKey: kGoogleApiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders());

    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);

    lat = detail.result.geometry!.location.lat;
    lng = detail.result.geometry!.location.lng;

    //add marker for the selected place
    markersList.add(Marker(
        markerId: const MarkerId("0"),
        position: LatLng(lat!, lng!),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        infoWindow: InfoWindow(title: detail.result.name)));

    //set camera to the place selected
    setState(() async {
      getCrimeAlerts();
      googleMapController
          .animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat!, lng!), 14.0));
    });
  }
}
