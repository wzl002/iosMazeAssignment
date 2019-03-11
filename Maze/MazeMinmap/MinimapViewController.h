//
//  MinimapViewController.h
//  Maze
//
//  Created by Zilong Wang on 2019/3/10.
//  Copyright © 2019 bcit. All rights reserved.
//

#ifndef MinimapViewController_h
#define MinimapViewController_h

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

#include "maze.hpp"

@interface MinimapViewController : UIViewController

@property Maze * mazeGenerate;

- (void) setCurrentPosition:(GLKVector3)location rotation:(GLKVector3)rotation;

@end

#endif /* MinimapViewController_h */
