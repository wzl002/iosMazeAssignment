//
//  Wall.m
//  Maze
//
//  Created by Zilong Wang on 2019/2/23.
//  Copyright © 2019年 bcit. All rights reserved.
//

#import "Wall.h"
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/glext.h>
#import "GLESRenderer.hpp"
#import "NGLTextureCache.h"


#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@interface ZLModel ()

@end

@implementation ZLModel
{
    char * _name;
    GLuint _vertexArrayObject;
    GLuint _vertexBuffers[3];
    GLuint _indexBuffer;
    GLuint _indexCount;
    NGLShader * _shader;
    
    GLKMatrix4 _MVPMatrix;
    GLKMatrix4 _modelViewMatrix;
    GLKMatrix4 _normalMatrix;
    
    UIView *_view;
    
    
    // cpp cube
    GLESRenderer glesRenderer;
    int *indices, numIndices;
    float *vertices, *normals, *texCoords;
    
    int _textureCount;
    NGLTextureCache * _textures;
    
}

- (instancetype) initWithName: (char *)name vertices:(GLfloat * )vertices vertexCount:(unsigned int)vertexCount indices:(GLubyte *)vertexIndices indexCount:(unsigned int)indexCount shader:(NGLShader *)shader view:(UIView *)view {
    
    if ((self = [super initWithShader:_shader])) {
        _name = name;
        _indexCount = indexCount;
        
        _view = view;
        _shader = shader;
        
        // _textureCount = globelTextureCount++;//TODO
        _textureCount = -1;
        
        [self loadModels];
        
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
    int numVerts;
    numIndices = glesRenderer.GenCube(1.0f, &vertices, &normals, &texCoords, &indices, &numVerts);
    // Generate vertices
    
    /* Vertex Array
     //    numIndices = generateSphere(50, 1, &vertices, &normals, &texCoords, &indices, &numVerts);
     numIndices = generateCube(1.5, &vertices, &normals, &texCoords, &indices, &numVerts);
     
     glVertexAttribPointer(_shader.vertexHandle, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 3, vertices);
     glVertexAttribPointer(_shader.normalHandle, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 3, normals);
     glVertexAttribPointer(_shader.textureCoordHandle, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 2, texCoords);
     glVertexAttrib4f ( _shader.colorHandle, 1.0f, 0.0f, 0.0f, 1.0f );
     
     glEnableVertexAttribArray(_shader.vertexHandle);
     glEnableVertexAttribArray(_shader.normalHandle);
     glEnableVertexAttribArray(_shader.textureCoordHandle);
     // */
    
    // Vertex Array Object + VBOs
    glGenVertexArraysOES(1, &_vertexArrayObject);
    glBindVertexArrayOES(_vertexArrayObject);
    
    glGenBuffers(3, _vertexBuffers);
    glGenBuffers(1, &_indexBuffer);
    
    // Set up GL buffers
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffers[0]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*3*numVerts, vertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(_shader.vertexHandle);
    glVertexAttribPointer(_shader.vertexHandle, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), BUFFER_OFFSET(0));
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffers[1]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*3*numVerts, normals, GL_STATIC_DRAW);
    glEnableVertexAttribArray(_shader.normalHandle);
    glVertexAttribPointer(_shader.normalHandle, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), BUFFER_OFFSET(0));
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffers[2]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*3*numVerts, texCoords, GL_STATIC_DRAW);
    glEnableVertexAttribArray(_shader.textureCoordHandle);
    glVertexAttribPointer(_shader.textureCoordHandle, 2, GL_FLOAT, GL_FALSE, 2*sizeof(float), BUFFER_OFFSET(0));
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(int)*numIndices, indices, GL_STATIC_DRAW);
    
    glBindVertexArrayOES(0);
    
}

- (void) update:(double) deltaTime {
    
    GLKMatrix4 modelMatrix = [self modelMatrix];
    _MVPMatrix = GLKMatrix4Multiply(self.viewProjectionMatrix, modelMatrix);
    _modelViewMatrix = GLKMatrix4Multiply(self.viewMatrix, modelMatrix);
    _normalMatrix = GLKMatrix4InvertAndTranspose(_modelViewMatrix, NULL);
}

- (void) draw {
    
    glBindVertexArrayOES(_vertexArrayObject);
    
    [_shader use];
    
    // [self loadModels];
    
    if(_textureCount != -1){
        [_textures bindUnit:_textureCount toLocation:_shader.texSampler2DHandle];
    }
    
    glUniformMatrix4fv(_shader.mvpMatrixHandle, 1, GL_FALSE, _MVPMatrix.m);
    glUniformMatrix4fv(_shader.mvMatrixHandle, 1, GL_FALSE, _modelViewMatrix.m);
    glUniformMatrix4fv(_shader.normalMatrixHandle, 1, GL_FALSE, _normalMatrix.m);
    
    glUniform4f(_shader.lightingHandle, 1, 1, 1.0f, 1.0f);
    glUniform4f(_shader.materialHandle, 1.0f, 1.0f, 0.5f, .5f);
    glUniform1f(_shader.transparencyHandle, 1.0f);
    
    // lighting
    //    GLKMatrix4 _mIMatrix = GLKMatrix4InvertAndTranspose(self.orthoMatrix, NULL);
    //    // normal Matrix
    //    GLKMatrix4 _mvIMatrix = GLKMatrix4InvertAndTranspose(GLKMatrix4Multiply(self.orthoMatrix, _cameraModelMatrix), NULL);
    //    // _mvIMatrix = GLKMatrix4Multiply(_viewMatrix, _mvIMatrix);
    //    glUniform3fv(_shader.scaleHandle, 1, self.scale.v);
    //    glUniformMatrix4fv(_shader.modelInverseMatrixHandle, 1, GL_FALSE, _mIMatrix.m);
    //    glUniformMatrix4fv(_shader.modelViewInverseMatrixHandle, 1, GL_FALSE, _mvIMatrix.m);
    // lighting end
    
    
    // lighting debug code
    //        GLKVector4 u_nglLightPosition = GLKVector4Make(2.0f, 2.0f, 3.0f, 1.0f);
    //        glUniform4fv(_shader.lightDirectionHandle, 1, u_nglLightPosition.v);
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
    // glDrawElements ( GL_TRIANGLES, numIndices, GL_UNSIGNED_INT, indices );
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glDrawElements(GL_TRIANGLES, numIndices, GL_UNSIGNED_INT, 0);
    
    glBindVertexArrayOES(0);
    
}


const static GLfloat attrArr[] =
{
    0.5f, -0.5f, 0.0f,     1.0f, 0.0f,
    -0.5f, 0.5f, 0.0f,     0.0f, 1.0f,
    -0.5f, -0.5f, 0.0f,    0.0f, 0.0f,
    0.5f, 0.5f, 0.0f,      1.0f, 1.0f,
//        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
//        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
};
const static GLubyte indices[] =
{
    0, 1, 2,
    3, 1, 0,
};


const static GLfloat gCubeVertexData[216] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,          1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    
    0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,
    
    -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,
    
    -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,
    
    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,
    
    0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f
};


@interface Wall ()

@end

@implementation Wall


- (instancetype)initWithShader:(NGLShader *)shader view:(UIView *)view {
    if((self = [super initWithName:"Wall"
                           vertices:(GLfloat *)gCubeVertexData
                        vertexCount:sizeof(gCubeVertexData)/sizeof(gCubeVertexData[0])
                            indices:(GLubyte *)indices
                         indexCount:sizeof(indices)/sizeof(indices[0])
                            shader:shader
                              view:view
                 ])) {
    }
    return self;

}


@end
