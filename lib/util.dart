bool isImage(String path) {
  RegExp imageRegex = RegExp(".png\$|.jpg\$|.jpeg\$", caseSensitive: false);

  return imageRegex.hasMatch(path);
}