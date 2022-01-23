import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mis_lab3/constants/constants.dart';
import 'package:mis_lab3/widgets/rounded_button.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class RegistrationScreen extends StatefulWidget {

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {

  final _auth = FirebaseAuth.instance;

  String email = '';
  String password = '';
  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                child: Text('Регистрирајте се за да внесете колоквиуми'),
              ),
              SizedBox(
                height: 30.0,
              ),
              TextField(
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    email = value;
                  },
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Внесете email'
                  )
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                  textAlign: TextAlign.center,
                  obscureText: true,
                  onChanged: (value) {
                    password = value;
                  },
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Внесете лозинка'
                  )
              ),
              SizedBox(
                height: 18.0,
              ),
              RoundedButton(
                  title: 'Регистрирај се',
                  color: Colors.blueAccent,
                  onPressed: () async {

                    setState(() {
                      showSpinner = true;
                    });

                    try {
                      final newUser = await _auth.createUserWithEmailAndPassword(
                          email: email, password: password);

                      if (newUser != null) {
                        Navigator.pushNamed(context, '/home');
                      }

                      setState(() {
                        showSpinner = false;
                      });

                    }catch(e) {
                      print(e);
                    }
                  }
              ),
            ],
          ),
        ),
      ),
    );
  }
}