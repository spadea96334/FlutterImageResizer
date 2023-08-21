#include "OpenCVBridge.h"

#include <filesystem>
#include <opencv2/opencv.hpp>

bool checkNeedResize(cv::Mat image, Config *config);
cv::Size calSize(cv::Mat image, Config *config);
void (*fPrint)(char *);

bool resizeImage(Config *config) {
  std::filesystem::path filePath{std::filesystem::u8path(config->file)};
  std::filesystem::path dstPath{std::filesystem::u8path(config->dst)};

  cv::Mat image = cv::imread(filePath.string(), cv::IMREAD_UNCHANGED);

  if (image.data == NULL) {
    return false;
  }

  cv::Size size = calSize(image, config);

  if (checkNeedResize(image, config)) {
    cv::Mat resizedImage;
    if (config->unit == pixel) {
      cv::resize(image, resizedImage, size, 0, 0, config->filter);
    } else {
      cv::resize(image, resizedImage, size, (double)config->width / 100, (double)config->height / 100, config->filter);
    }

    image = resizedImage;
  }

  std::vector<int> compressionParams;

  return cv::imwrite(dstPath.string(), image, compressionParams);
}

cv::Size calSize(cv::Mat image, Config *config) {
  cv::Size size;

  if (config->unit == scale) {
    return size;
  }

  if (config->width != 0 && config->height != 0) {
    size.width = config->width;
    size.height = config->height;
    return size;
  }

  if (config->width == 0) {
    double scale = (double)config->height / image.size().height;
    size.height = config->height;
    size.width = cv::saturate_cast<int>(image.size().width * scale);
  } else if (config->height == 0) {
    double scale = (double)config->width / image.size().width;
    size.width = config->width;
    size.height = cv::saturate_cast<int>(image.size().height * scale);
  }

  return size;
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

void initFPrint(void (*printCallback)(char *)) { fPrint = printCallback; }
