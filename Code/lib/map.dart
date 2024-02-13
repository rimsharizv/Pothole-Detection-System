// map.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';  // Google maps
import 'package:cloud_firestore/cloud_firestore.dart';  // Firestore
import 'package:intl/intl.dart';
import 'package:test/expect.dart';
import 'firebase_service.dart';  // Firebase service
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:pothole_detection_system/home.dart';
import 'package:pothole_detection_system/main.dart';
import 'package:pothole_detection_system/map_methods/polyline_directions.dart';
import 'package:pothole_detection_system/leaderboard.dart';
import 'package:pothole_detection_system/feedback.dart';
import 'dart:math';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool isBottomSheetDisplayed = false;
  
  Completer<GoogleMapController> _controller = Completer();
  Set<Circle> _circles = {};  // Set to hold circles for potholes
  //static const LatLng _center = const LatLng(37.414304, -122.092877);
  String? _currentAddress;
  Position? _currentPosition;
  LatLng ?_center;
  var distanceToDestinationKM;
  String _timeTaken = '';
  int timeToDestination = 0;
  bool isInMap = true;

  late PolylinePoints directionPoints; // For drawing directions from source to destination
  List<LatLng> directionsCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};

  List<Position> allPotholes = [];
  bool potholeClose = false;
  int ?closestPotholeDistance;

  DateTime? _lastAlertTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _afterBuild());
    _fetchPotholes();
    //_lastAlertTime = DateTime.now();
  }

  void _calculateTimeTaken() {
    // TODO: calculate the time taken for the route and update _timeTaken variable
    // You can use Google Maps API or any other service to calculate the time taken
    setState(() {
      _timeTaken = 'Time: $timeToDestination mins              Distance: $distanceToDestinationKM KM';
    });
  }

  Future<void> _afterBuild() async {
    await _getCurrentPosition();

    if (_currentPosition != null && destinationPosition != null) {
      List<LatLng> directionsCoordinates = await PolylineDirections.getPolylineCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        destinationPosition!.latitude,
        destinationPosition!.longitude,
      );

      _updatePolylines(directionsCoordinates);

      double totalDistance = 0;
      for(var i = 0; i < polylineCoordinates.length-1; i++){
        totalDistance += calculateDistance(
            polylineCoordinates[i].latitude,
            polylineCoordinates[i].longitude,
            polylineCoordinates[i+1].latitude,
            polylineCoordinates[i+1].longitude);
      }
      distanceToDestinationKM = totalDistance;
      distanceToDestinationKM = double.parse((distanceToDestinationKM).toStringAsFixed(2));
      timeToDestination = (distanceToDestinationKM * 3).round();
    }
    _calculateTimeTaken();
  }

  void _updatePolylines(List<LatLng> coordinates) {
    PolylineId id = PolylineId('direction');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.lightBlue,
      points: coordinates,
      width: 6,
    );

    setState(() {
      polylines[id] = polyline;
    });
  }

  void _onMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);
    _userMovingPosition();
  }

  void _userMovingPosition() async {
    var stream = Geolocator.getPositionStream();

    stream.listen((Position position) async {
      _currentPosition = position;
      _center = LatLng(position.latitude, position.longitude);
      // _moveCameraToPosition(_center!);
      //
      if(await _checkPotholeClose()){
        _showPotholeAlert(context);
      }

      if (destinationPosition != null) {
        // Get the new directions every time the user position changes
        List<LatLng> newDirectionsCoordinates = await PolylineDirections
            .getPolylineCoordinates(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          destinationPosition!.latitude,
          destinationPosition!.longitude,
        );

        // Update the polylines with the new directions
        _updatePolylines(newDirectionsCoordinates);

        double totalDistance = 0;
        for(var i = 0; i < polylineCoordinates.length-1; i++){
          totalDistance += calculateDistance(
              polylineCoordinates[i].latitude,
              polylineCoordinates[i].longitude,
              polylineCoordinates[i+1].latitude,
              polylineCoordinates[i+1].longitude);
        }
        distanceToDestinationKM = totalDistance;
        distanceToDestinationKM = double.parse((distanceToDestinationKM).toStringAsFixed(2));
        timeToDestination = (distanceToDestinationKM * 3).round() + 1;
      }
      _calculateTimeTaken();
      _moveCameraToPosition(_center!);
    });
  }


  void _moveCameraToPosition(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    controller.moveCamera(CameraUpdate.newLatLng(position));
  }


  // Fetch the potholes from Firestore and create markers for them
  List<Position> _fetchPotholes() {
    List<Position> fetchedPotholes = [];
    FirebaseService().getPotholesStream().listen((snapshot) {
      _circles.clear();

      for (var document in snapshot.docs) {
        final data = document.data() as Map<String, dynamic>;
        final potholeId = document.id;
        final lat = data['latitude'];
        final lon = data['longitude'];
        final size = data['size'];

        final potholePosition = Position(latitude: lat, longitude: lon,  timestamp: DateTime.now(), accuracy: 0, altitude: 0.0, altitudeAccuracy: 0.0, heading: 0.0, headingAccuracy: 0.0, speed: 0.0, speedAccuracy: 0.0);

        fetchedPotholes.add(potholePosition);
        // Determine circle color based on size
        Color circleColor;
        if (size == "small") {
          circleColor = Colors.yellow;
        } else if (size == "medium") {
          circleColor = Colors.orange;
        } else {
          circleColor = Colors.red;
        }

        Circle circle = Circle(
          circleId: CircleId(potholeId),
          center: LatLng(lat, lon),
          radius: 2.0,
          fillColor: circleColor,
          strokeWidth: 1,
          strokeColor: Colors.black,
        );

        setState(() {
          _circles.add(circle);
          allPotholes = fetchedPotholes;
        });
      }
    });
    return allPotholes;
  }

  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var a = 0.5 - cos((lat2 - lat1) * p)/2 +
        cos(lat1 * p) * cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

  Future<bool> _checkPotholeClose() async {
    List<Position> allPotholes = await _fetchPotholes();

    if (_lastAlertTime != null) {
      final secondsSinceLastAlert = DateTime.now().difference(_lastAlertTime!).inSeconds;
      if (secondsSinceLastAlert < 30) {
        return false; // Don't show the alert if less than 30 seconds have passed
      }
    }

    for(var pothole in allPotholes){
      double distanceFromPotholeToUser = calculateDistance(pothole.latitude, pothole.longitude, _currentPosition?.latitude, _currentPosition?.longitude);
      if(distanceFromPotholeToUser < 0.1){
        closestPotholeDistance = (distanceFromPotholeToUser * 1000).round();
        setState(() {

        });
        return true;
      }
    }
    return false;
  }


  @override
  Widget build(BuildContext context) {
    // Get the center position from the current position if it's available
    _center = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : null;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(''),
            backgroundColor: Colors.green[700],
            actions: [
              Row(children: [
                Text('Report Pothole',
                    style: TextStyle(
                        color: Colors.red[300],
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                PopupMenuButton<int>(
                    itemBuilder: (context) => [
                      // PopupMenuItem code for Small, Medium and Large goes here...
                      PopupMenuItem(
                        onTap: () {_reportPothole("small"); },
                        value: 1,
                        // row with 2 children
                        child: Row(
                          children: [
                            Icon(Icons.star),
                            SizedBox(
                              width: 10,
                            ),
                            Text("Small")
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        onTap: () {_reportPothole("medium");},
                        value: 2,
                        // row with 2 children
                        child: Row(
                          children: [
                            Icon(Icons.star),
                            SizedBox(
                              width: 10,
                            ),
                            Text("Medium")
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        onTap: () {_reportPothole("large");},
                        value: 3,
                        // row with 2 children
                        child: Row(
                          children: [
                            Icon(Icons.star),
                            SizedBox(
                              width: 10,
                            ),
                            Text("Large")
                          ],
                        ),
                      )
                    ])
              ]),
              IconButton(
                icon: Icon(Icons.help_outline),
                color: Colors.black,
                onPressed: _showHelpDialog,
              ),
            ]),
        body:
        _center == null
            ? Center(child: CircularProgressIndicator())
            : Stack(
          children: [
            Positioned.fill(
              child: GoogleMap(
                circles: _circles,
                polylines: Set<Polyline>.of(polylines.values),
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _center!,
                  zoom: 20.0,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
            ),
            Positioned(
              top: 0, // Place the UI box right below the app bar.
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                color: Colors.grey[300], // Light grey color for the UI box.
                width: MediaQuery.of(context).size.width,
                child: Text(
                  _timeTaken,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700], // Dark blue color for the text.
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.01,
              left: MediaQuery.of(context).size.width * 0.4, // Center the STOP button.
              child: ElevatedButton(
                onPressed: () async {
                  isInMap = false;
                  await showDialog<void>(context: context, builder: (context)=>AlertDialog(
                    content: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 300,

                          child: Column(
                            children: [
                              Text("Total Potholes reported: $potholesReportedByUser"),
                              SizedBox(height: 100),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackPage()));
                                },
                                child: Text('Give Feedback'),
                              ),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => LeaderboardPage()));
                                },
                                child: Text('View Leaderboard'),
                              ),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
                                },
                                child: Text('End trip!'),
                              ),
                            ]
                          )
                        )
                      ]
                    )
                  ));
                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (context) => StopPage()));
                },
                child: Text('STOP'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showPotholeAlert(BuildContext context){
    print("Attempting to show snackbar");
    if(isBottomSheetDisplayed){
      return;
    }
    if(!isInMap){
      return;
    }

    isBottomSheetDisplayed = true;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) { 
        return Container(
            decoration: BoxDecoration(
              color: Colors.black54
            ),
            child: Row(
            children: [
              SizedBox(width: 5,),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.red, // Background color
                  onPrimary: Colors.white, // Text color (for primary state)
                  // You can add more styling properties here
                ),
                child:
                const Text("It's Still There!",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 12
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _lastAlertTime = DateTime.now();
                  });
                },
              ),
              SizedBox(width: 5),
              Text("Pothole is $closestPotholeDistance m away!",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 12
              ),),
              SizedBox(width: 5),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.green, // Background color
                  onPrimary: Colors.white, // Text color (for primary state)
                  // You can add more styling properties here
                ),
                child:
                const Text("It's Fixed!",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 12
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _lastAlertTime = DateTime.now();
                  });
                },
              ),
            ]
          )
        );
      }, // Auto-hide after 5 seconds
    ).then((value) {
      setState(() {
        isBottomSheetDisplayed = false;
      });
    });
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

  Future<void> _reportPothole(String size) async {
    potholesReportedByUser++;

    setState(() {
      _lastAlertTime = DateTime.now();
    });

    // Get current location
    Position position;
    try {
      position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching location. Please try again.')));
      return;
    }

    // Get size of the pothole through a dialog
    if (size == null) return;  // If user cancelled or didn't select size

    // Add data to Firestore
    await _addPotholeToDatabase(position, size);
  }

  // Adding the pothole information to the database.
  Future<void> _addPotholeToDatabase(Position position, String size) async {
    try {
      await FirebaseFirestore.instance.collection('potholes').add({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'size': size,
        'date_reported': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        'reported_by': 'user_${Random().nextInt(9999)}'
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pothole reported successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error reporting pothole. Please try again.')));
    }
  }

  // Checks for location permission fro the user.
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // If location services is disabled.
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
  // Gets the position of the user.
  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  // function to convert a string variable to a position variable. This way we can convert destination string to desired location
  Position stringToPosition(String input) {
    final components = input.split(',');
    if (components.length != 2) {
      throw FormatException('Input should be in format "latitude,longitude"');
    }

    final latitude = double.tryParse(components[0]);
    final longitude = double.tryParse(components[1]);

    if (latitude == null || longitude == null) {
      throw FormatException('Invalid latitude or longitude value');
    }

    return Position(latitude: latitude, longitude: longitude, timestamp: DateTime.now(), accuracy: 0, altitude: 0.0, altitudeAccuracy: 0.0, heading: 0.0, headingAccuracy: 0.0, speed: 0.0, speedAccuracy: 0.0);
  }
}


class SemiCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.lightBlueAccent
      ..style = PaintingStyle.fill;

    final Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2,
    );

    // Change the starting angle to pi (180 degrees) to draw the semi-circle at the bottom
    canvas.drawArc(rect, pi, pi, true, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

