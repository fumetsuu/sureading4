import 'package:flutter/material.dart';
import 'dart:io';

Widget generateCard(BuildContext context, String title, String imagePath, [Function action]) {
  return GestureDetector(
      onTap: () { action(context); } ?? () {},
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: Stack(
          alignment: Alignment.bottomLeft,
          fit: StackFit.expand,
          children: <Widget>[
            Image(
              image: FileImage(File(imagePath)),
              fit: BoxFit.cover,
            ),
            Container(
              child: Stack(
                alignment: Alignment.bottomLeft,
                children: <Widget>[
                  SizedBox(height: 40, child: Container(decoration:  BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black54, Colors.black12, Colors.transparent], stops: [0.2, 0.7, 1])))),
                  Container(child: Text(title, overflow: TextOverflow.ellipsis, style: Theme.of(context).primaryTextTheme.body2), padding: EdgeInsets.all(6.0)),
                ],
              ) 
            )
          ],
        )
      )
    );
}