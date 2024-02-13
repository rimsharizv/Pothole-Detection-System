import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
//import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:pothole_detection_system/login.dart';

import 'package:pothole_detection_system/map.dart';
import 'package:pothole_detection_system/main.dart';

import 'home_methods/predictive_address.dart';

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: google_map_API);

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _Home();
}

// Define a corresponding State class.
// This class holds data related to the form.
class _Home extends State<Home> {
  String _currentAddress = "Address not found";
  Position? _currentPosition;

  // Define the focus node. To manage the lifecycle, create the FocusNode in
  // the initState method, and clean it up in the dispose method.
  late FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.lightGreen[900],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
        ),
        backgroundColor: Colors.black,
        title: Image.asset('lib/assets/appbarPic.png', height: 300, width: 400,),
      ),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Container(
          // decoration: const BoxDecoration(
          //   image: DecorationImage(
          //     image: AssetImage("lib/assets/background_phone_dimensions.jpeg"),
          //     fit: BoxFit.fill
          //   ),
          // ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,  // Adjust as needed
                child: IconButton(
                  icon: Icon(Icons.help_outline),
                  color: Colors.black,
                  onPressed: _showHelpDialog,
                ),
              ),
              //Image.asset('lib/assets/logo.png', width: 150, height: 150),
              const SizedBox(height: 70),
              ElevatedButton(
                onPressed: _getCurrentPosition,
                child: const Text("Get Current Location"),
              ),
              //Text("User Location:"),
              Text(_currentAddress),
              // The first text field is focused on as soon as the app starts.
              TextField(
                //readOnly: true,
                controller: destinationController,
                //textAlign: TextAlign.left,
                onTap: () {
                  // should show search screen here
                  showSearch(
                    context: context,
                    delegate: AddressSearch(),
                  );
                  if(destination != null) {
                    destinationController.text = "$destination";
                  }
                },
              ),
              // TextField(
              //   decoration: InputDecoration(
              //       labelText: 'Destination'),
              //   controller: destinationController,
              //   autofocus: true,),
              // The second text field is focused on when a user taps the
              // FloatingActionButton.
              const SizedBox(height: 100),
              FloatingActionButton.extended(
                backgroundColor: Colors.green[400],
                onPressed: ()  {
                  if (destinationPosition?.latitude != null &&
                      destinationPosition?.longitude != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MapScreen()),
                    );
                  }
              },
                icon: Icon(Icons.start),
                label: Text("START"),
              )
            ],
          ),
        ),
      )
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Help'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Pothole Detection System'),
                SizedBox(height: 15),
                Text('This app is designed to detect & report potholes.'),
                SizedBox(height: 10),
                Text('It aims to guide you through a secure journey.'),
                SizedBox(height: 15),
                Text('Pothole sizes are represented by the following colors:'),
                SizedBox(height: 10),
                Row(children: [
                  Container(width: 20, height: 20, color: Colors.yellow),
                  SizedBox(width: 10),
                  Text('Small Potholes'),
                ]),
                SizedBox(height: 5),
                Row(children: [
                  Container(width: 20, height: 20, color: Colors.orange),
                  SizedBox(width: 10),
                  Text('Medium Potholes'),
                ]),
                SizedBox(height: 5),
                Row(children: [
                  Container(width: 20, height: 20, color: Colors.red),
                  SizedBox(width: 10),
                  Text('Large Potholes'),
                ]),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
          _currentPosition = position;
          getAddressFromLatLng(context, _currentPosition);
          setState(() {});
    }).catchError((e) {
      debugPrint(e);
    });
  }

  getAddressFromLatLng(context, Position? position) async {
    double? lat = position?.latitude;
    double? lng = position?.longitude;
    String _host = 'https://maps.google.com/maps/api/geocode/json';
    final url = '$_host?key=$google_map_API&language=en&latlng=$lat,$lng';
    if(lat != null && lng != null){
      var response = await http.get(Uri.parse(url));
      if(response.statusCode == 200) {
        Map data = jsonDecode(response.body);
        setState(() {
          _currentAddress = data["results"][0]["formatted_address"];
        });
        print("response ==== $_currentAddress");
      }
    }
  }

  void setCurrentPosition(double lat, double long){
    _currentPosition = Position(latitude: lat, longitude: long, timestamp: null, accuracy: 100, altitude: 0, altitudeAccuracy: 0, heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0);
    setState(() {});
  }
  Position? getCurrentPosition(){
    return _currentPosition;
  }
  String? getCurrentAddress(){
    return _currentAddress;
  }
}
