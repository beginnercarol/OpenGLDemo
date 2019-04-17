//
//  CAOpenCVWrapper.m
//  CACamProcessor
//
//  Created by Carol on 2019/4/12.
//  Copyright © 2019 Carol. All rights reserved.
//
#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/imgproc.hpp>
#import <opencv2/highgui/highgui.hpp>
#import <opencv2/core/core_c.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CAOpenCVWrapper.hpp"
using namespace std;
@implementation CAOpenCVWrapper
+ (NSString *)openCVVersionString {
    return [NSString stringWithFormat:@"OpenCV Version: %s",CV_VERSION];
}
- (cv::Mat)cvMatFromUIImage: (UIImage *)image {
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;
}

//- (IplImage *)createIplImageFromUIImage: (UIImage *)image {
//    CGImageRef imageRef = image.CGImage;
//
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    // Creating temporal IplImage for drawing
//    IplImage *iplimage = cvCreateImage(
//                                       cvSize(image.size.width,image.size.height), IPL_DEPTH_8U, 4
//                                       );
//    // Creating CGContext for temporal IplImage
//    CGContextRef contextRef = CGBitmapContextCreate(
//                                                    iplimage->imageData, iplimage->width, iplimage->height,
//                                                    iplimage->depth, iplimage->widthStep,
//                                                    colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault
//                                                    );
//    // Drawing CGImage to CGContext
//    CGContextDrawImage(
//                       contextRef,
//                       CGRectMake(0, 0, image.size.width, image.size.height),
//                       imageRef
//                       );
//    CGContextRelease(contextRef);
//    CGColorSpaceRelease(colorSpace);
//
//    // Creating result IplImage
//    IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
//    cvCvtColor(iplimage, ret, CV_RGBA2BGR);
//    cvReleaseImage(&iplimage);
//
//    return ret;
//}

- (UIImage *)uiimageFromCVMat:(cv::Mat) mat {
    NSData *data = [NSData dataWithBytes:mat.data length:mat.elemSize()*mat.total()];
    CGColorSpaceRef colorSpace;
    if (mat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    CGImageRef imageRef = CGImageCreate(mat.cols,                                 //width
                                        mat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * mat.elemSize(),                       //bits per pixel
                                        mat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

- (UIImage *)grayImage: (UIImage *)srcImage {
    UIImage *grayImg;
    CGFloat cols = srcImage.size.width;
    CGFloat rows = srcImage.size.height;
    cv::Mat matImage = [self cvMatFromUIImage:srcImage];
    cv::Mat matGray;
    
    cv::cvtColor(matImage, matGray, cv::COLOR_BGR2GRAY);
    cv::Mat matThresh(rows, cols, CV_8UC1);
    
    double threshold = cv::threshold(matGray, matThresh, 0, 255, cv::THRESH_OTSU+cv::THRESH_BINARY);
    cv::Mat matBinary(rows, cols, CV_8UC1);
    cv::threshold(matThresh, matBinary, threshold, 255, cv::THRESH_OTSU);
    grayImg = [self uiimageFromCVMat:matBinary];
    self.completed(grayImg);
    return grayImg;
}

- (UIImage *)otsuImage:(UIImage *)srcImage {
    UIImage *otsuImg;
    CGFloat cols = srcImage.size.width;
    CGFloat rows = srcImage.size.height;
    cv::Mat matImage = [self cvMatFromUIImage: srcImage];
    cv::Mat grayImage;
    cv::cvtColor(matImage, grayImage, cv::COLOR_BGR2GRAY);
    
    cv::Mat matThresh(rows, cols, CV_8UC1);
    
    double threshold = cv::threshold(grayImage, matThresh, 0, 255, cv::THRESH_OTSU+cv::THRESH_BINARY);
    cv::Mat matBinary(rows, cols, CV_8UC1);
    cv::threshold(matThresh, matBinary, threshold, 255, cv::THRESH_OTSU);
    NSLog(@"threshold is : %f", threshold);
    //    self.completed([self uiimageFromCVMat:matBinary]);
    cv::Mat matMorphy(rows, cols, CV_8UC1);
    cv::Mat kernal = cv::Mat::ones(5, 5, CV_8UC1)*1;
    cv::morphologyEx(matBinary, matMorphy, cv::MORPH_CLOSE, kernal);
    
    cv::Mat matContour(rows, cols, CV_8UC1);
    vector<cv::Vec4i> hierarchy;
    vector<vector<cv::Point>> contours;
    cv::findContours(matMorphy, contours, hierarchy, cv::RETR_TREE, cv::CHAIN_APPROX_SIMPLE);
    cv::Mat matContours = cv::Mat::zeros(rows, cols, CV_8UC1);
    cv::Mat matMask = cv::Mat::zeros(rows, cols, CV_8UC1);
    double maxContour = cv::contourArea(contours[0]);
    int flag = 0;
    for (int i=0; i<contours.size(); i++) {
        double currentContour = cv::contourArea(contours[i]);
        if (currentContour > maxContour) {
            maxContour = currentContour;
            flag = i;
        }
        cv::Scalar color(rand()&255, rand()&255, rand()&255);
        cv::drawContours(matMask, contours, i, color, cv::FILLED, 8, hierarchy);
        for (int j=0; j<contours[i].size(); j++) {
            cv::Point2f p = cv::Point2f(contours[i][j].x, contours[i][j].y);
            
            matContours.at<uchar>(p) = 255;
        }
    }
    //    cv::Scalar color(rand()&255, rand()&255, rand()&255);
    //    cv::drawContours(matMask, contours, flag, color);
    cv::Mat matROI(rows, cols, CV_8UC1);
    cv::bitwise_and(matMorphy, matMask, matROI);
    
    UIImage *morphyImage = [self uiimageFromCVMat:matROI];
    self.completed(morphyImage);
    
    otsuImg = [self uiimageFromCVMat:matBinary];
    return otsuImg;
}

- (void)extraction:(cv::Mat) matPixel {
    int rows = matPixel.rows;
    int cols = matPixel.cols;
    if (rows > cols) {
        int temp = rows;
        rows = cols;
        cols = rows;
    }
    
    float *pixels = (float *)malloc(cols * sizeof(float));
    
    for (int i = 0; i < cols; i++) {
        pixels[i] = 0;
        for (int j = 0; j < rows; j++) {
            pixels[i] += matPixel.at<double>(i, j);
        }
    }
    // commet
}
@end
