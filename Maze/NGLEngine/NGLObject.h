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
#import "NGLShader.h"

@interface NGLObject : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic, weak) NGLShader * shader;

@property (nonatomic) GLKVector3 position;

@property (nonatomic) GLKVector3 scale;

@property (nonatomic) GLKVector3 rotation;

@property (nonatomic) NSString * textureImage;

// set Matrices

@property (nonatomic) GLKMatrix4 viewProjectionMatrix;

@property (nonatomic) GLKMatrix4 viewMatrix;

// get Matrices

@property (nonatomic, readonly) GLKMatrix4 modelMatrix;

@property (nonatomic, readonly) GLKMatrix4 orthoMatrix;

@property (nonatomic, readonly) GLKMatrix4 rotationMatrix;


@property (nonatomic, readonly) GLKMatrix4 modelViewProjectionMatrix;

@property (nonatomic, readonly) GLKMatrix4 modelViewMatrix;

@property (nonatomic, readonly) GLKMatrix4 normalMatrix;



- (id) initWithShader:(NGLShader *)shader;

- (void)bindTexture;

// override functions

- (void)loadModel;

- (void)update:(double)deltaTime;

- (void)draw;


@end

#endif /* NGLObject_h */
