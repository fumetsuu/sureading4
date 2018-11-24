import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import '../util.dart';

class ReadingPage extends StatefulWidget {
  final String volumePath;
  final String volumeTitle;

  ReadingPage(this.volumePath, this.volumeTitle);

  @override
    State<StatefulWidget> createState() {
      return ReadingPageState();
    }
}

class ReadingPageState extends State<ReadingPage> {

  final List<String> imagePaths = [];
  int currentPage = 1;

  void initState() {
    _populateImagePathsList();
    SystemChrome.setEnabledSystemUIOverlays([]);

    //TODO: set currentPage to page number saved in bookmarks

    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: PageView.builder(
          itemCount: imagePaths.length,
          reverse: true,
          itemBuilder: (context, i) {
            return Image(
              image: FileImage(File(imagePaths[i])),
            );
          },
        )
      ),
    );
  }

  void _populateImagePathsList() {
    
    Directory(widget.volumePath).listSync().forEach((FileSystemEntity entity) {
      if(isImage(entity.path)) imagePaths.add(entity.path);
    });

  }

}