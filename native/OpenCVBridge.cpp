#include "OpenCVBridge.h"
#include <opencv.hpp>

bool resizeImage(char *path, char *dst, int width, int height, double scaleX, double scaleY, int interpolation)
{
    cv::Mat image = cv::imread(path, cv::IMREAD_UNCHANGED);

    if (image.data == NULL) {
        return false;
    }

    cv::Mat resizedImage;

    cv::Size size;

    if (width != 0 || height != 0) {
        size.width = width;
        size.height = height;
    }

    cv::resize(image, resizedImage, size, scaleX, scaleY, cv::INTER_CUBIC);

    std::vector<int> compression_params;

    cv::imwrite(dst, resizedImage, compression_params);

    return true;
}
