enum ImageFormat {
  jpg,
  png,
  origin;
}

class ImageResizer {
  ImageResizer._private();

  static final ImageResizer _singleton = ImageResizer._private();
  List<String> fileList = [];
  ImageFormat imageFormat = ImageFormat.origin;
  int imageWidth = 0;
  int imageHeight = 0;

  factory ImageResizer() {
    return _singleton;
  }
}
