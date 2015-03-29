//
//  ImageStreamConvertorFactory.h
//  WebP
//
//  Created by LiangJin on 1/6/15.
//  Copyright (c) 2015 LiangJin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WebPConverter.h"
#import "ImageStreamConvertor.h"

@interface ImageStreamConvertorFactory : NSObject

+ (id<ImageStreamConvertor>)convertorWithType:(WebPConverterType)type
                                        width:(int)width
                                       height:(int)height
                                     hasAlpha:(BOOL)hasAlpha;

@end
