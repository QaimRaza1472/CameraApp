import 'dart:async';
import 'dart:io';
import 'package:cameraapp/preview_gallery.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ImageCapture extends StatefulWidget {
  @override
  _ImageCaptureState createState() => _ImageCaptureState();
}

class _ImageCaptureState extends State<ImageCapture> {
  late Directory _photoDir;
  getpath() async {
    final paths = 'storage/emulated/0/Brighten';
    final String p = paths;

    setState(() {
      _photoDir = new Directory(p);
    });
  }

  late Timer _timer;
  int _start = 10;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            //timer.cancel();
            _start = 10;
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getpath();
    startTimer();
    //'/storage/emulated/0/Android/data/com.example.cameraapp/files/'
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Brighten Images'),
      ),
      body: Container(
        child: FutureBuilder(
          builder: (context, status) {
            return ImageGrid(directory: _photoDir);
          },
        ),
      ),
    );
  }
}

class ImageGrid extends StatelessWidget {
  final Directory directory;

  const ImageGrid({Key? key, required this.directory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // var refreshGridView;

    var imageList = directory
        .listSync()
        .map((item) => item.path)
        .where((item) => item.endsWith(".png"))
        .toList(growable: false);
    return GridView.builder(
      itemCount: imageList.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, childAspectRatio: 3.0 / 4.6),
      itemBuilder: (context, index) {
        File file = new File(imageList[index]);
        String name = file.path.split('/').last;
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: InkWell(
              onTap: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PreviewScreenGallery(
                            imgPath: imageList[index],
                          )),
                ),
                //     refreshGridView =
                //     Navigator.push(context, MaterialPageRoute(builder: (context) {
                //   return ImageEditClass(
                //     imagepath: imageList[index],
                //   );
                // })).then((refreshGridView) {
                //   if (refreshGridView != null) {
                //     build(context);
                //   }
                // }).catchError((er) {
                //   print(er);
                // }),
              },
              child: Padding(
                padding: new EdgeInsets.all(4.0),
                child: Image.file(
                  File(imageList[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
