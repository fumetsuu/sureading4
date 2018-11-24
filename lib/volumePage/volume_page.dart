import 'package:flutter/material.dart';
import 'dart:io';


import '../card/card_gridview_builder.dart';
import './volume_card.dart';


class VolumePage extends StatelessWidget {

  final String mangaPath;
  final String mangaTitle;

  VolumePage(this.mangaPath, this.mangaTitle);

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mangaTitle),
      ),
      body: _buildVolumeView(context),
    );
  }

  Widget _buildVolumeView(BuildContext context) {
    
    List<String> volumePaths = [];

    Directory(mangaPath).listSync(recursive: false).forEach((FileSystemEntity entity) {
      if(FileSystemEntity.isDirectorySync(entity.path)) volumePaths.add(entity.path);
    });

    return buildCardGridview(context, volumePaths, (String path) => VolumeCard(path));

  }

}