//
//  MazeView.h
//  Maze
//
//  Created by Zilong Wang on 2019/3/7.
//  Copyright © 2019年 bcit. All rights reserved.
//

#ifndef MazeView_h
#define MazeView_h

#import <GLKit/GLKit.h>
#import <Foundation/Foundation.h>

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "Wall.h"

#include "maze.hpp"

@interface MazeView : NSObject

@property Maze *mazeGenerate;

@property NGLObject * camera;

- (void)setup:(GLKView *)view;

- (void)update:(double) deltaTime;

- (void)draw:(CGRect)drawRect;


#pragma mark interactions

- (void) switchDayNight;

- (void) switchFlashLight;

- (void) switchFog;

- (void) setFogIntensity:(float) value;

- (void) moveForward;

- (void) lookAround:(CGPoint) translation isEnd:(Boolean)isEnd;

- (void) resetCamera;

@end

#endif /* MazeView_h */
