import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/src/photo_view_scale_state.dart';

import '../colours.dart';
import '../util.dart';

class ReadingPage extends StatefulWidget {
  final String volumePath;
  final String volumeTitle;

  ReadingPage(this.volumePath, this.volumeTitle);

  @override
    State<StatefulWidget> createState() {
      return ReadingPageState();
    }
}

class ReadingPageState extends State<ReadingPage> {

  PageController _pageController;
  bool _scrollLocked = false;
  bool _controlsShowing = false;

  final List<String> imagePaths = [];
  int currentPage = 0; //actual page (counting from 1) = currentPage + 1

  void initState() {
    _populateImagePathsList();
    //TODO: set currentPage to page number saved in bookmarks
    _pageController = PageController(initialPage: currentPage);
    SystemChrome.setEnabledSystemUIOverlays([]);


    super.initState();
  }

  Widget build(BuildContext context) {
    if(imagePaths.isEmpty) {
      return Scaffold(
        body: Center(child: Text('loading...', style: Theme.of(context).primaryTextTheme.headline))
      );
    } else {
      return Scaffold(
          body: GestureDetector(
            onTapUp: _handleTap,
            child: Container(
              color: grey,
              child: PageView.builder(
                controller: _pageController,
                physics: _scrollLocked ? NeverScrollableScrollPhysics() : ScrollPhysics(),
                itemCount: imagePaths.length,
                reverse: true,
                onPageChanged: _handlePageChange,
                itemBuilder: (context, i) {
                  return PhotoView(
                    imageProvider: FileImage(File(imagePaths[i])),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.contained * 2.5,
                    scaleStateChangedCallback: _checkScaleState,
                  );
                },
              )
            )
          )
      );
    }
  }

  void _populateImagePathsList() {
    Directory(widget.volumePath).list().forEach((FileSystemEntity entity) {
      if(isImage(entity.path)) imagePaths.add(entity.path);
    }).then((_) {
      imagePaths.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      setState(() {});
    });
  }

  void _checkScaleState(PhotoViewScaleState scaleState) {
    setState(() {
      _scrollLocked = scaleState != PhotoViewScaleState.initial;
    });
  }

  void _handlePageChange(int pageIndex) {
    currentPage = pageIndex + 1; //don't re-render
  }

  void _handleTap(TapUpDetails details) {
    double screenWidth = MediaQuery.of(context).size.width;
    double dx = details.globalPosition.dx;
    
    if(dx < 30) {
      //go next page (user has tapped to the left of the screen)
      setState(() {
        currentPage++;
        _pageController.jumpToPage(currentPage);
      });
    } else if(dx > screenWidth - 30) {
      //go prev page (user has tapped to the right of the screen)
      setState(() {
        currentPage--;
        _pageController.jumpToPage(currentPage);
      });
    } else {
      //show controls (user has tapped in the middle of the screen)
      setState(() {
        _controlsShowing = !_controlsShowing;
      });
      SystemChrome.setEnabledSystemUIOverlays(_controlsShowing ? SystemUiOverlay.values : []);
    }
    
    
  }

}