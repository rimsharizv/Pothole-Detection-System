import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pothole_detection_system/login.dart';
import 'map.dart';
import 'home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geocoding/geocoding.dart';

const google_map_API = "AIzaSyAGWXvAmeJ7hsj9qxqVGnq9nqkge_ENu_8";
String? destination;
Position? destinationPosition;
int potholesReportedByUser = 0;
final geo = GeocodingPlatform.instance;
final destinationController = TextEditingController();
List<LatLng> polylineCoordinates = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pothole Detection System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginPage(),
    );
  }
}
