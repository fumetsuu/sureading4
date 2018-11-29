import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:async';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/src/photo_view_scale_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _showGridview = false;
  TimeOfDay currTime = TimeOfDay.now();
  Timer timer;

  final List<String> imagePaths = [];
  int currentPage = 0; //actual page (counting from 1) = currentPage + 1

  void initState() {
    _populateImagePathsList();
    _loadBookmark();

    RawKeyboard.instance.addListener(_keyboardListener);
  
    SystemChrome.setEnabledSystemUIOverlays([]);

    _initTimer();
    super.initState();
  }

  void dispose() {
    timer.cancel();
    _pageController.dispose();
    RawKeyboard.instance.removeListener(_keyboardListener);
    super.dispose();
  }

  void _keyboardListener(RawKeyEvent e) {
    if(e.runtimeType == RawKeyUpEvent) {
      RawKeyEventDataAndroid eA = e.data;
      if(eA.keyCode == 24) { //volume up key
        _goNextPage();
      }
      if(eA.keyCode == 25) { //volume down key
        _goPrevPage();
      }
    }
  }

  Widget build(BuildContext context) {
    if (imagePaths.isEmpty) {
      return Scaffold(
          body: Center(
              child: Text('loading...',
                  style: Theme.of(context).primaryTextTheme.headline)));
    } else if(_showGridview) {
      return WillPopScope(
        onWillPop: _handleGridBack,
        child: Scaffold(
          body: Container(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: MediaQuery.of(context).size.width*0.3, childAspectRatio: 0.6),
              itemCount: imagePaths.length,
              itemBuilder: (context, i) {
                return GestureDetector(
                  onTap: () => _handleGridPageTapped(i),
                  child: Container(
                    color: currentPage == i ? lightblue : Colors.transparent,
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Text((i+1).toString(), style: Theme.of(context).primaryTextTheme.button),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.19,
                          child: Image(image: FileImage(File(imagePaths[i])),
                                  gaplessPlayback: true),
                        )
                      ],
                    )
                  )
                );
              },
            )
          )
        )
      );
    } else {
      //viewportFraction hack to allow adjacent pages to load before scrolling
      _pageController = PageController(initialPage: currentPage, viewportFraction: 0.999);
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

  void _loadBookmark() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentPage = prefs.getInt(widget.volumePath) ?? 0;
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
      _goNextPage();
    } else if (dx > screenWidth - 30) {
      //go prev page (user has tapped to the right of the screen)
      _goPrevPage();
    } else {
      //show controls (user has tapped in the middle of the screen)
      setState(() {
        _controlsShowing = !_controlsShowing;
      });
      SystemChrome.setEnabledSystemUIOverlays(
          _controlsShowing ? SystemUiOverlay.values : []);
    }
  }

  void _goNextPage() {
    setState(() {
      currentPage++;
      _pageController.nextPage(
          duration: Duration(microseconds: 1), curve: Threshold(0));
    });
  }

  void _goPrevPage() {
    setState(() {
      currentPage--;
      _pageController.previousPage(
          duration: Duration(microseconds: 1), curve: Threshold(0));
    });
  }

  Widget _buildControls() {
    if (!_controlsShowing) return Container();
    
    return Builder(
      builder: (context) => Positioned(
        bottom: 0,
        left: 0,
        width: MediaQuery.of(context).size.width,
        height: 94,
        child: Container(
            color: black.withAlpha(200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Slider(
                    label: (currentPage+1).toString()+'/'+imagePaths.length.toString(),
                    activeColor: lightblue,
                    value: currentPage.toDouble()+1,
                    min: 1,
                    max: imagePaths.length.toDouble(),
                    divisions: imagePaths.length,
                    onChanged: _handleSliderChange,
                    onChangeEnd: _handleSliderChangeEnd,
                    inactiveColor: lightgrey,
                  ),
                  padding: EdgeInsets.all(6.0),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.0),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.view_module),
                        splashColor: lightblue,
                        onPressed: _showPagesGridview,
                      ),
                      IconButton(
                        icon: Icon(Icons.bookmark),
                        splashColor: lightblue,
                        onPressed: () { _bookmarkPage(context); }
                      )
                    ]
                  )
                )
              ]
            )
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

  void _showPagesGridview() {
    setState(() {
      _showGridview = true;
    });
  }

  Future<bool> _handleGridBack() {
    setState(() {
      _showGridview = false;    
    });
    return Future.value(false);
  }

  void _handleGridPageTapped(int index) {
    setState(() {
      currentPage = index;
      _showGridview = false;
    });
  }

  void _bookmarkPage(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(widget.volumePath, currentPage);
    await prefs.setStringList('lastRead', [widget.volumePath, currentPage.toString()]);

    final snackBar = SnackBar(content: Text('Bookmarked page ' + currentPage.toString()), duration: Duration(seconds: 1),backgroundColor: Color.fromARGB(150, 0, 0, 0));
    Scaffold.of(context).showSnackBar(snackBar);
  }

}
