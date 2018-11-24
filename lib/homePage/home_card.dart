import 'package:flutter/material.dart';
import 'dart:io';

import '../card/card_template.dart';
import '../volumePage/volume_page.dart';
import '../util.dart';

class HomeCard extends StatefulWidget {
  final String mangaPath;
  String mangaTitle;

  HomeCard(this.mangaPath) {
    List<String> splits = mangaPath.split('/');
    mangaTitle = splits[splits.length - 1];
  }

  @override
  State<StatefulWidget> createState() {
    return HomeCardState();
  }
}

class HomeCardState extends State<HomeCard> {
  String imagePath;

  void initState() {
    _getCoverImagePath();
    super.initState();
  }

  Widget build(BuildContext context) {
    return generateCard(context, widget.mangaTitle, imagePath, _gotoVolumePage);
  }

  void _getCoverImagePath() {
    if (File(widget.mangaPath + '/cover.jpg').existsSync()) {
      setState(() {
        imagePath = widget.mangaPath + '/cover.jpg';
      });
    } else {
      Directory(widget.mangaPath)
          .list()
          .firstWhere((FileSystemEntity entity) =>
              FileSystemEntity.isDirectorySync(entity.path))
          .then((FileSystemEntity entity) => Directory(entity.path)
              .list()
              .firstWhere((FileSystemEntity entity) => isImage(entity.path)))
          .then((FileSystemEntity entity) {
        setState(() {
          imagePath = entity.path;
        });
      });
    }
  }

  void _gotoVolumePage(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                VolumePage(widget.mangaPath, widget.mangaTitle)));
  }
}
