#include "OpenCVBridge.h"

#ifdef _WIN32
#include <Windows.h>
#endif

#include <filesystem>
#include <iostream>
#include <opencv2/opencv.hpp>

bool checkNeedResize(cv::Mat image, Config *config);
cv::Size calSize(cv::Mat image, Config *config);
void (*fPrint)(char *);
cv::Mat readFile(Config *config);
bool writeFile(cv::Mat image, Config *config);
std::vector<int> spawnWriteParams(Config *config);

bool resizeImage(Config *config) {
  cv::Mat image;

  image = readFile(config);

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

  return writeFile(image, config);
}

cv::Mat cvReadFile(Config *config) { return cv::imread(config->file, cv::IMREAD_UNCHANGED); }

cv::Mat readFile(Config *config) {
#ifndef _WIN32
  return cvReadFile(config);
#else
  UINT code = GetACP();
  if (code == 65001) {
    return cvReadFile(config);
  }

  FILE *f = _wfopen(config->file_utf16, L"rb");
  if (f == NULL) {
    return cv::Mat();
  }

  fseek(f, 0, SEEK_END);
  long length = ftell(f);
  char *buff = new char[length];
  fseek(f, 0, SEEK_SET);
  fread(buff, 1, length, f);
  cv::Mat rawMat(1, length, CV_8UC1, buff);
  cv::Mat mat = cv::imdecode(rawMat, cv::IMREAD_UNCHANGED);

  delete[] buff;
  fclose(f);

  return mat;
#endif
}

bool cvWriteFile(cv::Mat image, Config *config) {
  std::vector<int> params = spawnWriteParams(config);

  return cv::imwrite(config->dst, image, params);
}

bool writeFile(cv::Mat image, Config *config) {
#ifndef _WIN32
  return cvWriteFile(image, config);
#else
  UINT code = GetACP();
  if (code == 65001) {
    return cvWriteFile(image, config);
  }

  std::vector<uchar> encode;
  std::filesystem::path filePath(config->dst_utf16);
  std::vector<int> params = spawnWriteParams(config);

  cv::imencode(filePath.extension().string().c_str(), image, encode, params);
  FILE *f = _wfopen(config->dst_utf16, L"wb");

  if (f == NULL) {
    return false;
  }

  fwrite(encode.data(), sizeof(uchar), encode.size(), f);
  fclose(f);

  return true;
#endif
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

std::vector<int> spawnWriteParams(Config *config) {
  std::vector<int> params;
  std::filesystem::path filePath(config->dst);
  const char *ext = filePath.extension().string().c_str();

  if (ext == ".png") {
    params.push_back(cv::IMWRITE_PNG_COMPRESSION);
    params.push_back(config->pngCompression);
  } else if (ext == ".jpg") {
    params.push_back(cv::IMWRITE_JPEG_QUALITY);
    params.push_back(config->jpgQuality);
  }

  return params;
}

void initFPrint(void (*printCallback)(char *)) { fPrint = printCallback; }
