//
//  MGLView.h
//  Maze
//
//  Created by Zilong Wang on 2019/3/5.
//  Copyright © 2019 bcit. All rights reserved.
//



#ifndef MGLView_h
#define MGLView_h

#import <GLKit/GLKit.h>
#import "NGLEngine.h"

@class NGLView;


//@protocol NGLViewDelegate <NSObject>
//
//@required
//
//- (void) drawView;
//
//@end

@interface NGLView : GLKView
{
@private
    // States.
//    BOOL                    _paused;
//    BOOL                    _offscreen;
//    id <NGLViewDelegate>    _delegate;
    
    // NGLAntialias            _antialias;
    NGLEngine *             _engine;
    BOOL                    _useDepthBuffer;
    BOOL                    _useStencilBuffer;
    
    // Helpers.
    CGSize                    _size;
    GLKVector4                _color;
}

// @property (nonatomic, getter = isPaused) BOOL paused;

// @property(nonatomic, assign) IBOutlet id <NGLViewDelegate> delegate;

// @property (nonatomic) NGLAntialias antialias;

@property (nonatomic) BOOL useDepthBuffer;

@property (nonatomic) BOOL useStencilBuffer;

@property (nonatomic, readonly) UInt32 framebuffer;

@property (nonatomic, readonly) UInt32 renderbuffer;


// background color
@property (nonatomic, readonly) GLKVector4 *colorPointer;

/*!
 *                    Compiles the final engine and constructs the OpenGL's buffers. This method is called
 *                    automatically when the NGLView is initialized.
 *
 *                    This method should be called only after a change in the properties that affect the
 *                    view's size, color or layer.
 *
 *                    Calling this method will fire the render cycle, that means, if this NGLView was
 *                    paused, it will be resumed.
 */
- (void) compileCoreEngine;

- (void) preRender;

- (void) render;

@end


#endif /* MGLView_h */
