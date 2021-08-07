import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import '../generatefilter.dart';

import 'camera_screen.dart'; // import this

class PreviewScreen extends StatefulWidget {
  final String imgPath;
  final double brightness;
  final double transformation;

  PreviewScreen(
      {required this.imgPath,
      required this.brightness,
      required this.transformation});

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  //late Uint8List _imageFile;
  ScreenshotController screenshotController = ScreenshotController();
  String fileName = "";
  String path = "";
  int del = 0;
  Future<void> deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Error in getting access to the file.
    }
  }

  void capture() async {
    final directory = 'storage/emulated/0/Brighten'; //from path_provide package
    fileName = DateTime.now().microsecondsSinceEpoch.toString() + '.png';
    path = '$directory';

    //double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    screenshotController.captureAndSave(
        path, //set path where screenshot will be saved
        fileName: fileName,
        // pixelRatio: pixelRatio,
        delay: Duration(milliseconds: 2000));

    Timer(Duration(seconds: 5), () => changeState());
  }

  void changeState() {
    setState(() {
      del = 1;
    });
  }

  @override
  void initState() {
    super.initState();
    print(widget.imgPath);
    capture();
  }

  Widget ImageFilter({brightness, saturation, hue, child}) {
    return ColorFiltered(
        colorFilter:
            ColorFilter.matrix(ColorFilterGenerator.brightnessAdjustMatrix(
          value: brightness,
        )),
        child: ColorFiltered(
            colorFilter:
                ColorFilter.matrix(ColorFilterGenerator.saturationAdjustMatrix(
              value: saturation,
            )),
            child: ColorFiltered(
              colorFilter:
                  ColorFilter.matrix(ColorFilterGenerator.hueAdjustMatrix(
                value: hue,
              )),
              child: child,
            )));
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => CameraScreen()));
          return false;
        },
        child: new Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: new IconButton(
              icon: new Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (BuildContext context) => CameraScreen()));
              },
            ),
          ),
          body: Screenshot(
              controller: screenshotController,
              child: ImageFilter(
                  hue: 0.0,
                  brightness: widget.brightness,
                  saturation: 0.0,
                  child: Container(
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(widget.transformation),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Image.file(
                              File(widget.imgPath),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))),
          floatingActionButton: Wrap(
            direction: Axis.vertical,
            children: <Widget>[
              FloatingActionButton(
                backgroundColor: Colors.black,
                onPressed: () {
                  getBytesFromFile().then((bytes) {
                    Share.file('Share via', basename(path + fileName),
                        bytes.buffer.asUint8List(), 'image/path');
                  });
                },
                child: const Icon(
                  Icons.share,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 15),
              if (del == 1)
                FloatingActionButton(
                  backgroundColor: Colors.black,
                  onPressed: () {
                    deleteFile(File(path + '/' + fileName));
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (BuildContext context) => CameraScreen()));
                  },
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ));
  }

  Future<ByteData> getBytesFromFile() async {
    Uint8List bytes =
        File(path + '/' + fileName).readAsBytesSync() as Uint8List;
    return ByteData.view(bytes.buffer);
  }
}
