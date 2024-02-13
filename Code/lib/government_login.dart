import 'package:flutter/material.dart';
import 'package:pothole_detection_system/government_home.dart';

class GovernmentLoginPage extends StatefulWidget {
  const GovernmentLoginPage({super.key});

  @override
  _GovernmentLoginPageState createState() => _GovernmentLoginPageState();
}

class _GovernmentLoginPageState extends State<GovernmentLoginPage>{
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
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 75),
              Image.asset('lib/assets/GovernmentLoginImage.png', height: 175, width: 175, alignment: Alignment.center,),
              const TextField(
                //controller: usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              const SizedBox(height: 16),
              const TextField(
                //controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround, // Space buttons equally
                children: [
                  ElevatedButton(
                    onPressed: (){
                      Navigator.push(
                        context, MaterialPageRoute(builder: (context) => GovernmentHomePage())
                      );
                    },//_loginUser,
                    child: const Text('Login'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      //Navigator.push(
                      //    context, MaterialPageRoute(builder: (context) => SignUpPage()));
                    },
                    child: const Text('Sign Up'),
                  ),
                ],
              )
            ]
          )
        )
      )
    );
  }

}