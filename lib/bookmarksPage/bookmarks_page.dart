import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import '../readingPage/reading_page.dart';
import '../util.dart';

class BookmarksPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BookmarksPageState();
  }
}

class BookmarksPageState extends State<BookmarksPage> {
  List<List<String>> bookmarks = [];

  void initState() {
    _getBookmarks();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bookmarks')),
      body: bookmarks.length == 0
          ? Center(child: Text('Loading...',
              style: Theme.of(context).primaryTextTheme.headline))
          : ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            itemCount: bookmarks.length,
            itemBuilder: (context, i) {
              return ListTile(
                contentPadding: EdgeInsets.fromLTRB(12.0, 24.0, 12.0, 24.0),
                leading: Image(image: FileImage(File(bookmarks[i][3])), width: 65),
                title: Text(getMangaTitle(bookmarks[i][0]) + ' - ' + getVolumeTitle(bookmarks[i][0])),
                subtitle: Text('pg. ' + bookmarks[i][1] + ' | ' + bookmarks[i][2]),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ReadingPage(bookmarks[i][0], getVolumeTitle(bookmarks[i][0]))));
                },
              );
            },
            separatorBuilder: (context , i) {
              return SizedBox(height: 0.5, child: Container(color: Colors.grey));
            },
            ),
    );
  }

  void _getBookmarks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> prefKeys = prefs.getKeys().toSet();
    prefKeys.removeWhere((String key) => !key.startsWith(bookmarkPrefix));
    prefKeys.forEach((String key) {
        List<String> bookmark =  prefs.getStringList(key).toList();
          Directory(bookmark[0]).list().firstWhere((FileSystemEntity entity) => isImage(entity.path)).then((FileSystemEntity entity) {
            bookmark.add(entity.path);
            bookmarks.insert(0, bookmark);   
            if(bookmarks.length == prefKeys.length) {
              bookmarks.sort((a, b) {
                return b[2].compareTo(a[2]);
              });
              setState(() {});
            }       
        });
    });
  }
}
