//
//  NGLModel.m
//  Maze
//
//  Created by Zilong Wang on 2019/3/20.
//  Copyright © 2019 bcit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/glext.h>
#import "NGLModel.h"

#import "Model3D.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@interface NGLModel () {
    
    Model3D* model;
    
    GLuint _vertexArrayObject;
    GLuint _vertexBuffers[3];
    GLuint _indexBuffer;
    
    NSString * _objFile;
    NSString * _mtlFile;
    NSString * _textureImageFile;
}

@end

@implementation NGLModel

- (id) initWithObjFiles:(NGLShader *)shader
              objFile: (NSString *)objFile
              mtlFile: (NSString *)mtlFile
              textureImageFile: (NSString *)textureImageFile
{
    if ((self = [super initWithShader: shader])) {
        _objFile = objFile;
        _mtlFile = mtlFile;
        _textureImageFile = textureImageFile;
        
        [self loadObjModel];
    }
    return  self;
}

// override
- (void) loadModel
{
    
}

- (void) loadObjModel
{
    model = [Model3D initialize:_objFile
                    andMaterial:[self getFilePath:_mtlFile]
                    andTextures:[NSArray arrayWithObjects:[self getFilePath:_textureImageFile], nil]];
    
    int numVerts;
    float *vertices, *normals, *texCoords;
    int numIndices;
    void *indices;
    
    vertices = [model getVertices];
    normals = [model getNormals];
    texCoords = [model getTexCoords];
    indices = [model getElements];
    numVerts = [model getVertexCount];
    numIndices = [model getElementCount];
    
    NSLog(@"getVertexCount: %d, %d,", numVerts, numIndices);
    
    // Vertex Array Object + VBOs
    glGenVertexArraysOES(1, &_vertexArrayObject);
    glBindVertexArrayOES(_vertexArrayObject);
    
    glGenBuffers(3, _vertexBuffers);
    glGenBuffers(1, &_indexBuffer);
    
    // Set up GL buffers
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffers[0]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*3*numVerts, vertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(self.shader.vertexHandle);
    glVertexAttribPointer(self.shader.vertexHandle, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), BUFFER_OFFSET(0));
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffers[1]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*3*numVerts, normals, GL_STATIC_DRAW);
    glEnableVertexAttribArray(self.shader.normalHandle);
    glVertexAttribPointer(self.shader.normalHandle, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), BUFFER_OFFSET(0));
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffers[2]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*2*numVerts, texCoords, GL_STATIC_DRAW);
    glEnableVertexAttribArray(self.shader.textureCoordHandle);
    glVertexAttribPointer(self.shader.textureCoordHandle, 2, GL_FLOAT, GL_FALSE, 2*sizeof(float), BUFFER_OFFSET(0));
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, [model getElementSize] * numIndices, indices, GL_STATIC_DRAW);
    
    glBindVertexArrayOES(0);
}

- (NSString*) getFilePath:(NSString*)filename
{
    NSString *extension = [filename pathExtension];
    NSString *fileName = [filename stringByDeletingPathExtension];
    return [[NSBundle mainBundle] pathForResource:fileName ofType:extension];
}

- (void)draw
{
    glBindVertexArrayOES(_vertexArrayObject);
    
    [self.shader use];
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, [model getTextureID:0]);
    
    glUniformMatrix4fv(self.shader.mvpMatrixHandle, 1, GL_FALSE, self.modelViewProjectionMatrix.m);
    glUniformMatrix4fv(self.shader.mvMatrixHandle, 1, GL_FALSE, self.modelViewMatrix.m);
    glUniformMatrix4fv(self.shader.normalMatrixHandle, 1, GL_FALSE, self.normalMatrix.m);
    
    glUniform4f(self.shader.materialHandle, [model getAmbient], [model getDiffuse], [model getSpecular], [model getSpecularPower]);
    glUniform4f(self.shader.lightingHandle, 0, 0, 1.0f, 1.0f);
    glUniform1f(self.shader.transparencyHandle, 1.0f);
    glUniform1i(self.shader.texSampler2DHandle, 0);
    
    // glDrawElements(GL_TRIANGLES, [useModel getElementCount], [useModel getElementType], [useModel getElements]);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glDrawElements(GL_TRIANGLES, [model getElementCount], [model getElementType], 0);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    //    glDisable(GL_CULL_FACE);
    //    glDisable(GL_DEPTH_TEST);
    //    glDisable(GL_BLEND);
    
    glBindVertexArrayOES(0);
    
}

@end
