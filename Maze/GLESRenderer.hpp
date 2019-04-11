#ifndef GLESRenderer_hpp
#define GLESRenderer_hpp

#include <stdlib.h>

#include <OpenGLES/ES3/gl.h>

class GLESRenderer
{
public:
    char *LoadShaderFile(const char *shaderFileName);
    GLuint LoadShader(GLenum type, const char *shaderSrc);
    GLuint LoadProgram(const char *vertShaderSrc, const char *fragShaderSrc);
    
    int GenCube(float scale, float **vertices, float **normals,
                float **texCoords, int **indices, int *numVerts);
    
};

#endif /* GLESRenderer_hpp */
