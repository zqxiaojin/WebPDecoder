//
//  ImageStreamConvertor.h
//  WebP
//
//  Created by LiangJin on 1/6/15.
//  Copyright (c) 2015 LiangJin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImageStreamConvertor <NSObject>

- (instancetype)initWithWidth:(int)width
                       height:(int)height
                     hasAlpha:(BOOL)hasAlpha;

- (NSData*)pushRowsData:(const unsigned char*)startRowPtr
                   rows:(int)rows
                 stride:(int)stride;

- (NSData*)finishPushData;

@end