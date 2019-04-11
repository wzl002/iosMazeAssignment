//
//  MazeView.m
//  Maze
//
//  Created by Zilong Wang on 2019/3/7.
//  Copyright © 2019 bcit. All rights reserved.
//
#import "MazeView.h"

#import <AVFoundation/AVFoundation.h>
#import "NGLShader.h"
#import "math.h"
#import "ObjSample.h"

#import "ObjBrick.h"

#include "GLESRenderer.hpp"
#include <stdlib.h>
#include <stdio.h>


//#include "btBulletDynamicsCommon.h"
#define ARRAY_SIZE_Y 5
#define ARRAY_SIZE_X 5
#define ARRAY_SIZE_Z 5

//#include "LinearMath/btVector3.h"
//#include "LinearMath/btAlignedObjectArray.h"

static const int numRows = 4, numCols = 4;

 // maze size
const float cameraHight = 0.2;

const GLKVector4 backgroundColor = GLKVector4Make(0.3f, 0.4f, 0.5f, 1.0f);
const GLKVector4 darkBackgroundColor = GLKVector4Make(0.15f, 0.2f, 0.25f, 1.0f);

@interface MazeView()
{
    @private
        NGLShader *   _shader;
        GLKView *     _view;

        GLKMatrix4  _projectionMatrix;
        GLKMatrix4  _viewMatrix;
    
        NSMutableArray<Wall *> *_walls;
        Wall * _crate;
    // ObjSample * _obj;
    // ObjBrick * _obj2;
    Dog * dog;
    
    float rotAngle_x, rotAngle_y, lastRotation_x, lastRotation_y, posX, lastPosX, posY, lastPosY;
    float _moveSpeed;
    
    BOOL _isDayLighting;
    BOOL _isFlashLightOn;
    BOOL _isFogOn;
    float _fogIntensity;

    GLKVector4 _flashLightDirection;
    
    float x;
    float z;
    float crateRotation;
    
    
}

@end

@implementation MazeView
{
    //Skipped...
    
    //New variables
//    btBroadphaseInterface*                  _broadphase;
//    btDefaultCollisionConfiguration*        _collisionConfiguration;
//    btCollisionDispatcher*                  _dispatcher;
//    btSequentialImpulseConstraintSolver*    _solver;
//    btDiscreteDynamicsWorld*                _world;
}


- (void)setup:(GLKView *)view {
    
    _view = view;
    
    [self setupGL];
    
    [self createMaze];
    
    _camera = [[NGLObject alloc]init];
    [self initCameraLocation];
    
    _isDayLighting = true;
    _isFlashLightOn = true;
    _isFogOn = false;
    _fogIntensity = 0.5f;
    
    _flashLightDirection = GLKVector4Make(0, 0, -1, 0);
    _moveSpeed = 0.05;
    
}

- (void) initCameraLocation
{
    _camera.position = GLKVector3Make(0, -1.0, cameraHight);
    _camera.rotation = GLKVector3Make(90, 0, 0);
    lastRotation_x = 90;
    lastRotation_y = 0;
    lastPosX = lastPosY = 0;
}


- (void)setupGL {
    // glEnable(GL_DEPTH_TEST);
    // set scale
    // [self.view setContentScaleFactor:[[UIScreen mainScreen] scale]];

    _projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), fabs(_view.bounds.size.width / _view.bounds.size.height), 0.1f, 150.0f);
    
    _shader = [[NGLShader alloc] init];
    [_shader use];
    
    // lighting
    glUniform4f(_shader.lightColorHandle, 1.0f, 240.0/255.0f, 210.0f/255.0f, 1.0f);
    glUniform4f(_shader.lightDirectionHandle, 0.0f, 0.8f, 0.0f, 1.0f);
    
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
    
    dog = [self createObj: 0 col:0];
   // _obj2 = [self createBrick: 0 col:1];
    
   _crate = [self createCrate: 0 col:0];
    
   // [_walls addObject:_crate];
    
    _mazeGenerate = new Maze(numRows, numCols);
    _mazeGenerate->Create();
    
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
            printf(" %c ", _mazeGenerate->GetCell(i, j).southWallPresent ? '-' : ' ');
        }
        printf("\n");
        for (j=numCols-1; j>=0; j--) {    // left/right
            printf("%c", _mazeGenerate->GetCell(i, j).eastWallPresent ? '|' : ' ');
            printf("%c", ((i+j)< 1) ? '*' : ' ');
            printf("%c", _mazeGenerate->GetCell(i, j).westWallPresent ? '|' : ' ');
        }
        printf("\n");
        for (j=numCols-1; j>=0; j--) {    // bottom
            printf(" %c ", _mazeGenerate->GetCell(i, j).northWallPresent ? '-' : ' ');
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
            if(_mazeGenerate->GetCell(i, j).southWallPresent){
                // NSLog(@"Create south wall at %d : %d", -j, i);
                [_walls addObject:[self createNorthWall:-j col:i]];
            }
            if(_mazeGenerate->GetCell(i, j).northWallPresent){
                [_walls addObject:[self createSouthWall:-j col:i]];
            }
            if(_mazeGenerate->GetCell(i, j).eastWallPresent){
                [_walls addObject:[self createWestWall:-j col:i]];
            }
            if(_mazeGenerate->GetCell(i, j).westWallPresent){
                [_walls addObject:[self createEastWall:-j col:i]];
            }
            [_walls addObject:[self createFloor:-j col:i]];
        }
    }
}

- (Wall *)createSouthWall:(int) row col:(int)col
{
    Wall* wall = [[Wall alloc] initWithShader:_shader];
    
    wall.position = GLKVector3Make(row , col - 0.45, 0);
    wall.scale = GLKVector3Make(1.0f, 0.1f, 1.0f);
    
    wall.textureImage = @"south.jpg";
    return wall;
}

- (Wall *)createNorthWall:(int) row col:(int)col
{
    Wall * wall = [[Wall alloc] initWithShader:_shader];
    
    wall.position = GLKVector3Make(row , col + 0.45, 0);
    wall.scale = GLKVector3Make(1.0f, 0.1f, 1.0f);
    
    wall.textureImage = @"north.jpg";
    return wall;
}

- (Wall *)createEastWall:(int) row col:(int)col
{
    Wall * wall = [[Wall alloc] initWithShader:_shader];
    
    wall.position = GLKVector3Make(row + 0.45, col, 0);
    wall.scale = GLKVector3Make(0.1f, 1.0f, 1.0f);
    
    wall.textureImage = @"east.jpg";
    return wall;
}

- (Wall *)createWestWall:(int) row col:(int)col
{
    Wall * wall = [[Wall alloc] initWithShader:_shader];
    
    wall.position = GLKVector3Make(row - 0.45, col, 0);
    wall.scale = GLKVector3Make(0.1f, 1.0f, 1.0f);
    
    wall.textureImage = @"west.jpg";
    return wall;
}
- (Wall *)createFloor:(int) row col:(int)col
{
    Wall * wall = [[Wall alloc] initWithShader:_shader];
    
    wall.position = GLKVector3Make(row, col, - 0.45);
    wall.scale = GLKVector3Make(1.0f, 1.0f, 0.05f);
    
    wall.textureImage = @"floor.jpg";
    return wall;
}

- (Wall *)createCrate:(int) row col:(int)col
{
    Wall* wall = [[Wall alloc] initWithShader:_shader];
    
    float scale = 0.4f;
    wall.position = GLKVector3Make(row, col, - 0.45 + scale/2);
    wall.scale = GLKVector3Make(scale, scale, scale);
    
    wall.textureImage = @"crate.jpg";
    return wall;
}

- (Dog *)createObj:(int) row col:(int)col
{
    Dog* wall = [[Dog alloc] initWithShader:_shader];
    
    float scale = 0.01f;
    wall.position = GLKVector3Make(row, col, - 0.45 + scale/2);
    wall.scale = GLKVector3Make(scale, scale, scale);
    
    return wall;
}

- (ObjBrick *)createBrick:(int) row col:(int)col
{
    ObjBrick* wall = [[ObjBrick alloc] initWithShader:_shader];
    
    float scale = 0.4f;
    wall.position = GLKVector3Make(row, col, - 0.45 + scale/2);
    wall.scale = GLKVector3Make(scale, scale, scale);
    
    return wall;
}

- (void) updateRotatingCrate:(double) deltaTime
{
    crateRotation += 25 * deltaTime;
    while (crateRotation >= 360.0f)
        crateRotation -= 360.0f;
    
    _crate.rotation = GLKVector3Make(0, 0, crateRotation);
    // dog.rotation = GLKVector3Make(0, 0, crateRotation);
    // _obj2.rotation = GLKVector3Make(0, 0, crateRotation);
    
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
    glUniform1f(_shader.lightAttenuationHandle, _isDayLighting? 1.0f: 0.3f);
    GLKVector4 bgcolor = _isDayLighting? backgroundColor : darkBackgroundColor;
    glUniform4f(_shader.lightColorHandle, 250.0f/255.0, 1.0, 175.0f/255.0, 1.0);
    glClearColor(bgcolor.r, bgcolor.g, bgcolor.b, bgcolor.a);
    
    glUniform1i(_shader.fogOnHandle, _isFogOn);
    // NSLog(@"%f", _fogIntensity);
    glUniform1f(_shader.fogIntensityHandle, 1.1f - _fogIntensity);
    
    glUniform1i(_shader.flashLightOnHandle, _isFlashLightOn);
    
    // _flashLightDirection
    GLKMatrix4MultiplyVector4(_camera.rotationMatrix, _flashLightDirection);
    glUniform4fv(_shader.flashLightDirectionHandle, 1, GLKMatrix4MultiplyVector4(_camera.rotationMatrix, _flashLightDirection).v);
    
}

- (void)update:(double) deltaTime {

    [self updateRotatingCrate:deltaTime];
    [self updateCamera:deltaTime];
    [self updateLighting];
    
    bool invertible;
    _viewMatrix = GLKMatrix4Invert(_camera.modelMatrix, &invertible);
    if(!invertible){
        NSLog(@"ERROR: view matrix is not invertible");
    }

    GLKMatrix4 viewProjectionMatrix = GLKMatrix4Multiply(_projectionMatrix, _viewMatrix);
    
    for (Wall* wall in _walls) {
        wall.viewProjectionMatrix = viewProjectionMatrix;
        wall.viewMatrix = _viewMatrix;
        [wall update:deltaTime];
    }
    dog.viewProjectionMatrix = viewProjectionMatrix;
    dog.viewMatrix = _viewMatrix;
    [dog update:deltaTime];
    _crate.viewProjectionMatrix = viewProjectionMatrix;
    _crate.viewMatrix = _viewMatrix;
    [_crate update:deltaTime];
//    _obj2.viewProjectionMatrix = viewProjectionMatrix;
//    _obj2.viewMatrix = _viewMatrix;
//    [_obj2 update:deltaTime];
}

- (void)draw:(CGRect)drawRect {
    
    for (Wall* wall in _walls) {
        [wall draw];
    }
    [dog draw];
    [_crate draw];
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
    GLKVector3 cameraDirection = GLKVector3Make(0, 0, -1.0);
    cameraDirection = GLKMatrix4MultiplyVector3(_camera.modelMatrix, cameraDirection);
 
    GLKVector3 groundDirection = GLKVector3Normalize(GLKVector3Make(cameraDirection.x, cameraDirection.y, 0.0));
    
    posX = _camera.position.x + _moveSpeed * groundDirection.x;// sinf(_camera.rotation.x / 180 * M_PI);
    posY = _camera.position.y + _moveSpeed * groundDirection.y;//cosf(_camera.rotation.x / 180 * M_PI);
    _camera.position = GLKVector3Make(posX, posY, cameraHight);
}

- (void) lookAround:(CGPoint) translation isEnd:(Boolean)isEnd
{

    rotAngle_y = lastRotation_y - translation.x * 0.6; // 0.6 sensitivity
    rotAngle_x = lastRotation_x - translation.y; // never move
    // rotate two axis, implement in camera - todo

    while (rotAngle_x >= 360.0f)
        rotAngle_x -= 360.0f;
    while (rotAngle_y >= 360.0f)
        rotAngle_y -= 360.0f;
    while (rotAngle_x <= -360.0f)
        rotAngle_x += 360.0f;
    while (rotAngle_y <= -360.0f)
        rotAngle_y += 360.0f;
    
    _camera.rotation = GLKVector3Make(rotAngle_x, 0, rotAngle_y); // up down axis is Z
    
    // NSLog(@"%f/%f : %f/%f", translation.x, rotAngle_x, translation.y, rotAngle_y);
    
    if(isEnd){
        lastRotation_x = _camera.rotation.x;
        lastRotation_y = _camera.rotation.z;
    }
}

- (void) resetCamera
{
    [self initCameraLocation];
}


- (Dog * )getEnemy {
    return dog;
}

- (NSMutableArray<Wall *> *)getWalls {
    return _walls;
}

@end
