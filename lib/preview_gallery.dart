import 'dart:io';
import 'dart:typed_data';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

import 'package:cameraapp/generatefilter.dart';

class PreviewScreenGallery extends StatefulWidget {
  final String imgPath;

  PreviewScreenGallery({required this.imgPath});

  @override
  _PreviewScreenGalleryState createState() => _PreviewScreenGalleryState();
}

class _PreviewScreenGalleryState extends State<PreviewScreenGallery> {
  Future<void> deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Error in getting access to the file.
    }
  }

  @override
  void initState() {
    super.initState();
    print(widget.imgPath);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: Container(
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
      floatingActionButton: Wrap(
        direction: Axis.vertical,
        children: <Widget>[
          FloatingActionButton(
            backgroundColor: Colors.black,
            onPressed: () {
              getBytesFromFile().then((bytes) {
                Share.file('Share via', basename(widget.imgPath),
                    bytes.buffer.asUint8List(), 'image/path');
              });
            },
            child: const Icon(
              Icons.share,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 15),
          FloatingActionButton(
            backgroundColor: Colors.black,
            onPressed: () {
              deleteFile(File(widget.imgPath));
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<ByteData> getBytesFromFile() async {
    Uint8List bytes = File(widget.imgPath).readAsBytesSync() as Uint8List;
    return ByteData.view(bytes.buffer);
  }
}
