//
//  NGLObject.h
//  Maze
//
//  Created by Zilong Wang on 2019/3/9.
//  Copyright © 2019 bcit. All rights reserved.
//

#ifndef NGLObject_h
#define NGLObject_h

#import <GLKit/GLKit.h>

@interface NGLObject : NSObject

@property (nonatomic) int tag;

@property (nonatomic, copy) NSString *name;


@property (nonatomic) GLKVector3 position;

@property (nonatomic) GLKVector3 scale;

@property (nonatomic) GLKVector3 rotation;


/*! MODEL MATRIX: The transformations happen in the order: scales -> rotations -> translations.
 */
@property (nonatomic) GLKMatrix4 modelMatrix;

/*!
 *                    This is the orthogonal part of the final matrix. It contains information about the
 *                    object's rotation and translation, but not the scale. This is the orthogonal
 *                    portion of the MODEL MATRIX.
 */
@property (nonatomic) GLKMatrix4 orthoMatrix;

/*!
 *                    Defines a target of look at routine. At every render cycle, this object will perform
 *                    a lookAt routine with the specified target. The lookAt affects rotations in X and Y
 *                    axis. Any other rotation commands will be ignored to the final result.
 *                    The lookAt routine doesn't affect the absolute rotation values.
 */
@property (nonatomic, assign) NGLObject *lookAtTarget;


@end

#endif /* NGLObject_h */
