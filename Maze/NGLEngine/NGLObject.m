//
//  NGLObject.m
//  Maze
//
//  Created by Zilong Wang on 2019/3/9.
//  Copyright © 2019 bcit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NGLObject.h"

@interface NGLObject()


@end

@implementation NGLObject

#pragma mark Properties

- (GLKMatrix4) modelMatrix
{
    GLKMatrix4 modelMatrix = [self orthoMatrix];
    
    return GLKMatrix4Scale(modelMatrix, self.scale.x, self.scale.y, self.scale.z);
}

- (GLKMatrix4) orthoMatrix
{
    // Processes the lookAt routine, if exist.
    if (_lookAtTarget != nil)
    {
        //    [self lookAtObject:_lookAtTarget];
    }
    
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    modelMatrix = GLKMatrix4Translate(modelMatrix, self.position.x, self.position.y, self.position.z);
    modelMatrix = GLKMatrix4Rotate(modelMatrix, GLKMathDegreesToRadians(self.rotation.x), 1.0, 0.0, 0.0 );
    modelMatrix = GLKMatrix4Rotate(modelMatrix, GLKMathDegreesToRadians(self.rotation.y), 0.0, 1.0, 0.0 );
    modelMatrix = GLKMatrix4Rotate(modelMatrix, GLKMathDegreesToRadians(self.rotation.z), 0.0, 0.0, 1.0 );
    
    return modelMatrix;
}

#pragma mark -
#pragma mark Constructors
//**************************************************
//    Constructors
//**************************************************

- (id) init
{
    if ((self = [super init]))
    {

        _position = GLKVector3Make(0, 0, 0);
        _rotation = GLKVector3Make(0, 0, 0);
        _scale = GLKVector3Make(1.0, 1.0, 1.0);
        
        // Defines no lookAt target.
        _lookAtTarget = nil;
    }
    
    return self;
}


#pragma mark -
#pragma mark Self Public Methods

- (void) unimplement_lookAtObject:(NGLObject *)object
{
    // Calculates the distances between objects's pivots.
    GLKVector3 distance = (GLKVector3){object.position.x - self.position.x, object.position.y - self.position.y, object.position.z - self.position.z};
    
    [self unimplement_lookAtVector:distance];
}

- (void) unimplement_lookAtPointX:(float)xNum toY:(float)yNum toZ:(float)zNum
{
    // Calculates the distances between points.
    GLKVector3 distance = (GLKVector3){xNum - self.position.x, yNum - self.position.y, zNum - self.position.z};
    
    [self unimplement_lookAtVector:distance];
}

- (void) unimplement_lookAtVector:(GLKVector3)vector
{
    // This approach saves the Z rotation and can be used rather than the matrix formed
    // with the Front, Up and Side vector
    
    // Using Pythagoras Theorem, finds the projection magnitude on the plane XZ.
    // This will represent the adjacent side to X rotation (also known as roll or bank).
    float mag = sqrtf(vector.x * vector.x + vector.z * vector.z);
    
    // Applies the simple SOH-CAH-TOA formulas to find the angles in a triangle.
    // Here in both cases, use the Opposite and Adjacent sides.
    // The atan2f is better because can work in the four quadrants, not only 2 like atanf.
    float rotateX = GLKMathRadiansToDegrees(atan2f(-vector.y, mag));
    float rotateY = GLKMathRadiansToDegrees(atan2f(vector.x, vector.z));
    
    // Adds the rotation into the quaternion.
    // [_quat rotateByEuler:(GLKVector3){rotateX, rotateY, _rotation.z} mode:NGLAddModeSet];

}

- (void) dealloc
{
    _name = nil;
}

@end
