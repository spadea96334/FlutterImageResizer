#include "stdio.h"
#define EXPORT extern "C" __attribute__((visibility("default"))) __attribute__((used))

EXPORT bool resizeImage(char *path, char *dst, int width, int height, double scaleX, double scaleY, int interpolation);
