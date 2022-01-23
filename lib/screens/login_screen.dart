import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mis_lab3/constants/constants.dart';
import 'package:mis_lab3/widgets/rounded_button.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoginScreen extends StatefulWidget {

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _auth = FirebaseAuth.instance;

  String email = '';
  String password = '';
  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {

    _auth.userChanges()
        .listen((User? user) {
          if (user != null) {
            Navigator.pushNamed(context, '/home');
          }
        }
    );

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
                child: Text('Најавете се за да внесете колоквиуми'),
              ),
              SizedBox(
                height: 30.0,
              ),
              TextField(
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
                  title: 'Најави се',
                  color: Colors.lightBlueAccent,
                  onPressed: () async {

                    setState(() {
                      showSpinner = true;
                    });

                    try {
                      final user = await _auth.signInWithEmailAndPassword(
                          email: email, password: password);

                      if (user != null) {
                        Navigator.pushNamed(context, '/home');
                      }

                      setState(() {
                        showSpinner = false;
                      });

                    }catch(e){
                      print(e);
                    }
                  }
              ),
              RoundedButton(
                  title: 'Немаш профил? Регистрирај се',
                  color: Colors.grey,
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  }
              ),
            ],
          ),
        ),
      ),
    );
  }
}