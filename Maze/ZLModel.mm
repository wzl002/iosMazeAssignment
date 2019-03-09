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

static int globelTextureCount = 0;

NSMutableArray            *_fileNames;

@interface ZLModel ()

@end

@implementation ZLModel
{
    char * _name;
    GLuint _vertexArrayObject;
    GLuint _vertexBuffer;
    GLuint _indexBuffer;
    GLuint _indexCount;
    GLuint _shader;
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix4 _viewMatrix;
    // GLKBaseEffect *_effect;
    UIView *_view;
    
    NGLTextureCache * _textures;
    
    // cpp cube
    GLESRenderer glesRenderer;
    int *indices, numIndices;
    float *vertices, *normals, *texCoords;
    
    int _textureCount;
    
    float x;
    float z;
}

- (instancetype) initWithName: (char *)name vertices:(GLfloat * )vertices vertexCount:(unsigned int)vertexCount indices:(GLubyte *)vertexIndices indexCount:(unsigned int)indexCount shader:(GLuint)shader view:(UIView *)view {
    
    if ((self = [super init])) {
        _name = name;
        _indexCount = indexCount;
        z = -4.0f;
        
        _view = view;
        _shader = shader;
        
        // _textureCount = globelTextureCount++;//TODO
        _textureCount = -1;
        
        self.position = GLKVector3Make(0, 0, 0);
        self.rotation = GLKVector3Make(0, 0, 0);
        self.scale = GLKVector3Make(1.0, 1.0, 1.0);
        
        [self loadModels];
        
        return self;
        
        glGenVertexArraysOES(1, &_vertexArrayObject);
        glBindVertexArrayOES(_vertexArrayObject);
        
        //GLuint _vertexBuffer;
        glGenBuffers(1, &_vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * vertexCount, vertices, GL_STATIC_DRAW);
        
        GLint vertexHandle = glGetAttribLocation(_shader, "a_Position");
        GLint normalHandle = glGetAttribLocation(_shader, "a_Normal");
        // GLint textureCoordHandle = glGetAttribLocation(_shader, "a_TextureCoord");
        
        glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 6, NULL);
        glVertexAttribPointer(normalHandle, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 6, (float *)NULL + 3);
        
        glEnableVertexAttribArray(vertexHandle);
        glEnableVertexAttribArray(normalHandle);
        
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
        _textureCount = [self setupTexture:_textureImage];
    }
}

- (void)loadModels
{
    numIndices = glesRenderer.GenCube(1.0f, &vertices, &normals, &texCoords, &indices);
    
    // glGenVertexArraysOES(1, &_vertexArrayObject);
    // glBindVertexArrayOES(_vertexArrayObject);
//    GLuint crateTexture = [self setupTexture:_textureImage];
//    glActiveTexture(GL_TEXTURE0 + _textureCount);
//    glBindTexture(GL_TEXTURE_2D, crateTexture);
//    glUniform1i(glGetUniformLocation(_shader, "u_Texture"), _textureCount);
    
    GLint vertexHandle = glGetAttribLocation(_shader, "a_Position");
    GLint normalHandle = glGetAttribLocation(_shader, "a_Normal");
    GLint colorHandle = glGetAttribLocation(_shader, "a_Color");
    GLint textureCoord = glGetAttribLocation(_shader, "a_TextureCoord");
    
    glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 3, vertices);
    glVertexAttribPointer(normalHandle, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 3, normals);
    glVertexAttribPointer(textureCoord, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 2, texCoords);
    glVertexAttrib4f ( colorHandle, 1.0f, 0.0f, 0.0f, 1.0f );
    
    glEnableVertexAttribArray(vertexHandle);
    glEnableVertexAttribArray(normalHandle);
    glEnableVertexAttribArray(textureCoord);
    
    // glBindVertexArrayOES(0);
    
}


- (GLKMatrix4) modelMatrix {
    // local
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    modelMatrix = GLKMatrix4Translate(modelMatrix, self.position.x, self.position.y, self.position.z);
    modelMatrix = GLKMatrix4Rotate(modelMatrix, GLKMathDegreesToRadians(self.rotation.x), 1.0, 0.0, 0.0 );
    modelMatrix = GLKMatrix4Rotate(modelMatrix, GLKMathDegreesToRadians(self.rotation.y), 0.0, 1.0, 0.0 );
    modelMatrix = GLKMatrix4Rotate(modelMatrix, GLKMathDegreesToRadians(self.rotation.z), 0.0, 0.0, 1.0 );
    modelMatrix = GLKMatrix4Scale(modelMatrix, self.scale.x, self.scale.y, self.scale.z);
    
    return modelMatrix;
}

- (void) update:(double) deltaTime {
    
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), fabs(_view.bounds.size.width / _view.bounds.size.height), 0.1f, 150.0f);
    
    GLKMatrix4 modelViewMatrix = [self modelMatrix];
    
    x -= deltaTime;
    z -= 25 * deltaTime;
    
    // world
    _viewMatrix = GLKMatrix4MakeTranslation(1, -1, -0.1f);
    modelViewMatrix = GLKMatrix4Multiply(_viewMatrix, modelViewMatrix);
    
    // view
    //_viewMatrix = GLKMatrix4Rotate(_viewMatrix, GLKMathDegreesToRadians(0), 1.0, 0.0, 0.0 );
    //_viewMatrix = GLKMatrix4Rotate(_viewMatrix, GLKMathDegreesToRadians(0), 0.0, 1.0, 0.0 );
    _viewMatrix = GLKMatrix4Rotate(GLKMatrix4Identity, GLKMathDegreesToRadians(90), 1.0, 0.0, 0.0 );// vertical rotate
    _viewMatrix = GLKMatrix4Rotate(_viewMatrix, GLKMathDegreesToRadians(z), 0.0, 0.0, 1.0 ); // Horizontally rotate
    // _viewMatrix = GLKMatrix4Translate(_viewMatrix, -1, 1, 0);
    
    modelViewMatrix = GLKMatrix4Multiply(_viewMatrix, modelViewMatrix);
    

    
    _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);

}

- (void) draw {
    
    // glBindVertexArrayOES(_vertexArrayObject);
    
    glUseProgram(_shader);
    
    [self loadModels];
    
    if(_textureCount != -1){
        [_textures bindUnit:_textureCount toLocation:glGetUniformLocation(_shader, "u_Texture")];
    }
    
    GLint mvpMatrixHandle = glGetUniformLocation(_shader, "u_ModelViewProjection");
    glUniformMatrix4fv(mvpMatrixHandle, 1, GL_FALSE, _modelViewProjectionMatrix.m);
    
    GLKMatrix4 mvMat = GLKMatrix4Multiply(_viewMatrix, [self modelMatrix]);
    GLint modelView = glGetUniformLocation(_shader, "u_ModelView");
    glUniformMatrix4fv(modelView, 1, GL_FALSE, (const GLfloat*)mvMat.m);

    GLint lightingHandle = glGetUniformLocation(_shader,"u_LightingParameters");
    GLint transparencyHandle = glGetUniformLocation(_shader, "u_transparency");
    glUniform4f(lightingHandle, 0, 0, 1.0f, 1.0f);
    glUniform1f(transparencyHandle, 1.0f);
    
    // glDrawArrays(GL_TRIANGLES, 0, 36);
    
    glDrawElements ( GL_TRIANGLES, numIndices, GL_UNSIGNED_INT, indices );
    
    // glBindVertexArrayOES(0);
    
}


// Load in and set up texture image (adapted from Ray Wenderlich)
- (GLuint)setupTexture:(NSString *)fileName
{
    NGLTexture *texture = [[NGLTexture alloc] initWithFilePath:fileName];
    [_textures addTexture:(NGLTexture *) texture];
    
    return [_textures getLastUnit];
    
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte *spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGContextRelease(spriteContext);
    
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    free(spriteData);
    return texName;
}
@end
