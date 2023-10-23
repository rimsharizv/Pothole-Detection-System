import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'map.dart';
import 'home.dart';
import 'package:firebase_core/firebase_core.dart';

const google_map_API = "PUT_API_KEY_HERE";
String? destination;
Position? destinationPosition;
int potholesReportedByUser = 0;

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
      home: Home(),
    );
  }
}
