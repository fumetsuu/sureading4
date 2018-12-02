const String bookmarkPrefix = 'bkmk||';

bool isImage(String path) {
  RegExp imageRegex = RegExp(".png\$|.jpg\$|.jpeg\$", caseSensitive: false);
  return imageRegex.hasMatch(path);
}

//get manga title from volume path
String getMangaTitle(String path) {
  List<String> splits = path.split('/');
  return splits[splits.length - 2];
}

//get volume title from volume path
String getVolumeTitle(String path) {
  List<String> splits = path.split('/');
  return splits[splits.length - 1];
}