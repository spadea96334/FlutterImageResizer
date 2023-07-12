#include "OpenCVBridge.h"

#include <opencv2/opencv.hpp>

bool resizeImage(Config *config) {
  cv::Mat image = cv::imread(config->file, cv::IMREAD_UNCHANGED);

  if (image.data == NULL) {
    return false;
  }

  cv::Mat resizedImage;

  cv::Size size;

  if (config->width != 0 && config->height != 0) {
    size.width = config->width;
    size.height = config->height;
  }

  cv::resize(image, resizedImage, size, config->scaleX, config->scaleY, config->filter);
  std::vector<int> compression_params;

  cv::imwrite(config->dst, resizedImage, compression_params);

  return true;
}
