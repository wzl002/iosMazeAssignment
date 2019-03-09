//
//  NGLProgram.m
//  Maze
//
//  Created by Zilong Wang on 2019/3/7.
//  Copyright © 2019 bcit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NGLProgram.h"
#import "NGLFunctions.h"

#pragma mark Constants

static NSString *const PRG_ERROR_CONTEXT = @"Incorrect usage.\n\
No OpenGL context was created. You should initialize a NGLView before any other NinevehGL's object.";

// Global program cache.
static GLuint _currentProgram;


@interface NGLProgram()

// Compiles a shader based on a type (Vertex or Fragment) and a NSString.
- (void) compileShader:(GLuint *)shader type:(GLenum)type data:(NSString *)data;

// Deletes the current program.
- (void) clearProgram;

@end

@implementation NGLProgram

- (instancetype)init
{
    self = [super init];
    if (self) {
        _name = 0;
    }
    return self;
}

#pragma mark Private Methods

- (void) compileShader:(GLuint *)shader type:(GLenum)type data:(NSString *)data
{
    const GLchar *source = [data UTF8String];
    
    // Creates the shader name/index.
    *shader = glCreateShader(type);
    
    if (*shader == 0)
    {
        NSLog( @"Error while processing NGLES2Program. %@", PRG_ERROR_CONTEXT);
    }
    
    // Loads the shader source.
    glShaderSource(*shader, 1, &source, NULL);
    
    // Compiles the loaded source.
    glCompileShader(*shader);
    
#ifdef NGL_DEBUG
    // Prints a possible error on the console.
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        [NGLError errorInstantlyWithHeader:@"Error while processing NGLES2Program."
                                andMessage:[NSString stringWithFormat:@"Shader compile error.\n%s", log]];
        nglFree(log);
        
        glDeleteShader(*shader);
    }
#endif
}

- (void) clearProgram
{
    // If the current program has a valid name/id, deletes it.
    if(_name)
    {
        if (_currentProgram == _name)
        {
            _currentProgram = 0;
            glUseProgram(0);
        }
        
        glDeleteProgram(_name);
    }
}

#pragma mark Self Public Methods

- (void) setVertexString:(NSString *)vertex fragmentString:(NSString *)fragment
{
    // Deletes the current program, if needed.
    [self clearProgram];
    
    GLuint vsh;
    GLuint fsh;
    
    // Compiles the pair of shaders.
    [self compileShader:&vsh type:GL_VERTEX_SHADER data:vertex];
    [self compileShader:&fsh type:GL_FRAGMENT_SHADER data:fragment];
    
    // Creates the program name/index.
    _name = glCreateProgram();
    
    // Attaches the fragment and vertex shaders to current program.
    glAttachShader(_name, vsh);
    glAttachShader(_name, fsh);
    
    // Links the program into OpenGL's core.
    glLinkProgram(_name);
    
#ifdef NGL_DEBUG
    // Prints a possible error on the console.
    GLint logLength;
    glGetProgramiv(_name, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(_name, logLength, &logLength, log);
        [NGLError errorInstantlyWithHeader:@"Error while processing NGLES2Program."
                                andMessage:[NSString stringWithFormat:@"Program link error.\n%s", log]];
        nglFree(log);
    }
#endif
    
    // Clears the bound shaders.
    glDeleteShader(vsh);
    glDeleteShader(fsh);
}

- (NSString *) getSourceFromFile:(NSString *)named
{
    NSString * path = nglMakePath(named);
    return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
}

- (void) setVertexFile:(NSString *)vertexPath fragmentFile:(NSString *)fragmentPath
{
    [self setVertexString:[self getSourceFromFile:vertexPath] fragmentString:[self getSourceFromFile:fragmentPath] ];
}

- (GLint) attributeLocation:(NSString *)nameInShader
{
    return glGetAttribLocation(_name, [nameInShader UTF8String]);
}

- (GLint) uniformLocation:(NSString *)nameInShader
{
    return glGetUniformLocation(_name, [nameInShader UTF8String]);
}

- (void) use
{
    if (_currentProgram != _name)
    {
        _currentProgram = _name;
        glUseProgram(_currentProgram);
    }
}

#pragma mark Override Public Methods

- (void) dealloc
{
    [self clearProgram];
}

@end

