#include "OpenCVBridge.h"

#ifdef _WIN32
#include <Windows.h>
#endif

#include <filesystem>
#include <iostream>
#include <opencv2/opencv.hpp>

bool checkNeedResize(cv::Mat image, Config *config);
cv::Size calSize(cv::Mat image, Config *config);
cv::Mat readFile(Config *config);
bool writeFile(cv::Mat image, Config *config);
std::vector<int> spawnWriteParams(Config *config);
std::wstring convertToUTF16(const char *utf8Str);

bool resizeImage(Config *config) {
  cv::Mat image;

  image = readFile(config);

  if (image.data == NULL) {
    return false;
  }

  if (checkNeedResize(image, config)) {
    cv::Size size = calSize(image, config);
    cv::Mat resizedImage;

    if (config->unit == pixel) {
      cv::resize(image, resizedImage, size, 0, 0, config->filter);
    } else {
      cv::resize(image, resizedImage, size, (double)config->width / 100, (double)config->height / 100, config->filter);
    }

    image = resizedImage;
  } else if (!config->force) {
    return true;
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

  FILE *f = _wfopen(convertToUTF16(config->file).c_str(), L"rb");
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
  std::filesystem::path filePath(convertToUTF16(config->dst).c_str());
  std::vector<int> params = spawnWriteParams(config);
  cv::imencode(filePath.extension().string().c_str(), image, encode, params);
  std::wstring utf16Dst = convertToUTF16(config->dst);
  if (utf16Dst.empty()) {
    return false;
  }
  FILE *f = _wfopen(utf16Dst.c_str(), L"wb");
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
  std::wstring utf16Dst = convertToUTF16(config->dst);
  if (utf16Dst.empty()) {
    return params;
  }

  std::filesystem::path filePath(utf16Dst);
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

std::wstring convertToUTF16(const char *utf8Str) {
  int utf16Length = MultiByteToWideChar(CP_UTF8, 0, utf8Str, -1, NULL, 0);
  if (utf16Length == 0) {
    std::cerr << "Failed to convert UTF-8 to UTF-16." << std::endl;
    return L"";
  }

  std::wstring utf16Str(utf16Length, L'\0');
  MultiByteToWideChar(CP_UTF8, 0, utf8Str, -1, &utf16Str[0], utf16Length);
  return utf16Str;
}
