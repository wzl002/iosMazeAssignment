//
//  NGLTexture.m
//  Maze
//
//  Created by Zilong Wang on 2019/3/8.
//  Copyright © 2019年 bcit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NGLTexture.h"

@interface NGLTexture ()


@end

#pragma mark Public Interface

@implementation NGLTexture

- (id) initWithFilePath:(NSString *) filePath
{
    if ((self = [super init]))
    {
        _filePath = filePath;
        _quality = NGLTextureQualityNearest;
        _repeat = NGLTextureRepeatNormal;
        // _optimize; // = NGLTextureOptimizeAlways;
    }
    return self;
}

@end
