import 'package:flutter/material.dart';
import 'dart:io';

import '../card/card_template.dart';
import '../readingPage/reading_page.dart';

import '../util.dart';

class VolumeCard extends StatefulWidget {

  final String volumePath;
  String volumeTitle;

  VolumeCard(this.volumePath) {
    List<String> splits = volumePath.split('/');
    volumeTitle = splits[splits.length-1];
  }

  @override
    State<StatefulWidget> createState() {
      return VolumeCardState();
    }

}

class VolumeCardState extends State<VolumeCard>{

  String imagePath;

  void initState() {
    _getCoverImagePath();
    super.initState();
  }

  Widget build(BuildContext context) {
    return generateCard(context, widget.volumeTitle, imagePath, _gotoReadingPage); //add action 4th positional arg
  }

  void _gotoReadingPage(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ReadingPage(widget.volumePath, widget.volumeTitle) ));
  }

  void _getCoverImagePath() {
    Directory(widget.volumePath).list().firstWhere((FileSystemEntity entity) => isImage(entity.path)).then((FileSystemEntity entity) {
      setState(() {
        imagePath = entity.path;
      });
    });
  }
}