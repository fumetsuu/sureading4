import 'package:flutter/material.dart';
import 'dart:io';

import '../card/card_template.dart';

import '../util.dart';

class VolumeCard extends StatelessWidget {

  final String volumePath;
  String volumeTitle;

  VolumeCard(this.volumePath) {
    List<String> splits = volumePath.split('/');
    volumeTitle = splits[splits.length-1];
  }

  Widget build(BuildContext context) {
    return generateCard(context, volumeTitle, _getCoverImagePath()); //add action 4th positional arg
  }

  String _getCoverImagePath() {
      return Directory(volumePath).listSync().firstWhere((FileSystemEntity entity) => isImage(entity.path)).path;
  }
}