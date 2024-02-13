import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';  // Firestore

class LeaderboardPage extends StatefulWidget {
  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<DocumentSnapshot> leaderboardData = [];

  @override
  void initState() {
    super.initState();
    _fetchLeaderboardData();
  }

  Future<void> _fetchLeaderboardData() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('login')
        .orderBy('potholes_reported', descending: true)
        .get();

    setState(() {
      leaderboardData = snapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Text('Leaderboard', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("lib/assets/background_phone_dimensions.jpeg"),
              fit: BoxFit.fill),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: leaderboardData.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 5,
                child: ListTile(
                  leading: CircleAvatar(  // This will be used to display the rank
                    backgroundColor: Colors.grey[600],
                    child: Text('${index + 1}', style: TextStyle(color: Colors.white)),
                  ),
                  title: Text(leaderboardData[index]['username']),
                  subtitle: Text('Feedback: ${leaderboardData[index]['feedback']}'),
                  trailing: Text('${leaderboardData[index]['potholes_reported']} potholes'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}