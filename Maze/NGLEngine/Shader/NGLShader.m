//
//  NGLShader.m
//  Maze
//
//  Created by Zilong Wang on 2019/3/9.
//  Copyright © 2019 bcit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NGLShader.h"

@interface NGLShader ()

@end


@implementation NGLShader

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setVertexFile:@"Shader.vertsh" fragmentFile:@"Shader.fragsh"];

        // attr
        self.vertexHandle = [self attributeLocation:@"a_Position"];
        self.normalHandle = [self attributeLocation:@"a_Normal"];
        self.textureCoordHandle = [self attributeLocation:@"a_TextureCoord"];
        self.colorHandle = [self attributeLocation:@"a_Color"];
        self.verctor2Test = [self attributeLocation:@"a_Verctor2Test"];
        self.texSampler2DHandle  = [self uniformLocation:@"u_Texture"];
        // uniform
        self.mvpMatrixHandle = [self uniformLocation:@ "u_ModelViewProjection"];
        self.mvMatrixHandle = [self uniformLocation:@"u_ModelView"];
        self.materialHandle = [self uniformLocation:@"u_MaterialParameters"];
        self.lightingHandle = [self uniformLocation:@"u_LightingParameters"];
        self.transparencyHandle = [self uniformLocation:@"u_transparency"];
        
        // Light
        self.scaleHandle = [self uniformLocation:@"u_nglScale"];
        self.modelInverseMatrixHandle = [self uniformLocation:@"u_nglMIMatrix"];
        self.modelViewInverseMatrixHandle = [self uniformLocation:@"u_nglMVIMatrix"];
        self.lightPositionHandle = [self uniformLocation:@"u_nglLightPosition"];
        // Attenuation, 0-1000, default 2;
        self.lightAttenuationHandle = [self uniformLocation:@"u_nglLightAttenuation"];
        self.lightColorHandle = [self uniformLocation:@"u_nglLightColor"];
        
        // fog
//        uniform highp float u_nglFogEnd;
//        uniform highp float u_nglFogFactor;
//        vuniform ec4 u_nglFogColor
        self.fogEndHandle = [self uniformLocation:@"u_nglFogEnd"];
        // factor = end - start
        self.fogFactorHandle = [self uniformLocation:@"u_nglFogFactor"];
        self.fogColorHandle = [self uniformLocation:@"u_nglFogColor"];
        self.fogOnHandle = [self uniformLocation:@"u_nglfogOn"];
        self.fogIntensityHandle = [self uniformLocation:@"u_nglfogIntensityHandle"];
        
        // flash light
        self.flashLightOnHandle = [self uniformLocation:@"u_flashLightOn"];
        
    }
    return self;
}

- (void) use
{
    
    
    [super use];
}
@end
