//
//  GLModel.h
//  Maze
//
//  Created by Zilong Wang on 2019/2/23.
//  Copyright © 2019 bcit. All rights reserved.
//

#ifndef GLModel_h
#define GLModel_h

#import <GLKit/GLKit.h>

@interface ZLModel : NSObject

- (instancetype) initWithName: (char *)name vertices:(GLfloat *)vertices vertexCount:(unsigned int)vertexCount indices:(GLubyte *)indices indexCount:(unsigned int)indexCount shader:(GLuint)shader view:(UIView *)view;

- (void)update:(double) deltaTime;

- (void) draw;

@property (nonatomic, assign) GLKVector3 position;

@property (nonatomic, assign) GLKVector3 rotation; // degrees

@property (nonatomic, assign) GLKVector3 scale;

@property (nonatomic) NSString * textureImage;

@end

#endif /* GLModel_h */
