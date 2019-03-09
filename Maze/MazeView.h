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
#import "NGLProgram.h"


@interface MazeView : NSObject

@property (nonatomic , assign) GLuint       shader;


- (void)setup:(GLKView *)view;

- (void)update:(double) deltaTime;

- (void)draw:(CGRect)drawRect;

@end

#endif /* MazeView_h */
