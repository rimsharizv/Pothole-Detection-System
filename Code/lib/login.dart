import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Firestore
import 'package:pothole_detection_system/home.dart';
import 'package:pothole_detection_system/signup.dart';
import 'package:pothole_detection_system/government_login.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> _loginUser() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    // Fetching user data from Firestore based on username and password
    final user = await FirebaseFirestore.instance
        .collection('login')
        .where('username', isEqualTo: username)
        .where('password', isEqualTo: password)
        .get();

    if (user.docs.isNotEmpty) {
      // If user exists, navigate to Home
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Home()));
    } else {
      // Display an error message
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Invalid credentials!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('lib/assets/appbarPic.png', height: 300, width: 400,),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(top: 10, right: 10),
                  child:
                  SizedBox(
                    width: 100,
                    height: 40,
                    child: ElevatedButton(onPressed: () { Navigator.push(
                        context, MaterialPageRoute(builder: (context) => GovernmentLoginPage()));},
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(100, 40), // Set the size as per your requirement
                          padding: EdgeInsets.symmetric(horizontal: 10), // Adjust padding if needed
                          // You can add more styling properties here
                        ),
                        child: const Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Admin",
                            textAlign: TextAlign.center,),
                        )
                    ),
                  ),
                ),
              ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround, // Space buttons equally
                children: [
                  ElevatedButton(
                    onPressed: _loginUser,
                    child: Text('Login'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => SignUpPage()));
                    },
                    child: Text('Sign Up'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}