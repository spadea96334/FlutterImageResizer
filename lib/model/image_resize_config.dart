enum ImageFormat {
  jpg('jpg'),
  png('png'),
  bmp('bmp'),
  origin('');

  const ImageFormat(this.extension);
  final String extension;
}

enum Interpolation {
  nearest(0),
  linear(1),
  cubic(2),
  area(3),
  lanczos4(4),
  linearExact(5),
  nearestExact(6);

  const Interpolation(this.value);
  final int value;
}

class ImageResizeConfig {
  int height = 0;
  int width = 0;
  ImageFormat imageFormat = ImageFormat.origin;
  Interpolation filter = Interpolation.area;
  int jpgQuality = 95;
  int pngCompression = 1;
}
