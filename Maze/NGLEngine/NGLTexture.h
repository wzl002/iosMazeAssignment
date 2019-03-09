//
//  NGLTexture.h
//  Maze
//
//  Created by Zilong Wang on 2019/3/8.
//  Copyright © 2019年 bcit. All rights reserved.
//

#ifndef NGLTexture_h
#define NGLTexture_h


typedef enum
{
    NGLTextureQualityNearest        = 0x01,
    NGLTextureQualityBilinear        = 0x02,
    NGLTextureQualityTrilinear        = 0x03,
} NGLTextureQuality;

typedef enum
{
    NGLTextureRepeatNormal            = 0x01,
    NGLTextureRepeatMirrored        = 0x02,
    NGLTextureRepeatNone            = 0x03,
} NGLTextureRepeat;

typedef enum
{
    NGLTextureOptimizeAlways        = 0x01,
    NGLTextureOptimizeRGBA            = 0x02,
    NGLTextureOptimizeRGB            = 0x03,
    NGLTextureOptimizeNone            = 0x04,
} NGLTextureOptimize;


@interface NGLTexture : NSObject

@property (nonatomic) NSString *filePath;
@property (nonatomic) NGLTextureQuality quality;
@property (nonatomic) NGLTextureRepeat repeat;
//    @property (nonatomic) NGLTextureOptimize optimize;

- (id) initWithFilePath:(NSString *) filePath;

@end


#endif /* NGLTexture_h */
