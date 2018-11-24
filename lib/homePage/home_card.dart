import 'package:flutter/material.dart';
import 'dart:io';

import '../card/card_template.dart';
import '../volumePage/volume_page.dart';
class HomeCard extends StatelessWidget {

  final String mangaPath;
  String mangaTitle;

  HomeCard(this.mangaPath) {
    List<String> splits = mangaPath.split('/');
    mangaTitle = splits[splits.length-1];
  }

  Widget build(BuildContext context) {
    return generateCard(context, mangaTitle, _getCoverImagePath(), _gotoVolumePage);
  }

  String _getCoverImagePath() {
    if(File(mangaPath + '/cover.jpg').existsSync()) {
      return mangaPath + '/cover.jpg';
    } else {
      return Directory(Directory(mangaPath).listSync()[0].path).listSync().reversed.toList()[0].path;
    }
  }

  void _gotoVolumePage(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => VolumePage(mangaPath, mangaTitle) ));
  }
}