//
//  MazeRenderer.h
//  Maze
//
//  Created by Zilong Wang on 2019/2/6.
//  Copyright © 2019 bcit. All rights reserved.
//

#ifndef MazeRenderer_h
#define MazeRenderer_h

#import <GLKit/GLKit.h>

@interface MazeRenderer : NSObject

- (void)setup:(GLKView *)view;

- (void)setup;

- (void)update:(double) deltaTime;

- (void)draw:(CGRect)drawRect;

@end

#endif /* MazeRenderer_h */
