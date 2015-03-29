//
//  WebPConverter.h
//  WebP
//
//  Created by LiangJin on 1/5/15.
//  Copyright (c) 2015 LiangJin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    EWebPConverter_toPNG,
    EWebPConverter_notSupport
} WebPConverterType;

typedef enum : NSUInteger {
    WebPConverterError_None,
    WebPConverterError_wrongFormat,
//    EWebPConverter_notSupport
} WebPConverterError;



@interface WebPConverter : NSObject

- (instancetype)initWithType:(WebPConverterType)type;


- (NSData*)incrementalCovert:(NSData*)inputData withError:(WebPConverterError*)error;

- (NSData*)finishPushData;

@end
