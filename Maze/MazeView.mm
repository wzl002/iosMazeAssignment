//
//  MazeView.m
//  Maze
//
//  Created by Zilong Wang on 2019/3/7.
//  Copyright © 2019 bcit. All rights reserved.
//
#import "MazeView.h"
#include <chrono>
#include "maze.hpp"
#include "GLESRenderer.hpp"
#import <AVFoundation/AVFoundation.h>

#include <stdlib.h>
#include <stdio.h>

static const int numRows = 4, numCols = 4;    // maze size

@interface MazeView()
{
    @private
        NGLProgram *   _program;
        GLKView *     _view;
        NSMutableArray<Wall *> *_walls;
        float _rotate;
        Maze *mazeGenerate;
}
@end

@implementation MazeView

- (void)setup:(GLKView *)view {
    
    _view = view;
    
    [self setupGL];
    
    [self createMaze];
}


- (void)setupGL {
    // glEnable(GL_DEPTH_TEST);
    // 设置放大倍数
    // [self.view setContentScaleFactor:[[UIScreen mainScreen] scale]];

    //shader
//    _program = [[NGLProgram alloc] init];
//
//    [_program setVertexFile:@"Shader.vertsh" fragmentFile:@"Shader.fragsh"];
//
//    [_program use];
    
    self.shader = [self loadShaders:@"Shader"];
    
    glUseProgram(self.shader);
    
    [self setupTexture:@"for_test"];
    
    // wall.scale = 0.5;
    _rotate = 0;
    
}


- (void)createMaze
{
    _walls = [[NSMutableArray alloc]init];
    mazeGenerate = new Maze(numRows, numCols);
    mazeGenerate->Create();
    
    // box test
//    [_walls addObject:[self createSouthWall:0 col:1]];
//     [_walls addObject:[self createNorthWall:0 col:1]];
//     [_walls addObject:[self createEastWall:0 col:1]];
//     [_walls addObject:[self createWestWall:0 col:1]];
//    [_walls addObject:[self createSouthWall:0 col:0]];
//    [_walls addObject:[self createNorthWall:0 col:0]];
//    [_walls addObject:[self createEastWall:0 col:0]];
//    [_walls addObject:[self createWestWall:0 col:0]];
    
    int i, j;
    for (i=numRows-1; i>=0; i--) {
        for (j=numCols-1; j>=0; j--) {    // top
            printf(" %c ", mazeGenerate->GetCell(i, j).southWallPresent ? '-' : ' ');
        }
        printf("\n");
        for (j=numCols-1; j>=0; j--) {    // left/right
            printf("%c", mazeGenerate->GetCell(i, j).eastWallPresent ? '|' : ' ');
            printf("%c", ((i+j) < 1) ? '*' : ' ');
            printf("%c", mazeGenerate->GetCell(i, j).westWallPresent ? '|' : ' ');
        }
        printf("\n");
        for (j=numCols-1; j>=0; j--) {    // bottom
            printf(" %c ", mazeGenerate->GetCell(i, j).northWallPresent ? '-' : ' ');
        }
        printf("\n");
    }
    
    // Coordinate system of print maze is diff from screen Coordinate
    // 3:3 3:2 3:1      -3:3 -2:3 -1:3
    // 2:3 2:2 2:1  =>  -3:2 -2:2 -1:2
    // 1:3 1:2 1:1      -3:1 -2:1 -1:1
    
    // The map direction is also reversed
    // south <-> north, west <-> east
    
    for (i=numRows-1; i>=0; i--) {
        for (j=numCols-1; j>=0; j--) {
            if(mazeGenerate->GetCell(i, j).southWallPresent){
                NSLog(@"Create south wall at %d : %d", -j, i);
                [_walls addObject:[self createNorthWall:-j col:i]];
            }
            if(mazeGenerate->GetCell(i, j).northWallPresent){
                [_walls addObject:[self createSouthWall:-j col:i]];
            }
            if(mazeGenerate->GetCell(i, j).eastWallPresent){
                [_walls addObject:[self createWestWall:-j col:i]];
            }
            if(mazeGenerate->GetCell(i, j).westWallPresent){
                [_walls addObject:[self createEastWall:-j col:i]];
            }
        }
    }
}

- (Wall *)createSouthWall:(int) row col:(int)col
{
    Wall* wall = [[Wall alloc] initWithShader:self.shader view:_view];
    
    wall.position = GLKVector3Make(row , col - 0.45, 0);
    wall.scale = GLKVector3Make(1.0f, 0.1f, 1.0f);
    
    wall.textureImage = @"south.jpg";
    return wall;
}

- (Wall *)createNorthWall:(int) row col:(int)col
{
    Wall * wall = [[Wall alloc] initWithShader:self.shader view:_view];
    
    wall.position = GLKVector3Make(row , col + 0.45, 0);
    wall.scale = GLKVector3Make(1.0f, 0.1f, 1.0f);
    
    wall.textureImage = @"north.jpg";
    return wall;
}

- (Wall *)createEastWall:(int) row col:(int)col
{
    Wall * wall = [[Wall alloc] initWithShader:self.shader view:_view];
    
    wall.position = GLKVector3Make(row + 0.45, col, 0);
    wall.scale = GLKVector3Make(0.1f, 1.0f, 1.0f);
    
    wall.textureImage = @"east.jpg";
    return wall;
}

- (Wall *)createWestWall:(int) row col:(int)col
{
    Wall * wall = [[Wall alloc] initWithShader:self.shader view:_view];
    
    wall.position = GLKVector3Make(row - 0.45, col, 0);
    wall.scale = GLKVector3Make(0.1f, 1.0f, 1.0f);
    
    wall.textureImage = @"west.jpg";
    return wall;
}

- (void)update:(double) deltaTime {

    for (Wall* wall in _walls) {
        // model.modelViewProjectionMatrix = projectionMat;
        // model.viewMatrix = viewMat;
        [wall update:deltaTime];
    }
}

- (void)draw:(CGRect)drawRect {
    
    for (Wall* wall in _walls) {
        // model.modelViewProjectionMatrix = projectionMat;
        // model.viewMatrix = viewMat;
        [wall draw];
    }
    
}



/**
 *  c语言编译流程：预编译、编译、汇编、链接
 *  glsl的编译过程主要有glCompileShader、glAttachShader、glLinkProgram三步；
 *
 *  @return program
 */
- (GLuint)loadShaders:(NSString *)shaderName {
    //file
    NSString* vert = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"vertsh"];
    NSString* frag = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"fragsh"];
    
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
        glGetProgramInfoLog(self.shader, sizeof(messages), 0, &messages[0]);
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
