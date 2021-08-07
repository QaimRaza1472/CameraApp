import 'package:cameraapp/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cameraapp/pages/camera_screen.dart';
import 'package:admob_flutter/admob_flutter.dart';

void main() {
  Admob.initialize();
  runApp(CameraApp());
}

class CameraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.black));
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.black,
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
