//
//  CAOpenCVWrapper.h
//  CACamProcessor
//
//  Created by Carol on 2019/4/12.
//  Copyright © 2019 Carol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface CAOpenCVWrapper : NSObject
@property (nonatomic) void (^completed)(UIImage * _Nullable);
+ (NSString *)openCVVersionString;
- (UIImage *)grayImage: (UIImage *)srcImage;
- (UIImage *)otsuImage:(UIImage *)srcImage;
@end

NS_ASSUME_NONNULL_END
