// stop.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'feedback.dart';
import 'package:pothole_detection_system/home.dart';
import 'package:pothole_detection_system/main.dart';

class StopPage extends StatefulWidget {
  @override
  _StopPageState createState() => _StopPageState();
}

class _StopPageState extends State<StopPage> {
  int totalPotholesAvoided = 0;  // Just a placeholder, you'll fetch the real data from Firestore.
   // Placeholder again.

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    // Fetch total potholes avoided (assuming there's a field in Firestore for this).
    // Fetch total potholes reported by the current user.
    // ... implement fetching logic ...

    setState(() {
      totalPotholesAvoided = 0;  // Set this value after fetching.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[600],
        title: Text('Summary Statistics', style: TextStyle(color: Colors.white),),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("lib/assets/background_phone_dimensions.jpeg"),
              fit: BoxFit.fill
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Use stretch to make the buttons expand
          children: [
            Text('Total potholes avoided: $totalPotholesAvoided', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
            SizedBox(height: 20),
            Text('Potholes reported by you: $potholesReportedByUser', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
            Spacer(), // This will push the buttons to the bottom
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackPage()));
              },
              child: Text('Give Feedback'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
              },
              child: Text('End trip!'),
            ),
          ],
        ),
      ),
    );
  }
}
