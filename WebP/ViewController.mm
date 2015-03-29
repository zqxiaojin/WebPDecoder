//
//  ViewController.m
//  WebP
//
//  Created by LiangJin on 1/5/15.
//  Copyright (c) 2015 LiangJin. All rights reserved.
//

#import "ViewController.h"
#import "WebPConverter.h"

@interface ViewController ()
@property (retain, nonatomic) IBOutlet UIImageView *showImage;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString* inputImage = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"test_alpha.webp"];
    NSData* webpData = [NSData dataWithContentsOfFile:inputImage];
    
    int maxLength = [webpData length];
    int maxPart = maxLength;
    int partLength = maxLength / maxPart;
    
    WebPConverter* c = [[WebPConverter alloc] initWithType:EWebPConverter_toPNG];
    
    NSMutableData* pngData = [NSMutableData dataWithCapacity:4];
    //模拟 分段加入二进制流
    {
        for (int i = 0 ; i < maxPart; ++i)
        {
            NSData* partData = [NSData dataWithBytes:((char*)[webpData bytes]) + i * partLength length:partLength];
            
            [pngData appendData:[c incrementalCovert:partData]];
        }
        int resetOffset = maxPart * partLength;
        int resetLength = maxLength - resetOffset;
        if (resetLength > 0)
        {
            NSData* partData = [NSData dataWithBytes:((char*)[webpData bytes]) + resetOffset
                                              length:maxLength - resetOffset];
            
            [pngData appendData:[c incrementalCovert:partData]];
        }
    }
    [pngData appendData:[c finishPushData]];
    
    [c release];
    
    UIImage* image = [UIImage imageWithData:pngData scale:3.0f];
    
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    [self.showImage setBounds:imageRect];
    [self.showImage setImage:image];
    [self.showImage setBackgroundColor:[UIColor greenColor]];
    
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_showImage release];
    [super dealloc];
}
@end
