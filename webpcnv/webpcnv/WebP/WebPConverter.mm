//
//  WebPConverter.m
//  WebP
//
//  Created by LiangJin on 1/5/15.
//  Copyright (c) 2015 LiangJin. All rights reserved.
//

#import "WebPConverter.h"

#import "webp/decode.h"
#import "webp/encode.h"

#import "ImageStreamConvertor.h"
#import "ImageStreamConvertorFactory.h"

enum WebPCovertState
{
    ECovertState_Header,
    ECovertState_Content,
};

@interface WebPConverter ()
{
    WebPCovertState     m_state;
    NSMutableData*      m_headerBuffer;
    
    
    WebPIDecoder*       m_idec;
    WebPDecoderConfig*  m_config;
    int                 m_last_y;
    
    WebPConverterType   m_convertType;

}

@property (nonatomic,retain)NSObject<ImageStreamConvertor>* convertor;

@end



@implementation WebPConverter

- (instancetype)initWithType:(WebPConverterType)type;
{
    self = [super init];
    if (self)
    {
        m_config = new WebPDecoderConfig();
        
        WebPInitDecoderConfig(m_config);
        m_config->options.no_fancy_upsampling = true;
        
        m_convertType = type;
        
    }
    return self;
}

- (void)dealloc
{
    [_convertor release], _convertor = nil;
    
    delete m_config;
    [m_headerBuffer release], m_headerBuffer = nil;
    WebPIDelete(m_idec);
    m_idec = nil;
    
    
    [super dealloc];
}


- (NSData*)incrementalCovert:(NSData*)inputData withError:(WebPConverterError *)error
{
    NSData* result = nil;
    switch (m_state)
    {
        case ECovertState_Header:
        {
            VP8StatusCode state;
            if (m_headerBuffer == nil)
            {
                state = WebPGetFeatures((const uint8_t*)[inputData bytes]
                                  , [inputData length]
                                  , &m_config->input);
            }
            else
            {
                [m_headerBuffer appendData:inputData];
                state = WebPGetFeatures((const uint8_t*)[m_headerBuffer bytes]
                                        , [m_headerBuffer length]
                                        , &m_config->input);
            }

            if (state == VP8_STATUS_NOT_ENOUGH_DATA)
            {
                if (m_headerBuffer == nil)
                {
                    m_headerBuffer = [[NSMutableData alloc] initWithData:inputData];
                    
                }
                break;
            }
            else if (state == VP8_STATUS_OK)
            {
                // Specify the desired output colorspace:
                if (m_config->input.has_alpha)
                {
                    m_config->output.colorspace = MODE_RGBA;
                }
                else
                {
                    m_config->output.colorspace = MODE_RGB;
                }
                
                m_idec = WebPINewDecoder(&m_config->output);
                m_state = ECovertState_Content;
                
                VP8StatusCode status2;
                if (m_headerBuffer)
                {
                    status2 = WebPIAppend(m_idec
                                          , (const uint8_t*)[m_headerBuffer bytes]
                                          , [m_headerBuffer length]);
                }
                else
                {
                    status2 = WebPIAppend(m_idec
                                          , (const uint8_t*)[inputData bytes]
                                          , [inputData length]);
                }
                
                self.convertor = [ImageStreamConvertorFactory convertorWithType:m_convertType
                                                                          width:m_config->input.width
                                                                         height:m_config->input.height
                                                                       hasAlpha:m_config->input.has_alpha];
                
                result = [self dealAppendResult:status2];
            } else {
                switch (state) {
                    case VP8_STATUS_INVALID_PARAM:
                    case VP8_STATUS_BITSTREAM_ERROR:
                        *error = WebPConverterError_wrongFormat;
                        break;
                    default:
                        break;
                }
            }
            
        }
            break;
        case ECovertState_Content:
        {
            VP8StatusCode status = WebPIAppend(m_idec
                                               , (const uint8_t*)[inputData bytes]
                                               , [inputData length]);
            result = [self dealAppendResult:status];
        }
            break;
        default:
            assert(0);
            break;
    }
    return result;
}

- (NSData*)dealAppendResult:(VP8StatusCode)status
{
    NSData* result = nil;
    if (status == VP8_STATUS_OK || status == VP8_STATUS_SUSPENDED)
    {
        int last_y, width, height, stride;
        uint8_t* argb = WebPIDecGetRGB(m_idec, &last_y, &width, &height, &stride);
        if (argb)
        {
            int increaseY = last_y - m_last_y;
            
            if (increaseY > 0)
            {
                int startRow = m_last_y;
                m_last_y = last_y;
                int rows = increaseY;
                uint8_t* startRowPtr = argb + startRow * stride;

                result = [self.convertor pushRowsData:startRowPtr
                                                 rows:rows
                                               stride:stride];
            }
        }
    }

    return result;
}

- (NSData*)finishPushData
{
    return [self.convertor finishPushData];
}

@end
