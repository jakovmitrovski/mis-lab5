import 'package:flutter/material.dart';

// const kWebPushCertificate = 'BOUyo22lEGPr3Y6g-o1AxpQRxtsTusokfI09MztSjSyQp71zc8qgt8iLLp4bSXgxdP3wED-AqqnRZcx0mrGB9fE';

const kTextFieldDecoration = InputDecoration(
  hintText: 'Enter a value',
  // hintStyle: TextStyle(color: Colors.black54),
  contentPadding:
  EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blueAccent, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);