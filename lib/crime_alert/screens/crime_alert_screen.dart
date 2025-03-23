import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:crime/service/global.dart';
import 'package:crime/utils/theme.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/bottom_navigation.dart';
import '../../utils/custom_widgets.dart';
import '../models/alert_model.dart';

class CrimeAlertsScreen extends StatefulWidget {
  const CrimeAlertsScreen({Key? key}) : super(key: key);

  static final GlobalKey<_CrimeAlertsScreenState> globalKey =
      GlobalKey<_CrimeAlertsScreenState>();

  @override
  State<CrimeAlertsScreen> createState() => _CrimeAlertsScreenState();

  static void getCurrentLocation() {
    globalKey.currentState?.getCurrentLocation();
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
  bool _isLoading = true;
  bool _isSearching = false;
  late SharedPreferences _prefs;
  Set<String> _viewedAlerts = {};

  // Custom marker icons
  BitmapDescriptor? _alertMarkerIcon;

  // Add dark map style
  static const String _mapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#263c3f"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6b9a76"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#38414e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#212a37"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9ca5b3"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#1f2835"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#f3d19c"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#2f3948"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#515c6d"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  }
]
''';

  Future<BitmapDescriptor> _createCustomMarkerBitmap(Color color) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final double width = 40.0;
    final double height = 50.0;
    final double radius = width / 3;

    // Create the pin path
    final Path path = Path();
    path.moveTo(width / 2, height);
    path.quadraticBezierTo(width / 2, height - 10, width, height - height / 3);
    path.arcToPoint(
      Offset(0, height - height / 3),
      radius: Radius.circular(width / 2),
      clockwise: false,
    );
    path.quadraticBezierTo(width / 2, height - 10, width / 2, height);
    path.close();

    // Draw shadow
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawPath(path.shift(const Offset(0, 2)), shadowPaint);

    // Draw main pin body
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    // Draw border
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, borderPaint);

    // Draw inner circle
    final Paint circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(width / 2, height - height / 2),
      radius / 1.5,
      circlePaint,
    );

    final img = await pictureRecorder.endRecording().toImage(
          width.toInt(),
          height.toInt(),
        );
    final data = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  Future<void> _createMarkerIcon() async {
    try {
      _alertMarkerIcon = await _createCustomMarkerBitmap(Colors.red);
    } catch (e) {
      print('Error creating marker icon: $e');
      // Fallback to default marker if custom creation fails
      _alertMarkerIcon =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }

  @override
  void initState() {
    super.initState();
    _initializePrefs();
    _initializeMap();
    _createMarkerIcon();
  }

  Future<void> _initializePrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _viewedAlerts = _prefs.getStringList('viewed_alerts')?.toSet() ?? {};
    });
  }

  Future<void> _markAlertAsViewed(String alertId) async {
    setState(() {
      _viewedAlerts.add(alertId);
    });
    await _prefs.setStringList('viewed_alerts', _viewedAlerts.toList());
  }

  bool _shouldShowNotification(String alertId, String timestamp) {
    if (_viewedAlerts.contains(alertId)) {
      return false;
    }

    try {
      final alertTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(alertTime);

      // Only show notifications for alerts within the last 24 hours
      return difference.inHours <= 24;
    } catch (e) {
      print('Error parsing timestamp: $e');
      return false;
    }
  }

  void _initializeMap() async {
    setState(() => _isLoading = true);
    try {
      final position = await _determinePosition();
      setState(() {
        lng = position.longitude;
        lat = position.latitude;
        initialCameraPosition = CameraPosition(
          target: LatLng(lat, lng),
          zoom: 15.0,
        );
      });
      await getCrimeAlerts();
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error getting location: $e',
        backgroundColor: AppTheme.error,
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      final position = await _determinePosition();
      setState(() {
        lng = position.longitude;
        lat = position.latitude;
      });

      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(lat, lng),
            zoom: 15.0,
          ),
        ),
      );

      await getCrimeAlerts();
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error getting location: $e',
        backgroundColor: AppTheme.error,
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: CrimeAlertsScreen.globalKey,
      appBar: AppBar(
        title: Text('Crime Alerts', style: AppTheme.titleLarge),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 2,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Google Map
          _isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading map...',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                )
              : GoogleMap(
                  initialCameraPosition: initialCameraPosition!,
                  markers: markersList,
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  onMapCreated: (GoogleMapController controller) {
                    googleMapController = controller;
                    googleMapController.setMapStyle(_mapStyle);
                  },
                ),

          // Search Bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: _isSearching ? null : _handlePressButton,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: _isSearching
                            ? AppTheme.textLightColor
                            : AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _isSearching ? "Searching..." : "Search location",
                        style: AppTheme.bodyMedium.copyWith(
                          color: _isSearching
                              ? AppTheme.textLightColor
                              : AppTheme.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Alert Count
                if (markersList.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${markersList.length} crime alerts nearby',
                      style: AppTheme.bodyMedium.copyWith(color: Colors.white),
                    ),
                  ),

                // Controls Row
                Row(
                  children: [
                    // Current Location Button
                    FloatingActionButton(
                      heroTag: "btn1",
                      onPressed: _isLoading ? null : getCurrentLocation,
                      backgroundColor: _isLoading
                          ? AppTheme.textLightColor
                          : AppTheme.surfaceColor,
                      child: Icon(
                        Icons.my_location,
                        color:
                            _isLoading ? Colors.white : AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Refresh Alerts Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () {
                                getCrimeAlerts();
                                Fluttertoast.showToast(
                                  msg: 'Refreshing crime alerts...',
                                  backgroundColor: AppTheme.secondaryColor,
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isLoading
                              ? AppTheme.textLightColor
                              : AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.refresh),
                        label:
                            Text(_isLoading ? 'Loading...' : 'Refresh Alerts'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        defaultSelectedIndex: 0,
      ),
    );
  }

  Future<void> getAlertList() async {
    final reportRef = FirebaseDatabase.instance.ref().child('reports');
    try {
      final event = await reportRef.once();
      if (event.snapshot.value != null) {
        markersList.clear();
        int nearbyAlertsCount = 0;

        final data = event.snapshot.value as Map;
        for (var entry in data.entries) {
          try {
            final alertData = json.decode(json.encode(entry.value));
            double? latitude = double.tryParse(alertData['latitude'] ?? '');
            double? longitude = double.tryParse(alertData['longitude'] ?? '');

            if (latitude != null && longitude != null) {
              double distanceInMeters = await Geolocator.distanceBetween(
                  lat, lng, latitude, longitude);

              if (distanceInMeters < 2000) {
                nearbyAlertsCount++;
                if (_shouldShowNotification(entry.key, alertData["date"])) {
                  sendNotification(alertData["type"], alertData["date"]);
                }

                // Create marker with opacity based on whether it's viewed
                final isViewed = _viewedAlerts.contains(entry.key);
                final markerColor = isViewed ? Colors.grey : Colors.red;

                markersList.add(Marker(
                  markerId: MarkerId(entry.key),
                  position: LatLng(latitude, longitude),
                  icon: _alertMarkerIcon ?? BitmapDescriptor.defaultMarker,
                  alpha: isViewed ? 0.6 : 1.0,
                  infoWindow: InfoWindow(
                    title: '⚠️ ${alertData["type"]}',
                    snippet: isViewed
                        ? 'Click for details'
                        : '🔔 New Alert - Click for details',
                    onTap: () {
                      _markAlertAsViewed(entry.key);
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (context) => Container(
                          constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.75,
                          ),
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Drag Handle
                              Container(
                                width: 40,
                                height: 4,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.dividerColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),

                              // Alert Type Header
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceColor,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: markerColor.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.warning_rounded,
                                        color: markerColor,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            alertData["type"],
                                            style:
                                                AppTheme.titleMedium.copyWith(
                                              color: AppTheme.textColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          if (!isViewed)
                                            Container(
                                              margin:
                                                  const EdgeInsets.only(top: 4),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppTheme.primaryColor
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'New Alert',
                                                style:
                                                    AppTheme.bodySmall.copyWith(
                                                  color: AppTheme.primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Alert Details
                              Flexible(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Time and Reporter Section
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: AppTheme.surfaceColor
                                              .withOpacity(0.5),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          children: [
                                            _detailRow(
                                              Icons.access_time,
                                              'Reported',
                                              alertData["date"] ?? 'Unknown',
                                            ),
                                            const Divider(height: 16),
                                            _detailRow(
                                              Icons.person_outline,
                                              'Reported by',
                                              alertData["reporter_name"] ??
                                                  'Anonymous',
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Description Section
                                      if (alertData["description"] != null &&
                                          alertData["description"]
                                              .toString()
                                              .isNotEmpty) ...[
                                        Text(
                                          'Description',
                                          style: AppTheme.titleSmall.copyWith(
                                            color: AppTheme.primaryColor,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: AppTheme.surfaceColor
                                                .withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            alertData["description"],
                                            style: AppTheme.bodyMedium,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                      ],

                                      // Location Section
                                      Text(
                                        'Location',
                                        style: AppTheme.titleSmall.copyWith(
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: AppTheme.surfaceColor
                                              .withOpacity(0.5),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          children: [
                                            _detailRow(
                                              Icons.location_on_outlined,
                                              'Coordinates',
                                              '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
                                            ),
                                            if (alertData["address"] !=
                                                null) ...[
                                              const Divider(height: 16),
                                              _detailRow(
                                                Icons.map_outlined,
                                                'Address',
                                                alertData["address"],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ));
              }
            }
          } catch (e) {
            print('Error processing alert ${entry.key}: $e');
          }
        }
        setState(() {});
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error fetching alerts: $e',
        backgroundColor: AppTheme.error,
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  void sendNotification(String type, String date) {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'crime_alert_channel',
      'Crime Alert',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      enableLights: true,
      color: AppTheme.primaryColor,
    );

    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    flutterLocalNotificationsPlugin.show(
      0,
      'Crime Alert',
      'Nearby $type reported on $date',
      platformChannelSpecifics,
    );
  }

  getCrimeAlerts() async {
    await getAlertList();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(
        msg: 'Please enable location services',
        backgroundColor: AppTheme.warning,
        toastLength: Toast.LENGTH_LONG,
      );
      return Future.error('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _handlePressButton() async {
    setState(() => _isSearching = true);
    try {
      Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: kGoogleApiKey,
        onError: onError,
        mode: _mode,
        language: 'en',
        strictbounds: false,
        types: [""],
        decoration: InputDecoration(
          hintText: 'Search location',
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primaryColor),
          ),
        ),
        components: [Component(Component.country, "in")],
      );

      if (p != null) {
        await displayPrediction(p, homeScaffoldKey.currentState);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error searching location: $e',
        backgroundColor: AppTheme.error,
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void onError(PlacesAutocompleteResponse response) {
    Fluttertoast.showToast(
      msg: response.errorMessage ?? 'Unknown error',
      backgroundColor: AppTheme.error,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  Future<void> displayPrediction(
    Prediction p,
    ScaffoldState? currentState,
  ) async {
    setState(() => _isLoading = true);
    try {
      GoogleMapsPlaces places = GoogleMapsPlaces(
        apiKey: kGoogleApiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders(),
      );

      PlacesDetailsResponse detail =
          await places.getDetailsByPlaceId(p.placeId!);
      final lat = detail.result.geometry!.location.lat;
      final lng = detail.result.geometry!.location.lng;

      setState(() {
        this.lat = lat;
        this.lng = lng;
      });

      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(lat, lng),
            zoom: 15.0,
          ),
        ),
      );

      await getCrimeAlerts();
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error getting location details: $e',
        backgroundColor: AppTheme.error,
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
