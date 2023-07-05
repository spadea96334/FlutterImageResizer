import 'package:image/image.dart';

enum ImageFormat {
  jpg('jpg'),
  png('png'),
  bmp('bmp'),
  origin('');

  const ImageFormat(this.extension);
  final String extension;
}

class ImageResizeConfig {
  int height = 0;
  int width = 0;
  ImageFormat imageFormat = ImageFormat.origin;
  Interpolation filter = Interpolation.average;
}
