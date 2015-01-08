//
//  ImageStreamConvertorFactory.m
//  WebP
//
//  Created by LiangJin on 1/6/15.
//  Copyright (c) 2015 LiangJin. All rights reserved.
//

#import "ImageStreamConvertorFactory.h"
#import "PngStreamConvertor.h"

@implementation ImageStreamConvertorFactory


+ (id<ImageStreamConvertor>)convertorWithType:(WebPConverterType)type
                                        width:(int)width
                                       height:(int)height
                                     hasAlpha:(BOOL)hasAlpha;
{
    id<ImageStreamConvertor> convertor = nil;
    switch (type)
    {
        case EWebPConverter_toPNG:
            convertor = [[PngStreamConvertor alloc] initWithWidth:width
                                                   height:height
                                                 hasAlpha:hasAlpha];
            break;
        default:
            assert(0);
            break;
    }
    return [convertor autorelease];
}



@end
