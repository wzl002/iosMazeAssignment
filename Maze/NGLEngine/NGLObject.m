//
//  NGLObject.m
//  Maze
//
//  Created by Zilong Wang on 2019/3/9.
//  Copyright © 2019 bcit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NGLObject.h"
#import "NGLTextureCache.h"

@interface NGLObject()
{
    int _textureCount;
    NGLTextureCache * _textures;
    NSString * _textureImage;
}

@end

@implementation NGLObject

@dynamic textureImage, modelMatrix, orthoMatrix, rotationMatrix, modelViewProjectionMatrix, modelViewMatrix, normalMatrix;

#pragma mark Properties

- (GLKMatrix4) modelMatrix
{
    GLKMatrix4 modelMatrix = [self orthoMatrix];
    
    return GLKMatrix4Scale(modelMatrix, self.scale.x, self.scale.y, self.scale.z);
}

- (GLKMatrix4) orthoMatrix
{
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    modelMatrix = GLKMatrix4Translate(modelMatrix, self.position.x, self.position.y, self.position.z);
    
    modelMatrix = GLKMatrix4Multiply(modelMatrix, [self rotationMatrix]);
    return modelMatrix;
}

// rotate around axis
- (GLKMatrix4) rotationMatrix
{

    bool isInvertible;
    GLKMatrix4 rotMatrix = GLKMatrix4Identity;
    GLKVector3 xAxis = GLKMatrix4MultiplyVector3(GLKMatrix4Invert(rotMatrix, &isInvertible), GLKVector3Make(1, 0, 0));
    rotMatrix = GLKMatrix4Rotate(rotMatrix, GLKMathDegreesToRadians(self.rotation.x), xAxis.x, xAxis.y, xAxis.z);
    GLKVector3 yAxis = GLKMatrix4MultiplyVector3(GLKMatrix4Invert(rotMatrix, &isInvertible),  GLKVector3Make(0, 1, 0));
    rotMatrix = GLKMatrix4Rotate(rotMatrix, GLKMathDegreesToRadians(self.rotation.y), yAxis.x, yAxis.y, yAxis.z);
    GLKVector3 zAxis = GLKMatrix4MultiplyVector3(GLKMatrix4Invert(rotMatrix, &isInvertible), GLKVector3Make(0, 0, 1));
    rotMatrix = GLKMatrix4Rotate(rotMatrix, GLKMathDegreesToRadians(self.rotation.z), zAxis.x, zAxis.y, zAxis.z);
    
    return rotMatrix;
}

- (GLKMatrix4) modelViewProjectionMatrix
{
    return GLKMatrix4Multiply(_viewProjectionMatrix, self.modelMatrix);
}

- (GLKMatrix4) modelViewMatrix
{
    return GLKMatrix4Multiply(_viewMatrix, self.modelMatrix);
}

- (GLKMatrix4) normalMatrix
{
    return GLKMatrix4InvertAndTranspose(self.modelViewMatrix, NULL);
}

// rotate around self, Temporarily Abandoned
- (GLKMatrix4) selfRotationMatrix
{
    GLKMatrix4 rotMatrix = GLKMatrix4Identity;
    rotMatrix = GLKMatrix4Rotate(rotMatrix, GLKMathDegreesToRadians(self.rotation.x), 1.0, 0.0, 0.0 );
    rotMatrix = GLKMatrix4Rotate(rotMatrix, GLKMathDegreesToRadians(self.rotation.y), 0.0, 1.0, 0.0 );
    rotMatrix = GLKMatrix4Rotate(rotMatrix, GLKMathDegreesToRadians(self.rotation.z), 0.0, 0.0, 1.0 );
    return rotMatrix;
}

#pragma mark -
#pragma mark Constructors

- (id) initWithShader:(NGLShader *) shader
{
    if ((self = [self init]))
    {
        _shader = shader;
        [self loadModel];
    }
    
    return self;
}

- (instancetype)init
{
    if ((self = [super init]))
    {
        _position = GLKVector3Make(0, 0, 0);
        _rotation = GLKVector3Make(0, 0, 0);
        _scale = GLKVector3Make(1.0, 1.0, 1.0);
        _textureCount = -1;
    }
    return self;
}

- (void) dealloc
{
    _name = nil;
    _textures = nil;
    _textureImage = nil;
}

#pragma mark -
#pragma mark Public function

- (void)setTextureImage:(NSString *)fileName{
    if (fileName != _textureImage || _textureCount == -1)
    {
        _textureImage = fileName;
        if(_textures == nil){
            _textures = [[NGLTextureCache alloc] init];
        }
        NGLTexture *texture = [[NGLTexture alloc] initWithFilePath:fileName];
        [_textures addTexture:(NGLTexture *) texture];
        
        _textureCount = [_textures getLastUnit];
    }
}

- (void)bindTexture
{
    if(_textureCount != -1){
        [_textures bindUnit:_textureCount toLocation:_shader.texSampler2DHandle];
    }
}

// abstruct functions

- (void)loadModel{
    
}

- (void)update:(double)deltaTime{
    
}

- (void)draw {
    
}


@end
