//
//  PngStreamConvertor.h
//  WebP
//
//  Created by LiangJin on 1/6/15.
//  Copyright (c) 2015 LiangJin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageStreamConvertor.h"

@interface PngStreamConvertor : NSObject<ImageStreamConvertor>

- (instancetype)initWithWidth:(int)size
                       height:(int)height
                     hasAlpha:(BOOL)hasAlpha;

@end
