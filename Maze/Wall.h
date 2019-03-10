//
//  Wall.h
//  Maze
//
//  Created by Zilong Wang on 2019/2/23.
//  Copyright © 2019 bcit. All rights reserved.
//

#ifndef Wall_h
#define Wall_h

#import "ZLModel.h"
#import "NGLShader.h"

@interface Wall : ZLModel

- (instancetype)initWithShader:(NGLShader *)shader view:(UIView *)view;

@end

#endif /* Wall_h */
