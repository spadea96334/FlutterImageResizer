#include "stdio.h"

#ifdef _WIN32
#define EXPORT __declspec(dllexport)
extern "C" {
#else
#define EXPORT extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

enum resizePolicy { always, reduce, enlarge };

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
  int policy;
};

// EXPORT bool resizeImage(char *path, char *dst, int width, int height, double scaleX, double scaleY, int interpolation);
EXPORT bool resizeImage(Config *config);
#ifdef _WIN32
}
#endif
