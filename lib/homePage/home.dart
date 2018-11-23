import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import '../colours.dart';
import './home_card.dart';

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

    try {
      final String result = await platform.invokeMethod('getDirPath');
      setState(() {
        _mediaFolderPath = result;      
      });
    } on PlatformException catch (e) {
      print(e.toString());
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

      Directory mediaDir = new Directory(_mediaFolderPath);

      List<String> mangaPaths = [];

      mediaDir.listSync(recursive: false).map((FileSystemEntity entity) {
        return mangaPaths.add(entity.path);
      }).toList();


      return Scaffold(
        appBar: AppBar(
            title: Text('sureading',
                style: Theme.of(context).primaryTextTheme.headline)),
        body: _buildHomeView(mangaPaths)
      );

    }
  }

  Widget _buildHomeView(List<String> mangaPaths) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: MediaQuery.of(context).size.width*0.8, childAspectRatio: 0.72),
        itemCount: mangaPaths.length,
        itemBuilder: (context, i) {
          return HomeCard(mangaPaths[i]);
        },
      )
    );
  }

}
