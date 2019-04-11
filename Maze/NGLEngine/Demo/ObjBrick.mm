//
//  PlayerRenderer.m
//  MoneyDrive
//
//  Created by Zilong Wang on 2019/2/12.
//  Copyright © 2019 bcit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "ObjBrick.h"
#include <chrono>
#import <OpenGLES/ES2/glext.h>
#import "Model3D.h"
#import "NGLShader.h"
#import "NGLTextureCache.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@interface ObjBrick () {
    
}

@end

@implementation ObjBrick

- (id) initWithShader:(NGLShader *)shader {

    if ((self = [super initWithObjFiles:shader objFile: @"brick.obj" mtlFile:@"brick.mtl" textureImageFile:@"brick.png"])) {

    }
    return  self;
}

@end

