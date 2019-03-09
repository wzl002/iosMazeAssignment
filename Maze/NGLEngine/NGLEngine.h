//
//  NGLEngine.h
//  Maze
//
//  Created by Zilong Wang on 2019/3/5.
//  Copyright © 2019年 bcit. All rights reserved.
//

#ifndef NGLEngine_h
#define NGLEngine_h

#import <GLKit/GLKit.h>


@class NGLView;


@protocol NGLCoreEngine <NSObject>

@required


@property (nonatomic, readonly) BOOL isReady;

@property (nonatomic) BOOL useDepthBuffer;

@property (nonatomic) BOOL useStencilBuffer;

@property (nonatomic, assign) NGLView *layer;

@property (nonatomic, readonly) unsigned int framebuffer;

@property (nonatomic, readonly) unsigned int renderbuffer;

@property (nonatomic, readonly) CGSize size;

/*!
 *                    Initiates the NGLCoreEngine class with a NGLView.
 *
 *                    This method initializes a NGLCoreEngine instance and set its layer.
 *
 *    @param            layer
 *                    A NGLView instance. All the following render settings will be made based on this
 *                    layer and the render will be shown on it.
 *
 *    @result            A new instance of NGLCoreEngine.
 */
- (id) initWithLayer:(NGLView *)layer;

/*!
 *                    Constructs the Frame and Render Buffers. Must be called to start the OpenGL buffers.
 *
 *                    This method constructs the bridge between OpenGL render and device's window system.
 *                    The window system is responsible for drawing the image on the device's screen.
 *
 *                    This method should be called every time the layer change its properties, like
 *                    size, position or color.
 */
- (void) defineBuffers;

/*!
 *                    Clean up all the buffers (Frame and Render Buffers). Must be called to delete the
 *                    OpenGL buffers.
 *
 *                    This method erases all the buffers in this engine and make it empty again.
 *
 *                    This method should be called by the NGLCoreEngine owner before release it.
 */
- (void) clearBuffers;

/*!
 *                    The first method to be called at each render cycle.
 *
 *                    This method should be called to make a clean up and reset any necessary variable
 *                    to start a new render cycle.
 */
- (void) preRender;

/*!
 *                    The last method to be called at each render cycle.
 *
 *                    This method will deal with the Frame and Render Buffers, with the filters and
 *                    any other necessary process to produce the final image. Then it will output the
 *                    render's image to the desired surface previously defined.
 */
- (void) render;

/*!
 *                    Gets the pixel color into a specific point in the current frame buffer.
 *
 *                    The pixel color will be retrieved in the current state, that means no new render
 *                    will be produced.
 *
 *    @param            point
 *                    A CGPoint structure.
 *
 *    @result            A NGLivec4 representing the four components of the color: RGBA.
 */
- (GLKVector4) pixelColorAtPoint:(CGPoint)point;

@end

@interface NGLEngine : NSObject<NGLCoreEngine>
{
@private
    EAGLContext                *_context;
    // NGLView                    *_layer;
    
    GLbitfield                _clearBuffer;
    GLenum                    *_discards;
    GLsizei                    _discardCount;
    GLsizei                    _width;
    GLsizei                    _height;
    
    // Normal Buffers
    GLuint                    _frameBuffer;
    GLuint                    _colorBuffer;
    GLuint                    _depthBuffer;
    GLuint                    _stencilBuffer;
    
    // Multisample Buffers
    GLuint                    _msaaFrameBuffer;
    GLuint                    _msaaColorBuffer;
    GLuint                    _msaaDepthBuffer;
    
    BOOL                    _useDepthBuffer;
    BOOL                    _useStencilBuffer;
    BOOL                    _isReady;
    
    // ReadPixels APIs
    unsigned char            *_offscreenData;
    
    // Error API
    //    NGLError                *_error;
}

@end


#endif /* NGLEngine_h */
