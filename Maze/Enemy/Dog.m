//
//  Dog.m
//  Maze
//
//  Created by Zilong Wang on 2019/4/10.
//  Copyright © 2019 bcit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dog.h"

@interface Dog ()

@end

@implementation Dog

- (id) initWithShader:(NGLShader *)shader {
    
    if ((self = [super initWithObjFiles:shader objFile: @"Dog.obj" mtlFile:@"Dog.mtl" textureImageFile:@"Dog_diffuse.jpg"])) {

    }
    return  self;
}

@end
