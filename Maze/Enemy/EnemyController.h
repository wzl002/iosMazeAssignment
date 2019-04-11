//
//  EnemyController.h
//  Maze
//
//  Created by Zilong Wang on 2019/4/10.
//  Copyright © 2019年 bcit. All rights reserved.
//

#ifndef EnemyController_h
#define EnemyController_h


#import <Foundation/Foundation.h>
#import "NGLModel.h"
#import <GLKit/GLKit.h>
#import "Wall.h"

@interface EnemyController : NSObject

- (instancetype) initWithEnemy: (NGLModel * ) enemy walls:(NSMutableArray<Wall *> *)walls;

- (void)update:(float)deltaTime;

// enable / disable auto rotationg - double tap
- (void)switchAutoMoving:(BOOL) moving;

// Rotate manually - pan
- (void)rotate:(CGPoint) translation isEnd:(Boolean)isEnd;

// Zoom - pinch
- (void)zoom:(CGFloat) pinchScale isEnd:(Boolean)isEnd;

// Move around - two finger pan
- (void)moveAround:(CGPoint) translation isEnd:(Boolean)isEnd;


@end

#endif /* EnemyController_h */
