//
//  MazeRenderer.m
//  Maze
//
//  Created by Zilong Wang on 2019/2/6.
//  Copyright © 2019 bcit. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "MazeRenderer.h"
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#include <chrono>
#include "maze.hpp"
#include "GLESRenderer.hpp"

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "Wall.h"
#import "NGLProgram.h"

@interface MazeRenderer()
@property (nonatomic , strong) EAGLContext* myContext;
@property (nonatomic , strong) CAEAGLLayer* myEagLayer;
@property (nonatomic , assign) GLuint       myProgram;
@property (nonatomic , assign) GLKView*     view;
// @property (nonatomic , strong) GLKBaseEffect* mEffect;

@property (nonatomic , assign) GLuint myColorRenderBuffer;
@property (nonatomic , assign) GLuint myColorFrameBuffer;



@end

@implementation MazeRenderer{
    Wall *wall;
    float _rotate;
}


- (void)setup:(GLKView *)view {
    
    self.view = view;
    
    // [self setupLayer];
    
    // [self setupContext];
    
    [self setupGL];
    
    // [self setupShader];
    
    //[self uploadTexture];
    
    // [self destoryRenderAndFrameBuffer];
    
    // [self setupRenderBuffer];
    
    // [self setupFrameBuffer];
    
}

- (void)setup {
    
    // [self setupLayer];
    
    // [self setupContext];
    
    [self setupGL];
    
    // [self setupShader];
    
    //[self uploadTexture];
    
//    [self destoryRenderAndFrameBuffer];
//
//    [self setupRenderBuffer];
//    
//    [self setupFrameBuffer];
    
}

- (void)setupContext {
    
    EAGLContext* context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!context) {
        NSLog(@"Failed to initialize OpenGLES context");
        exit(1);
    }
    
    self.view.context = self.myContext = context;
    self.view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    self.view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    // 设置为当前上下文
    if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
    
    glEnable(GL_DEPTH_TEST);
}

- (void)setupGL {
    //shader
    // NGLProgram * _shader =
    self.myProgram = [self loadShaders:@"Shaderf"];
    
    glUseProgram(self.myProgram);
    
//    wall = [[Wall alloc] initWithShader:self.myProgram view:self.view];
//    
//    wall.position = GLKVector3Make(0.0, 0.0, 0);
//    wall.rotation = GLKVector3Make(0.0, 30.0, 0);
    // wall.scale = 0.5;
    _rotate = 0;
    
}




- (void)update:(double) deltaTime {
    _rotate += 5;
    wall.rotation = GLKVector3Make(0.0, _rotate, 0);
    [wall update:deltaTime];
}

- (void)draw:(CGRect)drawRect {

    [wall draw];

}



/**
 *  c语言编译流程：预编译、编译、汇编、链接
 *  glsl的编译过程主要有glCompileShader、glAttachShader、glLinkProgram三步；
 *
 *  @return program
 */
- (GLuint)loadShaders:(NSString *)shaderName {
    //file
    NSString* vert = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"vsh"];
    NSString* frag = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"fsh"];
    
    GLuint verShader, fragShader;
    GLint program = glCreateProgram();
    
    //compile
    [self compileShader:&verShader type:GL_VERTEX_SHADER file:vert];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:frag];
    
    glAttachShader(program, verShader);
    glAttachShader(program, fragShader);
    
    // link
    glLinkProgram(program);
    
    GLint linkSuccess;
    glGetProgramiv(program, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) { //连接错误
        GLchar messages[256];
        glGetProgramInfoLog(self.myProgram, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"error%@", messageString);
    }
    
    //release shader
    glDeleteShader(verShader);
    glDeleteShader(fragShader);
    
    return program;
}

- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {
    //读取字符串
    NSString* content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar* source = (GLchar *)[content UTF8String];
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
}



- (void)setupLayer
{
    self.myEagLayer = (CAEAGLLayer*) self.view.layer;
    //设置放大倍数
    [self.view setContentScaleFactor:[[UIScreen mainScreen] scale]];
    
    // CALayer 默认是透明的，必须将它设为不透明才能让其可见
    self.myEagLayer.opaque = YES;
    
    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    self.myEagLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}



- (void)setupRenderBuffer {
    GLuint buffer;
    glGenRenderbuffers(1, &buffer);
    self.myColorRenderBuffer = buffer;
    glBindRenderbuffer(GL_RENDERBUFFER, self.myColorRenderBuffer);
    // 为 颜色缓冲区 分配存储空间
    [self.myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myEagLayer];
}


- (void)setupFrameBuffer {
    GLuint buffer;
    glGenFramebuffers(1, &buffer);
    self.myColorFrameBuffer = buffer;
    // 设置为当前 framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, self.myColorFrameBuffer);
    // 将 _colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, self.myColorRenderBuffer);
}


- (void)destoryRenderAndFrameBuffer
{
    glDeleteFramebuffers(1, &_myColorFrameBuffer);
    self.myColorFrameBuffer = 0;
    glDeleteRenderbuffers(1, &_myColorRenderBuffer);
    self.myColorRenderBuffer = 0;
}




- (GLuint)setupTexture:(NSString *)fileName {
    // 1获取图片的CGImageRef
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    // 2 读取图片的大小
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte * spriteData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte)); //rgba 4 bytes
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,
                                                       CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    // 3在CGContextRef上绘图
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGContextRelease(spriteContext);
    
    // 4绑定纹理到默认的纹理ID（这里只有一张图片，故而相当于默认于片元着色器里面的colorMap，如果有多张图不可以这么做）
    glBindTexture(GL_TEXTURE_2D, 0);
    
    
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    float fw = width, fh = height;
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    free(spriteData);
    return 0;
}
@end
