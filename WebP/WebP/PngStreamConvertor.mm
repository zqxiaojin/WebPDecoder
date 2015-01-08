//
//  PngStreamConvertor.m
//  WebP
//
//  Created by LiangJin on 1/6/15.
//  Copyright (c) 2015 LiangJin. All rights reserved.
//

#import "PngStreamConvertor.h"

#import "png.h"

@interface PngStreamConvertor ()
{
    png_structp     m_png_ptr;
    png_infop       m_info_ptr;
    png_bytep       m_row;
    
    int             m_width;
    int             m_height;
    int             m_hasAlpha;
}

@property (nonatomic,retain) NSMutableData* pngBufferData;
- (void)receivePngData:(const unsigned char*)data length:(int)length;

@end


void my_png_write_data(png_structp png_ptr
                       , png_bytep data
                       , png_size_t length)
{
    //    /* with libpng15 next line causes pointer deference error; use libpng12 */
    PngStreamConvertor* covert = (PngStreamConvertor*)png_get_io_ptr(png_ptr); /* was png_ptr->io_ptr */
    [covert receivePngData:data length:length];
}

@implementation PngStreamConvertor

- (instancetype)initWithWidth:(int)width
                       height:(int)height
                     hasAlpha:(BOOL)hasAlpha;
{
    self = [super init];
    if (self)
    {
        m_width = width;
        m_height = height;
        m_hasAlpha = hasAlpha;
    }
    return self;
}

- (void)dealloc
{
    [_pngBufferData release], _pngBufferData = nil;
    png_destroy_info_struct(m_png_ptr, &m_info_ptr);
    png_destroy_write_struct(&m_png_ptr, &m_info_ptr);
    
    [super dealloc];
}

- (void)configPngIfNeeded
{
    if (m_png_ptr == nil)
    {
        m_png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
        
        m_info_ptr = png_create_info_struct(m_png_ptr);
        
        
        png_set_IHDR(m_png_ptr
                     , m_info_ptr
                     , m_width
                     , m_height
                     , 8
                     , m_hasAlpha ? PNG_COLOR_TYPE_RGB_ALPHA : PNG_COLOR_TYPE_RGB
                     , PNG_INTERLACE_NONE
                     , PNG_COMPRESSION_TYPE_BASE
                     , PNG_FILTER_TYPE_BASE);
        
        png_set_write_fn(m_png_ptr, self, my_png_write_data, NULL);
        
        png_write_info(m_png_ptr, m_info_ptr);
    }
}

- (NSData*)finishPushData
{
    NSData* result = nil;
    png_write_end(m_png_ptr, m_info_ptr);
    if (self.pngBufferData)
    {
        result = [[self.pngBufferData retain] autorelease];
        self.pngBufferData = nil;
    }
    return result;
}

- (NSData*)pushRowsData:(const unsigned char*)startRowPtr
                   rows:(int)rows
                 stride:(int)stride;
{
    NSData* result = nil;
    [self configPngIfNeeded];
    
    for (int i = 0; i < rows; ++i)
    {
        png_write_row(m_png_ptr, startRowPtr + i * stride);
    }
    
    
    if (self.pngBufferData)
    {
        result = [[self.pngBufferData retain] autorelease];
        self.pngBufferData = nil;
    }
    return result;
}

- (void)receivePngData:(const unsigned char*)data length:(int)length
{
    if (self.pngBufferData == nil)
    {
        self.pngBufferData = [[[NSMutableData alloc] initWithBytes:data length:length] autorelease];
    }
    else
    {
        [self.pngBufferData appendBytes:data length:length];
    }
}


@end
