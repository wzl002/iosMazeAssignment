//
//  NGLShader.h
//  Maze
//
//  Created by Zilong Wang on 2019/3/9.
//  Copyright © 2019 bcit. All rights reserved.
//

#ifndef NGLShader_h
#define NGLShader_h

#import "NGLProgram.h"

@interface NGLShader : NGLProgram

@property (nonatomic) GLint vertexHandle;
@property (nonatomic) GLint normalHandle;
@property (nonatomic) GLint colorHandle;
@property (nonatomic) GLint textureCoordHandle;
@property (nonatomic) GLint verctor2Test;

@property (nonatomic) GLint mvpMatrixHandle;
@property (nonatomic) GLint mvMatrixHandle;
@property (nonatomic) GLint normalMatrixHandle;
@property (nonatomic) GLint lightingHandle;
@property (nonatomic) GLint materialHandle;
@property (nonatomic) GLint texSampler2DHandle;
@property (nonatomic) GLint transparencyHandle;

// light
@property (nonatomic) GLint scaleHandle;
@property (nonatomic) GLint modelInverseMatrixHandle;
@property (nonatomic) GLint modelViewInverseMatrixHandle;
@property (nonatomic) GLint lightDirectionHandle;
@property (nonatomic) GLint lightAttenuationHandle;
@property (nonatomic) GLint lightColorHandle;

// fog
@property (nonatomic) GLint fogEndHandle;
// factor = end - start
@property (nonatomic) GLint fogFactorHandle;
@property (nonatomic) GLint fogColorHandle;
@property (nonatomic) GLint fogOnHandle;
@property (nonatomic) GLint fogIntensityHandle;

@property (nonatomic) GLint flashLightOnHandle;
@property (nonatomic) GLint flashLightDirectionHandle;

@end

#endif /* NGLShader_h */
