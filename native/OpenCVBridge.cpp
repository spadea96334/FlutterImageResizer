#include "OpenCVBridge.h"

#include <opencv2/opencv.hpp>

bool checkNeedResize(cv::Mat image, Config *config);

bool resizeImage(Config *config) {
  cv::Mat image = cv::imread(config->file, cv::IMREAD_UNCHANGED);

  if (image.data == NULL) {
    return false;
  }

  cv::Size size;

  if (config->width != 0 && config->height != 0) {
    size.width = config->width;
    size.height = config->height;
  }

  if (checkNeedResize(image, config)) {
    cv::Mat resizedImage;
    cv::resize(image, resizedImage, size, config->scaleX, config->scaleY, config->filter);
    image = resizedImage;
  }

  std::vector<int> compressionParams;

  return cv::imwrite(config->dst, image, compressionParams);
}

bool checkNeedResize(cv::Mat image, Config *config) {
  if (config->policy == always) {
    return true;
  }

  if (config->policy == reduce) {
    if (image.size().width < config->width && config->width != 0) {
      return false;
    }

    if (image.size().height < config->height && config->height != 0) {
      return false;
    }

    return true;
  } else if (config->policy == enlarge) {
    if (image.size().width > config->width && config->width != 0) {
      return true;
    }

    if (image.size().height > config->height && config->height != 0) {
      return false;
    }

    return true;
  }

  return false;
}
