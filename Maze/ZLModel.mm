//
//  GLModel.m
//  Maze
//
//  Created by Zilong Wang on 2019/2/23.
//  Copyright © 2019 bcit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZLModel.h"
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/glext.h>
#import "GLESRenderer.hpp"
#import "NGLTextureCache.h"

@interface ZLModel ()

@end

@implementation ZLModel
{
    char * _name;
    GLuint _vertexArrayObject;
    GLuint _vertexBuffer;
    GLuint _indexBuffer;
    GLuint _indexCount;
    NGLShader * _shader;
    
    GLKMatrix4 _MVPMatrix;
    
    UIView *_view;
    
    NGLTextureCache * _textures;
    
    // cpp cube
    GLESRenderer glesRenderer;
    int *indices, numIndices;
    float *vertices, *normals, *texCoords;
    
    int _textureCount;

}

- (instancetype) initWithName: (char *)name vertices:(GLfloat * )vertices vertexCount:(unsigned int)vertexCount indices:(GLubyte *)vertexIndices indexCount:(unsigned int)indexCount shader:(NGLShader *)shader view:(UIView *)view {
    
    if ((self = [super init])) {
        _name = name;
        _indexCount = indexCount;
        
        _view = view;
        _shader = shader;
        
        // _textureCount = globelTextureCount++;//TODO
        _textureCount = -1;
        
        [self loadModels];
        
        return self;
        
        glGenVertexArraysOES(1, &_vertexArrayObject);
        glBindVertexArrayOES(_vertexArrayObject);
        
        //GLuint _vertexBuffer;
        glGenBuffers(1, &_vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * vertexCount, vertices, GL_STATIC_DRAW);
        
        // GLint vertexHandle = glGetAttribLocation(_shader, "a_Position");
        // GLint normalHandle = glGetAttribLocation(_shader, "a_Normal");
        // GLint textureCoordHandle = glGetAttribLocation(_shader, "a_TextureCoord");
        
        glVertexAttribPointer(_shader.vertexHandle, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 6, NULL);
        glVertexAttribPointer(_shader.normalHandle, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 6, (float *)NULL + 3);
        
        glEnableVertexAttribArray(_shader.vertexHandle);
        glEnableVertexAttribArray(_shader.normalHandle);
        
        glBindVertexArrayOES(0);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        
        // [self uploadTexture];
    }
    return  self;
}

- (void) setTextureImage:(NSString *)fileName {
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

- (void)loadModels
{
    numIndices = glesRenderer.GenCube(1.0f, &vertices, &normals, &texCoords, &indices);
    
    // glGenVertexArraysOES(1, &_vertexArrayObject);
    // glBindVertexArrayOES(_vertexArrayObject);
    
    glVertexAttribPointer(_shader.vertexHandle, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 3, vertices);
    glVertexAttribPointer(_shader.normalHandle, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 3, normals);
    glVertexAttribPointer(_shader.textureCoordHandle, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 2, texCoords);
    glVertexAttrib4f ( _shader.colorHandle, 1.0f, 0.0f, 0.0f, 1.0f );
    
    glEnableVertexAttribArray(_shader.vertexHandle);
    glEnableVertexAttribArray(_shader.normalHandle);
    glEnableVertexAttribArray(_shader.textureCoordHandle);
    
    // glBindVertexArrayOES(0);
    
}

- (void) update:(double) deltaTime {

    GLKMatrix4 modelViewMatrix = [self modelMatrix];
    _MVPMatrix = GLKMatrix4Multiply(_viewProjectionMatrix, modelViewMatrix);
    
}

- (void) draw {
    
    // glBindVertexArrayOES(_vertexArrayObject);
    
    [_shader use];
    
    [self loadModels];
    
    if(_textureCount != -1){
        [_textures bindUnit:_textureCount toLocation:_shader.texSampler2DHandle];
    }
    
    glUniformMatrix4fv(_shader.mvpMatrixHandle, 1, GL_FALSE, _MVPMatrix.m);
    
    glUniform4f(_shader.lightingHandle, 1, 1, 1.0f, 1.0f);
    glUniform4f(_shader.materialHandle, 1.0f, 1.0f, 0.5f, .5f);
    glUniform1f(_shader.transparencyHandle, 1.0f);
    
    // lighting
    GLKMatrix4 _mIMatrix = GLKMatrix4Transpose(self.orthoMatrix);
    GLKMatrix4 _mvIMatrix = GLKMatrix4Multiply(_mIMatrix, _viewMatrix);
    glUniform3fv(_shader.scaleHandle, 1, self.scale.v);
    glUniformMatrix4fv(_shader.modelInverseMatrixHandle, 1, GL_FALSE, _mIMatrix.m);
    glUniformMatrix4fv(_shader.modelViewInverseMatrixHandle, 1, GL_FALSE, _mvIMatrix.m);
    // lighting end
    
    
    // lighting debug code
//        GLKVector4 u_nglLightPosition = GLKVector4Make(2.0f, 2.0f, 3.0f, 1.0f);
//        glUniform4fv(_shader.lightPositionHandle, 1, u_nglLightPosition.v);
//        glUniform4fv(_shader.lightColorHandle, 1, GLKVector4Make(1.0f, 240.0/255.0f, 210.0f/255.0f, 1.0f).v);
//        glUniform1f(_shader.lightAttenuationHandle, 10.0f); // intensity, 0-1;
//    
//     GLKVector4 a_Position = GLKVector4Make(0.5, 0.5, 0.5, 1.0);
//     GLKVector4 _nglOrigin = GLKVector4Make(0.0,0.0,0.0,1.0);
//    GLKVector4 _nglPosition = GLKVector4Multiply(a_Position, GLKVector4MakeWithVector3(self.scale, 1.0f));
//    GLKVector4 v_nglVEyeD = GLKMatrix4MultiplyVector4(_mvIMatrix, _nglOrigin);
//    GLKVector4 v_nglVEye = GLKVector4Subtract(v_nglVEyeD, _nglPosition);
//    float sp = GLKVector4DotProduct(v_nglVEyeD, v_nglVEye);
//    GLKVector4 v_nglVLight = GLKVector4Subtract(GLKMatrix4MultiplyVector4(_mIMatrix, u_nglLightPosition), _nglPosition);
//    GLKVector3 v_nglVLight3 = GLKVector3Make(v_nglVLight.x, v_nglVLight.y, v_nglVLight.z);
//    float length = GLKVector3Length(v_nglVLight3);
//    float v_nglLightLevel = 1.0f / GLKVector3Length(v_nglVLight3);
//    GLKVector3 nglNormal = GLKVector3Make(0.0f, 1.0f, 0.0f);
//    float _nglLightD = GLKVector3DotProduct(nglNormal, v_nglVLight3);
    
//    // fog debug
//    GLKVector4 gl_Position = GLKMatrix4MultiplyVector4( _MVPMatrix, a_Position);
//    float p_length = GLKVector4Length(gl_Position);
//    float v_nglFog = (75 - GLKVector4Length(gl_Position)) / 25;
//                     
// */ light debug end
    
    // glDrawArrays(GL_TRIANGLES, 0, 36);
    glDrawElements ( GL_TRIANGLES, numIndices, GL_UNSIGNED_INT, indices );
    
    // glBindVertexArrayOES(0);
    
}

@end
