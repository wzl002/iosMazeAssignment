//
//  PlayerRenderer.m
//  MoneyDrive
//
//  Created by Zilong Wang on 2019/2/12.
//  Copyright © 2019 bcit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "ObjSample.h"
#include <chrono>
#import <OpenGLES/ES2/glext.h>
#import "Model3D.h"
#import "NGLShader.h"
#import "NGLTextureCache.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@interface ObjSample () 

@end

@implementation ObjSample

- (id) initWithShader:(NGLShader *)shader {
    
    if ((self = [super initWithObjFiles:shader objFile: @"sample.obj" mtlFile:@"sample.mtl" textureImageFile:@"sample.jpg"])) {
        
    }
    return  self;
}

@end

