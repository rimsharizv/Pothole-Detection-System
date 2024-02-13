import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GovernmentHomePage extends StatefulWidget {
  @override
  _GovernmentHomePageState createState() => _GovernmentHomePageState();
}

class _GovernmentHomePageState extends State<GovernmentHomePage> {
  List<DocumentSnapshot> _potholes = [];
  final Map<String, bool> _fixedStatus = {}; // Map to track the fixed status of each pothole

  @override
  void initState() {
    super.initState();
    _fetchPotholes();
  }

  void _fetchPotholes() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('potholes')
        .orderBy('size', descending: false)
        .get();

    setState(() {
      _potholes = snapshot.docs;
      for (var doc in _potholes) {
        _fixedStatus[doc.id] = false; // Defaulting to 'not fixed'
      }
    });
  }

  void _toggleFixedStatus(String potholeId) {
    setState(() {
      _fixedStatus[potholeId] = !_fixedStatus[potholeId]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Image.asset('lib/assets/appbarPic.png', height: 300, width: 400,),
        backgroundColor: Colors.black,
      ),
      body: ListView.builder(
        itemCount: _potholes.length,
        itemBuilder: (context, index) {
          var pothole = _potholes[index];
          bool isFixed = _fixedStatus[pothole.id] ?? false;

          return ExpansionTile(
            leading: TextButton(
              onPressed: () => _toggleFixedStatus(pothole.id),
              style: TextButton.styleFrom(
                primary: isFixed ? Colors.green : Colors.red,
                backgroundColor: isFixed ? Colors.green[50] : Colors.red[50],
              ),
              child: Text(isFixed ? 'Fixed' : 'Not Fixed'),
            ),
            title: Text('Pothole ID: ${pothole.id} - Size: ${pothole['size']}'),
            initiallyExpanded: false,
            children: <Widget>[
              ListTile(
                title: const Text('Location'),
                subtitle: Text('Latitude: ${pothole['latitude']}, Longitude: ${pothole['longitude']}'),
              ),
            ],
          );
        },
      ),
    );
  }
}
