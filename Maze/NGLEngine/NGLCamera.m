//
//  NGLCamera.m
//  Maze
//
//  Created by Zilong Wang on 2019/3/16.
//  Copyright © 2019年 bcit. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NGLCamera.h"

@interface NGLCamera()


@end
   
   
@implementation NGLCamera

@dynamic viewMatrix;


- (id) init
{
    if ((self = [super init]))
    {
        
        _eyePosition = GLKVector3Make(0, 0, 0);
        _lootAtPoint = GLKVector3Make(0, 0, -1);
        _up = GLKVector3Make(0.0, 1.0, 0.0);
    }
    
    return self;
}

- (GLKMatrix4) viewMatrix
{
    return GLKMatrix4MakeLookAt(_eyePosition.x, _eyePosition.y, _eyePosition.z, _lootAtPoint.x, _eyePosition.y, _eyePosition.z, _up.x, _up.y, _up.z);
}

- (void) rotateCamera:(float)x y:(float)y
{
       
}


@end
