import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_permissions/simple_permissions.dart';

import './colours.dart';

import './homePage/home.dart';

void main() async {

  bool hasReadPermissions = await SimplePermissions.checkPermission(Permission.ReadExternalStorage);
  if(!hasReadPermissions) SimplePermissions.requestPermission(Permission.ReadExternalStorage);

  final prefs = await SharedPreferences.getInstance();

  String mediaFolderPath = prefs.getString('mediaFolderPath') ?? 'not set';

  runApp(Sureading(mediaFolderPath));

}

class Sureading extends StatelessWidget {
  final String _mediaFolderPath;

  Sureading(this._mediaFolderPath);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'sureading 4',
      theme: buildThemeData(),
      home: HomePage(_mediaFolderPath)
    );
  }
}

ThemeData buildThemeData() {
  final baseTheme = ThemeData.dark();

  return baseTheme.copyWith(
    primaryColor: lightblue,
    primaryColorLight: blue,
    primaryColorDark: darkblue,
    accentColor: lightblue,
    buttonColor: lightblue,
    backgroundColor: grey,
    primaryTextTheme: TextTheme(
        body1: TextStyle(fontSize: 16.0, fontFamily: 'Lato'),
        body2: TextStyle(
            fontSize: 14.0, fontFamily: 'Lato', fontWeight: FontWeight.w300),
        button: TextStyle(
            fontSize: 18.0, fontFamily: 'Source Sans Pro', color: white),
        caption: TextStyle(
            fontSize: 14.0,
            fontFamily: 'Open Sans Condensed',
            fontStyle: FontStyle.italic),
        headline: TextStyle(fontFamily: 'Source Sans Pro'),
        overline: TextStyle(fontSize: 12.0, fontFamily: 'Lato'),
        subhead: TextStyle(fontFamily: 'Source Sans Pro'),
        subtitle: TextStyle(fontFamily: 'Lato')
      ),
  );
}