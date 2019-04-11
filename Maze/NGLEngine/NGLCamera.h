//
//  NGLCamera.h
//  Maze
//
//  Created by Zilong Wang on 2019/3/16.
//  Copyright © 2019 bcit. All rights reserved.
//

#ifndef NGLCamera_h
#define NGLCamera_h


#import <GLKit/GLKit.h>

@interface NGLCamera: NSObject


@property (nonatomic) GLKVector3 eyePosition;

@property (nonatomic) GLKVector3 lootAtPoint;

@property (nonatomic) GLKVector3 up;


/*! VIEW MATRIX. */
@property (nonatomic, readonly) GLKMatrix4 viewMatrix;

- (void) rotateCamera:(float)x y:(float)y;

@end

#endif /* NGLCamera_h */
