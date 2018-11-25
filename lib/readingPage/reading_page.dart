import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:async';
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
  TimeOfDay currTime = TimeOfDay.now();
  Timer timer;

  final List<String> imagePaths = [];
  int currentPage = 0; //actual page (counting from 1) = currentPage + 1

  void initState() {
    _populateImagePathsList();
    //TODO: set currentPage to page number saved in bookmarks
    //viewportFraction hack to allow adjacent pages to load before scrolling
    _pageController =
        PageController(initialPage: currentPage, viewportFraction: 0.99);

    SystemChrome.setEnabledSystemUIOverlays([]);

    _initTimer();

    super.initState();
  }

  void dispose() {
    timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    if (imagePaths.isEmpty) {
      return Scaffold(
          body: Center(
              child: Text('loading...',
                  style: Theme.of(context).primaryTextTheme.headline)));
    } else {
      return Scaffold(
          body: GestureDetector(
              onTapUp: _handleTap,
              child: Stack(
                children: <Widget>[
                  Container(
                      child: PageView.builder(
                    controller: _pageController,
                    physics: _scrollLocked
                        ? NeverScrollableScrollPhysics()
                        : ScrollPhysics(),
                    itemCount: imagePaths.length,
                    reverse: true,
                    onPageChanged: _handlePageChange,
                    itemBuilder: (context, i) {
                      return PhotoView(
                        backgroundColor: grey,
                        imageProvider: FileImage(File(imagePaths[i])),
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.contained * 2.5,
                        scaleStateChangedCallback: _checkScaleState,
                      );
                    },
                  )),
                  _buildInfoBar(),
                  _buildControls()
                ],
              )));
    }
  }

  void _populateImagePathsList() {
    Directory(widget.volumePath).list().forEach((FileSystemEntity entity) {
      if (isImage(entity.path)) imagePaths.add(entity.path);
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
    setState(() {
      currentPage = pageIndex;
    });
  }

  void _initTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        currTime = TimeOfDay.now();
      });
    });
  }

  Widget _buildInfoBar() {
    if (_controlsShowing) return Container();
    int totalPages = imagePaths.length;
    return Positioned(
        top: 0,
        right: 0,
        child: Container(
          child: Text(
              '${widget.volumeTitle}  |   ${(currentPage + 1).toString()}/${totalPages.toString()}  |  ${currTime.format(context)}'),
          padding: EdgeInsets.fromLTRB(8.0, 2.0, 8.0, 2.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(4.0)),
              color: black),
        ));
  }

  void _handleTap(TapUpDetails details) {
    double screenWidth = MediaQuery.of(context).size.width;
    double dx = details.globalPosition.dx;

    if (dx < 30) {
      //go next page (user has tapped to the left of the screen)
      setState(() {
        currentPage++;
        _pageController.nextPage(
            duration: Duration(microseconds: 1), curve: Threshold(0));
      });
    } else if (dx > screenWidth - 30) {
      //go prev page (user has tapped to the right of the screen)
      setState(() {
        currentPage--;
        _pageController.previousPage(
            duration: Duration(microseconds: 1), curve: ElasticOutCurve());
      });
    } else {
      //show controls (user has tapped in the middle of the screen)
      setState(() {
        _controlsShowing = !_controlsShowing;
      });
      SystemChrome.setEnabledSystemUIOverlays(
          _controlsShowing ? SystemUiOverlay.values : []);
    }
  }

  Widget _buildControls() {
    return Positioned(
        bottom: 0,
        left: 0,
        width: MediaQuery.of(context).size.width,
        height: 120,
        child: Container(
            color: black.withAlpha(200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Slider(
                  activeColor: lightblue,
                  value: currentPage.toDouble()+1,
                  min: 1,
                  max: imagePaths.length.toDouble(),
                  divisions: imagePaths.length,
                  onChanged: _handleSliderChange,
                  onChangeEnd: _handleSliderChangeEnd,
                  inactiveColor: lightgrey,
                )
              ],
            )));
  }

  void _handleSliderChange(double val) {
    setState(() {
        currentPage = val.round() - 1;
    });
  }

  void _handleSliderChangeEnd(double val) {
    _pageController.jumpToPage(currentPage);
  }

}
