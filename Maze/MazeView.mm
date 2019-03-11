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
#import "NGLShader.h"
#import "math.h"

#include <stdlib.h>
#include <stdio.h>

static const int numRows = 4, numCols = 4;    // maze size
const float cameraHight = 0.2;

const GLKVector4 backgroundColor = GLKVector4Make(0.3f, 0.4f, 0.5f, 1.0f);
const GLKVector4 darkBackgroundColor = GLKVector4Make(0.15f, 0.2f, 0.25f, 1.0f);

@interface MazeView()
{
    @private
        NGLShader *   _shader;
        GLKView *     _view;
        NGLObject * _camera;
        GLKMatrix4  _perspective;
        NSMutableArray<Wall *> *_walls;
        Maze *mazeGenerate;
        Wall * _crate;
    
    float rotAngle_x, rotAngle_y, lastRotation_x, lastRotation_y, posX, lastPosX, posY, lastPosY;
    float _moveSpeed;
    
    BOOL _isDayLighting;
    BOOL _isFlashLightOn;
    BOOL _isFogOn;
    float _fogIntensity;

    
    float x;
    float z;
    float crateRotation;
}
@end

@implementation MazeView

- (void)setup:(GLKView *)view {
    
    _view = view;
    
    [self setupGL];
    
    [self createMaze];
    
    _camera = [[NGLObject alloc]init];
    [self initCameraLocation];
    
    _isDayLighting = true;
    _isFlashLightOn = true;
    _isFogOn = true;
    _fogIntensity = 0.5f;
    
    _moveSpeed = 0.05;
    
}

- (void) initCameraLocation
{
    _camera.position = GLKVector3Make(0, 0, cameraHight);
    _camera.rotation = GLKVector3Make(90, 0, 0);
    lastRotation_x = 90;
    lastRotation_y = 0;
    lastPosX = lastPosY = 0;
}


- (void)setupGL {
    // glEnable(GL_DEPTH_TEST);
    // 设置放大倍数
    // [self.view setContentScaleFactor:[[UIScreen mainScreen] scale]];

    _perspective = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), fabs(_view.bounds.size.width / _view.bounds.size.height), 0.1f, 150.0f);
    
    _shader = [[NGLShader alloc] init];
    [_shader use];
    
    // lighting
    glUniform4f(_shader.lightPositionHandle, 0.0f, 1.0f, 2.0f, 1.0f);
    glUniform4f(_shader.lightColorHandle, 1.0f, 240.0/255.0f, 210.0f/255.0f, 1.0f);
    
    // fog
    glUniform1f(_shader.fogEndHandle, 4.0f);
    // factor = end - start
    glUniform1f(_shader.fogFactorHandle, 3.6f);
    glUniform4f(_shader.fogColorHandle, 0.28f, 0.3f, 0.33f, 1.0f);
    
    [self updateLighting];
}


- (void)createMaze
{
    _walls = [[NSMutableArray alloc]init];
    
    _crate = [self createCrate: 0 col:0];
    
    [_walls addObject:_crate];
    
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
            [_walls addObject:[self createFloor:-j col:i]];
        }
    }
}

- (Wall *)createSouthWall:(int) row col:(int)col
{
    Wall* wall = [[Wall alloc] initWithShader:_shader view:_view];
    
    wall.position = GLKVector3Make(row , col - 0.45, 0);
    wall.scale = GLKVector3Make(1.0f, 0.1f, 1.0f);
    
    wall.textureImage = @"south.jpg";
    return wall;
}

- (Wall *)createNorthWall:(int) row col:(int)col
{
    Wall * wall = [[Wall alloc] initWithShader:_shader view:_view];
    
    wall.position = GLKVector3Make(row , col + 0.45, 0);
    wall.scale = GLKVector3Make(1.0f, 0.1f, 1.0f);
    
    wall.textureImage = @"north.jpg";
    return wall;
}

- (Wall *)createEastWall:(int) row col:(int)col
{
    Wall * wall = [[Wall alloc] initWithShader:_shader view:_view];
    
    wall.position = GLKVector3Make(row + 0.45, col, 0);
    wall.scale = GLKVector3Make(0.1f, 1.0f, 1.0f);
    
    wall.textureImage = @"east.jpg";
    return wall;
}

- (Wall *)createWestWall:(int) row col:(int)col
{
    Wall * wall = [[Wall alloc] initWithShader:_shader view:_view];
    
    wall.position = GLKVector3Make(row - 0.45, col, 0);
    wall.scale = GLKVector3Make(0.1f, 1.0f, 1.0f);
    
    wall.textureImage = @"west.jpg";
    return wall;
}
- (Wall *)createFloor:(int) row col:(int)col
{
    Wall * wall = [[Wall alloc] initWithShader:_shader view:_view];
    
    wall.position = GLKVector3Make(row, col, - 0.45);
    wall.scale = GLKVector3Make(1.0f, 1.0f, 0.05f);
    
    wall.textureImage = @"floor.jpg";
    return wall;
}

- (Wall *)createCrate:(int) row col:(int)col
{
    Wall* wall = [[Wall alloc] initWithShader:_shader view:_view];
    
    float scale = 0.4f;
    wall.position = GLKVector3Make(row, col + 1, - 0.45 + scale/2);
    wall.scale = GLKVector3Make(scale, scale, scale);
    
    wall.textureImage = @"crate.jpg";
    return wall;
}

- (void) updateRotatingCrate:(double) deltaTime
{
    crateRotation += 25 * deltaTime;
    while (crateRotation >= 360.0f)
        crateRotation -= 360.0f;
    
    _crate.rotation = GLKVector3Make(0, 0, crateRotation);
    
}

- (void) updateCamera:(double) deltaTime
{
    //    x -= deltaTime;
    // z -= 25 * deltaTime;
    //    _camera.position = GLKVector3Make(0, 0, 0.2f);
    //    _camera.rotation = GLKVector3Make(90, 0, 0);
}

- (void) updateLighting
{
    // intensity, 0-100;
    glUniform1f(_shader.lightAttenuationHandle, _isDayLighting? 50.0f: 0.9f);
    GLKVector4 bgcolor = _isDayLighting? backgroundColor : darkBackgroundColor;
    glClearColor(bgcolor.r, bgcolor.g, bgcolor.b, bgcolor.a);
    
    glUniform1i(_shader.fogOnHandle, _isFogOn);
    // NSLog(@"%f", _fogIntensity);
    glUniform1f(_shader.fogIntensityHandle, 1.1f - _fogIntensity);
}

- (void)update:(double) deltaTime {

    [self updateRotatingCrate:deltaTime];
    [self updateCamera:deltaTime];
    [self updateLighting];
    
    bool invertible;
    GLKMatrix4 viewMatrix = GLKMatrix4Invert(_camera.modelMatrix, &invertible);
    if(!invertible){
        NSLog(@"ERROR: view matrix is not invertible");
    }
    
    GLKMatrix4 projectionMatrix = GLKMatrix4Multiply(_perspective, viewMatrix);
    
    for (Wall* wall in _walls) {
        wall.viewProjectionMatrix = projectionMatrix;
        // model.viewMatrix = viewMat;
        [wall update:deltaTime];
    }
}

- (void)draw:(CGRect)drawRect {
    
    for (Wall* wall in _walls) {
        [wall draw];
    }
    
}

#pragma mark interactions

- (void) switchDayNight
{
    _isDayLighting = !_isDayLighting;
}

- (void) switchFlashLight
{
    _isFlashLightOn = !_isFlashLightOn;
}


- (void) switchFog
{
    _isFogOn = !_isFogOn;
}

- (void) setFogIntensity:(float) value
{
    _fogIntensity = value;
}

- (void) moveForward
{
    posX = _camera.position.x - _moveSpeed * sinf(_camera.rotation.y / 180 * M_PI);
    posY = _camera.position.y + _moveSpeed * cosf(_camera.rotation.y / 180 * M_PI);
    _camera.position = GLKVector3Make(posX, posY, cameraHight);
}

- (void) lookAround:(CGPoint) translation isEnd:(Boolean)isEnd
{

    rotAngle_y = lastRotation_y - translation.x * 0.6; // 0.6 sensitivity
    rotAngle_x = lastRotation_x; // - translation.y; // never move
    // rotate two axis, implement in camera - todo

    while (rotAngle_x >= 360.0f)
        rotAngle_x -= 360.0f;
    while (rotAngle_y >= 360.0f)
        rotAngle_y -= 360.0f;
    while (rotAngle_x <= -360.0f)
        rotAngle_x += 360.0f;
    while (rotAngle_y <= -360.0f)
        rotAngle_y += 360.0f;
    
    _camera.rotation = GLKVector3Make(rotAngle_x, rotAngle_y, 0);
    
    NSLog(@"%f/%f : %f/%f", translation.x, rotAngle_x, translation.y, rotAngle_y);
    
    if(isEnd){
        lastRotation_x = _camera.rotation.x;
        lastRotation_y = _camera.rotation.y;
    }
}

- (void) resetCamera
{
    [self initCameraLocation];
}

@end
