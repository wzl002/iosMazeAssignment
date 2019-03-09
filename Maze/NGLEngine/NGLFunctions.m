//
//  NGLFunction.m
//  Maze
//
//  Created by Zilong Wang on 2019/3/5.
//  Copyright © 2019 bcit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import "NGLFunctions.h"
// #import <pthread.h>

#pragma mark Constants

// The range 0xA0 - 0xAF is not used by OpenGL, so it's free for reference.
#define NGL_REF_DEFAULT        0xA001
#define NGL_REF_COLOR        0xA002
#define NGL_REF_CULL        0xA003
#define NGL_REF_FRONT        0xA004
#define NGL_REF_BLEND        0xA005
#define NGL_REF_VIEWPORT    0xA006

#pragma mark Private Definitions

NSString                *nglDefaultPath                    = nil;

static GLuint                _nglFramebuffer;
static GLuint                _nglRenderbuffer;

static EAGLContext            *_currentContext;
static NSMutableDictionary    *_currentStates;

static EAGLSharegroup *_nglGroup = nil;
static pthread_mutex_t _nglContextMutex;



#pragma mark -
#pragma mark Private Functions
//**************************************************
//    Private Functions
//**************************************************

// Retuns the dictionary of all context.
static NSMutableDictionary *contexts()
{
    // Persistent instance.
    static NSMutableDictionary *_default = nil;
    
    // Allocates once with Grand Central Dispatch (GCD) routine. Thread safe.
    static dispatch_once_t safer;
    dispatch_once(&safer, ^(void)
                  {
                      _default = [[NSMutableDictionary alloc] init];
                  });
    
    return _default;
}

// Retuns the dictionary of states for the current context.
// This function will set the current context for the current thread, if needed.
static NSMutableDictionary *currentContext()
 {
    EAGLContext *contextEAGL = nglContextEAGL();
    
    // Small optimization to avoid redundant calls when the current EAGLContext remains the same.
    if (_currentContext == contextEAGL)
    {
        return _currentStates;
    }
    
    // Setting the current EAGL context and get it pointer representation.
    NSString *key = [NSString stringWithFormat:@"%p",contextEAGL];
    
    // Gets the current context's dictionary of states.
    NSMutableDictionary *allContexts = contexts();
    NSMutableDictionary *states = [allContexts objectForKey:key];
    
    // Creates a new dictionary of states for the current context, if needed.
    if (states == nil)
    {
        states = [[NSMutableDictionary alloc] init];
        [allContexts setObject:states forKey:key];
    }
    
    _currentContext = contextEAGL;
    _currentStates = states;
    
    return states;
}
//*/
// Deletes the dictionary of states for the current context.
// This function will set the current context for the current thread, if needed.
/*
 static void deleteCurrentContext()
 {
 EAGLContext *contextEAGL = nglContextEAGL();
 
 // Setting the current EAGL context and get it pointer representation.
 NSString *key = [NSString stringWithFormat:@"%p",contextEAGL];
 
 // Gets the current context's dictionary of states.
 NSMutableDictionary *allContexts = contexts();
 
 // Removes and releases the current context's dictionary of sates.
 [allContexts removeObjectForKey:key];
 }
 //*/

// Gets the current value for a state name/id.


 static unsigned int contextValue(unsigned int name)
{
    NSNumber *key = [NSNumber numberWithUnsignedInt:name];
    
    return [[currentContext() objectForKey:key] unsignedIntValue];
}

// Sets the value for a state name/id.
static void contextSetValue(unsigned int name, unsigned int value)
{
    NSNumber *key = [NSNumber numberWithUnsignedInt:name];
    NSNumber *number = [NSNumber numberWithUnsignedInt:value];
    
    [currentContext() setObject:number forKey:key];
}
//*/
#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//    Public Interface
//
//**********************************************************************************************************


EAGLContext *nglContextEAGL(void)
{

    EAGLContext *contextEAGL = [EAGLContext currentContext];
    if (contextEAGL == nil)
    {
        
        // The first context created will generate the sharegroup (usually done in the main thread).
        // NinevehGL shares all resources between all contexts, useful when changing multithreading.
        contextEAGL = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3 sharegroup:_nglGroup];
        _nglGroup = (_nglGroup) ? _nglGroup : contextEAGL.sharegroup;

        // Commit changes and set the new EAGLContext.
        [EAGLContext setCurrentContext:contextEAGL];
        
        NSLog(@"DEBUG: create ContextEAGL");
    }
    
    return contextEAGL;
}

void nglContextDeleteCurrent(void)
{
    // Commit changes and set the new EAGLContext.
    [EAGLContext setCurrentContext:nil];
}

//*
// With redundant state prevention.
void ngles2Default(void)
{
    // Checks for already defined states.
    if (contextValue(NGL_REF_DEFAULT) != YES)
    {
        contextSetValue(NGL_REF_DEFAULT, YES);
        
        // Setting default states.
        glHint(GL_GENERATE_MIPMAP_HINT, GL_FASTEST);
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
        glPixelStorei(GL_PACK_ALIGNMENT, 4);
    }
}

UInt32 nglColorToHexadecimal(GLKVector4 color)
{
    GLKVector4 rgba = (GLKVector4){ color.r * 255.0f, color.g * 255.0f, color.b * 255.0f, color.a * 255.0f };
    
    return ((int)rgba.r << 24) + ((int)rgba.g << 16) + ((int)rgba.b << 8) + (rgba.a);
}

void ngles2Color(GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha)
{
    // unsigned int reference = nglColorToHexadecimal((GLKVector4){ red, green, blue, alpha });
    unsigned int reference = nglColorToHexadecimal(GLKVector4Make(red, green, blue, alpha));
    
    // Checks for already defined states.
    if (contextValue(NGL_REF_COLOR) != reference)
    {
        contextSetValue(NGL_REF_COLOR, reference);
        
        glClearColor(red, green, blue, alpha);
    }
    
    NSLog(@"DEBUG: create ngles2Color");
}
 //*/

void ngles2Viewport(GLint x, GLint y, GLsizei width, GLsizei height)
{
    int reference = [[NSString stringWithFormat:@"%i%i%i%i", x, y, width, height] intValue];
    
    // Checks for already defined states.
    if (contextValue(NGL_REF_VIEWPORT) != reference)
    {
        contextSetValue(NGL_REF_VIEWPORT, reference);
        
        glViewport(x, y, width, height);
    }
}

void ngles2BindBuffer(GLenum target, GLuint buffer, BOOL caching)
{
    // Checks for already bound buffers.
    if (!caching || contextValue(target) != buffer)
    {
        contextSetValue(target, buffer);
        
        // Binds the new one.
        switch (target)
        {
            case GL_FRAMEBUFFER:
                _nglFramebuffer = (caching) ? buffer : _nglFramebuffer;
                glBindFramebuffer(target, buffer);
                break;
            case GL_RENDERBUFFER:
                _nglRenderbuffer = (caching) ? buffer : _nglRenderbuffer;
                glBindRenderbuffer(target, buffer);
                break;
            default:
                glBindFramebuffer(target, buffer);
                break;
        }
    }
}

GLuint ngles2CurrentFramebuffer(void)
{
    // Makes sure the last buffer bound by NinevehGL is also bound in the actual context.
    ngles2BindBuffer(GL_RENDERBUFFER, _nglRenderbuffer, YES);
    
    return _nglRenderbuffer;
}

GLuint ngles2CurrentRenderbuffer(void)
{
    // Makes sure the last buffer bound by NinevehGL is also bound in the actual context.
    ngles2BindBuffer(GL_FRAMEBUFFER, _nglFramebuffer, YES);
    
    return _nglFramebuffer;
}

void ngles2State(GLenum state, BOOL enable)
{
    // Checks for already defined states.
    if (contextValue(state) != enable)
    {
        contextSetValue(state, enable);
        
        // Defines the new one.
        if (enable)
        {
            glEnable(state);
        }
        else
        {
            glDisable(state);
        }
    }
}

void ngles2FrontCullFace(GLenum front, GLenum cull)
{
    // Checks for already defined states.
    if (contextValue(NGL_REF_FRONT) != front || contextValue(NGL_REF_CULL) != cull)
    {
        contextSetValue(NGL_REF_FRONT, front);
        contextSetValue(NGL_REF_CULL, cull);
        
        if (cull == NGL_NULL || front == NGL_NULL)
        {
            ngles2State(GL_CULL_FACE, NO);
        }
        else
        {
            // As a good OpenGL practice, cull setting should comes first.
            ngles2State(GL_CULL_FACE, YES);
            glCullFace(cull);
            glFrontFace(front);
        }
    }
}

void ngles2BlendAlpha(BOOL activate)
{
    ngles2State(GL_BLEND, activate);
    
    // Checks for already defined states.
    if (contextValue(NGL_REF_BLEND) != GL_ONE_MINUS_SRC_ALPHA)
    {
        contextSetValue(NGL_REF_BLEND, GL_ONE_MINUS_SRC_ALPHA);
        
        // Default alpha blend function.
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    }
}

BOOL nglVec4IsEqual(GLKVector4 vecA, GLKVector4 vecB)
{
    return (vecA.x == vecB.x && vecA.y == vecB.y && vecA.z == vecB.z && vecA.w == vecB.w);
}

NSString *nglGetFile(NSString *named)
{
    NSRange range;
    
    // Prevent Microsoft Windows path file format.
    named = [named stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
    
    range = [named rangeOfString:@"/" options:NSBackwardsSearch];
    
    if (range.length > 0)
    {
        named = [named substringFromIndex:range.location + 1];
    }
    
    return named;
}

void nglGlobalFilePath(NSString *filePath)
{
    nglRelease(nglDefaultPath);
    nglDefaultPath = [filePath copy];
}

NSString *nglMakePath(NSString *named)
{
    NSString *fullPath;
    
    // Prevent Microsoft Windows path files.
    named = [named stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
    
    // Assuming the path already contains the file path, checks if the file exist,
    // in afirmative case use it, otherwise, uses the default file path.
    if ([[NSFileManager defaultManager] fileExistsAtPath:named])
    {
        fullPath = named;
    }
    else
    {
        // Initializes the default path once.
        if (nglDefaultPath == nil)
        {
            nglGlobalFilePath([[NSBundle mainBundle] bundlePath]);
        }
        
        fullPath = [nglDefaultPath stringByAppendingPathComponent:nglGetFile(named)];
    }
    
    return fullPath;
}

