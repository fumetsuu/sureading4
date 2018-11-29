import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import '../colours.dart';
import './home_card.dart';
import '../readingPage/reading_page.dart';
import '../card/card_gridview_builder.dart';
import '../util.dart';

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

  String lastReadTitle;
  String lastReadVolume;
  String lastReadPath;
  String lastReadImgPath;
  int lastReadPage;

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
      _getLastReadDetails();

      return Scaffold(
        appBar: AppBar(
            title: Text('sureading',
                style: Theme.of(context).primaryTextTheme.headline)),
                drawer: Drawer(
                  child: ListView(
                    itemExtent: MediaQuery.of(context).size.height*0.2,
                    children: <Widget>[
                      Container(
                        color: Color.fromARGB(150, 22, 22, 22),
                        child: InkWell(
                          onTap: lastReadPath == null ? null : () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ReadingPage(lastReadPath, lastReadTitle)));
                          },
                          child: Container(
                            padding: EdgeInsets.all(12.0),
                            child: Row(
                              children: <Widget>[
                                Image(image: lastReadImgPath == null ? AssetImage('assets/placeholder.jpg') : FileImage(File(lastReadImgPath))),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text('Continue Reading...', style: Theme.of(context).primaryTextTheme.subtitle),
                                      Text(lastReadPath == null ? 'Bookmark a page!' : '$lastReadTitle - $lastReadVolume\npg.${lastReadPage.toString()}', style: Theme.of(context).primaryTextTheme.body2),
                                    ],
                                  )
                                )
                              ]
                            )
                          )
                        )
                      )
                    ],
                  )
                ),
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

  void _getLastReadDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> lastReadDetails = prefs.getStringList('lastRead');
    if(lastReadDetails != null) {
      Directory(lastReadDetails[0]).list().firstWhere((FileSystemEntity entity) => isImage(entity.path)).then((FileSystemEntity entity) {
        setState(() {
          lastReadImgPath = entity.path;
          lastReadPath = lastReadDetails[0];
          lastReadPage = int.tryParse(lastReadDetails[1]);
          lastReadTitle = lastReadPath.split('/')[lastReadPath.split('/').length-2];
          lastReadVolume = lastReadPath.split('/')[lastReadPath.split('/').length-1];  
        });
      });
    }
  }

}
