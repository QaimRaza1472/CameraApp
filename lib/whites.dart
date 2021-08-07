import 'dart:async';
import 'package:camera/camera.dart';
import 'package:cameraapp/pages/camera_screen.dart';
import 'package:cameraapp/pages/preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:screen/screen.dart';
import 'dart:math' as math;

class WhiteScreen extends StatefulWidget {
  final double brighntess;
  final int backorfront;
  final String colour;
  WhiteScreen(
      {required this.brighntess,
      required this.backorfront,
      required this.colour});

  @override
  _WhiteScreenState createState() => _WhiteScreenState();
}

class _WhiteScreenState extends State<WhiteScreen> {
  CameraController? controller;
  late List cameras;
  late int selectedCameraIndex;
  late String imgPath;
  late double _brightness;
  late var colour;
  initPlatformState() async {
    double brightness = await Screen.brightness;
    setState(() {
      _brightness = brightness;
      print(_brightness);
    });
  }

  void ClickPic() async {
    controller!.setFlashMode(FlashMode.off);

    final imgPth = await controller!.takePicture();
    Screen.setBrightness(_brightness);
    if (widget.backorfront == 0) {
      Timer(
          Duration(seconds: 0),
          () => Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => PreviewScreen(
                    imgPath: imgPth.path,
                    brightness: 0.0,
                    transformation: 0.0,
                  ))));
    } else {
      Timer(
          Duration(seconds: 0),
          () => Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => PreviewScreen(
                    imgPath: imgPth.path,
                    brightness: 0.0,
                    transformation: math.pi,
                  ))));
    }
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    if (widget.colour == 'White') {
      colour = Colors.white;
    } else if (widget.colour == 'Pink') {
      colour = Colors.pink;
    } else if (widget.colour == 'Peach') {
      colour = Color(0xFFE5B400);
    } else if (widget.colour == 'Yellow') {
      colour = Colors.yellow;
    } else if (widget.colour == 'Orange') {
      colour = Colors.orange;
    }

    Screen.setBrightness(widget.brighntess);

    availableCameras().then((availableCameras) {
      cameras = availableCameras;

      if (cameras.length > 0) {
        setState(() {
          selectedCameraIndex = widget.backorfront;
        });
        _initCameraController(cameras[selectedCameraIndex]).then((void v) {});
      } else {
        print('No camera available');
      }
    }).catchError((err) {
      print('Error :${err.code}Error message : ${err.message}');
    });
    Timer(Duration(seconds: 2), () => ClickPic());
  }

  Future _initCameraController(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller!.dispose();
    }
    controller = CameraController(cameraDescription, ResolutionPreset.high);

    controller!.addListener(() {
      if (mounted) {
        setState(() {});
      }

      if (controller!.value.hasError) {
        print('Camera error ${controller!.value.errorDescription}');
      }
    });

    try {
      await controller!.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _showCameraException(CameraException e) {
    String errorText = 'Error:${e.code}\nError message : ${e.description}';
    print(errorText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colour,
      body: Center(
        child: Text(""),
      ),
    );
  }
}
