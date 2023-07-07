#include "stdio.h"
#define EXPORT extern "C" __attribute__((visibility("default"))) __attribute__((used))

struct Config {
  char *file;
  char *dst;
  int width;
  int height;
  double scaleX;
  double scaleY;
  int filter;
  int jpgQuality;
  int pngCompression;
};

// EXPORT bool resizeImage(char *path, char *dst, int width, int height, double scaleX, double scaleY, int interpolation);
EXPORT bool resizeImage(Config *config);
