
#import "NGLView.h"
#import "NGLFunctions.h"
// #import "NGLTimer.h"
// #import "NGLThread.h"
// #import "NGLArray.h"

// Parsers
// #import "NGLParserImage.h"

static NSString *const VIEW_ERROR_DELEGATE = @"Error while processing NGLView: The instance %@ can't be declared as a delegate instance \
because it doesn't implement the NGLViewDelegate protocol correctly. \n\
It should implements the drawView() method.";

@interface NGLView()

// Initializes a new instance.
- (void) initialize;

// Recreates the core engine.
- (void) updateCoreEngine;

// Deletes the current core engine.
- (void) deleteCoreEngine;

@end

#pragma mark Private Functions

// Recreates the buffers. This method sends a synchronous task to the core mesh thread.
static void fillCoreEngine(id <NGLCoreEngine> coreEngine)
{
    if (coreEngine != nil)
    {
        CGSize size = coreEngine.layer.bounds.size;
        
        // Avoids NGLView without a valid size.
        if (size.width == 0.0f || size.height == 0.0f)
        {
            NSLog(@"ERROR: init NGLView without a valid size.");
            return;
        }

        [coreEngine defineBuffers];
    }
    NSLog(@"DEBUG: fill Core Engine");
    
}

#pragma mark Implementation NGLView

@implementation NGLView

@dynamic delegate, useDepthBuffer, useStencilBuffer, framebuffer, renderbuffer, colorPointer;

- (BOOL) useDepthBuffer { return _useDepthBuffer; }
- (void) setUseDepthBuffer:(BOOL)value
{
    if (value != _useDepthBuffer)
    {
        _useDepthBuffer = value;
        
        // Every change in the engine entails in reconstructing the engine buffers.
        _engine.useDepthBuffer = _useDepthBuffer;
        fillCoreEngine(_engine);
    }
}

- (BOOL) useStencilBuffer { return _useStencilBuffer; }
- (void) setUseStencilBuffer:(BOOL)value
{
    if (value != _useStencilBuffer)
    {
        _useStencilBuffer = value;
        
        // Every change in the engine entails in reconstructing the engine buffers.
        _engine.useStencilBuffer = _useStencilBuffer;
        fillCoreEngine(_engine);
    }
}

- (UInt32) framebuffer { return _engine.framebuffer; }

- (UInt32) renderbuffer { return _engine.renderbuffer; }

- (GLKVector4 *) colorPointer { return &_color; }

#pragma mark Constructors

- (id) init
{
    if ((self = [super init]))
    {
        [self initialize];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self initialize];
    }
    
    return self;
}

- (id) initWithCoder:(NSCoder *)decoder
{
    if ((self = [super initWithCoder:decoder]))
    {
        [self initialize];
    }
    return self;
}

#pragma mark Private Methods

- (void) initialize
{
    // Settings.
    // _antialias = NGLAntialiasNone;
    _useDepthBuffer = YES;
    _useStencilBuffer = NO;
    _color = GLKVector4Make(0.3f, 0.4f, 0.5f, 1.0f);
    
    // Constructs the core engine but not initialize the buffers nor the timer.
    [self updateCoreEngine];
}

- (void) updateCoreEngine
{
    //    EAGL Settings
    NSString *color;
    CAEAGLLayer *eaglLayer;
    NSDictionary *layperProperties;
    
    BOOL isOpaque = YES;
    
    // Chooses the right color format.
    color = kEAGLColorFormatRGBA8;
    
    // Retains the last frame is not used by NinevehGL,
    // because the frame is reconstructed at every render cycle.
    layperProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,
                        color, kEAGLDrawablePropertyColorFormat,
                        nil];

    // Sets the properties to CAEALLayer, the Apple's Layer to present OpenGL graphics.
    eaglLayer = (CAEAGLLayer *)[self layer];
    [eaglLayer setOpaque:isOpaque];
    [eaglLayer setDrawableProperties:layperProperties];
    
    self.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    self.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    // Setting Engine
    // Clears the buffers and release the instance.
    [self deleteCoreEngine];
    
    // Starts the new engine.
    _engine = [[NGLEngine alloc] initWithLayer:self];
    
    // _engine.antialias = _antialias;
    _engine.useDepthBuffer = _useDepthBuffer;
    _engine.useStencilBuffer = _useStencilBuffer;
    
    // Fills the new core engine synchronously.
    fillCoreEngine(_engine);
    
    NSLog(@"DEBUG: updateCoreEngine");
}

- (void) deleteCoreEngine
{
    if (_engine != nil)
    {
        [_engine clearBuffers];
        _engine = nil;
    }
}

#pragma mark Self Public Methods

- (void) compileCoreEngine
{
    // Performs updates on the render thread.
    [self updateCoreEngine];
}

- (void) timerCallBack
{
    // Prepares a new render.
    [_engine preRender];
    
    // Custom draws.
    // [super.delegate glkView:self drawInRect:<#(CGRect)#>];
    
    // Commits the new render.
    [_engine render];
}

- (void) preRender
{
    [_engine preRender];
}

- (void) render
{
    [_engine render];
}


- (void) drawView
{
    // Does nothing here, just override.
}


// override
- (void) setBounds:(CGRect)value
{
    [super setBounds:value];
    
    // Avoids unecessary changes on the OpenGL buffers.
    if (_size.width != value.size.width || _size.height != value.size.height)
    {
        _size = value.size;
        fillCoreEngine(_engine);
    }
}
// override
- (void) setFrame:(CGRect)value
{
    [super setFrame:value];
    
    // Avoids unecessary changes on the OpenGL buffers.
    if (_size.width != value.size.width || _size.height != value.size.height)
    {
        _size = value.size;
        fillCoreEngine(_engine);
    }
}
//*/

- (void) setContentScaleFactor:(CGFloat)value
{
    float scale = self.contentScaleFactor;
    
    [super setContentScaleFactor:value];
    
    // Avoids unecessary changes on the OpenGL buffers.
    if (value != scale && value != 0.0f)
    {
        fillCoreEngine(_engine);
    }
}

GLKVector4 nglColorFromUIColor(UIColor *uiColor)
{
    CGColorRef cgColor = uiColor.CGColor;
    GLKVector4 color = GLKVector4Make(0, 0, 0, 0);
    
    size_t numComponents = CGColorGetNumberOfComponents(cgColor);
    const CGFloat *components = CGColorGetComponents(cgColor);
    
    switch (numComponents)
    {
        case 2:
            color.r = color.g = color.b = components[0];
            color.a = components[1];
            break;
        case 4:
            color.r = components[0];
            color.g = components[1];
            color.b = components[2];
            color.a = components[3];
            break;
        default:
            break;
    }
    
    return color;
}

UIColor *nglColorToUIColor(GLKVector4 color)
{
    return [UIColor colorWithRed:color.r green:color.g blue:color.b alpha:color.a];
}

- (UIColor *) backgroundColor { return nglColorToUIColor(_color); }
// override
- (void) setBackgroundColor:(UIColor *)value
{
    GLKVector4 newColor = nglColorFromUIColor(value);
    
    // Avoids unecessary changes on the OpenGL buffers.
    if (!nglVec4IsEqual(_color, newColor))
    {
        _color = newColor;
        fillCoreEngine(_engine);
    }
}

- (void) dealloc
{
    [self deleteCoreEngine];
}

+ (Class) layerClass
{
    return [CAEAGLLayer class];
}

+ (BOOL) accessInstanceVariablesDirectly
{
    return NO;
}

@end
