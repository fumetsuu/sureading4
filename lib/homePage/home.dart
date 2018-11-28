import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import '../colours.dart';
import './home_card.dart';
import '../card/card_gridview_builder.dart';

class HomePage extends StatefulWidget {
  final String _mediaFolderPath;

  HomePage(this._mediaFolderPath);

  @override
  State<StatefulWidget> createState() {
    return HomePageState(_mediaFolderPath);
  }
}

class HomePageState extends State<HomePage> {
  String _mediaFolderPath;
  static const platform = const MethodChannel('sureading/dirpicker');

  HomePageState(this._mediaFolderPath);

  Future<void> _setMediaFolderPath() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      final String result = await platform.invokeMethod('getDirPath');
      prefs.setString('mediaFolderPath', result);
      setState(() {
        _mediaFolderPath = result;
      });
    } on PlatformException catch (e) {
      print(e);
    }
  }

  Widget build(BuildContext context) {
    if(_mediaFolderPath == 'not set') {
      return Scaffold(
        appBar: AppBar(
            title: Text('sureading',
                style: Theme.of(context).primaryTextTheme.headline)),
        body: Center(child: 
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(child: Text('Media folder path not yet set.', style: Theme.of(context).primaryTextTheme.body2), padding: EdgeInsets.symmetric(vertical: 12.0),),
              FlatButton(
                color: lightblue,
                child: Text('Set media folder path'),
                onPressed: _setMediaFolderPath,
              )
            ]
        ))
      );
    } else {
      return Scaffold(
        appBar: AppBar(
            title: Text('sureading',
                style: Theme.of(context).primaryTextTheme.headline)),
        body: _buildHomeView()
      );
    }
  }

  Widget _buildHomeView() {
    
    Directory mediaDir = new Directory(_mediaFolderPath);

    List<String> mangaPaths = [];

    mediaDir.listSync(recursive: false).forEach((FileSystemEntity entity) {
      mangaPaths.add(entity.path);
    });

    return buildCardGridview(context, mangaPaths, (String path) => HomeCard(path));
  }


}
