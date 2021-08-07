import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:admob_flutter/admob_flutter.dart';
import 'package:camera/camera.dart';
import 'package:cameraapp/Database/cameradb.dart';
import 'package:cameraapp/Database/cameraprovider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cameraapp/pages/preview_screen.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../Gallery.dart';
import '../whites.dart'; // import this

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State {
  late AdmobInterstitial interstitialAd;
  CameraController? controller;
  late List cameras;
  late int selectedCameraIndex = 1;
  late String imgPath;
  int flash = 1;
  int opc = 0;
  String dropdownValue = 'White'; // For Colour Flash
  double _value = 1.0;
  String getInterstitialAdUnitId() {
    if (Platform.isIOS) {
      //return 'ca-app-pub-3940 2560 9994 2544/4411468910';
      return "ca-app-pub-3289 8881 2578 8884/7777374209";
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-3289888125788884/6663840766';
    }
    return '';
  }

  //ca-app-pub-3289888125788884/7777374209

  Future<void> Dbfetch() async {
    camDbProvider camDb = camDbProvider();
    var camos = await camDb.fetchMemos();
    if (camos.length != 0) {
      setState(() {
        flash = camos[0].flash;
        selectedCameraIndex = camos[0].camindex;
        _value = camos[0].brightness;
        dropdownValue = camos[0].colour;
      });
    }
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
    //Ads
    interstitialAd = AdmobInterstitial(
      adUnitId: getInterstitialAdUnitId(),
      listener: (AdmobAdEvent event, Map<String, dynamic> args) {
        if (event == AdmobAdEvent.closed) interstitialAd.load();
      },
    );

    interstitialAd.load();

    //
    Dbfetch();
    Timer(Duration(milliseconds: 1000), () {
      availableCameras().then((availableCameras) {
        cameras = availableCameras;

        if (cameras.length > 0) {
          setState(() {
            selectedCameraIndex = selectedCameraIndex;
          });
          _initCameraController(cameras[selectedCameraIndex]).then((void v) {});
        } else {
          print('No camera available');
        }
      }).catchError((err) {
        print('Error :${err.code}Error message : ${err.message}');
      });
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    controller!.dispose();
    super.dispose();
  }

  Future _initCameraController(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller!.dispose();
    }
    controller = CameraController(cameraDescription, ResolutionPreset.max);

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

  _filesDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (thisLowerContext, innerSetState) {
            return Padding(
              padding: EdgeInsets.only(top: 2.0),
              child: Dialog(
                insetPadding: EdgeInsets.zero,
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  width: 380,
                  height: 340,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 30,
                      ),

                      SizedBox(height: 10),
                      Text(
                        'Brightness',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFF707583),
                        ),
                      ),
                      SizedBox(height: 20),

                      /////////////////////////////////////////    Yahan Slider adjust kr lena     /////////////////////////////////////
                      Slider(
                        min: 0.0,
                        max: 1.0,
                        value: _value,
                        onChanged: (value) {
                          innerSetState(() {
                            _value = value;
                          });
                        },
                        // divisions: 0.1,
                      ),

                      SizedBox(height: 10),
                      Text(
                        'Flash Colour',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFF707583),
                        ),
                      ),
                      SizedBox(height: 20),
                      DropdownButton<String>(
                        value: dropdownValue,
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: const TextStyle(color: Colors.black),
                        underline: Container(
                          height: 2,
                          color: Colors.black,
                        ),
                        onChanged: (String? newValue) {
                          innerSetState(() {
                            dropdownValue = newValue!;
                          });
                        },
                        items: <String>[
                          'White',
                          'Pink',
                          'Peach',
                          'Yellow',
                          'Orange'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 110,
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Center(
                                child: Text(
                                  'Cancel',
                                  //textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            width: 110,
                            height: 45,
                            decoration: BoxDecoration(
                              //color: Color(0xFFDC0000),
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Db();
                              },
                              child: Center(
                                child: Text(
                                  'Save',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    var height1 = MediaQuery.of(context).size.height;
    var width1 = MediaQuery.of(context).size.width;
    return WillPopScope(
        onWillPop: () async => false,
        child: SafeArea(
          child:

              ///////////////////////////////////////////////   By Qaim Raza  //////////////////////////////////////////////////////////////////
              //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
              Scaffold(
            body: Stack(
              children: [
                //Container(

                //height: height1 + 7,
                // width: width1 - 1,
                _cameraPreviewWidget(context),

                //),
                opc == 1
                    ? Container(
                        color: Colors.white.withOpacity(0.8),
                      )
                    : Container(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width1 * 0.12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          _cameraToggleRowWidget(context),
                          // SizedBox(
                          //   width: 2,
                          // ),
                          _cameraControlWidget(context),
                          _cameraFlashWidget(),
                          // SizedBox(
                          //   width: 0,
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),

                //////////////////////////////////////////////////////////// Top Setting  ////////////////////////////////////////////
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Image.asset(
                          "assets/Camera-Switching-icon.png",
                        ),
                        onPressed: () {
                          setState(() async {
                            if (selectedCameraIndex == 1) {
                              selectedCameraIndex = 0;
                              await _initCameraController(
                                      cameras[selectedCameraIndex])
                                  .then((void v) {});
                              flash = 0;
                              Db();
                            } else {
                              selectedCameraIndex = 1;
                              await _initCameraController(
                                      cameras[selectedCameraIndex])
                                  .then((void v) {});
                              flash = 1;
                              Db();
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: Image.asset(
                          "assets/Setting-icon.png",
                        ),
                        onPressed: () {
                          //openAlert();
                          _filesDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        ));

    //////////////////////////////////////////////////               Scaffold End                       ///////////////////////
  }

  /// Display Camera preview.
  Widget _cameraPreviewWidget(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Text(
        'Loading',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w900,
        ),
      );
    }
    // fetch screen size
    final size = MediaQuery.of(context).size;

    // calculate scale depending on screen and camera ratios
    // this is actually size.aspectRatio / (1 / camera.aspectRatio)
    // because camera preview size is received as landscape
    // but we're calculating for portrait orientation
    var camera = controller!.value;
    var scale = size.aspectRatio * camera.aspectRatio;

    // to prevent scaling down, invert the value
    if (scale < 1) scale = 1 / scale;

    return Transform.scale(
      scale: scale,
      child: Center(
        child: CameraPreview(controller!),
      ),
    );

    // return CameraPreview(controller!);

    // return Center(
    //   //aspectRatio: controller!.value.aspectRatio,
    //   child: new CameraPreview(controller!),
    // );
  }

  //////////////////////////////////////////////////  BY  Qaim Raza   ////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////
  Future<void> Db() async {
    camDbProvider camDb = camDbProvider();
    var camos = await camDb.fetchMemos();
    if (camos.length != 0) {
      final cam = CameraModel(
        id: 1,
        flash: flash,
        camindex: selectedCameraIndex,
        brightness: _value,
        colour: dropdownValue,
      );

      await camDb.updateMemo(1, cam);
    } else {
      final cam = CameraModel(
        id: 1,
        flash: flash,
        camindex: selectedCameraIndex,
        brightness: _value,
        colour: dropdownValue,
      );

      await camDb.addItem(cam);
    }
  }

  Widget _cameraToggleRowWidget(context) {
    return IconButton(
      icon: Image.asset(
        "assets/Galery-icon.png",
      ),
      iconSize: 50,
      //backgroundColor: Colors.white,
      onPressed: () async {
        if (await interstitialAd.isLoaded) {
          interstitialAd.show();
        } else {
          interstitialAd.show();
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ImageCapture()),
        );
      },
    );
  }

  Widget _cameraControlWidget(context) {
    return IconButton(
      icon: Image.asset(
        "assets/Capture-icon.png",
      ),
      iconSize: 120.0,
      onPressed: () {
        if (selectedCameraIndex == 0 && flash == 0) {
          setState(() {
            opc = 1;
          });
          Timer(Duration(milliseconds: 1000), () {
            _onCapturePressed(context, 0.5, 0);
          });
        } else if (selectedCameraIndex == 1 && flash == 0) {
          setState(() {
            opc = 1;
          });
          Timer(Duration(milliseconds: 1000), () {
            _onCapturePressed(context, 0.5, math.pi);
          });
        } else if (selectedCameraIndex == 0 && flash == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WhiteScreen(
                      brighntess: _value,
                      backorfront: 0,
                      colour: dropdownValue,
                    )),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WhiteScreen(
                      brighntess: _value,
                      backorfront: 1,
                      colour: dropdownValue,
                    )),
          );
        }
      },
    );
  }

  Widget _cameraFlashWidget() {
    return IconButton(
      icon: flash == 1
          ? Image.asset(
              "assets/Flash-On.png",
            )
          : Image.asset(
              "assets/Flash-off-icon.png",
            ),
      iconSize: 55,
      // backgroundColor: Colors.white,
      onPressed: () {
        setState(() {
          if (flash == 1) {
            flash = 0;
            Db();
          } else {
            flash = 1;
            Db();
          }
        });
      },
    );
  }

  IconData _getCameraLensIcon() {
    return Icons.image;
  }

  void _showCameraException(CameraException e) {
    String errorText = 'Error:${e.code}\nError message : ${e.description}';
    print(errorText);
  }

  void _onCapturePressed(context, double bright, double trans) async {
//    try {
    // final path = join(
    //     (await getExternalStorageDirectory()).path, '${DateTime.now()}.png');
    controller!.setFlashMode(FlashMode.off);
    final imgpth = await controller!.takePicture();
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewScreen(
              imgPath: imgpth.path, brightness: 0.5, transformation: trans),
        ));
  }

  // void _onSwitchCamera() {
  //   selectedCameraIndex = 0;
  //   // selectedCameraIndex < cameras.length - 1 ? selectedCameraIndex + 1 : 0;
  //   CameraDescription selectedCamera = cameras[selectedCameraIndex];
  //   _initCameraController(selectedCamera);
  // }
}
