#include "stdio.h"

#ifdef _WIN32
#define EXPORT __declspec(dllexport)
extern "C" {
#else
#define EXPORT extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

enum resizePolicy { always, reduce, enlarge };
enum sizeUnit { pixel, scale };

struct Config {
  wchar_t *file;
  wchar_t *dst;
  sizeUnit unit;
  int width;
  int height;
  int filter;
  int jpgQuality;
  int pngCompression;
  int policy;
};

// EXPORT bool resizeImage(char *path, char *dst, int width, int height, double scaleX, double scaleY, int interpolation);
EXPORT bool resizeImage(Config *config);
EXPORT void initFPrint(void (*printCallback)(char *));

#ifdef _WIN32
}
#endif
