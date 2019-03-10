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
 *                    The VIEW_PROJECTION matrix.
 */
@property (nonatomic) GLKMatrix4 viewProjectionMatrix;

/*!
 *                    The final MODEL_VIEW matrix, camera matrix for set lighting
 */
@property (nonatomic, readonly) GLKMatrix4 viewMatrix;

/*!
 *                    The final orthogonal MODEL_INVERSE matrix (doesn't include the scale).
 */
@property (nonatomic, readonly) GLKMatrix4 matrixMInverse;

/*!
 *                    The final orthogonal MODEL_VIEW_INVERSE matrix (doesn't include the scale).
 */
@property (nonatomic, readonly) GLKMatrix4 matrixMVInverse;

@end

#endif /* GLModel_h */
