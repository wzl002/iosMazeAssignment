//
//  GLModel.h
//  Maze
//
//  Created by Zilong Wang on 2019/2/23.
//  Copyright © 2019 bcit. All rights reserved.
//

#ifndef GLModel_h
#define GLModel_h

#import <GLKit/GLKit.h>
#import "NGLShader.h"
#import "NGLObject.h"

@interface ZLModel : NGLObject

- (instancetype) initWithName: (char *)name vertices:(GLfloat *)vertices vertexCount:(unsigned int)vertexCount indices:(GLubyte *)indices indexCount:(unsigned int)indexCount shader:(NGLShader *)shader view:(UIView *)view;

- (void)update:(double) deltaTime;

- (void) draw;


@property (nonatomic) NSString * textureImage;

/*!
 *                    The final camera model matrix, camera matrix for set lighting
 */
@property (nonatomic) GLKMatrix4 cameraModelMatrix;

@end

#endif /* GLModel_h */
