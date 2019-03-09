//
//  NGLFunction.h
//  Maze
//
//  Created by Zilong Wang on 2019/3/5.
//  Copyright © 2019年 bcit. All rights reserved.
//

#ifndef NGLFunction_h
#define NGLFunction_h

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <GLKit/GLKit.h>


#define NGL_NULL            0x00

#ifdef __cplusplus

// Extern instruction for C++ code.
#define NGL_API            extern "C" __attribute__((visibility ("default")))

#else

// Extern instruction for C code.
#define NGL_API            extern __attribute__((visibility ("default")))

#endif

#define nglRelease(x)        ({ if(x) { (x) = nil; } })
//[x release];

/*!
 *                    Defines a EAGLContext for the current running thread.
 *
 *                    If the context was already created, just returns the pointer to it. The created
 *                    instance will be internally retained.
 *
 *                    You must call <code>nglContextDeleteCurrent()</code> to delete the created context.
 *
 *    @result            A pointer to the created EAGLContext.
 */
NGL_API EAGLContext *nglContextEAGL(void);

/*!
 *                    Deletes the EAGLContext for the current running thread. This call must be called from
 *                    the thread you want to delete contexts (EAGLContext and NGLContext). Both contexts
 *                    work together, so they are also deleted together.
 */
NGL_API void nglContextDeleteCurrent(void);

/*!
 *                    Defines the initial default state for NinevehGL/OpenGL.
 *
 *                    This function sets the global hint for the mipmap level and the alignments for pixel
 *                    storage. Those values will be:
 *
 *                        - GL_GENERATE_MIPMAP_HINT = GL_FASTEST;
 *                        - GL_UNPACK_ALIGNMENT = 1;
 *                        - GL_PACK_ALIGNMENT = 4.
 *
 *                    As all NGLES2 functions, this one is made to avoid any kind of reduntant calls to
 *                    OpenGL ES states.
 */
NGL_API void ngles2Default(void);

/*!
 *                    Defines the clear color for OpenGL render.
 *
 *                    As all NGLES2 functions, this one is made to avoid any kind of reduntant calls to
 *                    OpenGL ES states.
 *
 *    @param            red
 *                    The red color. The range for this value is [0.0, 1.0].
 *
 *    @param            green
 *                    The green color. The range for this value is [0.0, 1.0].
 *
 *    @param            blue
 *                    The blue color. The range for this value is [0.0, 1.0].
 *
 *    @param            alpha
 *                    The alpha color. The range for this value is [0.0, 1.0].
 */
NGL_API void ngles2Color(GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha);

/*!
 *                    Defines the viewport size for OpenGL render.
 *
 *                    As all NGLES2 functions, this one is made to avoid any kind of reduntant calls to
 *                    OpenGL ES states.
 *
 *    @param            x
 *                    The X initial position of the viewport in pixels.
 *
 *    @param            y
 *                    The Y initial position of the viewport in pixels.
 *
 *    @param            width
 *                    The width of the viewport in pixels.
 *
 *    @param            height
 *                    The height of the viewport in pixels.
 */
NGL_API void ngles2Viewport(GLint x, GLint y, GLsizei width, GLsizei height);

/*!
 *                    Binds a buffer (frame or render) to the current OpenGL context.
 *
 *                    As all NGLES2 functions, this one is made to avoid any kind of reduntant calls to
 *                    OpenGL ES states.
 *
 *    @param            target
 *                    The target that will bound the buffer. Acceptable values are:
 *
 *                        - GL_FRAMEBUFFER;
 *                        - GL_RENDERBUFFER;
 *                        - GL_DRAW_FRAMEBUFFER_APPLE;
 *                        - GL_READ_FRAMEBUFFER_APPLE.
 *
 *    @param            buffer
 *                    The OpenGL buffer's name/id.
 *
 *    @param            caching
 *                    If YES, the target and buffer will be cached to avoid future redundant calls.
 *                    If it's NO, the old cache will be ignored and no new current buffer will be set.
 */
NGL_API void ngles2BindBuffer(GLenum target, GLuint buffer, BOOL caching);

/*!
 *                    Retrieves the last/current bound frame buffer.
 *
 *                    This function will bind the last/current frame buffer in the current EAGLContext,
 *                    if needed.
 */
NGL_API GLuint ngles2CurrentFramebuffer(void);

/*!
 *                    Retrieves the last/current bound render buffer.
 *
 *                    This function will bind the last/current render buffer in the current EAGLContext,
 *                    if needed.
 */
NGL_API GLuint ngles2CurrentRenderbuffer(void);

/*!
 *                    Enables or disables an OpenGL state.
 *
 *                    As all NGLES2 functions, this one is made to avoid any kind of reduntant calls to
 *                    OpenGL ES states.
 *
 *    @param            state
 *                    The state to change.
 *
 *    @param            enable
 *                    If YES the state will be turned on with glEnable(), if NO it will be disabled.
 */
NGL_API void ngles2State(GLenum state, BOOL enable);

/*!
 *                    Sets the front and cull face. Besides it will turn ON or OFF the cull face state.
 *
 *                    As all NGLES2 functions, this one is made to avoid any kind of reduntant calls to
 *                    OpenGL ES states.
 *
 *    @param            front
 *                    The front face setting. If it's null (NGL_NULL) the cull face state will be disabled.
 *
 *    @param            cull
 *                    The cull face setting. If it's null (NGL_NULL) the cull face state will be disabled.
 */
NGL_API void ngles2FrontCullFace(GLenum front, GLenum cull);

/*!
 *                    Turns ON or OFF the alpha blend.
 *
 *                    The value for the alpha blend will be GL_ONE_MINUS_SRC_ALPHA.
 *
 *                    As all NGLES2 functions, this one is made to avoid any kind of reduntant calls to
 *                    OpenGL ES states.
 *
 *    @param            activate
 *                    If YES the alpha blend will be turned ON, otherwise it will be turned OFF.
 */
NGL_API void ngles2BlendAlpha(BOOL activate);

#define nglFree(x)            ({ if(x) { free(x); (x) = NULL; } })

BOOL nglVec4IsEqual(GLKVector4 vecA, GLKVector4 vecB);


void nglGlobalFilePath(NSString *filePath);

NSString *nglMakePath(NSString *named);

#endif /* NGLFunction_h */
