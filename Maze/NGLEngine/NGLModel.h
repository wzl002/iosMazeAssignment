//
//  NGLModel.h
//  Maze
//
//  Created by Zilong Wang on 2019/3/20.
//  Copyright © 2019年 bcit. All rights reserved.
//

#ifndef NGLModel_h
#define NGLModel_h

#import "NGLObject.h"
#import "NGLShader.h"
#import <GLKit/GLKit.h>

@interface NGLModel : NGLObject

- (id) initWithObjFiles:(NGLShader *)shader
                objFile: (NSString *)objFile
                mtlFile: (NSString *)mtlFile
       textureImageFile: (NSString *)textureImageFile;

@end

#endif /* NGLModel_h */
