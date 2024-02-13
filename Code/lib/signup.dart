import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pothole_detection_system/home.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> _signUpUser() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    // Add the new user's data to Firestore
    await FirebaseFirestore.instance.collection('login').add({
      'username': username,
      'password': password,
      'potholes_reported': 0,
      'feedback': '',
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('User registered successfully!')));

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Home()));

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Image.asset('lib/assets/appbarPic.png', height: 300, width: 400,),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 50),
              Image.asset('lib/assets/profilePic.png', height: 175, width: 175,),
              // Adjust the size as needed
              SizedBox(height: 50),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _signUpUser,
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}