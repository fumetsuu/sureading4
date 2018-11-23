import 'package:flutter/material.dart';
import 'dart:io';

class HomeCard extends StatelessWidget {

  final String mangaPath;
  String mangaTitle;

  HomeCard(this.mangaPath) {
    List<String> splits = mangaPath.split('/');
    mangaTitle = splits[splits.length-1];
  }

  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Stack(
        alignment: Alignment.bottomLeft,
        fit: StackFit.expand,
        children: <Widget>[
          Image(
            image: FileImage(File(_getCoverImagePath())),
            fit: BoxFit.cover,
          ),
          Container(
            child: Stack(
              alignment: Alignment.bottomLeft,
              children: <Widget>[
                SizedBox(height: 40, child: Container(decoration:  BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black54, Colors.black12, Colors.transparent], stops: [0.2, 0.7, 1])))),
                Container(child: Text(mangaTitle, overflow: TextOverflow.ellipsis, style: Theme.of(context).primaryTextTheme.body2), padding: EdgeInsets.all(6.0)),
              ],
            ) 
          )
        ],
      )
    );
  }

  String _getCoverImagePath() {
    if(File(mangaPath + '/cover.jpg').existsSync()) {
      return mangaPath + '/cover.jpg';
    } else {
      return Directory(Directory(mangaPath).listSync()[0].path).listSync()[0].path;
    }
  }
}