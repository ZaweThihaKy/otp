// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:xsphereotp/otp.dart';

void main() {runApp(const MyApp());}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  OTPValidationPage(),
    );
  }
}

///i Was unable to change the colors accordingly only manage 
///to had control of 1 textfield 
///while the rest stayed feault 